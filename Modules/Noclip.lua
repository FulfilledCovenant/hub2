-- Noclip.lua

--// Cache

local getgenv, UserInputService, RunService = getgenv, game:GetService("UserInputService"), game:GetService("RunService")

--// Launching checks

if not getgenv().Xryo or getgenv().Xryo.Noclip then return end

--// Variables

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character
local Humanoid
local HumanoidRootPart

local IsNoclipEnabled = false
local NoclipType = "Normal"
local Running = false
local TriggerKey = "N" -- Default to N

--// Environment

getgenv().Xryo.Noclip = {
	Settings = {
		Enabled = false,
		Toggle = false,
		TriggerKey = TriggerKey,
		NoclipType = NoclipType
	},
	Functions = {}
}

local Noclip = getgenv().Xryo.Noclip

--// Core Functions

local function UpdateCharacterRefs()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
end

local function SetNoclip(enabled, noclipType)
	if Character then
		local collisionGroupName = enabled and (noclipType == "Bypass" and "NoCollision" or "Default") or "Default"

		for _, part in pairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not enabled
				if noclipType == "Bypass" then
					if enabled then
						part:SetNetworkOwner(LocalPlayer) -- Attempt to take network ownership for bypassing
					end
					-- Check for existing collision group using GetCollisionGroupId instead of GetCanCollideWithPart
					if part.CollisionGroupId == 0 then -- 0 is the default collision group ID
						local success, collisionGroupId = pcall(function()
							return game:GetService("PhysicsService"):GetCollisionGroupId(collisionGroupName)
						end)
						if success and collisionGroupId then
							part.CollisionGroupId = collisionGroupId
						else
							warn("Failed to get or create collision group ID for:", collisionGroupName)
						end
					end
				end
			end
		end

		if Humanoid then
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not enabled)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, not enabled)
		end
	end
end

local function OnInputBegan(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if Noclip.Settings.TriggerKey and input.KeyCode == Enum.KeyCode[Noclip.Settings.TriggerKey] and not gameProcessedEvent then
            if Noclip.Settings.Toggle then
                Running = not Running
                IsNoclipEnabled = Running
                if IsNoclipEnabled then
                    if Noclip.Settings.NoclipType == "Normal" then
                        Noclip.Functions:EnableNormalNoclip()
                    elseif Noclip.Settings.NoclipType == "Bypass" then
                        Noclip.Functions:EnableBypassNoclip()
                    end
                else
                    Noclip.Functions:DisableNoclip()
                end
                print("Noclip Running:", Running)
            else
                IsNoclipEnabled = true
                if Noclip.Settings.NoclipType == "Normal" then
                    Noclip.Functions:EnableNormalNoclip()
                elseif Noclip.Settings.NoclipType == "Bypass" then
                    Noclip.Functions:EnableBypassNoclip()
                end
                print("Noclip Running:", IsNoclipEnabled)
            end
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
        if not Noclip.Settings.Toggle and IsNoclipEnabled then
            Noclip.Functions:DisableNoclip()
            IsNoclipEnabled = false
        end
    end
end

local function OnInputEnded(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if Noclip.Settings.TriggerKey and input.KeyCode == Enum.KeyCode[Noclip.Settings.TriggerKey] and not gameProcessedEvent then
			if not Noclip.Settings.Toggle then
				Noclip.Functions:DisableNoclip()
				IsNoclipEnabled = false
				print("Noclip Running:", IsNoclipEnabled)
			end
		end
	end
end

local function OnRenderStep()
	if IsNoclipEnabled and Noclip.Settings.NoclipType == "Bypass" then
		-- Continuously reapply bypass properties in case something tries to reset them
		SetNoclip(true, "Bypass")
	end
end

--// Connections

local InputBeganConnection
local InputEndedConnection
local RenderStepConnection
local CharacterAddedConnection

local function Load()
	UpdateCharacterRefs()

	InputBeganConnection = UserInputService.InputBegan:Connect(OnInputBegan)
	InputEndedConnection = UserInputService.InputEnded:Connect(OnInputEnded)
	RenderStepConnection = RunService.RenderStepped:Connect(OnRenderStep)

	CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
		Noclip.Functions:DisableNoclip()
		UpdateCharacterRefs()
	end)

	-- Create a new collision group for bypass noclip if it doesn't exist
	local collisionGroupName = "NoCollision"
	local collisionGroupExists = false

	-- Use GetCollisionGroupNames to check for existing collision group names
	local collisionGroupNames = game:GetService("PhysicsService"):GetCollisionGroupNames()
	for _, name in pairs(collisionGroupNames) do
		if name == collisionGroupName then
			collisionGroupExists = true
			break
		end
	end

	if not collisionGroupExists then
		local success, err = pcall(function()
			game:GetService("PhysicsService"):RegisterCollisionGroup(collisionGroupName)
		end)
		if not success then
			warn("Failed to register collision group:", collisionGroupName, "Error:", err)
		else
			-- Only set collidability if registration is successful
			game:GetService("PhysicsService"):CollisionGroupSetCollidable(collisionGroupName, "Default", false)
		end
	else
		-- Assume collision group is already set up correctly if it exists
	end
end

--// Functions

function Noclip.Functions:EnableNormalNoclip()
	SetNoclip(true, "Normal")
end

function Noclip.Functions:EnableBypassNoclip()
	SetNoclip(true, "Bypass")
end

function Noclip.Functions:DisableNoclip()
	SetNoclip(false, Noclip.Settings.NoclipType) -- Use the currently selected type when disabling
end

function Noclip.Functions:Exit()
	if InputBeganConnection then InputBeganConnection:Disconnect() end
	if InputEndedConnection then InputEndedConnection:Disconnect() end
	if RenderStepConnection then RenderStepConnection:Disconnect() end
	if CharacterAddedConnection then CharacterAddedConnection:Disconnect() end

	Noclip.Functions:DisableNoclip()

	getgenv().Xryo.Noclip.Functions = nil
	getgenv().Xryo.Noclip = nil
end

function Noclip.Functions:Restart()
	Noclip.Functions:Exit()
	Load()
end

function Noclip.Functions:Stop()
	Running = false
	IsNoclipEnabled = false
	Noclip.Functions:DisableNoclip()
end

function Noclip.Functions:ResetSettings()
	Noclip.Settings.Enabled = false
	Noclip.Settings.Toggle = false
	Noclip.Settings.TriggerKey = TriggerKey
	Noclip.Settings.NoclipType = NoclipType
	Noclip.Functions:Stop()
end

--// Load

Load()
