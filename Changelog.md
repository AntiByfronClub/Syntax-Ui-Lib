# Changelog

## Unreleased

### Known bugs

- The library must run in a client context, such as a `LocalScript`, where `Players.LocalPlayer` is available.
- An invalid `SettingsWindowActivateKey` prevents the settings keyboard shortcut from being registered.
- Invalid `Color3`, `UDim2`, or Roblox asset ID values may cause UI elements to render incorrectly or fail to appear.
- Toggle, slider, and other callbacks run asynchronously through `task.spawn`; code that requires synchronous execution should use the control's `Get()` method or its own state management.
- Removing UI elements while the hub is running may cause later UI operations to fail.

## Version 1.1.0

- Added customizable hub branding with launch logo name, image, and accent color settings.
- Added draggable main hub and settings windows.
- Added settings window keyboard activation support.
- Added tab-based layout and scrollable content windows.
- Added toggle and slider controls with `Set`, `Get`, and callback support.
- Added loading sequence messages and popup notifications.
- Expanded the project documentation and configuration examples.

## Version 1.0.0

- Initial release of Syntax UI Lib.
- Added the dark green UI theme, hub creation flow, and core window controls.
