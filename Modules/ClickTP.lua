-- ClickTP.lua

--// Cache

local getgenv, UserInputService, RunService = getgenv, game:GetService("UserInputService"), game:GetService("RunService")

--// Launching checks

if not getgenv().Xryo or getgenv().Xryo.ClickTP then return end

--// Variables

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character
local HumanoidRootPart
local Mouse
local Camera = workspace.CurrentCamera

local IsClickTPEnabled = false
local Running = false
local TriggerKey = "Q" -- Default to Q

--// Environment

getgenv().Xryo.ClickTP = {
	Settings = {
		Enabled = false,
		Toggle = false,
		TriggerKey = TriggerKey
	},
	Functions = {}
}

local ClickTP = getgenv().Xryo.ClickTP

--// Core Functions

-- ... (Other core functions: UpdateCharacterRefs, TeleportTo, OnMouseClick) ...

local function OnInputBegan(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if ClickTP.Settings.TriggerKey and input.KeyCode == Enum.KeyCode[ClickTP.Settings.TriggerKey] and not gameProcessedEvent then
            if ClickTP.Settings.Toggle then
				if ClickTP.Settings.Enabled then
                	Running = not Running
                	IsClickTPEnabled = Running
                	print("Click TP Running:", Running)
				end
            else
				if ClickTP.Settings.Enabled then
                	Running = true
					IsClickTPEnabled = true
                	print("Click TP Running:", Running)
                	OnMouseClick() -- Teleport only if Enabled and mouse is clicked
					Running = false
					IsClickTPEnabled = false
				end
            end
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
        if not ClickTP.Settings.Toggle and Running and ClickTP.Settings.Enabled then
            OnMouseClick()
			Running = false
			IsClickTPEnabled = false
        end
    end
end

--// Connections

local InputConnection
local RenderStepConnection
local CharacterAddedConnection

local function Load()
    UpdateCharacterRefs()

    InputConnection = UserInputService.InputBegan:Connect(OnInputBegan)
    RenderStepConnection = RunService.RenderStepped:Connect(OnRenderStep)

    CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        UpdateCharacterRefs()
    end)
end

--// Functions

-- ... (Other functions: Exit, Restart) ...

function ClickTP.Functions:Stop()
	Running = false
	IsClickTPEnabled = false
end

function ClickTP.Functions:ResetSettings()
	ClickTP.Settings.Enabled = false
	ClickTP.Settings.Toggle = false
	ClickTP.Settings.TriggerKey = TriggerKey
	ClickTP.Functions:Stop()
end

--// Load

Load()
