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

local function SetNoclip(enabled)
	if Character then
		for _, part in pairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				if enabled then
					part.CanCollide = false
					if NoclipType == "Bypass" then
						part:SetNetworkOwner(LocalPlayer) -- Set network owner to client
					end
				else
					part.CanCollide = true
					if NoclipType == "Bypass" then
						part:SetNetworkOwner(nil) -- Reset network owner
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
	-- No longer needed for bypass mode
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
end

--// Functions

function Noclip.Functions:EnableNormalNoclip()
	NoclipType = "Normal"
	SetNoclip(true)
end

function Noclip.Functions:EnableBypassNoclip()
	NoclipType = "Bypass"
	SetNoclip(true)
end

function Noclip.Functions:DisableNoclip()
	SetNoclip(false)
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
