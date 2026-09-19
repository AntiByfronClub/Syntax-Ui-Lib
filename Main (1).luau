local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local function Tween(inst, t, props)
	TweenService:Create(inst, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function NewInstance(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do inst[k] = v end
	if parent then inst.Parent = parent end
	return inst
end

local function Corner(radius, parent)
	return NewInstance("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function Stroke(color, thickness, transparency, parent)
	return NewInstance("UIStroke", {
		Color        = color,
		Thickness    = thickness,
		Transparency = transparency or 0,
	}, parent)
end

local function ListLayout(parent, padding)
	return NewInstance("UIListLayout", {
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Padding             = UDim.new(0, padding or 6),
		FillDirection       = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, parent)
end

local function Padding(l, r, t, b, parent)
	return NewInstance("UIPadding", {
		PaddingLeft   = UDim.new(0, l),
		PaddingRight  = UDim.new(0, r),
		PaddingTop    = UDim.new(0, t),
		PaddingBottom = UDim.new(0, b),
	}, parent)
end

local SyntaxHub   = {}
SyntaxHub.__index = SyntaxHub

function SyntaxHub.new(config)
	config = config or {}
	local credits      = config.Credits or {}
	local featureMaker = tostring(credits.FeaturesMadeBy or "N/A")
	local uiCreator    = tostring(credits.UICreator or "")

	local creditLine = "UI by " .. uiCreator .. "  |  Features by " .. featureMaker

	local logo  = config.CustomizeOpenLogo    or {}
	local frame = config.CustomizeMainHubFrame or {}

	local accentColor = Color3.fromRGB(logo.R or 0, logo.G or 170, logo.B or 127)
	local hubName     = logo.Name  or "Syntax Hub"
	local hubImage    = logo.Image or "rbxassetid://85366189380329"

	local hubSize = frame.Size                   or UDim2.fromOffset(480, 400)
	local hubPos  = frame.Position               or UDim2.fromScale(0.5, 0.5)
	local hubBg   = frame.BackgroundColor        or Color3.fromRGB(8, 14, 12)
	local hubBgTr = frame.BackgroundTransparency or 0

	local draggable          = config.MakeDraggable ~= false
	local settingsSelectable = config.SettingsWindowSelectable or false
	local activateKeyName    = config.SettingsWindowActivateKey or nil

	local ScreenGui = NewInstance("ScreenGui", {
		Name           = "SyntaxHub_" .. hubName,
		ResetOnSpawn   = false,
		DisplayOrder   = 9998,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, PlayerGui)

	local SideBtn = NewInstance("Frame", {
		Name             = "SyntaxOpenBtn",
		AnchorPoint      = Vector2.new(0, 0.5),
		Position         = UDim2.new(0, 12, 0.5, 0),
		Size             = UDim2.fromOffset(44, 44),
		BackgroundColor3 = Color3.fromRGB(8, 14, 12),
		BorderSizePixel  = 0,
		ZIndex           = 10,
	}, ScreenGui)
	Corner(8, SideBtn)
	Stroke(accentColor, 1.5, 0.2, SideBtn)

	NewInstance("ImageLabel", {
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Position               = UDim2.fromScale(0.5, 0.42),
		Size                   = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Image                  = hubImage,
		ImageColor3            = accentColor,
		ZIndex                 = 11,
	}, SideBtn)

	NewInstance("TextLabel", {
		AnchorPoint            = Vector2.new(0.5, 1),
		Position               = UDim2.new(0.5, 0, 1, -4),
		Size                   = UDim2.new(1, 0, 0, 11),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.GothamBold,
		Text                   = hubName,
		TextColor3             = accentColor,
		TextSize               = 9,
		TextTruncate           = Enum.TextTruncate.AtEnd,
		ZIndex                 = 11,
	}, SideBtn)

	local SideBtnClick = NewInstance("TextButton", {
		Size                   = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text                   = "",
		ZIndex                 = 12,
	}, SideBtn)

	local HubFrame = NewInstance("Frame", {
		Name                   = "HubFrame",
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Position               = hubPos,
		Size                   = hubSize,
		BackgroundColor3       = hubBg,
		BackgroundTransparency = hubBgTr,
		BorderSizePixel        = 0,
		ZIndex                 = 20,
		Visible                = false,
	}, ScreenGui)
	Corner(10, HubFrame)
	Stroke(accentColor, 1.5, 0.15, HubFrame)

	NewInstance("ImageLabel", {
		Size                   = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image                  = "rbxassetid://5028857472",
		ImageColor3            = accentColor,
		ImageTransparency      = 0.88,
		ScaleType              = Enum.ScaleType.Stretch,
		ZIndex                 = 21,
	}, HubFrame)

	local TitleBar = NewInstance("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Color3.fromRGB(5, 10, 8),
		BorderSizePixel  = 0,
		ZIndex           = 22,
	}, HubFrame)
	Corner(10, TitleBar)
	NewInstance("Frame", {
		Position         = UDim2.new(0, 0, 0.5, 0),
		Size             = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(5, 10, 8),
		BorderSizePixel  = 0,
		ZIndex           = 22,
	}, TitleBar)

	NewInstance("ImageLabel", {
		AnchorPoint            = Vector2.new(0, 0.5),
		Position               = UDim2.new(0, 10, 0.5, 0),
		Size                   = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Image                  = hubImage,
		ImageColor3            = accentColor,
		ZIndex                 = 23,
	}, TitleBar)

	NewInstance("TextLabel", {
		AnchorPoint            = Vector2.new(0, 0.5),
		Position               = UDim2.new(0, 34, 0.5, 0),
		Size                   = UDim2.fromOffset(200, 22),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.GothamBold,
		Text                   = hubName,
		TextColor3             = accentColor,
		TextSize               = 14,
		TextXAlignment         = Enum.TextXAlignment.Left,
		ZIndex                 = 23,
	}, TitleBar)

	local CloseBtn = NewInstance("TextButton", {
		AnchorPoint            = Vector2.new(1, 0.5),
		Position               = UDim2.new(1, -10, 0.5, 0),
		Size                   = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.GothamBold,
		Text                   = "✕",
		TextColor3             = Color3.fromRGB(160, 220, 200),
		TextSize               = 13,
		ZIndex                 = 23,
	}, TitleBar)

	local TabBar = NewInstance("Frame", {
		Name             = "TabBar",
		Position         = UDim2.new(0, 0, 0, 38),
		Size             = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(6, 12, 10),
		BorderSizePixel  = 0,
		ZIndex           = 22,
	}, HubFrame)
	local TabBarList = ListLayout(TabBar, 4)
	TabBarList.FillDirection       = Enum.FillDirection.Horizontal
	TabBarList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TabBarList.VerticalAlignment   = Enum.VerticalAlignment.Center
	Padding(8, 8, 0, 0, TabBar)

	local ContentScroll = NewInstance("ScrollingFrame", {
		Name                   = "Contents",
		Position               = UDim2.new(0, 0, 0, 68),
		Size                   = UDim2.new(1, 0, 1, -82),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ScrollBarThickness     = 4,
		ScrollBarImageColor3   = accentColor,
		CanvasSize             = UDim2.fromScale(0, 0),
		AutomaticCanvasSize    = Enum.AutomaticSize.Y,
		ZIndex                 = 22,
	}, HubFrame)
	ListLayout(ContentScroll, 6)
	Padding(10, 10, 6, 6, ContentScroll)

	NewInstance("TextLabel", {
		Name                   = "_credit_bar",
		AnchorPoint            = Vector2.new(0.5, 1),
		Position               = UDim2.new(0.5, 0, 1, -4),
		Size                   = UDim2.new(1, -20, 0, 12),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.Gotham,
		Text                   = creditLine,
		TextColor3             = Color3.fromRGB(0, 80, 60),
		TextSize               = 10,
		TextXAlignment         = Enum.TextXAlignment.Center,
		ZIndex                 = 22,
	}, HubFrame)

	local LoadingOverlay = NewInstance("Frame", {
		Name                   = "_LoadingOverlay",
		Size                   = UDim2.fromScale(1, 1),
		BackgroundColor3       = hubBg,
		BackgroundTransparency = 0.08,
		BorderSizePixel        = 0,
		ZIndex                 = 50,
		Visible                = false,
	}, HubFrame)
	Corner(10, LoadingOverlay)

	local Dots = {}
	for i = 1, 3 do
		local d = NewInstance("TextLabel", {
			Name                   = tostring(i),
			AnchorPoint            = Vector2.new(0.5, 0.5),
			Position               = UDim2.new(0.5, (i - 2) * 22, 0.38, 0),
			Size                   = UDim2.fromOffset(18, 28),
			BackgroundTransparency = 1,
			Font                   = Enum.Font.GothamBold,
			Text                   = "•",
			TextColor3             = accentColor,
			TextSize               = 28,
			TextScaled             = false,
			TextStrokeTransparency = 0.85,
			ZIndex                 = 51,
		}, LoadingOverlay)
		Dots[i] = d
	end

	local LoadingMsgLabel = NewInstance("TextLabel", {
		Name                   = "_LoadingMsg",
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Position               = UDim2.fromScale(0.5, 0.58),
		Size                   = UDim2.new(0.7, 0, 0, 24),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.GothamBold,
		Text                   = "",
		TextColor3             = Color3.fromRGB(200, 255, 235),
		TextSize               = 15,
		TextScaled             = false,
		TextXAlignment         = Enum.TextXAlignment.Center,
		ZIndex                 = 51,
	}, LoadingOverlay)

	local LoadingSubLabel = NewInstance("TextLabel", {
		Name                   = "_LoadingSubMsg",
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Position               = UDim2.fromScale(0.5, 0.67),
		Size                   = UDim2.new(0.65, 0, 0, 16),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.Gotham,
		Text                   = "",
		TextColor3             = Color3.fromRGB(100, 170, 140),
		TextSize               = 11,
		TextScaled             = false,
		TextXAlignment         = Enum.TextXAlignment.Center,
		ZIndex                 = 51,
	}, LoadingOverlay)

	local dotConn
	dotConn = RunService.RenderStepped:Connect(function()
		if not LoadingOverlay or not LoadingOverlay.Parent then
			dotConn:Disconnect()
			return
		end
		if LoadingOverlay.Visible then
			local t = os.clock()
			for i, d in ipairs(Dots) do
				d.TextTransparency = 0.15 + 0.85 * (0.5 + 0.5 * math.sin(t * 3 + i * 1.2))
			end
		end
	end)

	local SettingsFrame = NewInstance("Frame", {
		Name                   = "SettingsFrame",
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Position               = hubPos,
		Size                   = hubSize,
		BackgroundColor3       = hubBg,
		BackgroundTransparency = hubBgTr,
		BorderSizePixel        = 0,
		ZIndex                 = 20,
		Visible                = false,
	}, ScreenGui)
	Corner(10, SettingsFrame)
	Stroke(accentColor, 1.5, 0.15, SettingsFrame)

	local STitleBar = NewInstance("Frame", {
		Size             = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Color3.fromRGB(5, 10, 8),
		BorderSizePixel  = 0,
		ZIndex           = 22,
	}, SettingsFrame)
	Corner(10, STitleBar)
	NewInstance("Frame", {
		Position         = UDim2.new(0, 0, 0.5, 0),
		Size             = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(5, 10, 8),
		BorderSizePixel  = 0,
		ZIndex           = 22,
	}, STitleBar)
	NewInstance("TextLabel", {
		AnchorPoint            = Vector2.new(0, 0.5),
		Position               = UDim2.new(0, 12, 0.5, 0),
		Size                   = UDim2.fromOffset(200, 22),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.GothamBold,
		Text                   = "Settings — " .. hubName,
		TextColor3             = accentColor,
		TextSize               = 14,
		TextXAlignment         = Enum.TextXAlignment.Left,
		ZIndex                 = 23,
	}, STitleBar)

	local SettingsScroll = NewInstance("ScrollingFrame", {
		Name                   = "SettingsContents",
		Position               = UDim2.new(0, 0, 0, 44),
		Size                   = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ScrollBarThickness     = 4,
		ScrollBarImageColor3   = accentColor,
		CanvasSize             = UDim2.fromScale(0, 0),
		AutomaticCanvasSize    = Enum.AutomaticSize.Y,
		ZIndex                 = 22,
	}, SettingsFrame)
	ListLayout(SettingsScroll, 6)
	Padding(10, 10, 6, 6, SettingsScroll)

	local self = setmetatable({}, SyntaxHub)
	self._screenGui          = ScreenGui
	self._hubFrame           = HubFrame
	self._settingsFrame      = SettingsFrame
	self._contentScroll      = ContentScroll
	self._settingsScroll     = SettingsScroll
	self._tabBar             = TabBar
	self._accentColor        = accentColor
	self._hubBg              = hubBg
	self._hubOpen            = false
	self._settingsOpen       = false
	self._tabs               = {}
	self._activeTab          = nil
	self._uiCreator          = uiCreator
	self._featureMaker       = featureMaker
	self._creditLine         = creditLine
	self._activateKey        = activateKeyName
	self._settingsSelectable = settingsSelectable
	self._keyPopupShown      = false
	self._loadingMessages    = {}
	self._hasOpened          = false

	local function RunLoadingSequence(onDone)
		if #self._loadingMessages == 0 then
			onDone()
			return
		end

		LoadingOverlay.Visible               = true
		LoadingOverlay.BackgroundTransparency = 0.08
		for _, d in ipairs(Dots) do
			d.TextTransparency = 0
		end
		LoadingMsgLabel.TextTransparency = 0
		LoadingSubLabel.TextTransparency = 0

		local msgs = self._loadingMessages
		local idx  = 1

		local function ShowNext()
			if idx > #msgs then
				Tween(LoadingOverlay, 0.3, { BackgroundTransparency = 1 })
				for _, d in ipairs(Dots) do
					Tween(d, 0.3, { TextTransparency = 1 })
				end
				Tween(LoadingMsgLabel, 0.3, { TextTransparency = 1 })
				Tween(LoadingSubLabel, 0.3, { TextTransparency = 1 })
				task.delay(0.32, function()
					LoadingOverlay.Visible = false
					onDone()
				end)
				return
			end

			local m = msgs[idx]
			idx += 1

			LoadingMsgLabel.Text       = m.text  or ""
			LoadingSubLabel.Text       = m.sub   or ""
			LoadingMsgLabel.TextColor3 = m.color or Color3.fromRGB(200, 255, 235)

			task.delay(m.duration or 0.85, ShowNext)
		end

		ShowNext()
	end

	local function OpenHub()
		self._hubOpen    = true
		HubFrame.Visible = true
		HubFrame.Position = UDim2.new(
			hubPos.X.Scale, hubPos.X.Offset,
			hubPos.Y.Scale + 0.04, hubPos.Y.Offset
		)
		HubFrame.BackgroundTransparency = 1
		Tween(HubFrame, 0.28, {
			Position               = hubPos,
			BackgroundTransparency = hubBgTr,
		})
	end

	local function CloseHub()
		self._hubOpen = false
		Tween(HubFrame, 0.22, {
			Position               = UDim2.new(hubPos.X.Scale, hubPos.X.Offset, hubPos.Y.Scale + 0.05, hubPos.Y.Offset),
			BackgroundTransparency = 1,
		})
		task.delay(0.25, function()
			HubFrame.Visible  = false
			HubFrame.Position = hubPos
		end)
	end

	SideBtnClick.MouseButton1Click:Connect(function()
		if self._hubOpen then
			CloseHub()
		else
			if self._settingsOpen then
				Tween(SettingsFrame, 0.2, { BackgroundTransparency = 1 })
				task.delay(0.22, function()
					SettingsFrame.Visible = false
					self._settingsOpen    = false
				end)
			end
			if not self._hasOpened and #self._loadingMessages > 0 then
				self._hasOpened = true
				HubFrame.Visible = true
				HubFrame.Position = hubPos
				HubFrame.BackgroundTransparency = hubBgTr
				LoadingOverlay.Visible = true
				RunLoadingSequence(function()
					OpenHub()
				end)
			else
				self._hasOpened = true
				OpenHub()
			end
		end
	end)

	SideBtnClick.MouseEnter:Connect(function()
		Tween(SideBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(12, 22, 18) })
	end)
	SideBtnClick.MouseLeave:Connect(function()
		Tween(SideBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(8, 14, 12) })
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		CloseHub()
	end)

	if draggable then
		local function MakeDraggable(frame, handle)
			local dragging, dragStart, startPos
			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging  = true
					dragStart = input.Position
					startPos  = frame.Position
				end
			end)
			handle.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				) then
					local delta = input.Position - dragStart
					frame.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end)
		end
		MakeDraggable(HubFrame, TitleBar)
		MakeDraggable(SettingsFrame, STitleBar)
	end

	if settingsSelectable and activateKeyName then
		local keyOk, keyCode = pcall(function()
			return Enum.KeyCode[activateKeyName]
		end)
		if keyOk and keyCode then
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.KeyCode ~= keyCode then return end
				if self._settingsOpen then
					Tween(SettingsFrame, 0.22, { BackgroundTransparency = 1 })
					task.delay(0.24, function()
						SettingsFrame.Visible = false
						self._settingsOpen    = false
					end)
					OpenHub()
				else
					if self._hubOpen then CloseHub() end
					self._settingsOpen                   = true
					SettingsFrame.Visible                = true
					SettingsFrame.BackgroundTransparency = 1
					Tween(SettingsFrame, 0.28, { BackgroundTransparency = hubBgTr })
					if not self._keyPopupShown then
						self._keyPopupShown = true
						task.delay(0.3, function()
							self:CreatePopup(
								"Keybind Active",
								"Press " .. activateKeyName .. " to toggle Settings / Hub"
							)
						end)
					end
				end
			end)
		else
			warn("[SyntaxHub] SettingsWindowActivateKey: invalid KeyCode '" .. tostring(activateKeyName) .. "'")
		end
	end

	return self
end

function SyntaxHub:CreateLoadingMessage(text, sub, duration, color)
	table.insert(self._loadingMessages, {
		text     = text     or "Loading...",
		sub      = sub      or "",
		duration = duration or 0.85,
		color    = color    or Color3.fromRGB(200, 255, 235),
	})
end

function SyntaxHub:CustomizeLoadingMessage(index, props)
	local m = self._loadingMessages[index]
	if not m then return end
	if props.text     ~= nil then m.text     = props.text     end
	if props.sub      ~= nil then m.sub      = props.sub      end
	if props.duration ~= nil then m.duration = props.duration end
	if props.color    ~= nil then m.color    = props.color    end
end

function SyntaxHub:CreateWindow(title)
	title = tostring(title or "Window")

	local TabBtn = NewInstance("TextButton", {
		Name             = title,
		Size             = UDim2.fromOffset(0, 22),
		AutomaticSize    = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(10, 20, 16),
		Font             = Enum.Font.GothamBold,
		Text             = "  " .. title .. "  ",
		TextColor3       = self._accentColor,
		TextSize         = 12,
		BorderSizePixel  = 0,
		ZIndex           = 24,
		LayoutOrder      = #self._tabs + 1,
	}, self._tabBar)
	Corner(6, TabBtn)

	local TabContent = NewInstance("Frame", {
		Name                   = title .. "_Content",
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ZIndex                 = 22,
		Visible                = false,
		LayoutOrder            = #self._tabs + 1,
	}, self._contentScroll)
	ListLayout(TabContent, 6)

	local window = {
		_hub         = self,
		_tabBtn      = TabBtn,
		_tabContent  = TabContent,
		_title       = title,
		_layoutOrder = 0,
	}

	table.insert(self._tabs, window)

	if #self._tabs == 1 then
		TabContent.Visible      = true
		self._activeTab         = window
		TabBtn.BackgroundColor3 = self._accentColor
		TabBtn.TextColor3       = Color3.fromRGB(6, 12, 10)
	end

	TabBtn.MouseButton1Click:Connect(function()
		if self._activeTab then
			self._activeTab._tabContent.Visible = false
			Tween(self._activeTab._tabBtn, 0.15, {
				BackgroundColor3 = Color3.fromRGB(10, 20, 16),
				TextColor3       = self._accentColor,
			})
		end
		TabContent.Visible = true
		self._activeTab    = window
		Tween(TabBtn, 0.15, {
			BackgroundColor3 = self._accentColor,
			TextColor3       = Color3.fromRGB(6, 12, 10),
		})
	end)

	function window:CreateButton(btnTitle, btnDesc, callback)
		self._layoutOrder += 1
		local accent = self._hub._accentColor

		local Row = NewInstance("Frame", {
			Name             = btnTitle,
			Size             = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = Color3.fromRGB(10, 18, 14),
			BorderSizePixel  = 0,
			ZIndex           = 23,
			LayoutOrder      = self._layoutOrder,
		}, self._tabContent)
		Corner(8, Row)
		Stroke(accent, 1, 0.75, Row)

		NewInstance("TextLabel", {
			Position               = UDim2.new(0, 12, 0, 8),
			Size                   = UDim2.new(1, -70, 0, 18),
			BackgroundTransparency = 1,
			Font                   = Enum.Font.GothamBold,
			Text                   = btnTitle,
			TextColor3             = Color3.fromRGB(220, 255, 240),
			TextSize               = 13,
			TextXAlignment         = Enum.TextXAlignment.Left,
			RichText               = true,
			ZIndex                 = 24,
		}, Row)

		NewInstance("TextLabel", {
			Position               = UDim2.new(0, 12, 0, 28),
			Size                   = UDim2.new(1, -70, 0, 16),
			BackgroundTransparency = 1,
			Font                   = Enum.Font.Gotham,
			Text                   = btnDesc or "",
			TextColor3             = Color3.fromRGB(120, 180, 155),
			TextSize               = 11,
			TextXAlignment         = Enum.TextXAlignment.Left,
			RichText               = true,
			ZIndex                 = 24,
			TextTruncate           = Enum.TextTruncate.AtEnd,
		}, Row)

		local ToggleTrack = NewInstance("Frame", {
			AnchorPoint      = Vector2.new(1, 0.5),
			Position         = UDim2.new(1, -12, 0.5, 0),
			Size             = UDim2.fromOffset(42, 22),
			BackgroundColor3 = Color3.fromRGB(20, 35, 28),
			BorderSizePixel  = 0,
			ZIndex           = 24,
		}, Row)
		Corner(11, ToggleTrack)

		local ToggleThumb = NewInstance("Frame", {
			AnchorPoint      = Vector2.new(0, 0.5),
			Position         = UDim2.new(0, 3, 0.5, 0),
			Size             = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Color3.fromRGB(80, 110, 95),
			BorderSizePixel  = 0,
			ZIndex           = 25,
		}, Row)
		Corner(8, ToggleThumb)

		local toggled  = false
		local debounce = false

		local function SetToggle(state, silent)
			toggled = state
			Tween(ToggleTrack, 0.18, {
				BackgroundColor3 = state and accent or Color3.fromRGB(20, 35, 28),
			})
			Tween(ToggleThumb, 0.18, {
				Position         = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
				BackgroundColor3 = state and Color3.fromRGB(220, 255, 240) or Color3.fromRGB(80, 110, 95),
			})
			if not silent and callback then
				task.spawn(callback, state)
			end
		end

		local ClickOverlay = NewInstance("TextButton", {
			Size                   = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text                   = "",
			ZIndex                 = 26,
		}, Row)
		Corner(8, ClickOverlay)

		ClickOverlay.MouseButton1Click:Connect(function()
			if debounce then return end
			debounce = true
			task.delay(0.2, function() debounce = false end)
			SetToggle(not toggled)
		end)
		ClickOverlay.MouseEnter:Connect(function()
			Tween(Row, 0.12, { BackgroundColor3 = Color3.fromRGB(14, 24, 19) })
		end)
		ClickOverlay.MouseLeave:Connect(function()
			Tween(Row, 0.12, { BackgroundColor3 = Color3.fromRGB(10, 18, 14) })
		end)

		return {
			Set = function(_, state) SetToggle(state, false) end,
			Get = function(_) return toggled end,
		}
	end

	function window:CreateSlider(slTitle, slDesc, minVal, maxVal, step, default, callback)
		self._layoutOrder += 1
		local accent = self._hub._accentColor
		minVal  = minVal  or 0
		maxVal  = maxVal  or 100
		step    = step    or 1
		default = math.clamp(default or minVal, minVal, maxVal)

		assert(type(step) == "number" and step > 0, "[SyntaxHub] CreateSlider: step must be a positive number, got " .. tostring(step))
		assert(minVal < maxVal, "[SyntaxHub] CreateSlider: minVal must be less than maxVal")

		local Row = NewInstance("Frame", {
			Name             = slTitle,
			Size             = UDim2.new(1, 0, 0, 64),
			BackgroundColor3 = Color3.fromRGB(10, 18, 14),
			BorderSizePixel  = 0,
			ZIndex           = 23,
			LayoutOrder      = self._layoutOrder,
		}, self._tabContent)
		Corner(8, Row)
		Stroke(accent, 1, 0.75, Row)

		NewInstance("TextLabel", {
			Position               = UDim2.new(0, 12, 0, 7),
			Size                   = UDim2.new(1, -60, 0, 16),
			BackgroundTransparency = 1,
			Font                   = Enum.Font.GothamBold,
			Text                   = slTitle,
			TextColor3             = Color3.fromRGB(220, 255, 240),
			TextSize               = 13,
			TextXAlignment         = Enum.TextXAlignment.Left,
			RichText               = true,
			ZIndex                 = 24,
		}, Row)

		NewInstance("TextLabel", {
			Position               = UDim2.new(0, 12, 0, 25),
			Size                   = UDim2.new(1, -70, 0, 14),
			BackgroundTransparency = 1,
			Font                   = Enum.Font.Gotham,
			Text                   = slDesc or "",
			TextColor3             = Color3.fromRGB(120, 180, 155),
			TextSize               = 11,
			TextXAlignment         = Enum.TextXAlignment.Left,
			RichText               = true,
			ZIndex                 = 24,
			TextTruncate           = Enum.TextTruncate.AtEnd,
		}, Row)

		local ValueLabel = NewInstance("TextLabel", {
			AnchorPoint            = Vector2.new(1, 0),
			Position               = UDim2.new(1, -12, 0, 7),
			Size                   = UDim2.fromOffset(44, 16),
			BackgroundTransparency = 1,
			Font                   = Enum.Font.GothamBold,
			Text                   = tostring(default),
			TextColor3             = accent,
			TextSize               = 12,
			TextXAlignment         = Enum.TextXAlignment.Right,
			ZIndex                 = 24,
		}, Row)

		local Track = NewInstance("Frame", {
			AnchorPoint      = Vector2.new(0, 1),
			Position         = UDim2.new(0, 12, 1, -10),
			Size             = UDim2.new(1, -24, 0, 4),
			BackgroundColor3 = Color3.fromRGB(20, 35, 28),
			BorderSizePixel  = 0,
			ZIndex           = 24,
		}, Row)
		Corner(2, Track)

		local Fill = NewInstance("Frame", {
			Size             = UDim2.fromScale(0, 1),
			BackgroundColor3 = accent,
			BorderSizePixel  = 0,
			ZIndex           = 25,
		}, Track)
		Corner(2, Fill)

		local Dragger = NewInstance("Frame", {
			AnchorPoint      = Vector2.new(0.5, 0.5),
			Position         = UDim2.fromScale(0, 0.5),
			Size             = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.fromRGB(220, 255, 240),
			BorderSizePixel  = 0,
			ZIndex           = 26,
		}, Track)
		Corner(6, Dragger)

		local currentValue = default
		local dragging     = false

		local function Snap(v)
			return math.clamp(
				tonumber(string.format("%.10g", math.floor((v / step) + 0.5) * step)) or minVal,
				minVal, maxVal
			)
		end

		local function SetValue(v, silent)
			currentValue = Snap(v)
			local pct    = (currentValue - minVal) / math.max(maxVal - minVal, 0.001)
			Tween(Fill,    0.08, { Size     = UDim2.fromScale(pct, 1) })
			Tween(Dragger, 0.08, { Position = UDim2.new(pct, 0, 0.5, 0) })
			ValueLabel.Text = tostring(currentValue)
			if not silent and callback then
				task.spawn(callback, currentValue)
			end
		end

		SetValue(default, true)

		local Mouse = LocalPlayer:GetMouse()

		local DraggerBtn = NewInstance("TextButton", {
			Size                   = UDim2.fromOffset(20, 20),
			AnchorPoint            = Vector2.new(0.5, 0.5),
			Position               = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Text                   = "",
			ZIndex                 = 27,
		}, Dragger)

		local mouseConn
		local renderConn

		DraggerBtn.MouseButton1Down:Connect(function()
			dragging = true

			renderConn = RunService.RenderStepped:Connect(function()
				if not dragging then
					renderConn:Disconnect()
					renderConn = nil
					return
				end
				local pct = math.clamp(
					(Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1
				)
				SetValue(minVal + (maxVal - minVal) * pct)
			end)

			mouseConn = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					mouseConn:Disconnect()
					mouseConn = nil
				end
			end)
		end)

		return {
			Set = function(_, v) SetValue(v, false) end,
			Get = function(_) return currentValue end,
		}
	end

	return window
end

function SyntaxHub:CreatePopup(popTitle, popBody)
	local accent    = self._accentColor
	local signature = self._uiCreator

	local Toast = NewInstance("Frame", {
		Name             = "SyntaxPopup",
		AnchorPoint      = Vector2.new(1, 1),
		Position         = UDim2.new(1, -14, 1, 60),
		Size             = UDim2.fromOffset(260, 68),
		BackgroundColor3 = Color3.fromRGB(8, 14, 12),
		BorderSizePixel  = 0,
		ZIndex           = 9999,
	}, self._screenGui)
	Corner(8, Toast)
	Stroke(accent, 1.5, 0.2, Toast)

	NewInstance("Frame", {
		Size             = UDim2.new(0, 3, 1, -12),
		Position         = UDim2.new(0, 6, 0, 6),
		BackgroundColor3 = accent,
		BorderSizePixel  = 0,
		ZIndex           = 10000,
	}, Toast)
	Corner(2, Toast:FindFirstChildOfClass("Frame"))

	NewInstance("TextLabel", {
		Position               = UDim2.new(0, 18, 0, 7),
		Size                   = UDim2.new(1, -24, 0, 18),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.GothamBold,
		Text                   = popTitle or "Notice",
		TextColor3             = Color3.fromRGB(200, 255, 230),
		TextSize               = 13,
		TextXAlignment         = Enum.TextXAlignment.Left,
		ZIndex                 = 10000,
	}, Toast)

	NewInstance("TextLabel", {
		Position               = UDim2.new(0, 18, 0, 27),
		Size                   = UDim2.new(1, -24, 0, 22),
		BackgroundTransparency = 1,
		Font                   = Enum.Font.Gotham,
		Text                   = popBody or "",
		TextColor3             = Color3.fromRGB(120, 180, 155),
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		ZIndex                 = 10000,
	}, Toast)

	NewInstance("TextLabel", {
		AnchorPoint            = Vector2.new(1, 1),
		Position               = UDim2.new(1, -8, 1, -5),
		Size                   = UDim2.fromOffset(0, 10),
		AutomaticSize          = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font                   = Enum.Font.Gotham,
		Text                   = signature,
		TextColor3             = Color3.fromRGB(0, 55, 40),
		TextSize               = 9,
		ZIndex                 = 10000,
	}, Toast)

	Tween(Toast, 0.3, { Position = UDim2.new(1, -14, 1, -14) })
	task.delay(5, function()
		Tween(Toast, 0.35, { Position = UDim2.new(1, -14, 1, 80) })
		task.delay(0.4, function() Toast:Destroy() end)
	end)
end

function SyntaxHub:ApplyTheme(theme)
	theme = theme or {}

	if theme.AccentColor then
		local a           = theme.AccentColor
		self._accentColor = a
		for _, d in ipairs(self._screenGui:GetDescendants()) do
			if d:IsA("UIStroke") then
				Tween(d, 0.3, { Color = a })
			elseif d:IsA("ScrollingFrame") then
				d.ScrollBarImageColor3 = a
			elseif d:IsA("TextLabel") or d:IsA("TextButton") then
				local n = d.Name
				if n == "_credit_watermark" or n == "_credit_bar" then
				elseif d.TextColor3 == self._accentColor then
					Tween(d, 0.3, { TextColor3 = a })
				end
			elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
				if d.ImageColor3 == self._accentColor then
					Tween(d, 0.3, { ImageColor3 = a })
				end
			elseif d:IsA("Frame") then
				if d.BackgroundColor3 == self._accentColor then
					Tween(d, 0.3, { BackgroundColor3 = a })
				end
			end
		end
		self._accentColor = a
	end

	if theme.BackgroundColor then
		local c = theme.BackgroundColor
		Tween(self._hubFrame,      0.3, { BackgroundColor3 = c })
		Tween(self._settingsFrame, 0.3, { BackgroundColor3 = c })
	end

	if theme.BackgroundImage then
		local function ApplyBgImage(frame)
			local img = frame:FindFirstChild("_BgImage") or NewInstance("ImageLabel", {
				Name                   = "_BgImage",
				Size                   = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex                 = 19,
			}, frame)
			img.Image             = theme.BackgroundImage
			img.ImageTransparency = theme.BackgroundTransparency or 0.6
		end
		ApplyBgImage(self._hubFrame)
		ApplyBgImage(self._settingsFrame)
	elseif theme.BackgroundTransparency then
		Tween(self._hubFrame,      0.3, { BackgroundTransparency = theme.BackgroundTransparency })
		Tween(self._settingsFrame, 0.3, { BackgroundTransparency = theme.BackgroundTransparency })
	end

	if theme.FontStyle then
		for _, d in ipairs(self._screenGui:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				pcall(function() d.Font = theme.FontStyle end)
			end
		end
	end

	return {
		SetAccent          = function(c) self:ApplyTheme({ AccentColor = c }) end,
		SetBackground      = function(c) self:ApplyTheme({ BackgroundColor = c }) end,
		SetBackgroundImage = function(img, tr) self:ApplyTheme({ BackgroundImage = img, BackgroundTransparency = tr }) end,
		SetFont            = function(f) self:ApplyTheme({ FontStyle = f }) end,
	}
end

function SyntaxHub:SettingsDeclared(theme)
	warn("[SyntaxHub] SettingsDeclared is deprecated and will be removed in a future version. Use ApplyTheme instead.")
	return self:ApplyTheme(theme)
end

function SyntaxHub:GetSettingsScroll()
	return self._settingsScroll
end

return SyntaxHub
