-- Fly.lua

--// Cache

local getgenv, UserInputService, RunService = getgenv, game:GetService("UserInputService"), game:GetService("RunService")

--// Launching checks

if not getgenv().Xryo or getgenv().Xryo.Fly then return end

--// Variables

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character
local Humanoid
local HumanoidRootPart
local Camera = workspace.CurrentCamera

local IsFlyEnabled = false
local Running = false
local TriggerKey = "F" -- Default to F
local FlySpeed = 50

--// Environment

getgenv().Xryo.Fly = {
	Settings = {
		Enabled = false,
		TriggerKey = TriggerKey,
		FlySpeed = FlySpeed
	},
	Functions = {}
}

local Fly = getgenv().Xryo.Fly

--// Core Functions

local function UpdateCharacterRefs()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
end

local function OnInputBegan(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode then -- Check if KeyCode exists
		if Fly.Settings.TriggerKey and input.KeyCode == Enum.KeyCode[Fly.Settings.TriggerKey] and not gameProcessedEvent then
			Running = not Running
			IsFlyEnabled = Running
			if IsFlyEnabled then
				Fly.Functions:Fly()
			else
				Fly.Functions:Stop()
			end
			print("Fly Running:", Running)
		end
	end
end

--// Connections

local InputBeganConnection
local RenderStepConnection
local CharacterAddedConnection

local function Load()
	UpdateCharacterRefs()

	InputBeganConnection = UserInputService.InputBegan:Connect(OnInputBegan)

	CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
		Fly.Functions:Stop()
		UpdateCharacterRefs()
	end)
end

--// Functions

function Fly.Functions:Fly()
    if Fly.Settings.Enabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlyBodyVelocity"
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = hrp

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "FlyBodyGyro"
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 3000
            bodyGyro.Parent = hrp

            RenderStepConnection = RunService.RenderStepped:Connect(function()
                if Fly.Settings.Enabled then
                    local direction = Vector3.new(0, 0, 0)
                    if IsFlyEnabled then
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            direction = direction + (Camera.CFrame.LookVector * Fly.Settings.FlySpeed)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            direction = direction - (Camera.CFrame.LookVector * Fly.Settings.FlySpeed)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            direction = direction - (Camera.CFrame.RightVector * Fly.Settings.FlySpeed)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            direction = direction + (Camera.CFrame.RightVector * Fly.Settings.FlySpeed)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            direction = direction + (Camera.CFrame.UpVector * Fly.Settings.FlySpeed)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            direction = direction - (Camera.CFrame.UpVector * Fly.Settings.FlySpeed)
                        end
                    end
                    bodyVelocity.Velocity = direction
                    bodyGyro.CFrame = Camera.CFrame
                else
                    local bv = hrp:FindFirstChild("FlyBodyVelocity")
                    if bv then bv:Destroy() end
                    local bg = hrp:FindFirstChild("FlyBodyGyro")
                    if bg then bg:Destroy() end
                end
            end)
        end
    end
end

function Fly.Functions:Stop()
	Running = false
	IsFlyEnabled = false
	if RenderStepConnection then RenderStepConnection:Disconnect(), RenderStepConnection = nil end
	local Character = LocalPlayer.Character
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		local hrp = Character.HumanoidRootPart
		local bv = hrp:FindFirstChild("FlyBodyVelocity")
		if bv then bv:Destroy() end
		local bg = hrp:FindFirstChild("FlyBodyGyro")
		if bg then bg:Destroy() end
	end
end

function Fly.Functions:Exit()
	if InputBeganConnection then InputBeganConnection:Disconnect() end
	if RenderStepConnection then RenderStepConnection:Disconnect() end
	if CharacterAddedConnection then CharacterAddedConnection:Disconnect() end

	Fly.Functions:Stop()

	getgenv().Xryo.Fly.Functions = nil
	getgenv().Xryo.Fly = nil
end

function Fly.Functions:Restart()
	Fly.Functions:Exit()
	Load()
end

function Fly.Functions:ResetSettings()
	Fly.Settings.Enabled = false
	Fly.Settings.TriggerKey = TriggerKey
	Fly.Settings.FlySpeed = FlySpeed
	Fly.Functions:Stop()
end

--// Load

Load()
