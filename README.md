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

Require the library from your Roblox experience. The root `Main` module remains available as a compatibility wrapper:

```lua
local SyntaxHub = require(path.to.Main)
```

The source module can also be required directly:

```lua
local SyntaxHub = require(path.to.src.Main)
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

### `SyntaxHub.new(config)`

Creates a hub. The optional `Credits` table controls the attribution text shown in the UI.

### `hub:CreateWindow(title)`

Creates a tab and returns its window object. The first window is selected automatically.

### `window:CreateButton(title, description, callback)`

Creates a toggle and returns a control with `Set(state)` and `Get()` methods. The initial state is `false`. Calling `Set` invokes the callback.

### `window:CreateSlider(title, description, min, max, step, default, callback)`

Creates a slider. Values are clamped to the range and rounded to the selected step. It returns a control with `Set(value)` and `Get()` methods. Defaults are `min = 0`, `max = 100`, and `step = 1`.

### `hub:CreateLoadingMessage(text, sub, duration, color)`

Adds a message to the first-open loading sequence. Add messages before opening the hub.

### `hub:CustomizeLoadingMessage(index, props)`

Updates a loading message by its one-based index. Supported properties are `text`, `sub`, `duration`, and `color`.

### `hub:CreatePopup(title, body)`

Shows a toast notification in the lower-right corner.

### `hub:SettingsDeclared(theme)`

Accepts a theme table containing `AccentColor`. This method is retained for compatibility, but currently only updates the stored accent color and does not fully recolor existing UI elements.

## Notes

- Run the library from a `LocalScript` or another client context where `Players.LocalPlayer` is available.
- The `ScreenGui` is created inside the local player's `PlayerGui`.
- `SettingsWindowSelectable` and a valid `SettingsWindowActivateKey` are required for the settings shortcut.
- Callbacks run asynchronously with `task.spawn`.
- `Color3`, `UDim2`, and Roblox asset IDs must be valid.
- The library does not enforce a creator or ownership requirement.

## License

This project is licensed under the [Apache License 2.0](LICENSE).
