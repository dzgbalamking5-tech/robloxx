-- uilibrarymain.lua — Premium Dark UI (total redesign)
-- Fokus: tampilan super modern + halus, sidebar tabs kiri, animasi hover/click,
-- fade antar tab, draggable custom (lebih mulus), minimize & close bundar, hotkey hide/show.

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local UILib = {}
UILib.__index = UILib

--========================--
-- THEME & UTILITIES
--========================--
local Theme = {
	Bg1 = Color3.fromRGB(16,16,22),      -- window background
	Bg2 = Color3.fromRGB(24,24,34),      -- content background
	Bg3 = Color3.fromRGB(32,32,46),      -- sidebar/tab background
	Text = Color3.fromRGB(230,232,238),
	SubText = Color3.fromRGB(170,176,186),
	Accent = Color3.fromRGB(0, 196, 155), -- primary accent
	AccentSoft = Color3.fromRGB(0, 150, 120),
	Danger = Color3.fromRGB(235, 85, 92),
	Warn = Color3.fromRGB(255, 193, 72),
	Stroke = Color3.fromRGB(60,60,78)
}

local function round(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = o
	return c
end

local function stroke(o, color, t)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Thickness = t or 1
	s.Transparency = 0.4
	s.Parent = o
	return s
end

local function padding(o, l,t,r,b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = o
	return p
end

local function tween(o, info, props)
	return TweenService:Create(o, info or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function makeShadow(parent)
	local sh = Instance.new("ImageLabel")
	sh.Name = "_Shadow"
	sh.BackgroundTransparency = 1
	sh.Image = "rbxassetid://5028857084" -- soft shadow slice
	sh.ScaleType = Enum.ScaleType.Slice
	sh.SliceCenter = Rect.new(24,24,276,276)
	sh.ImageTransparency = 0.45
	sh.Size = UDim2.new(1, 35, 1, 35)
	sh.Position = UDim2.new(0, -18, 0, -18)
	sh.ZIndex = parent.ZIndex - 1
	sh.Parent = parent
	return sh
end

--========================--
-- WINDOW
--========================--
function UILib:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "🌙 Premium Hub"
	local name = opts.Name or "PremiumUI"
	local hotkey = opts.Hotkey or Enum.KeyCode.RightControl

	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Window root
	local root = Instance.new("Frame")
	root.Name = "Window"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.new(0.5, 0, 0.5, 0)
	root.Size = UDim2.new(0, 720, 0, 420)
	root.BackgroundColor3 = Theme.Bg1
	root.ZIndex = 50
	root.Parent = gui
	round(root, 14)
	stroke(root)
	makeShadow(root)

	-- TitleBar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 46)
	titleBar.BackgroundColor3 = Theme.Bg2
	titleBar.Parent = root
	round(titleBar, 14)
	stroke(titleBar)
	padding(titleBar, 14, 0, 14, 0)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 16
	titleLbl.TextColor3 = Theme.Text
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Size = UDim2.new(1, -120, 1, 0)
	titleLbl.Parent = titleBar

	-- macOS-style dots on right (as per your preference)
	local btnWrap = Instance.new("Frame")
	btnWrap.Size = UDim2.new(0, 70, 1, 0)
	btnWrap.Position = UDim2.new(1, -70, 0, 0)
	btnWrap.BackgroundTransparency = 1
	btnWrap.Parent = titleBar

	local function makeDot(color, xOffset)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false
		b.BackgroundColor3 = color
		b.Size = UDim2.new(0, 18, 0, 18)
		b.Position = UDim2.new(0, xOffset, 0.5, -9)
		b.Text = ""
		b.Parent = btnWrap
		round(b, 50)
		stroke(b, Color3.fromRGB(0,0,0), 1).Transparency = 0.7
		b.MouseEnter:Connect(function()
			tween(b, nil, {BackgroundColor3 = color:lerp(Color3.new(1,1,1), 0.15)}):Play()
		end)
		b.MouseLeave:Connect(function()
			tween(b, nil, {BackgroundColor3 = color}):Play()
		end)
		return b
	end

	local minBtn = makeDot(Theme.Warn, 10)
	local closeBtn = makeDot(Theme.Danger, 40)

	-- Body: Sidebar + Content
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Position = UDim2.new(0, 0, 0, 46)
	body.Size = UDim2.new(1, 0, 1, -46)
	body.BackgroundColor3 = Theme.Bg1
	body.Parent = root
	padding(body, 10, 12, 12, 12)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 190, 1, 0)
	sidebar.BackgroundColor3 = Theme.Bg3
	sidebar.Parent = body
	round(sidebar, 12)
	stroke(sidebar)
	padding(sidebar, 10, 10, 10, 10)

	local sideList = Instance.new("UIListLayout")
	sideList.Padding = UDim.new(0, 8)
	sideList.SortOrder = Enum.SortOrder.LayoutOrder
	sideList.Parent = sidebar

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -200, 1, 0)
	content.Position = UDim2.new(0, 200, 0, 0)
	content.BackgroundColor3 = Theme.Bg2
	content.Parent = body
	round(content, 12)
	stroke(content)
	padding(content, 16, 16, 16, 16)

	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.BackgroundTransparency = 1
	tabContainer.Size = UDim2.new(1, 0, 1, 0)
	tabContainer.Parent = content

	-- tabs registry
	local tabs = {}
	local currentTab

	-- switching with fade
	local function showTab(name)
		for n, t in pairs(tabs) do
			if n == name then
				if currentTab == t.Page then return end
				if currentTab then
					-- fade out current
					tween(currentTab, TweenInfo.new(0.15), {GroupTransparency = 1}):Play()
					wait(0.15)
					currentTab.Visible = false
				end
				t.Page.Visible = true
				t.Page.GroupTransparency = 1
				currentTab = t.Page
				tween(t.Page, TweenInfo.new(0.18), {GroupTransparency = 0}):Play()
				-- highlight button
				for _, info in pairs(tabs) do
					local active = (info == t)
					tween(info.Button, nil, {BackgroundColor3 = active and Theme.AccentSoft or Theme.Bg3}):Play()
					info.Button.TextColor3 = active and Theme.Text or Theme.SubText
				end
			end
		end
	end

	-- create sidebar button
	local function makeTabButton(text)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 36)
		b.AutoButtonColor = false
		b.Text = text
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 14
		b.TextColor3 = Theme.SubText
		b.BackgroundColor3 = Theme.Bg3
		b.Parent = sidebar
		round(b, 8)
		stroke(b)
		b.MouseEnter:Connect(function()
			tween(b, nil, {BackgroundColor3 = Theme.Bg2}):Play()
		end)
		b.MouseLeave:Connect(function()
			if currentTab and tabs[text] and tabs[text].Button == b and tabs[text].Page.Visible then return end
			tween(b, nil, {BackgroundColor3 = Theme.Bg3}):Play()
		end)
		return b
	end

	-- PUBLIC object
	local self = setmetatable({
		Gui = gui,
		Root = root,
		TitleBar = titleBar,
		Sidebar = sidebar,
		Content = tabContainer,
		Tabs = tabs,
		Theme = Theme,
		_Hotkey = hotkey,
	}, UILib)

	-- Minimize
	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		body.Visible = not minimized
		root.Size = minimized and UDim2.new(0, 720, 0, 46) or UDim2.new(0, 720, 0, 420)
	end)

	-- Close
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- Hotkey toggle visibility
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == hotkey then
			root.Visible = not root.Visible
		end
	end)

	-- Custom drag (smooth & works in all executors)
	local dragging = false
	local dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = root.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- methods
	function self:AddTab(tabName)
		if tabs[tabName] then return tabs[tabName].Page end

		local btn = makeTabButton(tabName)
		local page = Instance.new("CanvasGroup")
		page.Name = tabName .. "Page"
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Parent = tabContainer
		page.Visible = false
		page.GroupTransparency = 1

		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll"
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.ScrollBarThickness = 4
		scroll.Parent = page

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 10)
		list.Parent = scroll
		padding(scroll, 8, 8, 8, 12)

		tabs[tabName] = { Button = btn, Page = page, Scroll = scroll }

		btn.MouseButton1Click:Connect(function()
			showTab(tabName)
		end)

		if not currentTab then showTab(tabName) end
		return scroll
	end

	-- COMPONENTS (Premium look)
	function self:AddLabel(tab, text)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Text = text or "Label"
		l.Font = Enum.Font.GothamMedium
		l.TextSize = 14
		l.TextColor3 = Theme.SubText
		l.Size = UDim2.new(1, -4, 0, 22)
		l.Parent = tab
		return l
	end

	local function baseButton(text)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false
		b.Text = text or "Button"
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 14
		b.TextColor3 = Theme.Text
		b.Size = UDim2.new(1, -4, 0, 38)
		b.BackgroundColor3 = Theme.Bg3
		round(b, 10)
		stroke(b)
		b.MouseEnter:Connect(function()
			tween(b, nil, {BackgroundColor3 = Theme.Bg2}):Play()
		end)
		b.MouseLeave:Connect(function()
			tween(b, nil, {BackgroundColor3 = Theme.Bg3}):Play()
		end)
		return b
	end

	function self:AddButton(tab, opt)
		opt = opt or {}
		local b = baseButton(opt.Text or "Button")
		b.Parent = tab
		b.MouseButton1Click:Connect(function()
			if opt.Callback then opt.Callback() end
			local pulse = Instance.new("Frame")
			pulse.BackgroundColor3 = Theme.Accent
			pulse.BackgroundTransparency = 0.2
			pulse.Size = UDim2.new(0,0,1,0)
			pulse.Parent = b
			round(pulse, 10)
			tween(pulse, TweenInfo.new(0.25), {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}):Play()
			game.Debris:AddItem(pulse, 0.3)
		end)
		return b
	end

	function self:AddToggle(tab, opt)
		opt = opt or {}
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, -4, 0, 38)
		holder.BackgroundColor3 = Theme.Bg3
		holder.Parent = tab
		round(holder, 10)
		stroke(holder)
		padding(holder, 12, 8, 12, 8)

		local txt = Instance.new("TextLabel")
		txt.BackgroundTransparency = 1
		txt.Text = opt.Text or "Toggle"
		txt.Font = Enum.Font.GothamSemibold
		txt.TextSize = 14
		txt.TextColor3 = Theme.Text
		txt.Size = UDim2.new(1, -60, 1, 0)
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.Parent = holder

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(1, 0.5)
		knob.Position = UDim2.new(1, -6, 0.5, 0)
		knob.Size = UDim2.new(0, 44, 0, 22)
		knob.BackgroundColor3 = Color3.fromRGB(60,62,78)
		knob.Parent = holder
		round(knob, 999)
		stroke(knob)

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 18, 0, 18)
		dot.Position = UDim2.new(0, 2, 0.5, -9)
		dot.BackgroundColor3 = Theme.Text
		dot.Parent = knob
		round(dot, 999)

		local state = false
		local function setState(v)
			state = v
			if v then
				tween(knob, nil, {BackgroundColor3 = Theme.AccentSoft}):Play()
				tween(dot, nil, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
			else
				tween(knob, nil, {BackgroundColor3 = Color3.fromRGB(60,62,78)}):Play()
				tween(dot, nil, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
			end
			if opt.Callback then opt.Callback(state) end
		end

		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then setState(not state) end
		end)

		return {
			Instance = holder,
			Set = setState,
			Get = function() return state end
		}
	end

	function self:AddInput(tab, opt)
		opt = opt or {}
		local box = baseButton("")
		box.Text = ""
		box.BackgroundColor3 = Theme.Bg3
		box.Parent = tab

		local tb = Instance.new("TextBox")
		tb.BackgroundTransparency = 1
		tb.Size = UDim2.new(1, -16, 1, 0)
		tb.Position = UDim2.new(0, 8, 0, 0)
		tb.Font = Enum.Font.Gotham
		tb.TextSize = 14
		tb.Text = ""
		tb.PlaceholderText = opt.Placeholder or "Type here..."
		tb.TextColor3 = Theme.Text
		tb.PlaceholderColor3 = Theme.SubText
		tb.Parent = box

		tb.FocusLost:Connect(function(enter)
			if enter and opt.Callback then opt.Callback(tb.Text) end
		end)
		return tb
	end

	function self:AddDropdown(tab, opt)
		opt = opt or {}
		local list = opt.Choices or {}

		local btn = baseButton(opt.Text or "Dropdown")
		btn.Parent = tab

		local open = false
		local container

		local function close()
			if container then container:Destroy() container = nil end
			open = false
		end

		btn.MouseButton1Click:Connect(function()
			if open then close() return end
			open = true
			container = Instance.new("Frame")
			container.BackgroundColor3 = Theme.Bg1
			container.Parent = tab
			container.Size = UDim2.new(1, -4, 0, (#list * 30) + 8)
			round(container, 10)
			stroke(container)
			padding(container, 8, 8, 8, 8)

			local l = Instance.new("UIListLayout")
			l.Parent = container
			l.Padding = UDim.new(0, 6)

			for _, choice in ipairs(list) do
				local item = baseButton(choice)
				item.Size = UDim2.new(1, -4, 0, 28)
				item.Parent = container
				item.MouseButton1Click:Connect(function()
					btn.Text = choice
					if opt.Callback then opt.Callback(choice) end
					close()
				end)
			end
		end)

		return {
			Button = btn,
			Close = close
		}
	end

	function self:AddSlider(tab, opt)
		opt = opt or {}
		local min, max = opt.Min or 0, opt.Max or 100
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, -4, 0, 52)
		holder.BackgroundTransparency = 1
		holder.Parent = tab

		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Text = opt.Text or "Slider"
		name.Font = Enum.Font.GothamSemibold
		name.TextSize = 14
		name.TextColor3 = Theme.Text
		name.Size = UDim2.new(1, 0, 0, 20)
		name.Parent = holder

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, 10)
		bar.Position = UDim2.new(0, 0, 0, 30)
		bar.BackgroundColor3 = Theme.Bg3
		bar.Parent = holder
		round(bar, 6)
		stroke(bar)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.Parent = bar
		round(fill, 6)

		local valLbl = Instance.new("TextLabel")
		valLbl.BackgroundTransparency = 1
		valLbl.Text = tostring(min)
		valLbl.Font = Enum.Font.Gotham
		valLbl.TextSize = 13
		valLbl.TextColor3 = Theme.SubText
		valLbl.Position = UDim2.new(1, -48, 0, 14)
		valLbl.Size = UDim2.new(0, 48, 0, 16)
		valLbl.Parent = holder

		local dragging = false
		local value = min

		local function setPercent(p)
			p = math.clamp(p, 0, 1)
			fill.Size = UDim2.new(p, 0, 1, 0)
			value = math.floor(min + (max - min) * p + 0.5)
			valLbl.Text = tostring(value)
			if opt.Callback then opt.Callback(value) end
		end

		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				setPercent((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				setPercent((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)

		return {
			Set = function(v)
				local p = (v - min) / (max - min)
				setPercent(p)
			end,
			Get = function() return value end
		}
	end

	return self
end

return UILib
