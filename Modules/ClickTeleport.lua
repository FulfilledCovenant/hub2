-- ClickTeleport.lua

--// Cache

local getgenv, UserInputService, RunService = getgenv, game:GetService("UserInputService"), game:GetService("RunService")

--// Launching checks

if not getgenv().Xryo or getgenv().Xryo.ClickTeleport then return end

--// Variables

local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Enabled = false
local TeleportKeybind = "LeftControl" -- Default keybind

--// Environment

getgenv().Xryo.ClickTeleport = {
    Settings = {
        Enabled = false,
        TeleportKeybind = TeleportKeybind,
    },
    Functions = {}
}

local ClickTeleport = getgenv().Xryo.ClickTeleport

--// Core Functions

local function Teleport(Position)
    print("Teleport called with Position:", Position)
    if not LocalPlayer or not LocalPlayer.Character then return end

    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if HumanoidRootPart then
        print("HumanoidRootPart found:", HumanoidRootPart)
        -- Method 1: CFrame with Offset (Less likely to be detected)
        local Offset = Vector3.new(0, 3, 0) -- Teleport slightly above the target position
        print("Teleporting to CFrame:", CFrame.new(Position + Offset))
        HumanoidRootPart.CFrame = CFrame.new(Position + Offset)

        -- Method 2: CFraming Body Parts Individually (More complex, potentially less detectable)
        -- for _, Part in pairs(Character:GetChildren()) do
        --     if Part:IsA("BasePart") and Part ~= HumanoidRootPart then
        --         Part.CFrame = CFrame.new(Position + Offset + (Part.Position - HumanoidRootPart.Position))
        --     end
        -- end
    else
        print("HumanoidRootPart not found!")
    end
end

local function OnUpdate()
    if not Enabled then return end

    print("Click Teleport Enabled:", ClickTeleport.Settings.Enabled)
    print("Teleport Keybind:", ClickTeleport.Settings.TeleportKeybind)

    if UserInputService:IsKeyDown(Enum.KeyCode[ClickTeleport.Settings.TeleportKeybind]) then
        print("Teleport key pressed")
        if Mouse.Target and Mouse.Target ~= workspace.Terrain then
            local MouseHit = Mouse.Hit
            local pos = MouseHit.p
            print("Mouse Target:", Mouse.Target)
            print("Mouse Hit:", MouseHit)
            print("Teleporting to:", pos)
            Teleport(pos)
        end
    end
end

--// Connections

local UpdateConnection

local function Load()
    UpdateConnection = RunService.Stepped:Connect(OnUpdate)
    print("UpdateConnection:", UpdateConnection)
end

--// Functions

function ClickTeleport.Functions:Exit()
    if UpdateConnection then UpdateConnection:Disconnect() end

    getgenv().Xryo.ClickTeleport.Functions = nil
    getgenv().Xryo.ClickTeleport = nil
end

function ClickTeleport.Functions:Restart()
    ClickTeleport.Functions:Exit()
    Load()
end

function ClickTeleport.Functions:ResetSettings()
    ClickTeleport.Settings.Enabled = false
    ClickTeleport.Settings.TeleportKeybind = TeleportKeybind
end

--// Load

Load()
