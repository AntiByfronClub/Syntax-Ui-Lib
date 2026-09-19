# Syntax UI Lib

A lightweight Roblox Luau library for making custom hubs with tabs, toggles, sliders, popups, loading messages, and an optional settings window.

## Project structure

- `src/` - the library source code
- `examples/` - example usage scripts
- root files - public compatibility shims and project metadata

## Installation

Require the module from your Roblox experience:

```lua
local SyntaxHub = require(path.to.src.Main)
```

## Quick start

```lua
local SyntaxHub = require(path.to.src.Main)

local hub = SyntaxHub.new({
    Credits = {
        UICreator = "YourName",
        FeaturesMadeBy = "YourName",
    },
})

local main = hub:CreateWindow("Main")

main:CreateButton("Enable feature", "Turn the feature on or off", function(enabled)
    print("Feature enabled:", enabled)
end)

main:CreateSlider("Walk speed", "Choose a value from 16 to 100", 16, 100, 1, 16, function(value)
    print("Walk speed:", value)
end)
```

The hub opens from the small button on the left side of the screen.

## Example script

See `examples/Example.luau` for a full usage example.
