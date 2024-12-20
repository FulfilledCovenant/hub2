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

--// Environment

getgenv().Xryo.ClickTP = {
	Settings = {
		Enabled = false
	},
	Functions = {}
}

local ClickTP = getgenv().Xryo.ClickTP

--// Core Functions

local function UpdateCharacterRefs()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		Mouse = LocalPlayer:GetMouse()
    end
end

local function TeleportTo(position)
    if Character and HumanoidRootPart then
        -- Teleport the character
        HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function OnMouseClick()
    if IsClickTPEnabled and Mouse then
        local target = Mouse.Target
        if target then
            local position = Mouse.Hit.Position
            TeleportTo(position)
        end
    end
end

local function OnRenderStep()
	-- Not used in this module currently
end

--// Connections

local InputConnection
local RenderStepConnection
local CharacterAddedConnection

local function Load()
    UpdateCharacterRefs()

    InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
			if ClickTP.Settings.Enabled then
				IsClickTPEnabled = true
				OnMouseClick()
				IsClickTPEnabled = false
			end
		end
	end)
    RenderStepConnection = RunService.RenderStepped:Connect(OnRenderStep)

    CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        UpdateCharacterRefs()
    end)
end

--// Functions

function ClickTP.Functions:Exit()
	if InputConnection then InputConnection:Disconnect() end
	if RenderStepConnection then RenderStepConnection:Disconnect() end
	if CharacterAddedConnection then CharacterAddedConnection:Disconnect() end

	getgenv().Xryo.ClickTP.Functions = nil
	getgenv().Xryo.ClickTP = nil
end

function ClickTP.Functions:Restart()
	ClickTP.Functions:Exit()
	Load()
end

function ClickTP.Functions:Stop()
	IsClickTPEnabled = false
end

function ClickTP.Functions:ResetSettings()
	ClickTP.Settings.Enabled = false
	Stop()
end

--// Load

Load()
