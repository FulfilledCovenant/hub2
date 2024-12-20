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
    print("Updating Character References")
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        print("Character:", Character, "Humanoid:", Humanoid, "HumanoidRootPart:", HumanoidRootPart)
    else
        print("Character not found")
    end
end

local function StartFlying()
    print("StartFlying called")
    if not Character or not Humanoid or not HumanoidRootPart then 
        print("Character, Humanoid, or HumanoidRootPart not found")
        return 
    end

    IsFlying = true
    print("IsFlying set to:", IsFlying)
    -- Disable default flight controls if any
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    end

    -- Anchor the HumanoidRootPart to prevent falling
    if HumanoidRootPart then
        print("HumanoidRootPart.Anchored before:", HumanoidRootPart.Anchored)
        HumanoidRootPart.Anchored = true
        print("HumanoidRootPart.Anchored after:", HumanoidRootPart.Anchored)
    end
end

local function StopFlying()
    print("StopFlying called")
    IsFlying = false
    print("IsFlying set to:", IsFlying)
    -- Re-enable default flight controls
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
    end

    -- Unanchor HumanoidRootPart
    if HumanoidRootPart then
        print("HumanoidRootPart.Anchored before:", HumanoidRootPart.Anchored)
        HumanoidRootPart.Anchored = false
        print("HumanoidRootPart.Anchored after:", HumanoidRootPart.Anchored)
    end
end

local function HandleInput(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- Check if CFrameFly.Settings.FlyKeybind is valid before using it
        if CFrameFly.Settings.FlyKeybind and input.KeyCode == Enum.KeyCode[CFrameFly.Settings.FlyKeybind] and not gameProcessedEvent then
            print("Fly keybind pressed. Enabled:", CFrameFly.Settings.Enabled)
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
    print("OnRenderStep running")
    print("IsFlying:", IsFlying, "Character:", Character, "Humanoid:", Humanoid, "HumanoidRootPart:", HumanoidRootPart)
    if not IsFlying or not Character or not HumanoidRootPart then return end

    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new(0, 0, 0)

    print("CFrameFly.Settings.UpKeybind:", CFrameFly.Settings.UpKeybind)
    if UserInputService:IsKeyDown(Enum.KeyCode[CFrameFly.Settings.UpKeybind]) then
        print("Up key pressed")
        moveVector = moveVector + camera.CFrame.UpVector
    end

    print("CFrameFly.Settings.DownKeybind:", CFrameFly.Settings.DownKeybind)
    if UserInputService:IsKeyDown(Enum.KeyCode[CFrameFly.Settings.DownKeybind]) then
        print("Down key pressed")
        moveVector = moveVector - camera.CFrame.UpVector
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        print("W key pressed")
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        print("S key pressed")
        moveVector = moveVector - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        print("A key pressed")
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        print("D key pressed")
        moveVector = moveVector + camera.CFrame.RightVector
    end

    -- Check if moveVector is a zero vector before normalizing
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * CFrameFly.Settings.Speed
    else
        -- Optionally, set moveVector to a small value in a desired direction if it's zero
        print("moveVector is zero")
        -- moveVector = camera.CFrame.LookVector * 0.01 -- Example: move slightly forward
    end

    print("moveVector:", moveVector)
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + moveVector
end

--// Connections

local InputConnection
local RenderStepConnection
local CharacterAddedConnection

local function Load()
    CFrameFly.Functions:ResetSettings() -- Initialize settings
    UpdateCharacterRefs()

    print("CFrameFly.Settings.FlyKeybind:", CFrameFly.Settings.FlyKeybind)
    print("CFrameFly.Settings.UpKeybind:", CFrameFly.Settings.UpKeybind)
    print("CFrameFly.Settings.DownKeybind:", CFrameFly.Settings.DownKeybind)

    InputConnection = UserInputService.InputBegan:Connect(HandleInput)
    RenderStepConnection = RunService.RenderStepped:Connect(OnRenderStep)
    print("RenderStepConnection:", RenderStepConnection) -- Check the connection

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
