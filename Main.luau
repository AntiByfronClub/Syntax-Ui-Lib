--[[
	lynx.cc UI Library
	Reverse-engineered from ludowig.cc Prison Life source.
	Topography dot-field background ported from getmadium.net.
	
	Usage:
		local Lynx = loadstring(game:HttpGet("..."))()
		local Window = Lynx:CreateWindow({ Title = "lynx.cc | Game", Size = UDim2.fromOffset(720, 480) })
		local Tab = Window:AddTab({ Title = "Aimbot", Icon = "" })
		local Section = Tab:AddSection("Silent Aim")
		Section:AddToggle("MyToggle", { Title = "Enable", Default = false, Callback = function(v) end })
		Section:AddSlider("MySlider", { Title = "Value", Min = 0, Max = 100, Default = 50, Rounding = 0, Callback = function(v) end })
		Section:AddKeybind("MyKey", { Title = "Key", Default = "E", Mode = "Toggle", Callback = function(active) end })
		Section:AddDropdown("MyDrop", { Title = "Pick", Values = {"A","B"}, Default = "A", Callback = function(v) end })
		Section:AddColorpicker("MyColor", { Title = "Color", Default = Color3.new(1,1,1), Callback = function(v) end })
		Section:AddButton({ Title = "Click Me", Callback = function() end })
		Section:AddInput("MyInput", { Title = "Text", Placeholder = "...", Default = "", Finished = false, Callback = function(v) end })
		Section:AddParagraph({ Title = "Note", Content = "Some info text." })
]]

local Lynx = {}
Lynx.__index = Lynx

local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

local THEME = {
	Background        = Color3.fromRGB(18, 18, 18),
	Sidebar           = Color3.fromRGB(23, 23, 23),
	Element           = Color3.fromRGB(28, 28, 28),
	ElementHover      = Color3.fromRGB(34, 34, 34),
	Stroke            = Color3.fromRGB(55, 55, 55),
	TabSelected       = Color3.fromRGB(240, 240, 240),
	TabHover          = Color3.fromRGB(38, 38, 38),
	TabUnselected     = Color3.fromRGB(100, 100, 100),
	Text              = Color3.fromRGB(235, 235, 235),
	SubText           = Color3.fromRGB(150, 150, 150),
	Accent            = Color3.fromRGB(240, 240, 240),
	ToggleOn          = Color3.fromRGB(240, 240, 240),
	ToggleOff         = Color3.fromRGB(55, 55, 55),
	SliderFill        = Color3.fromRGB(240, 240, 240),
	SliderTrack       = Color3.fromRGB(50, 50, 50),
	WindowClose       = Color3.fromRGB(220, 60, 60),
	WindowMin         = Color3.fromRGB(220, 180, 50),
	WindowMax         = Color3.fromRGB(50, 200, 80),
	WindowControlStroke = Color3.fromRGB(80, 80, 80),
	Header            = Color3.fromRGB(20, 20, 20),
	SectionLabel      = Color3.fromRGB(90, 90, 90),
	Notification = {
		Info    = Color3.fromRGB(80, 140, 230),
		Success = Color3.fromRGB(60, 190, 100),
		Warning = Color3.fromRGB(220, 160, 40),
		Error   = Color3.fromRGB(220, 60, 60),
	},
}

local function tween(obj, props, t, style, dir)
	TweenService:Create(obj, TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function make(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if parent then obj.Parent = parent end
	return obj
end

local function corner(parent, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, thickness, transparency)
	return make("UIStroke", {
		Color = color or THEME.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function padding(parent, all, l, r, t, b)
	return make("UIPadding", {
		PaddingLeft   = UDim.new(0, l or all or 0),
		PaddingRight  = UDim.new(0, r or all or 0),
		PaddingTop    = UDim.new(0, t or all or 0),
		PaddingBottom = UDim.new(0, b or all or 0),
	}, parent)
end

local function listlayout(parent, pad, sort, align)
	return make("UIListLayout", {
		Padding = UDim.new(0, pad or 6),
		SortOrder = sort or Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
	}, parent)
end

local function autocanvas(scroll, layout)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
	end)
end

-- ─── TOPOGRAPHY DOT FIELD ───────────────────────────────────────────────────

local function hashf(x, y)
	local v = math.sin(x * 127.1 + y * 311.7) * 43758.5453
	return v - math.floor(v)
end

local function smoothstep(lo, hi, val)
	local n = math.max(0, math.min(1, (val - lo) / (hi - lo)))
	return n * n * (3 - 2 * n)
end

local function backOut(t)
	local x = t - 1
	return 1 + x * x * (2.2 * x + 1.2)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function buildTopography(screenGui, canvasFrame)
	local dots         = {}
	local ripples      = {}
	local pointer      = { x = -10000, y = -10000, tx = -10000, ty = -10000, power = 0, target = 0 }
	local startTime    = os.clock()
	local prevTime     = nil
	local GAP          = 18
	local MAX_ALPHA    = 0.32
	local BUCKETS      = 20
	local BAND         = { -0.48, -0.24, 0.23, 0.5 }

	local drawings     = {}
	local bucketDrawings = {}

	for i = 1, BUCKETS do
		local d = Drawing.new("Circle")
		d.Visible     = false
		d.Filled      = true
		d.NumSides    = 8
		d.Transparency = 0
		table.insert(bucketDrawings, d)
		table.insert(drawings, d)
	end

	local function rebuild()
		for _, d in ipairs(drawings) do d:Remove() end
		drawings = {}
		bucketDrawings = {}
		for i = 1, BUCKETS do
			local d = Drawing.new("Circle")
			d.Visible     = false
			d.Filled      = true
			d.NumSides    = 8
			d.Transparency = 0
			table.insert(bucketDrawings, d)
			table.insert(drawings, d)
		end

		dots = {}
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		local W, H = vp.X, vp.Y
		local cx, cy = W / 2, H / 2
		local diag = math.sqrt(cx * cx + cy * cy)
		local cols = math.ceil(W / GAP)
		local rows = math.ceil(H / GAP)
		for rr = 0, rows do
			for cc = 0, cols do
				local x = cc * GAP + (hashf(cc, rr) - 0.5) * 2.2
				local y = rr * GAP + (hashf(rr + 91, cc + 43) - 0.5) * 2.2
				local dx = (x - cx) / (W / 2)
				local dy = (y - cy) / (H / 2)
				local pr = smoothstep(0.18, 0.5, math.sqrt(dx * dx + dy * dy))
				table.insert(dots, {
					x = x, y = y,
					nx = (x - cx) / W,
					ny = (y - cy) / H,
					seed = hashf(cc + 7, rr + 13) * math.pi * 2,
					mask = 0.28 + pr * 0.72,
					reveal = math.sqrt((x - cx)^2 + (y - cy)^2) / diag,
				})
			end
		end
	end

	rebuild()

	local conn
	conn = RunService.RenderStepped:Connect(function()
		local ok, err = pcall(function()
			local now    = os.clock()
			local age    = now - startTime
			local t      = now * 1.0
			local dt     = math.min(0.05, now - (prevTime or now - 0.0167))
			prevTime     = now

			local ease   = function(rate) return 1 - (1 - rate) ^ (dt * 60) end
			pointer.x    = lerp(pointer.x, pointer.tx, ease(0.08))
			pointer.y    = lerp(pointer.y, pointer.ty, ease(0.08))
			pointer.power = lerp(pointer.power, pointer.target, ease(0.05))

			local nowS   = now
			for i = #ripples, 1, -1 do
				if nowS - ripples[i].t0 > 1.8 then table.remove(ripples, i) end
			end

			local sway   = math.sin(t * 0.35) * 0.06
			local b0, b1, b2, b3 = BAND[1], BAND[2], BAND[3], BAND[4]

			local bucketX   = {}
			local bucketY   = {}
			local bucketR   = {}
			local bucketIdx = {}
			for i = 1, BUCKETS do
				bucketX[i] = {}
				bucketY[i] = {}
				bucketR[i] = {}
			end

			for _, d in ipairs(dots) do
				local intro = smoothstep(0, 0.35, age * 1.1 - d.reveal * 0.75)
				if intro <= 0 then continue end

				local nx    = d.nx + t * 0.045
				local ny    = d.ny - t * 0.012
				local terrain = math.sin(nx * 13 + ny * 3.8 + t * 0.55) * 0.48
					+ math.sin(nx * 6.7 - ny * 12.5 - t * 0.42) * 0.32
				local rg    = 0.5 + 0.5 * math.sin(ny * 28 + terrain * 5.7
					+ math.sin(nx * 8.5 + t * 0.3) * 1.4 - t * 1.6)
				local density = smoothstep(0.28, 0.79, math.max(0, math.min(1, terrain + 0.86))) * rg
				local fade  = smoothstep(b0 + sway, b1 + sway, d.ny)
					* (1 - smoothstep(b2 + sway, b3 + sway, d.ny))

				local x, y  = d.x, d.y
				x = x + math.sin(t * 1.4 + d.seed) * 0.9
				y = y + math.cos(t * 1.1 + d.seed) * 0.9

				local glow  = 0

				local px, py = x - pointer.x, y - pointer.y
				local pdist = math.sqrt(px * px + py * py)
				if pointer.power > 0.01 and pdist < 170 then
					local f = (1 - pdist / 170) ^ 2 * pointer.power
					glow = glow + f
					local push = f * 9 / (pdist + 0.001)
					x = x + px * push
					y = y + py * push
				end

				for _, r in ipairs(ripples) do
					local rage  = nowS - r.t0
					local front = rage * 620
					local rx, ry = x - r.x, y - r.y
					local rdist = math.sqrt(rx * rx + ry * ry)
					local band  = math.exp(-((rdist - front) / 38) ^ 2) * (1 - rage / 1.8) ^ 2
					if band > 0.01 then
						glow = glow + band * 0.9
						local push = band * 7 / (rdist + 0.001)
						x = x + rx * push
						y = y + ry * push
					end
				end

				if intro < 1 then
					glow = glow + math.sin(intro * math.pi) * 0.45 * (0.35 + 0.65 * fade) * d.mask
				end

				local alpha = math.min(MAX_ALPHA,
					((0.018 + density * 0.19) * fade * d.mask + glow * 0.17) * intro)
				if alpha <= 0.012 then continue end

				local radius = (0.7 + density * 0.95 + glow * 0.55) * (0.4 + backOut(intro) * 0.6)
				local bi     = math.min(BUCKETS, math.floor(alpha / MAX_ALPHA * BUCKETS) + 1)

				table.insert(bucketX[bi], x)
				table.insert(bucketY[bi], y)
				table.insert(bucketR[bi], radius)
			end

			for i = 1, BUCKETS do
				local bd = bucketDrawings[i]
				if #bucketX[i] > 0 then
					local midIdx = math.ceil(#bucketX[i] / 2)
					local alpha  = (i - 0.5) / BUCKETS * MAX_ALPHA
					bd.Color       = Color3.fromRGB(220, 220, 220)
					bd.Transparency = 1 - alpha
					bd.Position    = Vector2.new(bucketX[i][midIdx], bucketY[i][midIdx])
					bd.Radius      = bucketR[i][midIdx]
					bd.Visible     = true
				else
					bd.Visible = false
				end
			end
		end)
	end)

	UserInput.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if #ripples > 5 then table.remove(ripples, 1) end
			table.insert(ripples, { x = input.Position.X, y = input.Position.Y, t0 = os.clock() })
		end
	end)

	UserInput.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			pointer.tx     = input.Position.X
			pointer.ty     = input.Position.Y
			pointer.target = 1
			if pointer.x < -1000 then
				pointer.x = pointer.tx
				pointer.y = pointer.ty
			end
		end
	end)

	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rebuild)

	return {
		Connections = { conn },
		Drawings    = drawings,
		Destroy = function(self)
			for _, c in ipairs(self.Connections) do c:Disconnect() end
			for _, d in ipairs(self.Drawings) do d:Remove() end
		end,
	}
end

-- ─── NOTIFICATION SYSTEM ────────────────────────────────────────────────────

local NotifyHolder

local function ensureNotifyHolder()
	if NotifyHolder and NotifyHolder.Parent then return end
	local sg = make("ScreenGui", {
		Name = "LynxNotifications",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 9999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, PlayerGui)
	NotifyHolder = make("Frame", {
		Name = "Holder",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(300, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, sg)
	local layout = listlayout(NotifyHolder, 8)
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
end

local function notify(opts)
	ensureNotifyHolder()
	local typeColor = THEME.Notification[opts.Type or "Info"] or THEME.Notification.Info
	local card = make("Frame", {
		Size = UDim2.fromOffset(300, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, NotifyHolder)
	corner(card, 10)
	stroke(card, THEME.Stroke, 1, 0.3)

	local accent = make("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = typeColor,
		BorderSizePixel = 0,
	}, card)
	corner(accent, 2)

	local inner = make("Frame", {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -14, 1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, card)
	padding(inner, nil, 0, 10, 10, 10)

	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = THEME.Text,
		Text = opts.Title or "",
		TextXAlignment = Enum.TextXAlignment.Left,
	}, inner)

	if opts.Content and opts.Content ~= "" then
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = THEME.SubText,
			Text = opts.Content,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
		}, inner)
	end

	listlayout(inner, 3)

	card.BackgroundTransparency = 1
	tween(card, { BackgroundTransparency = 0.1 }, 0.2)

	task.delay(opts.Duration or 3, function()
		tween(card, { BackgroundTransparency = 1, Size = UDim2.fromOffset(300, 0) }, 0.25)
		task.delay(0.26, function() card:Destroy() end)
	end)
end

-- ─── SECTION ────────────────────────────────────────────────────────────────

local Section = {}
Section.__index = Section

function Section.new(parent, title)
	local self = setmetatable({}, Section)

	local container = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, parent)

	if title and title ~= "" then
		local header = make("Frame", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
		}, container)

		make("TextLabel", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.fromOffset(16, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = THEME.SectionLabel,
			Text = string.upper(title),
			TextXAlignment = Enum.TextXAlignment.Left,
		}, header)

		make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = THEME.Stroke,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, header)
	end

	self.ItemContainer = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, container)

	listlayout(self.ItemContainer, 4)
	padding(self.ItemContainer, nil, 12, 12, 0, 4)

	return self
end

local function makeRow(parent, minH)
	local row = make("Frame", {
		Size = UDim2.new(1, 0, 0, minH or 40),
		BackgroundColor3 = THEME.Element,
		BorderSizePixel = 0,
	}, parent)
	corner(row, 7)
	stroke(row, THEME.Stroke, 1, 0.4)
	padding(row, nil, 14, 14, 0, 0)
	return row
end

local function rowTitle(row, text, subText)
	local lbl = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = THEME.Text,
		Text = text or "",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	return lbl
end

function Section:AddToggle(id, opts)
	local row = makeRow(self.ItemContainer, 40)
	rowTitle(row, opts.Title or id)

	local track = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 20),
		BackgroundColor3 = opts.Default and THEME.ToggleOn or THEME.ToggleOff,
		BorderSizePixel = 0,
	}, row)
	corner(track, 10)

	local thumb = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = opts.Default and UDim2.fromOffset(18, 10) or UDim2.fromOffset(2, 10),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, track)
	corner(thumb, 8)

	local value = opts.Default or false
	local obj = { Value = value }

	local btn = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, row)

	local function refresh(v)
		value = v
		obj.Value = v
		tween(track, { BackgroundColor3 = v and THEME.ToggleOn or THEME.ToggleOff }, 0.12)
		tween(thumb, { Position = v and UDim2.fromOffset(18, 10) or UDim2.fromOffset(2, 10) }, 0.12)
	end

	btn.MouseButton1Click:Connect(function()
		value = not value
		refresh(value)
		if opts.Callback then opts.Callback(value) end
	end)

	function obj:SetValue(v, silent)
		refresh(v)
		if not silent and opts.Callback then opts.Callback(v) end
	end

	return obj
end

function Section:AddSlider(id, opts)
	local min     = opts.Min or 0
	local max     = opts.Max or 100
	local default = math.clamp(opts.Default or min, min, max)
	local round   = opts.Rounding or 0
	local value   = default
	local row     = makeRow(self.ItemContainer, 54)

	local topRow = make("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
	}, row)

	rowTitle(topRow, opts.Title or id)

	local valLbl = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(50, 24),
		BackgroundColor3 = THEME.Sidebar,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.SubText,
		Text = tostring(default),
		TextXAlignment = Enum.TextXAlignment.Center,
		BorderSizePixel = 0,
	}, topRow)
	corner(valLbl, 5)

	local track = make("Frame", {
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = THEME.SliderTrack,
		BorderSizePixel = 0,
	}, row)
	corner(track, 2)

	local fill = make("Frame", {
		Size = UDim2.fromScale((default - min) / (max - min), 1),
		BackgroundColor3 = THEME.SliderFill,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 2)

	local obj = { Value = value }

	local function setVal(v)
		v = math.clamp(v, min, max)
		if round == 0 then v = math.round(v)
		else v = math.round(v * 10^round) / 10^round end
		value = v
		obj.Value = v
		local pct = (v - min) / (max - min)
		tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.07)
		valLbl.Text = tostring(v)
	end

	local dragging = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInput.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local abs = track.AbsolutePosition
			local sz  = track.AbsoluteSize
			local pct = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
			local v   = min + pct * (max - min)
			setVal(v)
			if opts.Callback then opts.Callback(obj.Value) end
		end
	end)

	function obj:SetValue(v, silent)
		setVal(v)
		if not silent and opts.Callback then opts.Callback(obj.Value) end
	end

	return obj
end

function Section:AddKeybind(id, opts)
	local row = makeRow(self.ItemContainer, 40)
	rowTitle(row, opts.Title or id)

	local keyVal = opts.Default or "None"
	local mode   = opts.Mode or "Hold"
	local active = false
	local obj    = { Value = keyVal, Active = false }
	local binding = false

	local keyBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(60, 26),
		BackgroundColor3 = THEME.Sidebar,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.SubText,
		Text = keyVal,
		BorderSizePixel = 0,
	}, row)
	corner(keyBtn, 5)
	stroke(keyBtn, THEME.Stroke, 1, 0.4)

	local modeLbl = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -68, 0.5, 0),
		Size = UDim2.fromOffset(54, 26),
		BackgroundColor3 = THEME.Sidebar,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.SubText,
		Text = mode,
		BorderSizePixel = 0,
	}, row)
	corner(modeLbl, 5)
	stroke(modeLbl, THEME.Stroke, 1, 0.4)

	modeLbl.MouseButton1Click:Connect(function()
		mode = mode == "Toggle" and "Hold" or "Toggle"
		modeLbl.Text = mode
	end)

	keyBtn.MouseButton1Click:Connect(function()
		binding = true
		keyBtn.Text = "..."
		keyBtn.TextColor3 = THEME.Text
	end)

	UserInput.InputBegan:Connect(function(input, gp)
		if gp then return end
		if binding then
			local name
			if input.UserInputType == Enum.UserInputType.Keyboard then
				name = input.KeyCode.Name
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				name = "MouseButton1"
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				name = "MouseButton2"
			end
			if name then
				keyVal = name
				obj.Value = name
				keyBtn.Text = name
				keyBtn.TextColor3 = THEME.SubText
				binding = false
				if obj.OnChanged then obj.OnChanged() end
			end
			return
		end

		local matches = (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == keyVal)
			or (input.UserInputType == Enum.UserInputType.MouseButton1 and keyVal == "MouseButton1")
			or (input.UserInputType == Enum.UserInputType.MouseButton2 and keyVal == "MouseButton2")

		if matches then
			if mode == "Toggle" then
				active = not active
				obj.Active = active
				if opts.Callback then opts.Callback(active) end
			elseif mode == "Hold" then
				active = true
				obj.Active = true
				if opts.Callback then opts.Callback(true) end
			end
		end
	end)

	UserInput.InputEnded:Connect(function(input)
		if mode == "Hold" then
			local matches = (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == keyVal)
				or (input.UserInputType == Enum.UserInputType.MouseButton1 and keyVal == "MouseButton1")
				or (input.UserInputType == Enum.UserInputType.MouseButton2 and keyVal == "MouseButton2")
			if matches then
				active = false
				obj.Active = false
				if opts.Callback then opts.Callback(false) end
			end
		end
	end)

	function obj:OnChanged(fn)
		self._changed = fn
	end

	return obj
end

function Section:AddDropdown(id, opts)
	local value  = opts.Default
	local values = opts.Values or {}
	local row    = makeRow(self.ItemContainer, 40)
	rowTitle(row, opts.Title or id)

	local obj = { Value = value }

	local dropBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(120, 26),
		BackgroundColor3 = THEME.Sidebar,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.Text,
		Text = tostring(value or "Select"),
		BorderSizePixel = 0,
		ClipsDescendants = false,
	}, row)
	corner(dropBtn, 5)
	stroke(dropBtn, THEME.Stroke, 1, 0.4)

	local open    = false
	local menu

	local function closeMenu()
		if menu then menu:Destroy(); menu = nil end
		open = false
	end

	dropBtn.MouseButton1Click:Connect(function()
		if open then closeMenu(); return end
		open = true

		local sg = dropBtn:FindFirstAncestorOfClass("ScreenGui")
		local abs = dropBtn.AbsolutePosition
		local sz  = dropBtn.AbsoluteSize

		menu = make("Frame", {
			Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 4),
			Size = UDim2.fromOffset(sz.X, math.min(#values, 6) * 30 + 8),
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
			BorderSizePixel = 0,
			ZIndex = 500,
		}, sg)
		corner(menu, 7)
		stroke(menu, THEME.Stroke, 1, 0.3)
		padding(menu, 4)

		local ll = listlayout(menu, 2)

		for _, v in ipairs(values) do
			local item = make("TextButton", {
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = v == value and THEME.TabSelected or Color3.fromRGB(32, 32, 32),
				BackgroundTransparency = v == value and 0.85 or 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = v == value and THEME.Text or THEME.SubText,
				Text = tostring(v),
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				ZIndex = 501,
			}, menu)
			corner(item, 5)
			padding(item, nil, 8, 0, 0, 0)

			item.MouseButton1Click:Connect(function()
				value = v
				obj.Value = v
				dropBtn.Text = tostring(v)
				closeMenu()
				if opts.Callback then opts.Callback(v) end
			end)
		end
	end)

	function obj:SetValue(v, silent)
		value = v
		self.Value = v
		dropBtn.Text = tostring(v)
		if not silent and opts.Callback then opts.Callback(v) end
	end

	return obj
end

function Section:AddColorpicker(id, opts)
	local value = opts.Default or Color3.new(1, 1, 1)
	local row   = makeRow(self.ItemContainer, 40)
	rowTitle(row, opts.Title or id)
	local obj   = { Value = value }

	local swatch = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(32, 20),
		BackgroundColor3 = value,
		Text = "",
		BorderSizePixel = 0,
	}, row)
	corner(swatch, 5)
	stroke(swatch, THEME.Stroke, 1, 0.3)

	function obj:SetValue(v, silent)
		value = v
		self.Value = v
		swatch.BackgroundColor3 = v
		if not silent and opts.Callback then opts.Callback(v) end
	end

	swatch.MouseButton1Click:Connect(function()
		notify({ Title = opts.Title or id, Content = "Color picker coming soon.", Type = "Info", Duration = 2 })
	end)

	return obj
end

function Section:AddButton(opts)
	local row = makeRow(self.ItemContainer, 36)
	row.BackgroundColor3 = THEME.Sidebar

	local btn = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = THEME.Text,
		Text = opts.Title or "Button",
		BorderSizePixel = 0,
	}, row)

	btn.MouseEnter:Connect(function() tween(row, { BackgroundColor3 = THEME.ElementHover }, 0.1) end)
	btn.MouseLeave:Connect(function() tween(row, { BackgroundColor3 = THEME.Sidebar }, 0.1) end)
	btn.MouseButton1Click:Connect(function()
		if opts.Callback then opts.Callback() end
	end)
end

function Section:AddInput(id, opts)
	local row = makeRow(self.ItemContainer, 40)
	rowTitle(row, opts.Title or id)

	local input = make("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(140, 26),
		BackgroundColor3 = THEME.Sidebar,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.Text,
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = THEME.SubText,
		Text = opts.Default or "",
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
	}, row)
	corner(input, 5)
	stroke(input, THEME.Stroke, 1, 0.4)

	local obj = { Value = opts.Default or "" }

	local function fire(v)
		obj.Value = v
		if opts.Callback then opts.Callback(v) end
	end

	if opts.Finished then
		input.FocusLost:Connect(function() fire(input.Text) end)
	else
		input:GetPropertyChangedSignal("Text"):Connect(function() fire(input.Text) end)
	end

	function obj:SetValue(v, silent)
		input.Text = v
		self.Value = v
		if not silent and opts.Callback then opts.Callback(v) end
	end

	return obj
end

function Section:AddParagraph(opts)
	local container = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = THEME.Element,
		BorderSizePixel = 0,
	}, self.ItemContainer)
	corner(container, 7)
	stroke(container, THEME.Stroke, 1, 0.5)
	padding(container, nil, 14, 14, 10, 10)

	local ll = listlayout(container, 4)

	if opts.Title and opts.Title ~= "" then
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = THEME.Text,
			Text = opts.Title,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, container)
	end

	if opts.Content and opts.Content ~= "" then
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = THEME.SubText,
			Text = opts.Content,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
		}, container)
	end
end

-- ─── TAB ────────────────────────────────────────────────────────────────────

local Tab = {}
Tab.__index = Tab

function Tab.new(scroll, tabBtn)
	local self = setmetatable({}, Tab)

	self.Scroll = make("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = THEME.Accent,
		CanvasSize = UDim2.fromOffset(0, 0),
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Visible = false,
	}, scroll)

	self.Layout = listlayout(self.Scroll, 6)
	padding(self.Scroll, nil, 12, 12, 10, 10)
	autocanvas(self.Scroll, self.Layout)

	self.TabButton = tabBtn
	return self
end

function Tab:AddSection(title)
	return Section.new(self.Scroll, title)
end

function Tab:Select()
	self.Scroll.Visible = true
	self.TabButton.TextColor3 = THEME.Text
	self.TabButton.BackgroundColor3 = THEME.TabSelected
	self.TabButton.BackgroundTransparency = 0.9
end

function Tab:Deselect()
	self.Scroll.Visible = false
	self.TabButton.TextColor3 = THEME.TabUnselected
	self.TabButton.BackgroundColor3 = Color3.new(0, 0, 0)
	self.TabButton.BackgroundTransparency = 1
end

-- ─── WINDOW ─────────────────────────────────────────────────────────────────

local Window = {}
Window.__index = Window

function Window.new(lib, opts)
	local self = setmetatable({}, Window)

	self.Library   = lib
	self.Visible   = true
	self.Tabs      = {}
	self.ActiveTab = nil

	local sg = make("ScreenGui", {
		Name = "LynxUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, PlayerGui)
	self.ScreenGui = sg

	local size = opts.Size or UDim2.fromOffset(720, 480)

	local frame = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, sg)
	corner(frame, 12)
	stroke(frame, THEME.Stroke, 1, 0.2)
	self.Frame = frame

	local topbar = make("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = THEME.Header,
		BorderSizePixel = 0,
	}, frame)
	corner(topbar, 12)

	make("Frame", {
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = THEME.Header,
		BorderSizePixel = 0,
	}, topbar)

	make("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.Stroke,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, topbar)

	local titleLbl = make("TextLabel", {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -180, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = THEME.SubText,
		Text = opts.Title or "lynx.cc",
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topbar)

	local function makeControl(color, xOffset)
		local btn = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOffset, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = color,
			Text = "",
			BorderSizePixel = 0,
		}, topbar)
		corner(btn, 7)
		local s = stroke(btn, THEME.WindowControlStroke, 1, 0.3)
		btn.MouseEnter:Connect(function() tween(s, { Transparency = 0.0 }, 0.1) end)
		btn.MouseLeave:Connect(function() tween(s, { Transparency = 0.3 }, 0.1) end)
		return btn
	end

	local closeBtn = makeControl(THEME.WindowClose, -14)
	local minBtn   = makeControl(THEME.WindowMin, -34)
	local maxBtn   = makeControl(THEME.WindowMax, -54)

	closeBtn.MouseButton1Click:Connect(function()
		sg:Destroy()
		if lib.Topography then lib.Topography:Destroy() end
	end)

	minBtn.MouseButton1Click:Connect(function()
		self.Visible = not self.Visible
		frame.Visible = self.Visible
	end)

	local sidebar = make("Frame", {
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(0, 170, 1, -46),
		BackgroundColor3 = THEME.Sidebar,
		BorderSizePixel = 0,
	}, frame)

	make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = THEME.Stroke,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, sidebar)

	local tabList = make("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.new(1, 0, 1, -16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, sidebar)

	local tabLayout = listlayout(tabList, 2)
	autocanvas(tabList, tabLayout)
	padding(tabList, nil, 8, 8, 0, 0)

	local contentArea = make("Frame", {
		Position = UDim2.fromOffset(170, 46),
		Size = UDim2.new(1, -170, 1, -46),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, frame)

	self.TabList    = tabList
	self.ContentArea = contentArea

	if opts.ToggleKey then
		UserInput.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.KeyCode == opts.ToggleKey then
				self.Visible = not self.Visible
				frame.Visible = self.Visible
			end
		end)
	end

	-- drag
	local dragging, dragStart, startPos = false, nil, nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = input.Position
			startPos  = frame.Position
		end
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInput.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	return self
end

function Window:AddTab(opts)
	local tabBtn = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(0, 0, 0),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = THEME.TabUnselected,
		Text = "  " .. (opts.Title or "Tab"),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
	}, self.TabList)
	corner(tabBtn, 7)

	tabBtn.MouseEnter:Connect(function()
		if self.ActiveTab and self.Tabs[self.ActiveTab].TabButton == tabBtn then return end
		tween(tabBtn, { BackgroundTransparency = 0.85, BackgroundColor3 = THEME.TabHover }, 0.1)
	end)
	tabBtn.MouseLeave:Connect(function()
		if self.ActiveTab and self.Tabs[self.ActiveTab].TabButton == tabBtn then return end
		tween(tabBtn, { BackgroundTransparency = 1 }, 0.1)
	end)

	local tab = Tab.new(self.ContentArea, tabBtn)
	local idx = #self.Tabs + 1
	self.Tabs[idx] = tab

	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(idx)
	end)

	if idx == 1 then
		self:SelectTab(1)
	end

	return tab
end

function Window:SelectTab(idx)
	for i, t in ipairs(self.Tabs) do
		if i == idx then t:Select()
		else t:Deselect() end
	end
	self.ActiveTab = idx
end

function Window:Notify(opts)
	notify(opts)
end

-- ─── LIBRARY ENTRY ──────────────────────────────────────────────────────────

function Lynx:CreateWindow(opts)
	self.Topography = buildTopography()
	local w = Window.new(self, opts)
	return w
end

function Lynx:Notify(opts)
	notify(opts)
end

return Lynx
