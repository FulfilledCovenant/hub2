-- CFrameFly.lua

--// Cache

local getgenv, UserInputService, RunService = getgenv, game:GetService("UserInputService"), game:GetService("RunService")

--// Launching checks

if not getgenv().Xryo or getgenv().Xryo.CFrameFly then return end

--// Variables

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character
local Humanoid
local HumanoidRootPart

local IsFlying = false
local FlySpeed = 0.5
local FlyKeybind = "Q" -- Default to Q
local UpKeybind = "E"   -- Default to E
local DownKeybind = "Space" -- Default to Space

--// Environment

getgenv().Xryo.CFrameFly = {
	Settings = {
		Enabled = false,
		Speed = FlySpeed,
		FlyKeybind = FlyKeybind,
		UpKeybind = UpKeybind,
		DownKeybind = DownKeybind,
	},
	Functions = {}
}

local CFrameFly = getgenv().Xryo.CFrameFly

--// Core Functions

local function UpdateCharacterRefs()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
end

local function StartFlying()
    if not Character or not Humanoid or not HumanoidRootPart then return end

    IsFlying = true
    -- Disable default flight controls if any
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    end

    -- Anchor the HumanoidRootPart to prevent falling
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = true
    end
end

local function StopFlying()
    IsFlying = false
    -- Re-enable default flight controls
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
    end

    -- Unanchor HumanoidRootPart
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = false
    end
end

local function HandleInput(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- Use the stored keybind values from Settings
        if CFrameFly.Settings.FlyKeybind and input.KeyCode == Enum.KeyCode[CFrameFly.Settings.FlyKeybind] and not gameProcessedEvent then
            if CFrameFly.Settings.Enabled then
                if IsFlying then
                    StopFlying()
                else
                    StartFlying()
                end
            end
        end
    end
end

local function OnRenderStep()
    if not IsFlying or not Character or not HumanoidRootPart then return end

    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new(0, 0, 0)

    -- Use the stored keybind values from Settings
    if UserInputService:IsKeyDown(Enum.KeyCode[CFrameFly.Settings.UpKeybind]) then
        moveVector = moveVector + camera.CFrame.UpVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode[CFrameFly.Settings.DownKeybind]) then
        moveVector = moveVector - camera.CFrame.UpVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + camera.CFrame.RightVector
    end

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * CFrameFly.Settings.Speed
    end

    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + moveVector
end

--// Connections

local InputConnection
local RenderStepConnection
local CharacterAddedConnection

local function Load()
    CFrameFly.Functions:ResetSettings()
    UpdateCharacterRefs()

    InputConnection = UserInputService.InputBegan:Connect(HandleInput)
    RenderStepConnection = RunService.RenderStepped:Connect(OnRenderStep)

    CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        StopFlying()
        UpdateCharacterRefs()
    end)
end

--// Functions

function CFrameFly.Functions:Exit()
	if InputConnection then InputConnection:Disconnect() end
	if RenderStepConnection then RenderStepConnection:Disconnect() end
	if CharacterAddedConnection then CharacterAddedConnection:Disconnect() end

	StopFlying()

	getgenv().Xryo.CFrameFly.Functions = nil
	getgenv().Xryo.CFrameFly = nil
end

function CFrameFly.Functions:Restart()
	CFrameFly.Functions:Exit()
	Load()
end

function CFrameFly.Functions:ResetSettings()
	CFrameFly.Settings.Enabled = false
	CFrameFly.Settings.Speed = FlySpeed
	CFrameFly.Settings.FlyKeybind = FlyKeybind
	CFrameFly.Settings.UpKeybind = UpKeybind
	CFrameFly.Settings.DownKeybind = DownKeybind
	StopFlying()
end

--// Load

Load()
