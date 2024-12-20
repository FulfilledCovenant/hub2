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
local AllowTeleportInVoid = false -- Setting to allow teleporting even if Mouse.Target is nil

--// Environment

getgenv().Xryo.ClickTeleport = {
    Settings = {
        Enabled = false,
        TeleportKeybind = TeleportKeybind,
        AllowTeleportInVoid = false,
    },
    Functions = {}
}

local ClickTeleport = getgenv().Xryo.ClickTeleport

--// Core Functions

local function Teleport(MouseHit)
    if not LocalPlayer or not LocalPlayer.Character then return end

    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if HumanoidRootPart then
        -- Use the provided teleport method (directly setting CFrame)
        HumanoidRootPart.CFrame = MouseHit
    end
end

local function OnUpdate()
    if not Enabled then return end

    if UserInputService:IsKeyDown(Enum.KeyCode[ClickTeleport.Settings.TeleportKeybind]) then
        local MouseHit = Mouse.Hit
        if Mouse.Target or ClickTeleport.Settings.AllowTeleportInVoid then
            Teleport(MouseHit)
        end
    end
end

--// Connections

local UpdateConnection

local function Load()
    ClickTeleport.Functions:ResetSettings()
    UpdateConnection = RunService.Stepped:Connect(OnUpdate)
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
    ClickTeleport.Settings.AllowTeleportInVoid = false
end

--// Load

Load()
