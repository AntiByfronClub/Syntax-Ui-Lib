
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local HttpService     = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local THEMES = {
    Monochrome = {
        Background    = Color3.fromRGB(14, 14, 14),
        Surface       = Color3.fromRGB(20, 20, 20),
        SurfaceHover  = Color3.fromRGB(28, 28, 28),
        SurfaceActive = Color3.fromRGB(34, 34, 34),
        Border        = Color3.fromRGB(50, 50, 50),
        BorderHover   = Color3.fromRGB(80, 80, 80),
        Accent        = Color3.fromRGB(240, 240, 240),
        AccentDim     = Color3.fromRGB(160, 160, 160),
        TextPrimary   = Color3.fromRGB(235, 235, 235),
        TextSecondary = Color3.fromRGB(155, 155, 155),
        TextMuted     = Color3.fromRGB(100, 100, 100),
        Toggle        = Color3.fromRGB(50, 50, 50),
        ToggleOn      = Color3.fromRGB(230, 230, 230),
        SliderFill    = Color3.fromRGB(220, 220, 220),
        SliderTrack   = Color3.fromRGB(40, 40, 40),
        TabActive     = Color3.fromRGB(235, 235, 235),
        TabInactive   = Color3.fromRGB(90, 90, 90),
        NotifySuccess = Color3.fromRGB(80, 200, 100),
        NotifyWarning = Color3.fromRGB(230, 170, 50),
        NotifyError   = Color3.fromRGB(220, 60, 60),
        NotifyInfo    = Color3.fromRGB(100, 170, 240),
    },
}

local FONT_MEDIUM = Enum.Font.GothamMedium
local FONT_REG    = Enum.Font.Gotham
local FONT_BOLD   = Enum.Font.GothamBold

local CORNER_SM  = UDim.new(0, 6)
local CORNER_MD  = UDim.new(0, 8)
local CORNER_LG  = UDim.new(0, 10)
local CORNER_XL  = UDim.new(0, 14)

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(r, parent)
    return Create("UICorner", { CornerRadius = r }, parent)
end

local function Stroke(color, thickness, parent)
    return Create("UIStroke", {
        Color     = color,
        Thickness = thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode    = Enum.LineJoinMode.Round,
    }, parent)
end

local function Padding(t, b, l, r, parent)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, t),
        PaddingBottom = UDim.new(0, b),
        PaddingLeft   = UDim.new(0, l),
        PaddingRight  = UDim.new(0, r),
    }, parent)
end

local function ListLayout(dir, align, spacing, parent)
    return Create("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, spacing or 0),
    }, parent)
end

local function Tween(inst, info, props)
    TweenService:Create(inst, info, props):Play()
end

local function GetParentGui()
    if gethui then return gethui() end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return pg or game:GetService("CoreGui")
end

local function IsKeyCode(str)
    
    if str == "MouseButton1" or str == "MouseLeft" then
        return Enum.UserInputType.MouseButton1
    end
    if str == "MouseButton2" or str == "MouseRight" then
        return Enum.UserInputType.MouseButton2
    end
    local ok, kc = pcall(function() return Enum.KeyCode[str] end)
    return (ok and kc) or nil
end

local function KeyCodeToString(kc)
    if typeof(kc) == "EnumItem" then
        if kc.EnumType == Enum.UserInputType then
            if kc == Enum.UserInputType.MouseButton1 then return "MouseButton1" end
            if kc == Enum.UserInputType.MouseButton2 then return "MouseButton2" end
        end
        return kc.Name
    end
    return tostring(kc)
end

local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging  = true
        dragStart = input.Position
        startPos  = target.Position
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        target.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

local Signal = {}
Signal.__index = Signal
function Signal.new()
    return setmetatable({ _cbs = {} }, Signal)
end
function Signal:Connect(fn)
    table.insert(self._cbs, fn)
    return { Disconnect = function() for i, v in ipairs(self._cbs) do if v == fn then table.remove(self._cbs, i) return end end end }
end
function Signal:Fire(...)
    for _, fn in ipairs(self._cbs) do pcall(fn, ...) end
end

local LynxUI   = {}
LynxUI.__index = LynxUI

function LynxUI:CreateWindow(opts)
    opts = opts or {}
    local theme = THEMES[opts.Theme or "Monochrome"]
    local W = {}  

    
    local gui = Create("ScreenGui", {
        Name            = "LynxUI",
        ResetOnSpawn    = false,
        IgnoreGuiInset  = true,
        DisplayOrder    = 999,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    }, GetParentGui())

    
    local backdrop = Create("Frame", {
        Name                = "Backdrop",
        Size                = UDim2.fromScale(1, 1),
        BackgroundColor3    = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel     = 0,
        ZIndex              = 1,
    }, gui)

    
    local initSize = opts.Size or UDim2.fromOffset(720, 480)
    local winFrame = Create("Frame", {
        Name                = "Window",
        Size                = initSize,
        AnchorPoint         = Vector2.new(0.5, 0.5),
        Position            = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3    = theme.Background,
        BorderSizePixel     = 0,
        ClipsDescendants    = false,
        ZIndex              = 2,
    }, gui)
    Corner(CORNER_XL, winFrame)
    Stroke(theme.Border, 1, winFrame)

    
    local titleBar = Create("Frame", {
        Name                = "TitleBar",
        Size                = UDim2.new(1, 0, 0, 44),
        BackgroundColor3    = theme.Surface,
        BorderSizePixel     = 0,
        ZIndex              = 3,
    }, winFrame)
    Corner(CORNER_XL, titleBar)
    
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, CORNER_XL.Offset),
        Position         = UDim2.new(0, 0, 1, -CORNER_XL.Offset),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, titleBar)

    local titleLabel = Create("TextLabel", {
        Text            = opts.Title or "lynx.cc",
        Font            = FONT_MEDIUM,
        TextSize        = 15,
        TextColor3      = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size            = UDim2.new(1, -100, 1, 0),
        Position        = UDim2.fromOffset(16, 0),
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 4,
        AutoLocalize    = false,
    }, titleBar)

    local brandLabel = Create("TextLabel", {
        Text            = "lynx.cc",
        Font            = FONT_MEDIUM,
        TextSize        = 13,
        TextColor3      = theme.TextMuted,
        BackgroundTransparency = 1,
        Size            = UDim2.new(0, 80, 1, 0),
        Position        = UDim2.new(1, -88, 0, 0),
        TextXAlignment  = Enum.TextXAlignment.Right,
        ZIndex          = 4,
        AutoLocalize    = false,
    }, titleBar)

    
    local closeBtn = Create("TextButton", {
        Text            = "✕",
        Font            = FONT_REG,
        TextSize        = 13,
        TextColor3      = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size            = UDim2.fromOffset(32, 32),
        Position        = UDim2.new(1, -38, 0.5, -16),
        ZIndex          = 5,
        AutoLocalize    = false,
    }, titleBar)

    MakeDraggable(titleBar, winFrame)

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, TWEEN_FAST, { TextColor3 = theme.TextPrimary })
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, TWEEN_FAST, { TextColor3 = theme.TextSecondary })
    end)
    closeBtn.Activated:Connect(function()
        winFrame.Visible = false
        backdrop.Visible = false
    end)

    
    local iconSize = opts.IconSize or 36
    local sidebarW = iconSize + 20

    local sidebar = Create("Frame", {
        Name                = "Sidebar",
        Size                = UDim2.new(0, sidebarW, 1, -44),
        Position            = UDim2.fromOffset(0, 44),
        BackgroundColor3    = theme.Surface,
        BorderSizePixel     = 0,
        ZIndex              = 3,
    }, winFrame)
    
    Create("Frame", {
        Size             = UDim2.new(0, CORNER_XL.Offset, 1, 0),
        Position         = UDim2.new(1, -CORNER_XL.Offset, 0, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, sidebar)
    Corner(CORNER_XL, sidebar)
    
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, CORNER_XL.Offset),
        Position         = UDim2.new(0, 0, 1, -CORNER_XL.Offset),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, sidebar)

    local tabList = Create("ScrollingFrame", {
        Name                      = "TabList",
        Size                      = UDim2.new(1, 0, 1, -8),
        Position                  = UDim2.fromOffset(0, 4),
        BackgroundTransparency    = 1,
        BorderSizePixel           = 0,
        ScrollBarThickness        = 0,
        CanvasSize                = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize       = Enum.AutomaticSize.Y,
        ZIndex                    = 4,
    }, sidebar)
    local tabListLayout = ListLayout(nil, Enum.HorizontalAlignment.Center, 4, tabList)
    Padding(6, 6, 0, 0, tabList)

    
    local contentArea = Create("Frame", {
        Name                = "Content",
        Size                = UDim2.new(1, -sidebarW, 1, -44),
        Position            = UDim2.new(0, sidebarW, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ZIndex              = 3,
        ClipsDescendants    = true,
    }, winFrame)

    
    local notifContainer = Create("Frame", {
        Name                = "Notifications",
        Size                = UDim2.new(0, 300, 1, 0),
        Position            = UDim2.new(1, -310, 0, 0),
        BackgroundTransparency = 1,
        ZIndex              = 100,
        AnchorPoint         = Vector2.new(0, 1),
    }, gui)
    Create("Frame", {   
        Name = "NotifAnchor",
        Size = UDim2.fromOffset(300, 1),
        Position = UDim2.new(1, -310, 1, -10),
        BackgroundTransparency = 1,
        ZIndex = 1,
    })
    
    local notifHolder = Create("Frame", {
        Name                = "NotifHolder",
        Size                = UDim2.new(0, 300, 0, 400),
        AnchorPoint         = Vector2.new(1, 1),
        Position            = UDim2.new(1, -10, 1, -10),
        BackgroundTransparency = 1,
        ZIndex              = 100,
    }, gui)
    local notifLayout = ListLayout(
        Enum.FillDirection.Vertical,
        Enum.HorizontalAlignment.Right,
        6,
        notifHolder
    )
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    
    if opts.Acrylic then
        local blur = Create("BlurEffect", {
            Size   = opts.GlassIntensity or 24,
        }, game:GetService("Lighting"))
        
        W._blur = blur
    end

    
    
    
    W._gui        = gui
    W._winFrame   = winFrame
    W._theme      = theme
    W._tabs       = {}
    W._activeTab  = nil
    W._iconSize   = iconSize
    W._tabList    = tabList
    W._content    = contentArea
    W._notifHolder= notifHolder
    W.Visible     = true
    W.Window      = winFrame   

    
    if opts.ToggleKey then
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == opts.ToggleKey then
                W.Visible = not W.Visible
                winFrame.Visible  = W.Visible
                backdrop.Visible  = W.Visible
            end
        end)
        W._toggleConn = conn
    end

    
    function W:SetTheme(name)
        
        self._theme = THEMES[name] or THEMES.Monochrome
    end

    
    function W:Notify(opts2)
        opts2 = opts2 or {}
        local t = self._theme
        local duration = opts2.Duration or 4
        local ntype    = opts2.Type or "Info"

        local accentColor =
            ntype == "Success" and t.NotifySuccess or
            ntype == "Warning" and t.NotifyWarning or
            ntype == "Error"   and t.NotifyError   or
            t.NotifyInfo

        local card = Create("Frame", {
            Name                = "Notification",
            Size                = UDim2.new(1, 0, 0, 64),
            BackgroundColor3    = t.Surface,
            BorderSizePixel     = 0,
            BackgroundTransparency = 1,
            ZIndex              = 101,
            AutomaticSize       = Enum.AutomaticSize.Y,
        }, self._notifHolder)
        Corner(CORNER_MD, card)
        Stroke(t.Border, 1, card)

        
        Create("Frame", {
            Size             = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = accentColor,
            BorderSizePixel  = 0,
            ZIndex           = 102,
        }, card)
        Corner(CORNER_SM, card)   

        local inner = Create("Frame", {
            Size                = UDim2.new(1, -10, 1, 0),
            Position            = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            ZIndex              = 102,
        }, card)
        Padding(10, 10, 6, 6, inner)
        ListLayout(nil, nil, 2, inner)

        if opts2.Title then
            Create("TextLabel", {
                Text            = opts2.Title,
                Font            = FONT_MEDIUM,
                TextSize        = 13,
                TextColor3      = t.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, 0, 0, 16),
                TextXAlignment  = Enum.TextXAlignment.Left,
                AutoLocalize    = false,
                ZIndex          = 103,
            }, inner)
        end

        if opts2.Content then
            Create("TextLabel", {
                Text            = opts2.Content,
                Font            = FONT_REG,
                TextSize        = 12,
                TextColor3      = t.TextSecondary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, 0, 0, 14),
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
                AutoLocalize    = false,
                ZIndex          = 103,
            }, inner)
        end

        
        local progBg = Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = t.SliderTrack,
            BorderSizePixel  = 0,
            ZIndex           = 103,
        }, card)
        Create("Frame", {
            Name             = "Fill",
            Size             = UDim2.fromScale(1, 1),
            BackgroundColor3 = accentColor,
            BorderSizePixel  = 0,
            ZIndex           = 104,
        }, progBg)

        
        card.BackgroundTransparency = 1
        Tween(card, TWEEN_MED, { BackgroundTransparency = 0 })

        
        task.spawn(function()
            local fill = progBg:FindFirstChild("Fill")
            local elapsed = 0
            local conn = RunService.Heartbeat:Connect(function(dt)
                elapsed += dt
                if fill then
                    fill.Size = UDim2.fromScale(math.max(0, 1 - elapsed / duration), 1)
                end
            end)
            task.wait(duration)
            conn:Disconnect()
            Tween(card, TWEEN_MED, { BackgroundTransparency = 1 })
            task.wait(0.25)
            card:Destroy()
        end)
    end

    
    function W:AddTab(opts2)
        opts2 = opts2 or {}
        local t    = self._theme
        local iSz  = self._iconSize

        local tabBtn = Create("TextButton", {
            Name                = opts2.Title or "Tab",
            Text                = "",
            Size                = UDim2.fromOffset(iSz, iSz),
            BackgroundColor3    = t.SurfaceHover,
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            ZIndex              = 5,
            AutoButtonColor     = false,
        }, self._tabList)
        Corner(CORNER_MD, tabBtn)

        
        local iconLabel = Create("TextLabel", {
            Text            = string.sub(opts2.Title or "?", 1, 1):upper(),
            Font            = FONT_BOLD,
            TextSize        = math.floor(iSz * 0.42),
            TextColor3      = t.TabInactive,
            BackgroundTransparency = 1,
            Size            = UDim2.fromScale(1, 1),
            ZIndex          = 6,
            AutoLocalize    = false,
        }, tabBtn)

        
        local tooltip = Create("TextLabel", {
            Text            = opts2.Title or "",
            Font            = FONT_REG,
            TextSize        = 11,
            TextColor3      = t.TextPrimary,
            BackgroundColor3= t.Surface,
            Size            = UDim2.fromOffset(0, 20),
            AutomaticSize   = Enum.AutomaticSize.X,
            Position        = UDim2.new(1, 6, 0.5, -10),
            ZIndex          = 20,
            Visible         = false,
            AutoLocalize    = false,
        }, tabBtn)
        Padding(0, 0, 6, 6, tooltip)
        Corner(CORNER_SM, tooltip)
        Stroke(t.Border, 1, tooltip)

        tabBtn.MouseEnter:Connect(function()
            tooltip.Visible = true
            Tween(tabBtn, TWEEN_FAST, { BackgroundTransparency = 0.7 })
        end)
        tabBtn.MouseLeave:Connect(function()
            tooltip.Visible = false
            if self._activeTab ~= tabPage then
                Tween(tabBtn, TWEEN_FAST, { BackgroundTransparency = 1 })
            end
        end)

        
        local tabPage = Create("ScrollingFrame", {
            Name                   = (opts2.Title or "Tab").."Page",
            Size                   = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = t.Border,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = false,
            ZIndex                 = 4,
        }, self._content)
        Padding(10, 10, 12, 12, tabPage)
        ListLayout(nil, nil, 8, tabPage)

        tabBtn.Activated:Connect(function()
            self:_SelectTab(tabPage, tabBtn, iconLabel)
        end)

        local tabObj = {
            _page     = tabPage,
            _btn      = tabBtn,
            _icon     = iconLabel,
            _window   = self,
            _sections = {},
        }

        table.insert(self._tabs, tabObj)

        
        if #self._tabs == 1 then
            self:_SelectTab(tabPage, tabBtn, iconLabel)
        end

        
        function tabObj:AddSection(title)
            local t2  = self._window._theme
            local sec = Create("Frame", {
                Name                = title or "Section",
                Size                = UDim2.new(1, 0, 0, 0),
                AutomaticSize       = Enum.AutomaticSize.Y,
                BackgroundColor3    = t2.Surface,
                BorderSizePixel     = 0,
                ZIndex              = 5,
            }, self._page)
            Corner(CORNER_MD, sec)
            Stroke(t2.Border, 1, sec)
            Padding(8, 8, 10, 10, sec)

            local secLayout = ListLayout(nil, nil, 4, sec)

            
            local header = Create("TextLabel", {
                Text            = (title or ""):upper(),
                Font            = FONT_MEDIUM,
                TextSize        = 10,
                TextColor3      = t2.TextMuted,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, 0, 0, 14),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 6,
                AutoLocalize    = false,
            }, sec)

            local divider = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = t2.Border,
                BorderSizePixel  = 0,
                ZIndex           = 6,
            }, sec)

            local secObj = {
                _frame  = sec,
                _window = self._window,
                _theme  = t2,
            }

            

            local function RowFrame(h)
                return Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, h or 32),
                    BackgroundTransparency = 1,
                    ZIndex          = 6,
                }, sec)
            end

            
            function secObj:AddToggle(key, cfg)
                cfg = cfg or {}
                local row = RowFrame(cfg.Description and 44 or 32)
                local th  = self._theme

                Create("TextLabel", {
                    Text            = cfg.Title or key,
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(1, -50, 0, 16),
                    Position        = UDim2.fromOffset(0, cfg.Description and 4 or 8),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, row)

                if cfg.Description then
                    Create("TextLabel", {
                        Text            = cfg.Description,
                        Font            = FONT_REG,
                        TextSize        = 11,
                        TextColor3      = th.TextMuted,
                        BackgroundTransparency = 1,
                        Size            = UDim2.new(1, -50, 0, 14),
                        Position        = UDim2.fromOffset(0, 22),
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        TextWrapped     = true,
                        ZIndex          = 7,
                        AutoLocalize    = false,
                    }, row)
                end

                
                local pill = Create("Frame", {
                    Size             = UDim2.fromOffset(36, 20),
                    Position         = UDim2.new(1, -36, 0.5, -10),
                    BackgroundColor3 = cfg.Default and th.ToggleOn or th.Toggle,
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                }, row)
                Corner(UDim.new(1, 0), pill)

                local knob = Create("Frame", {
                    Size             = UDim2.fromOffset(14, 14),
                    Position         = cfg.Default and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
                    BackgroundColor3 = cfg.Default and th.Background or th.TextMuted,
                    BorderSizePixel  = 0,
                    ZIndex           = 8,
                }, pill)
                Corner(UDim.new(1, 0), knob)

                
                local hit = Create("TextButton", {
                    Text                = "",
                    Size                = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    ZIndex              = 9,
                    AutoButtonColor     = false,
                }, row)

                local value   = cfg.Default == true
                local changed = Signal.new()

                local function Set(v)
                    value = v == true
                    Tween(pill,  TWEEN_FAST, { BackgroundColor3 = value and th.ToggleOn or th.Toggle })
                    Tween(knob,  TWEEN_FAST, {
                        Position         = value and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
                        BackgroundColor3 = value and th.Background or th.TextMuted,
                    })
                    changed:Fire(value)
                    if cfg.Callback then pcall(cfg.Callback, value) end
                end

                hit.Activated:Connect(function() Set(not value) end)

                local obj = { Value = value }
                function obj:SetValue(v) value = not not v; Set(value) end
                function obj:OnChanged(fn) return changed:Connect(fn) end
                return obj
            end

            
            function secObj:AddSlider(key, cfg)
                cfg = cfg or {}
                local row = RowFrame(50)
                local th  = self._theme

                local minV    = cfg.Min or 0
                local maxV    = cfg.Max or 100
                local round   = cfg.Rounding
                local suffix  = cfg.Suffix or ""
                local value   = math.clamp(cfg.Default or minV, minV, maxV)

                local function Fmt(v)
                    if round and round > 0 then
                        return string.format("%."..round.."f", v)..suffix
                    end
                    return math.floor(v + 0.5)..suffix
                end

                local titleRow = Create("Frame", {
                    Size                = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    ZIndex              = 7,
                }, row)

                Create("TextLabel", {
                    Text            = cfg.Title or key,
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, titleRow)

                local valLabel = Create("TextLabel", {
                    Text            = Fmt(value),
                    Font            = FONT_REG,
                    TextSize        = 12,
                    TextColor3      = th.AccentDim,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(0.4, 0, 1, 0),
                    Position        = UDim2.fromScale(0.6, 0),
                    TextXAlignment  = Enum.TextXAlignment.Right,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, titleRow)

                
                local track = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.fromOffset(0, 24),
                    BackgroundColor3 = th.SliderTrack,
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                }, row)
                Corner(UDim.new(1, 0), track)

                local fill = Create("Frame", {
                    Size             = UDim2.fromScale((value - minV) / (maxV - minV), 1),
                    BackgroundColor3 = th.SliderFill,
                    BorderSizePixel  = 0,
                    ZIndex           = 8,
                }, track)
                Corner(UDim.new(1, 0), fill)

                
                local knob = Create("Frame", {
                    Size             = UDim2.fromOffset(12, 12),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new((value - minV) / (maxV - minV), 0, 0.5, 0),
                    BackgroundColor3 = th.TextPrimary,
                    BorderSizePixel  = 0,
                    ZIndex           = 9,
                }, track)
                Corner(UDim.new(1, 0), knob)

                local changed = Signal.new()
                local dragging = false

                local function SetFromAlpha(alpha)
                    alpha = math.clamp(alpha, 0, 1)
                    local raw = minV + (maxV - minV) * alpha
                    if round then
                        local factor = 10 ^ round
                        raw = math.floor(raw * factor + 0.5) / factor
                    else
                        raw = math.floor(raw + 0.5)
                    end
                    value = math.clamp(raw, minV, maxV)
                    local a2 = (value - minV) / (maxV - minV)
                    fill.Size     = UDim2.fromScale(a2, 1)
                    knob.Position = UDim2.new(a2, 0, 0.5, 0)
                    valLabel.Text = Fmt(value)
                    changed:Fire(value)
                    if cfg.Callback then pcall(cfg.Callback, value) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                    dragging = true
                    local abs = track.AbsolutePosition
                    local sz  = track.AbsoluteSize
                    SetFromAlpha((input.Position.X - abs.X) / sz.X)
                end)

                local moveConn = UserInputService.InputChanged:Connect(function(input)
                    if not dragging then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                    local abs = track.AbsolutePosition
                    local sz  = track.AbsoluteSize
                    SetFromAlpha((input.Position.X - abs.X) / sz.X)
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local obj = { Value = value }
                function obj:SetValue(v)
                    value = math.clamp(v, minV, maxV)
                    SetFromAlpha((value - minV) / (maxV - minV))
                end
                function obj:OnChanged(fn) return changed:Connect(fn) end
                return obj
            end

            
            function secObj:AddDropdown(key, cfg)
                cfg = cfg or {}
                local th     = self._theme
                local values = cfg.Values or {}
                local value  = cfg.Default or values[1]
                local open   = false
                local changed = Signal.new()

                local container = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 0),
                    AutomaticSize   = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ZIndex          = 7,
                }, sec)

                local row = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ZIndex          = 7,
                }, container)

                Create("TextLabel", {
                    Text            = cfg.Title or key,
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(0.5, 0, 1, 0),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, row)

                local pill = Create("TextButton", {
                    Text            = value or "",
                    Font            = FONT_REG,
                    TextSize        = 12,
                    TextColor3      = th.TextPrimary,
                    BackgroundColor3= th.SurfaceActive,
                    Size            = UDim2.new(0.48, 0, 0, 24),
                    Position        = UDim2.new(0.52, 0, 0.5, -12),
                    BorderSizePixel = 0,
                    ZIndex          = 8,
                    AutoButtonColor = false,
                    AutoLocalize    = false,
                }, row)
                Corner(CORNER_SM, pill)
                Stroke(th.Border, 1, pill)

                
                local list = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 0),
                    AutomaticSize   = Enum.AutomaticSize.Y,
                    BackgroundColor3= th.SurfaceActive,
                    BorderSizePixel = 0,
                    Visible         = false,
                    ZIndex          = 10,
                }, container)
                Corner(CORNER_SM, list)
                Stroke(th.Border, 1, list)
                Padding(4, 4, 4, 4, list)
                ListLayout(nil, nil, 2, list)

                local function Select(v)
                    value     = v
                    pill.Text = v
                    open      = false
                    list.Visible = false
                    changed:Fire(v)
                    if cfg.Callback then pcall(cfg.Callback, v) end
                end

                for _, v in ipairs(values) do
                    local item = Create("TextButton", {
                        Text            = v,
                        Font            = FONT_REG,
                        TextSize        = 12,
                        TextColor3      = th.TextSecondary,
                        BackgroundColor3= th.Surface,
                        BackgroundTransparency = 1,
                        Size            = UDim2.new(1, 0, 0, 24),
                        BorderSizePixel = 0,
                        ZIndex          = 11,
                        AutoButtonColor = false,
                        AutoLocalize    = false,
                    }, list)
                    Corner(CORNER_SM, item)
                    item.MouseEnter:Connect(function()
                        Tween(item, TWEEN_FAST, { BackgroundTransparency = 0, TextColor3 = th.TextPrimary })
                    end)
                    item.MouseLeave:Connect(function()
                        Tween(item, TWEEN_FAST, { BackgroundTransparency = 1, TextColor3 = th.TextSecondary })
                    end)
                    item.Activated:Connect(function() Select(v) end)
                end

                pill.Activated:Connect(function()
                    open = not open
                    list.Visible = open
                end)

                local obj = { Value = value }
                function obj:SetValue(v) Select(v) end
                function obj:OnChanged(fn) return changed:Connect(fn) end
                return obj
            end

            
            function secObj:AddColorpicker(key, cfg)
                cfg = cfg or {}
                local th     = self._theme
                local value  = cfg.Default or Color3.new(1, 1, 1)
                local open   = false
                local changed = Signal.new()
                local rainbowEnabled = false
                local rainbowConn    = nil

                local container = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 0),
                    AutomaticSize   = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ZIndex          = 7,
                }, sec)

                local row = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ZIndex          = 7,
                }, container)

                Create("TextLabel", {
                    Text            = cfg.Title or key,
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(1, -48, 1, 0),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, row)

                
                local swatch = Create("TextButton", {
                    Text            = "",
                    Size            = UDim2.fromOffset(36, 20),
                    Position        = UDim2.new(1, -36, 0.5, -10),
                    BackgroundColor3= value,
                    BorderSizePixel = 0,
                    ZIndex          = 8,
                    AutoButtonColor = false,
                }, row)
                Corner(CORNER_SM, swatch)
                Stroke(th.Border, 1, swatch)

                
                local panel = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 160),
                    BackgroundColor3= th.SurfaceActive,
                    BorderSizePixel = 0,
                    Visible         = false,
                    ZIndex          = 10,
                }, container)
                Corner(CORNER_SM, panel)
                Stroke(th.Border, 1, panel)
                Padding(8, 8, 8, 8, panel)

                
                local canvas = Create("ImageLabel", {
                    Size            = UDim2.new(1, 0, 0, 100),
                    BackgroundColor3= Color3.new(1, 0, 0),
                    BorderSizePixel = 0,
                    Image           = "rbxassetid://6020299385",
                    ZIndex          = 11,
                }, panel)
                Corner(CORNER_SM, canvas)

                
                local hueBar = Create("ImageLabel", {
                    Size            = UDim2.new(1, 0, 0, 14),
                    Position        = UDim2.fromOffset(0, 108),
                    Image           = "rbxassetid://6020331641",
                    BorderSizePixel = 0,
                    ZIndex          = 11,
                }, panel)
                Corner(CORNER_SM, hueBar)

                
                local h, s, v2 = value:ToHSV()

                local cursor = Create("Frame", {
                    Size             = UDim2.fromOffset(10, 10),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(s, 0, 1 - v2, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                    ZIndex           = 12,
                }, canvas)
                Corner(UDim.new(1, 0), cursor)
                Stroke(Color3.new(0,0,0), 1, cursor)

                local hCursor = Create("Frame", {
                    Size             = UDim2.fromOffset(4, 14),
                    AnchorPoint      = Vector2.new(0.5, 0),
                    Position         = UDim2.new(h, 0, 0, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                    ZIndex           = 12,
                }, hueBar)

                
                local rbBtn = Create("TextButton", {
                    Text            = "Rainbow",
                    Font            = FONT_REG,
                    TextSize        = 11,
                    TextColor3      = th.TextMuted,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(0.5, 0, 0, 14),
                    Position        = UDim2.new(0, 0, 1, -18),
                    ZIndex          = 11,
                    AutoButtonColor = false,
                    AutoLocalize    = false,
                }, panel)

                local function Apply()
                    value = Color3.fromHSV(h, s, v2)
                    swatch.BackgroundColor3 = value
                    canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    cursor.Position = UDim2.new(s, 0, 1 - v2, 0)
                    hCursor.Position = UDim2.new(h, 0, 0, 0)
                    changed:Fire(value)
                    if cfg.Callback then pcall(cfg.Callback, value) end
                end

                local function PickSV(input)
                    local abs = canvas.AbsolutePosition
                    local sz  = canvas.AbsoluteSize
                    s  = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
                    v2 = 1 - math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
                    Apply()
                end

                local function PickH(input)
                    local abs = hueBar.AbsolutePosition
                    local sz  = hueBar.AbsoluteSize
                    h = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
                    Apply()
                end

                local dragSV, dragH = false, false

                canvas.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = true; PickSV(inp) end
                end)
                hueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragH = true; PickH(inp) end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    if dragSV then PickSV(inp) end
                    if dragH  then PickH(inp) end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragSV = false; dragH = false
                    end
                end)

                rbBtn.Activated:Connect(function()
                    rainbowEnabled = not rainbowEnabled
                    rbBtn.TextColor3 = rainbowEnabled and th.TextPrimary or th.TextMuted
                    if rainbowEnabled then
                        local t0 = tick()
                        rainbowConn = RunService.Heartbeat:Connect(function()
                            h = (tick() - t0) * 0.3 % 1
                            Apply()
                        end)
                    else
                        if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
                    end
                end)

                swatch.Activated:Connect(function()
                    open = not open
                    panel.Visible = open
                end)

                local obj = { Value = value }
                function obj:SetValue(c)
                    h, s, v2 = c:ToHSV()
                    Apply()
                end
                function obj:OnChanged(fn) return changed:Connect(fn) end
                return obj
            end

            
            function secObj:AddKeybind(key, cfg)
                cfg = cfg or {}
                local th    = self._theme
                local mode  = cfg.Mode or "Toggle"  
                local value = (mode == "Toggle") and false or false
                local bound = IsKeyCode(cfg.Default or "None")
                local listening  = false
                local changed    = Signal.new()

                local row = RowFrame(32)

                Create("TextLabel", {
                    Text            = cfg.Title or key,
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, row)

                local bindBtn = Create("TextButton", {
                    Text            = cfg.Default or "None",
                    Font            = FONT_REG,
                    TextSize        = 12,
                    TextColor3      = th.AccentDim,
                    BackgroundColor3= th.SurfaceActive,
                    Size            = UDim2.new(0.38, 0, 0, 22),
                    Position        = UDim2.new(0.62, 0, 0.5, -11),
                    BorderSizePixel = 0,
                    ZIndex          = 8,
                    AutoButtonColor = false,
                    AutoLocalize    = false,
                }, row)
                Corner(CORNER_SM, bindBtn)
                Stroke(th.Border, 1, bindBtn)

                bindBtn.Activated:Connect(function()
                    if listening then return end
                    listening      = true
                    bindBtn.Text   = "..."
                    bindBtn.TextColor3 = th.TextPrimary
                end)

                local inputConn
                inputConn = UserInputService.InputBegan:Connect(function(input, processed)
                    if not listening then
                        
                        if bound then
                            local match = false
                            if typeof(bound) == "EnumItem" then
                                if bound.EnumType == Enum.KeyCode then
                                    match = input.KeyCode == bound
                                elseif bound.EnumType == Enum.UserInputType then
                                    match = input.UserInputType == bound
                                end
                            end
                            if match then
                                if mode == "Toggle" then
                                    value = not value
                                    changed:Fire(value)
                                    if cfg.Callback then pcall(cfg.Callback, value) end
                                elseif mode == "Hold" then
                                    value = true
                                    changed:Fire(true)
                                    if cfg.Callback then pcall(cfg.Callback, true) end
                                end
                            end
                        end
                        return
                    end
                    
                    if not cfg.AllowProcessedInput and processed then return end
                    if input.KeyCode == Enum.KeyCode.Escape then
                        bound          = nil
                        bindBtn.Text   = "None"
                        bindBtn.TextColor3 = th.TextMuted
                    else
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            bound          = input.KeyCode
                            bindBtn.Text   = input.KeyCode.Name
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            bound          = Enum.UserInputType.MouseButton1
                            bindBtn.Text   = "MouseButton1"
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            bound          = Enum.UserInputType.MouseButton2
                            bindBtn.Text   = "MouseButton2"
                        end
                        bindBtn.TextColor3 = th.AccentDim
                    end
                    listening = false
                end)

                if mode == "Hold" then
                    UserInputService.InputEnded:Connect(function(input)
                        if not bound then return end
                        local match = false
                        if typeof(bound) == "EnumItem" then
                            if bound.EnumType == Enum.KeyCode then match = input.KeyCode == bound
                            elseif bound.EnumType == Enum.UserInputType then match = input.UserInputType == bound end
                        end
                        if match and value then
                            value = false
                            changed:Fire(false)
                            if cfg.Callback then pcall(cfg.Callback, false) end
                        end
                    end)
                end

                local obj = { Value = value, Active = value }
                function obj:SetValue(v) value = not not v; obj.Active = value; changed:Fire(value) end
                function obj:SetVisible(v) row.Visible = v end
                function obj:OnChanged(fn) return changed:Connect(fn) end
                return obj
            end

            
            function secObj:AddButton(cfg)
                cfg = cfg or {}
                local th  = self._theme
                local h   = cfg.Description and 44 or 32

                local row = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, h),
                    BackgroundTransparency = 1,
                    ZIndex          = 7,
                }, sec)

                local btn = Create("TextButton", {
                    Text            = cfg.ButtonText or cfg.Title or "Button",
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundColor3= th.SurfaceHover,
                    BackgroundTransparency = 0.5,
                    Size            = UDim2.new(1, 0, 0, h),
                    BorderSizePixel = 0,
                    ZIndex          = 8,
                    AutoButtonColor = false,
                    AutoLocalize    = false,
                }, row)
                Corner(CORNER_SM, btn)
                Stroke(th.Border, 1, btn)

                if cfg.Description then
                    Create("TextLabel", {
                        Text            = cfg.Description,
                        Font            = FONT_REG,
                        TextSize        = 10,
                        TextColor3      = th.TextMuted,
                        BackgroundTransparency = 1,
                        Size            = UDim2.new(1, -16, 0, 14),
                        Position        = UDim2.new(0, 8, 0, 24),
                        TextXAlignment  = Enum.TextXAlignment.Center,
                        ZIndex          = 9,
                        AutoLocalize    = false,
                    }, btn)
                    
                    local titleLbl = btn:FindFirstChildOfClass("TextLabel")
                    
                    btn.TextYAlignment = Enum.TextYAlignment.Top
                    btn.Text = ""  
                    Create("TextLabel", {
                        Text            = cfg.ButtonText or cfg.Title or "Button",
                        Font            = FONT_REG,
                        TextSize        = 13,
                        TextColor3      = th.TextPrimary,
                        BackgroundTransparency = 1,
                        Size            = UDim2.new(1, -16, 0, 20),
                        Position        = UDim2.fromOffset(8, 6),
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        ZIndex          = 9,
                        AutoLocalize    = false,
                    }, btn)
                end

                btn.MouseEnter:Connect(function()
                    Tween(btn, TWEEN_FAST, { BackgroundTransparency = 0.2 })
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, TWEEN_FAST, { BackgroundTransparency = 0.5 })
                end)
                btn.MouseButton1Down:Connect(function()
                    Tween(btn, TWEEN_FAST, { BackgroundTransparency = 0 })
                end)
                btn.MouseButton1Up:Connect(function()
                    Tween(btn, TWEEN_FAST, { BackgroundTransparency = 0.2 })
                end)

                btn.Activated:Connect(function()
                    if cfg.Callback then pcall(cfg.Callback) end
                end)

                return { Button = btn }
            end

            
            function secObj:AddInput(key, cfg)
                cfg = cfg or {}
                local th   = self._theme
                local value = cfg.Default or ""
                local changed = Signal.new()

                local row = RowFrame(50)

                Create("TextLabel", {
                    Text            = cfg.Title or key,
                    Font            = FONT_REG,
                    TextSize        = 13,
                    TextColor3      = th.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(1, 0, 0, 16),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    AutoLocalize    = false,
                }, row)

                local box = Create("TextBox", {
                    Text            = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "",
                    Font            = FONT_REG,
                    TextSize        = 12,
                    TextColor3      = th.TextPrimary,
                    PlaceholderColor3 = th.TextMuted,
                    BackgroundColor3= th.SurfaceActive,
                    Size            = UDim2.new(1, 0, 0, 24),
                    Position        = UDim2.fromOffset(0, 20),
                    BorderSizePixel = 0,
                    ClearTextOnFocus= false,
                    ZIndex          = 8,
                    AutoLocalize    = false,
                }, row)
                Corner(CORNER_SM, box)
                Stroke(th.Border, 1, box)
                Padding(0, 0, 6, 6, box)

                box.FocusLost:Connect(function(enterPressed)
                    value = box.Text
                    if cfg.Finished and not enterPressed then return end
                    changed:Fire(value)
                    if cfg.Callback then pcall(cfg.Callback, value) end
                end)

                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if not cfg.Finished then
                        value = box.Text
                        changed:Fire(value)
                        if cfg.Callback then pcall(cfg.Callback, value) end
                    end
                end)

                local obj = { Value = value }
                function obj:SetValue(v) box.Text = tostring(v); value = v end
                function obj:OnChanged(fn) return changed:Connect(fn) end
                return obj
            end

            
            function secObj:AddParagraph(cfg)
                cfg = cfg or {}
                local th = self._theme

                local row = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 0),
                    AutomaticSize   = Enum.AutomaticSize.Y,
                    BackgroundColor3= th.SurfaceHover,
                    BackgroundTransparency = 0.5,
                    ZIndex          = 7,
                }, sec)
                Corner(CORNER_SM, row)
                Padding(6, 6, 8, 8, row)
                ListLayout(nil, nil, 2, row)

                if cfg.Title then
                    Create("TextLabel", {
                        Text            = cfg.Title,
                        Font            = FONT_MEDIUM,
                        TextSize        = 12,
                        TextColor3      = th.TextSecondary,
                        BackgroundTransparency = 1,
                        Size            = UDim2.new(1, 0, 0, 14),
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        ZIndex          = 8,
                        AutoLocalize    = false,
                    }, row)
                end

                if cfg.Content then
                    Create("TextLabel", {
                        Text            = cfg.Content,
                        Font            = FONT_REG,
                        TextSize        = 11,
                        TextColor3      = th.TextMuted,
                        BackgroundTransparency = 1,
                        Size            = UDim2.new(1, 0, 0, 0),
                        AutomaticSize   = Enum.AutomaticSize.Y,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        TextWrapped     = true,
                        ZIndex          = 8,
                        AutoLocalize    = false,
                    }, row)
                end

                return {}
            end

            return secObj
        end  

        return tabObj
    end  

    
    function W:_SelectTab(page, btn, icon)
        for _, tabObj in ipairs(self._tabs) do
            local active = tabObj._page == page
            tabObj._page.Visible = active
            Tween(tabObj._btn,  TWEEN_FAST, { BackgroundTransparency = active and 0.5 or 1 })
            Tween(tabObj._icon, TWEEN_FAST, { TextColor3 = active and self._theme.TabActive or self._theme.TabInactive })
        end
        self._activeTab = page
    end

    
    function W:Destroy()
        if self._toggleConn then self._toggleConn:Disconnect() end
        if self._blur        then self._blur:Destroy() end
        if self._gui         then self._gui:Destroy() end
    end

    return W
end

return setmetatable(LynxUI, {
    __call = function(self, ...) return self:CreateWindow(...) end,
})
