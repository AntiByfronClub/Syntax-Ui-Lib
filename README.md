# Syntax UI Lib


<img width="800" height="600" alt="image (6)" src="https://github.com/user-attachments/assets/5beb5c14-059e-43b9-bbcf-cd40f515a282" />



A lightweight Roblox Luau library for making custom hubs with tabs, toggles, sliders, popups, loading messages, and an optional settings window.

It is built for quick UI setup and easy customization without making the code harder to work with.

## Features

- Dark UI with green accents and smooth open and close animations
- Custom hub name, icon, colors, size, position, and background
- Draggable hub and settings windows
- Tabs and scrollable content areas
- Toggle buttons and sliders with callbacks, `Set`, and `Get`
- Loading messages and popup notifications
- Optional keyboard shortcut for the settings window

## Installation


Require the module from your Roblox experience:

```lua
local SyntaxHub = require(path.to.Main)
```

## Quick start

```lua
local SyntaxHub = require(path.to.Main)

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

## Configuration

All values are optional. The `Credits` table is used only for displayed attribution text.

```lua
local hub = SyntaxHub.new({
    Credits = {
        UICreator = "YourName",
        FeaturesMadeBy = "YourName",
    },

    CustomizeOpenLogo = {
        Name = "My Hub",
        Image = "rbxassetid://1234567890",
        R = 0,
        G = 170,
        B = 127,
    },

    CustomizeMainHubFrame = {
        Size = UDim2.fromOffset(480, 400),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor = Color3.fromRGB(8, 14, 12),
        BackgroundTransparency = 0,
    },

    MakeDraggable = true,
    SettingsWindowSelectable = true,
    SettingsWindowActivateKey = "RightShift",
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Credits.UICreator` | string | `"N/A"` | Name displayed as the UI creator. |
| `Credits.FeaturesMadeBy` | string | `"N/A"` | Name shown in the hub credit line. |
| `CustomizeOpenLogo.Name` | string | `"Syntax Hub"` | Name shown on the launcher and title bar. |
| `CustomizeOpenLogo.Image` | string | built-in asset | Image asset used by the launcher and title bar. |
| `CustomizeOpenLogo.R/G/B` | number | `0, 170, 127` | Accent color values. |
| `CustomizeMainHubFrame.Size` | `UDim2` | `UDim2.fromOffset(480, 400)` | Hub and settings-window size. |
| `CustomizeMainHubFrame.Position` | `UDim2` | `UDim2.fromScale(0.5, 0.5)` | Hub and settings-window position. |
| `CustomizeMainHubFrame.BackgroundColor` | `Color3` | dark green | Hub and settings background color. |
| `CustomizeMainHubFrame.BackgroundTransparency` | number | `0` | Background transparency. |
| `MakeDraggable` | boolean | `true` | Allows dragging from the title bars. |
| `SettingsWindowSelectable` | boolean | `false` | Enables the keyboard settings shortcut. |
| `SettingsWindowActivateKey` | string | none | KeyCode name used for the settings shortcut. |

## API

## `SyntaxHub.new(config)`

Creates a hub. The optional `Credits` table controls the attribution text shown in the UI.

## `hub:CreateWindow(title)`

Creates a tab and returns its window object. The first window is selected automatically.

```lua
local combat = hub:CreateWindow("Combat")
local visuals = hub:CreateWindow("Visuals")
```

## `window:CreateButton(title, description, callback)`

Creates a toggle and returns a control with `Set(state)` and `Get()` methods. The initial state is `false`.

```lua
local enabled = combat:CreateButton("Aimbot", "Enable the combat feature", function(state)
    print(state and "Enabled" or "Disabled")
end)

enabled:Set(true)
print(enabled:Get())
```

## `window:CreateSlider(title, description, min, max, step, default, callback)`

Creates a slider. Values are clamped to the range and rounded to the selected step. It returns a control with `Set(value)` and `Get()` methods.

```lua
local volume = visuals:CreateSlider("Volume", "Adjust the interface volume", 0, 100, 5, 50, function(value)
    print("Volume:", value)
end)

volume:Set(75)
print(volume:Get())
```

Defaults are `min = 0`, `max = 100`, and `step = 1`.

## `hub:CreateLoadingMessage(text, sub, duration, color)`

Adds a message to the first-open loading sequence. Add messages before opening the hub.

```lua
hub:CreateLoadingMessage("Starting", "Preparing the interface", 0.8)
hub:CreateLoadingMessage("Almost ready", "Loading features", 0.8, Color3.fromRGB(120, 255, 190))
```

## `hub:CustomizeLoadingMessage(index, props)`

Updates a loading message by its one-based index. Supported properties are `text`, `sub`, `duration`, and `color`.

```lua
hub:CustomizeLoadingMessage(1, {
    text = "Boot complete",
    sub = "Welcome back",
    duration = 1,
    color = Color3.fromRGB(180, 255, 220),
})
```

## `hub:CreatePopup(title, body)`

Shows a toast notification in the lower-right corner.

```lua
hub:CreatePopup("Saved", "Your settings were saved.")
```

## Notes

- Run the library from a `LocalScript` or another client context where `Players.LocalPlayer` is available.
- The `ScreenGui` is created inside the local player's `PlayerGui`.
- `SettingsWindowSelectable` and a valid `SettingsWindowActivateKey` are required for the settings shortcut.
- Callbacks run asynchronously with `task.spawn`.
- `Color3`, `UDim2`, and Roblox asset IDs must be valid.
- The library does not enforce a creator or ownership requirement.

## Using and redistributing this project

This project is licensed under the Apache License 2.0.

If you redistribute this library or modified versions, keep the LICENSE file and retain the required copyright and license notices in the source, documentation, and distributed copies. Mark modified files clearly and state that changes were made.

You may modify and redistribute the project in accordance with the Apache License 2.0.

## License

This project is licensed under the [Apache License 2.0](LICENSE).

See the [LICENSE](LICENSE) file for the full legal text.
