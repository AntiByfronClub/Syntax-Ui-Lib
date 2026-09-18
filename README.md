# Syntax UI Lib

A lightweight Roblox **Luau** UI library for creating a customizable, Forsaken-inspired hub with animated tabs, toggle buttons, sliders, loading messages, popups, and an optional settings window.

> **Status:** Early development. The public API may change as the library is expanded.

## Features

- Dark, green-accented UI with tweened opening and closing animations
- Custom hub name, icon, accent color, size, position, and background
- Draggable hub and settings windows
- Tab/window support
- Toggle buttons with callbacks and `Set`/`Get` controls
- Sliders with min/max values, step snapping, callbacks, and `Set`/`Get` controls
- Custom loading sequences shown the first time the hub is opened
- Toast-style popup notifications
- Optional keyboard settings-window toggle
- Scrolling content areas for larger interfaces

## Installation

Require the module from wherever you store it in your Roblox experience:

```lua
local SyntaxHub = require(path.to.Main)
```

If you are loading the file from a remote source, use the loader supported by your environment and make sure the returned value is the module table.

## Quick start

`Credits.UICreator` is required and must be exactly `"AntiByfron"`.

```lua
local SyntaxHub = require(path.to.Main)

local hub = SyntaxHub.new({
    Credits = {
        UICreator = "AntiByfron",
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

hub:CreatePopup("Ready", "The hub has loaded.")
```

The hub is opened and closed using the small button on the left side of the screen.

## Configuration

All configuration values are optional except `Credits.UICreator`.

```lua
local hub = SyntaxHub.new({
    Credits = {
        UICreator = "AntiByfron", -- required; exact spelling and capitalization
        FeaturesMadeBy = "YourName", -- optional; defaults to "N/A"
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

### Configuration reference

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Credits.UICreator` | string | required | Must be exactly `AntiByfron`. The library displays this credit and validates it when creating or using UI elements. |
| `Credits.FeaturesMadeBy` | string | `"N/A"` | Name displayed in the hub credit line. |
| `CustomizeOpenLogo.Name` | string | `"Syntax Hub"` | Hub name shown on the launcher, title bar, and settings title. |
| `CustomizeOpenLogo.Image` | string | built-in asset | Roblox image asset ID used by the launcher and title bar. |
| `CustomizeOpenLogo.R/G/B` | number | `0, 170, 127` | RGB values for the accent color. |
| `CustomizeMainHubFrame.Size` | `UDim2` | `UDim2.fromOffset(480, 400)` | Hub and settings-window size. |
| `CustomizeMainHubFrame.Position` | `UDim2` | `UDim2.fromScale(0.5, 0.5)` | Hub and settings-window position. |
| `CustomizeMainHubFrame.BackgroundColor` | `Color3` | dark green | Hub and settings background color. |
| `CustomizeMainHubFrame.BackgroundTransparency` | number | `0` | Hub and settings background transparency. |
| `MakeDraggable` | boolean | `true` | Allows dragging from the title bars. |
| `SettingsWindowSelectable` | boolean | `false` | Enables the keyboard-controlled settings window. |
| `SettingsWindowActivateKey` | string | none | A valid `Enum.KeyCode` name, such as `"RightShift"`, used with `SettingsWindowSelectable`. |

## API

### `SyntaxHub.new(config)`

Creates and returns a hub object.

```lua
local hub = SyntaxHub.new(config)
```

If `Credits.UICreator` is missing or is not exactly `"AntiByfron"`, construction stops with an error.

### `hub:CreateWindow(title)`

Creates a tab and returns a window object. The first created window is selected automatically.

```lua
local combat = hub:CreateWindow("Combat")
local visuals = hub:CreateWindow("Visuals")
```

### `window:CreateButton(title, description, callback)`

Creates a toggle row. The callback receives the new boolean state whenever the user clicks the row or the returned control is set.

```lua
local enabled = combat:CreateButton(
    "Aimbot",
    "Enable the combat feature",
    function(state)
        print(state and "Enabled" or "Disabled")
    end
)

enabled:Set(true)
print(enabled:Get())
```

Returns a control with:

- `control:Set(state)` — sets the toggle state and invokes the callback.
- `control:Get()` — returns the current boolean state.

The initial state is `false`.

### `window:CreateSlider(title, description, min, max, step, default, callback)`

Creates a slider. Values are clamped to the supplied range and rounded to the supplied step.

```lua
local volume = visuals:CreateSlider(
    "Volume",
    "Adjust the interface volume",
    0,
    100,
    5,
    50,
    function(value)
        print("Volume:", value)
    end
)

volume:Set(75)
print(volume:Get())
```

Returns a control with:

- `control:Set(value)` — clamps/snaps the value and invokes the callback.
- `control:Get()` — returns the current numeric value.

Defaults are `min = 0`, `max = 100`, and `step = 1`. The default value is clamped to the range.

### `hub:CreateLoadingMessage(text, sub, duration, color)`

Adds a message to the loading sequence. The sequence is displayed the first time the launcher opens the hub, in the order messages were added.

- `text` — main message text; defaults to `"Loading..."`.
- `sub` — secondary text; defaults to an empty string.
- `duration` — display time in seconds; defaults to `0.85`.
- `color` — main message `Color3`; defaults to a light green/white color.

```lua
hub:CreateLoadingMessage("Starting", "Preparing the interface", 0.8)
hub:CreateLoadingMessage("Almost ready", "Loading features", 0.8, Color3.fromRGB(120, 255, 190))
```

Add loading messages before the first open so they are included in the initial sequence.

### `hub:CustomizeLoadingMessage(index, props)`

Edits an existing loading message by its one-based index. Unknown indexes are ignored.

```lua
hub:CustomizeLoadingMessage(1, {
    text = "Boot complete",
    sub = "Welcome back",
    duration = 1,
    color = Color3.fromRGB(180, 255, 220),
})
```

Supported properties are `text`, `sub`, `duration`, and `color`.

### `hub:CreatePopup(title, body)`

Creates a toast-style popup notification in the lower-right corner of the screen.

```lua
hub:CreatePopup("Saved", "Your settings were saved.")
```

### `hub:CheckCredits()`

Validates that the required credit watermark and credit bar still exist. It is normally called internally by the library. It raises an error if either required credit element cannot be found.

## Important notes

- This library is client-side UI code and expects to run in a `LocalScript` or another client context where `Players.LocalPlayer` is available.
- The module creates its `ScreenGui` inside the local player's `PlayerGui`.
- `SettingsWindowSelectable` must be enabled and `SettingsWindowActivateKey` must be a valid key name for the settings shortcut to work.
- Callbacks are run asynchronously with `task.spawn`.
- The library uses Roblox `Color3`, `UDim2`, and asset ID strings, so those values must be valid for the experience.
- Do not remove the generated credit watermark or credit bar; the library checks for them before creating and interacting with UI components.

## License

Go to LICENSE.MD
