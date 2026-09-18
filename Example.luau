-- Example script for Syntax UI Lib.
-- This example is written for an executor environment but Syntax itself
-- is just a UI library and works in any LocalScript.
local SyntaxHub = require(script.Parent.Main)

local hub = SyntaxHub.new({
    Credits = {
        UICreator = "YourName",
        FeaturesMadeBy = "YourName",
    },
    CustomizeOpenLogo = {
        Name = "My Hub",
        R = 0,
        G = 170,
        B = 127,
    },
    CustomizeMainHubFrame = {
        Size = UDim2.fromOffset(500, 420),
        Position = UDim2.fromScale(0.5, 0.5),
    },
    MakeDraggable = true,
    SettingsWindowSelectable = true,
    SettingsWindowActivateKey = "RightShift",
})

-- These show up when the hub opens for the first time.
hub:CreateLoadingMessage("Loading UI", "Getting things ready", 0.7)
hub:CreateLoadingMessage("Almost ready", "Opening tabs", 0.8)

local combat = hub:CreateWindow("Combat")
local visuals = hub:CreateWindow("Visuals")

-- Simple toggle button example.
local aimAssist = combat:CreateButton("Aim assist", "Toggle the feature", function(enabled)
    print("Aim assist:", enabled)
end)

-- Slider with a min, max, step, and starting value.
local fov = combat:CreateSlider("FOV", "Adjust field of view", 60, 120, 1, 90, function(value)
    print("FOV:", value)
end)

local bloom = visuals:CreateButton("Bloom", "Apply a soft glow effect", function(enabled)
    print("Bloom:", enabled)
end)

local volume = visuals:CreateSlider("Volume", "Set menu volume", 0, 100, 5, 55, function(value)
    print("Volume:", value)
end)

-- Set values after creating them.
aimAssist:Set(true)
bloom:Set(false)
fov:Set(100)
volume:Set(70)

-- Small popup message in the corner.
hub:CreatePopup("Loaded", "Syntax UI is ready.")
