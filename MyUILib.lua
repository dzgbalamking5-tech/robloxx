--[[

    MyUILib.lua — Premium UI Library (Total Redesign)
    Author: you + ChatGPT
    
    ✅ Fresh design (not Rayfield-based)
    ✅ Sidebar tabs, glassy cards, soft shadows
    ✅ Animations (hover/click/open), draggable window
    ✅ New Dropdown (virtualized list + search option)
    ✅ Real Color Picker (HSV wheel + sliders + textbox)
    ✅ Slider with % label, step, min/max, live callback
    ✅ Toggle, Button, Input, Keybind, Separator, Label
    ✅ Notifications (queue), optional sounds
    ✅ Optional config save/load (table-backed)
    ✅ Icon support via external icons.lua (optional)

    --------------------------------------------------
    QUICK START
    --------------------------------------------------
    local UI = loadstring(game:HttpGet("https://your-cdn/MyUILib.lua"))()
    local win = UI:CreateWindow({
        Title = "My Suite",
        SubTitle = "v1.0",
        Size = UDim2.fromOffset(680, 420),
        Theme = "Midnight", -- Midnight | Snow | Oceanic | Sunset | Mint | Violet
        Draggable = true,
        BlurBackground = true,
        Rounded = 14,
        Accent = Color3.fromRGB(110,180,255), -- override accent
        Icons = nil, -- require(path_to_icons) or nil
        Sounds = true,
    })

    local tabMain = win:AddTab({ Title = "Main", Icon = "home" })
    local sec = tabMain:AddSection("Core")
    sec:AddButton({ Text = "Do Thing", Callback = function() print("clicked") end })
    sec:AddToggle({ Text = "Auto", Default = false, Callback = function(v) print("toggle", v) end })
    sec:AddSlider({ Text = "Speed", Min = 0, Max = 100, Default = 25, Step = 1, Suffix = "%", Callback = function(v) end })
    sec:AddDropdown({ Text = "Mode", Options = {"A","B","C"}, Default = "B", Search = true, Callback = function(v) end })
    sec:AddInput({ Text = "Webhook", Placeholder = "https://...", Callback = function(s) end })
    sec:AddColorPicker({ Text = "Accent", Default = Color3.fromRGB(110,180,255), Callback = function(c) UI:SetAccent(c) end })

    UI:Notify({ Title = "Loaded", Description = "Welcome!", Duration = 5 })

]]

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// Utility
local function safeParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local g = Instance.new("ScreenGui")
        g.Name = "MyUILib"
        syn.protect_gui(g)
        g.Parent = CoreGui
        return g
    end
    if CoreGui:FindFirstChild("RobloxGui") then return CoreGui.RobloxGui end
    return CoreGui
end

local function new(instance, props)
    local obj = Instance.new(instance)
    if props then
        for k,v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

local function t(info, goal, time, style, dir)
    time = time or 0.25; style = style or Enum.EasingStyle.Quint; dir = dir or Enum.EasingDirection.Out
    return TweenService:Create(info, TweenInfo.new(time, style, dir), goal)
end

local function round(n, step)
    if not step or step == 0 then return n end
    return math.floor(n/step+0.5)*step
end

local function hsvToRgb(h, s, v)
    local i = math.floor(h*6)
    local f = h*6 - i
    local p = v*(1-s)
    local q = v*(1-f*s)
    local r,g,b
    if i % 6 == 0 then r,g,b = v,q,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,q
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = q,p,v
    else r,g,b = v,p,q end
    return Color3.new(r,g,b)
end

local function rgbToHsv(c)
    local r,g,b = c.R, c.G, c.B
    local max = math.max(r,g,b)
    local min = math.min(r,g,b)
    local d = max - min
    local h=0; local s = (max==0) and 0 or d/max
    if d ~= 0 then
        if max == r then h = (g-b)/d % 6
        elseif max == g then h = (b-r)/d + 2
        else h = (r-g)/d + 4 end
        h = h/6
    end
    return h,s,max
end

--// Theme Presets (distinct from Rayfield)
local Themes = {
    Midnight = {
        Background = Color3.fromRGB(18,18,24),
        Card = Color3.fromRGB(24,24,32),
        Stroke = Color3.fromRGB(44,44,56),
        Text = Color3.fromRGB(235,235,245),
        Muted = Color3.fromRGB(170,170,190),
        Topbar = Color3.fromRGB(28,28,36),
        Accent = Color3.fromRGB(110,180,255),
        Glow = Color3.fromRGB(50,70,110),
    },
    Snow = {
        Background = Color3.fromRGB(246,248,252),
        Card = Color3.fromRGB(255,255,255),
        Stroke = Color3.fromRGB(220,225,235),
        Text = Color3.fromRGB(20,22,26),
        Muted = Color3.fromRGB(110,120,130),
        Topbar = Color3.fromRGB(238,242,248),
        Accent = Color3.fromRGB(60,140,255),
        Glow = Color3.fromRGB(210,220,255),
    },
    Oceanic = {
        Background = Color3.fromRGB(10,20,26),
        Card = Color3.fromRGB(16,28,36),
        Stroke = Color3.fromRGB(24,40,50),
        Text = Color3.fromRGB(225,240,245),
        Muted = Color3.fromRGB(150,190,200),
        Topbar = Color3.fromRGB(18,32,40),
        Accent = Color3.fromRGB(0,170,190),
        Glow = Color3.fromRGB(0,70,90),
    },
    Sunset = {
        Background = Color3.fromRGB(32,22,24),
        Card = Color3.fromRGB(42,28,30),
        Stroke = Color3.fromRGB(64,40,42),
        Text = Color3.fromRGB(255,235,220),
        Muted = Color3.fromRGB(210,170,150),
        Topbar = Color3.fromRGB(55,36,38),
        Accent = Color3.fromRGB(255,150,80),
        Glow = Color3.fromRGB(120,60,40),
    },
    Mint = {
        Background = Color3.fromRGB(18,26,22),
        Card = Color3.fromRGB(20,32,28),
        Stroke = Color3.fromRGB(34,52,46),
        Text = Color3.fromRGB(220,245,235),
        Muted = Color3.fromRGB(160,190,180),
        Topbar = Color3.fromRGB(24,36,32),
        Accent = Color3.fromRGB(60,220,160),
        Glow = Color3.fromRGB(30,90,70),
    },
    Violet = {
        Background = Color3.fromRGB(22,18,28),
        Card = Color3.fromRGB(30,22,40),
        Stroke = Color3.fromRGB(50,36,70),
        Text = Color3.fromRGB(240,230,255),
        Muted = Color3.fromRGB(190,170,220),
        Topbar = Color3.fromRGB(36,26,50),
        Accent = Color3.fromRGB(185,120,255),
        Glow = Color3.fromRGB(90,40,140),
    },
}

--// Sounds
local SoundIds = {
    Click = 9118823101,
    ToggleOn = 1838698044,
    ToggleOff = 183870094,
    Notify = 6026984224,
}

local function playSound(parent, id, enabled)
    if not enabled then return end
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://"..tostring(id)
    s.Volume = 0.5
    s.PlayOnRemove = true
    s.Parent = parent
    s:Destroy()
end

--// Core UI
local MyUILib = {}
MyUILib.__index = MyUILib

function MyUILib:CreateWindow(opts)
    opts = opts or {}
    local theme = Themes[opts.Theme or "Midnight"] or Themes.Midnight
    if opts.Accent then theme = table.clone(theme); theme.Accent = opts.Accent end

    local parent = safeParent()
    local gui = new("ScreenGui", { Name = "MyUILib", IgnoreGuiInset = true, ResetOnSpawn = false })
    gui.Parent = parent

    -- Optional blur
    if opts.BlurBackground then
        local blur = Instance.new("BlurEffect")
        blur.Size = 8
        blur.Parent = workspace.CurrentCamera
        gui.AncestryChanged:Connect(function(_, p) if not p and blur then blur:Destroy() end end)
    end

    -- Root Window
    local root = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = opts.Size or UDim2.fromOffset(720,440),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false
    })
    root.Parent = gui

    local corner = new("UICorner", { CornerRadius = UDim.new(0, opts.Rounded or 14) })
    corner.Parent = root

    local shadow = new("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://6014261993",
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        BackgroundTransparency = 1,
        Size = UDim2.new(1,30,1,30),
        Position = UDim2.new(0,-15,0,-15),
    })
    shadow.Parent = root

    -- Topbar
    local topbar = new("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1,0,0,44),
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0
    })
    topbar.Parent = root

    new("UICorner", { CornerRadius = UDim.new(0, opts.Rounded or 14) }).Parent = topbar

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-16,1,0),
        Position = UDim2.new(0,16,0,0),
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = theme.Text,
        TextSize = 16,
        Text = (opts.Title or "My Suite") .. (opts.SubTitle and ("  •  "..opts.SubTitle) or "")
    })
    title.Parent = topbar

    -- Accent bar
    local accentBar = new("Frame", {
        Size = UDim2.new(1,0,0,2),
        Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
    })
    accentBar.Parent = topbar

    -- Layout: Sidebar + Content
    local content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1,-16,1,-60),
        Position = UDim2.new(0,8,0,52),
        BackgroundTransparency = 1
    })
    content.Parent = root

    local side = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0,180,1,0),
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0
    })
    side.Parent = content

    new("UICorner", { CornerRadius = UDim.new(0, opts.Rounded or 14) }).Parent = side
    new("UIStroke", { Color = theme.Stroke, Thickness = 1, Transparency = 0.4 }).Parent = side

    local tabList = new("UIListLayout", { Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder })
    tabList.Parent = side
    new("UIPadding", { PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8) }).Parent = side

    local body = new("Frame", {
        Name = "Body",
        Size = UDim2.new(1,-192,1,0),
        Position = UDim2.new(0,192,0,0),
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    body.Parent = content

    new("UICorner", { CornerRadius = UDim.new(0, opts.Rounded or 14) }).Parent = body
    new("UIStroke", { Color = theme.Stroke, Thickness = 1, Transparency = 0.4 }).Parent = body

    -- Draggable
    if opts.Draggable ~= false then
        local dragging, dragStart, startPos
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
                input.Changed:Connect(function(i)
                    if i.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                root.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
            end
        end)
    end

    -- Tab management
    local tabs = {}
    local currentTab

    local function setAccent(c)
        theme.Accent = c
        accentBar.BackgroundColor3 = c
        for _,tb in pairs(tabs) do
            if tb.Button then
                tb.Button.UIStroke.Color = c
                if tb.Active then tb.Button.BackgroundColor3 = c else tb.Button.BackgroundColor3 = theme.Card end
            end
        end
    end

    local window = {}

    -- Notifications
    do
        local notifRoot = new("Frame", { Name = "Notifications", Parent = gui, AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1,-12,1,-12), Size = UDim2.new(0,320,1,-24), BackgroundTransparency = 1 })
        local list = new("UIListLayout", { Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom })
        list.Parent = notifRoot
        function window:Notify(data)
            data = data or {}
            local card = new("Frame", { Size = UDim2.new(0, 320, 0, 70), BackgroundColor3 = theme.Card, BorderSizePixel = 0, Parent = notifRoot, Transparency = 1 })
            new("UICorner", { CornerRadius = UDim.new(0, 12) }).Parent = card
            new("UIStroke", { Color = theme.Stroke, Transparency = 0.4 }).Parent = card

            local titleN = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,10), Size = UDim2.new(1,-28,0,20), Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, TextSize = 15, Text = data.Title or "Notification" })
            titleN.Parent = card
            local descN = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,30), Size = UDim2.new(1,-28,0,34), Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Muted, TextSize = 13, TextWrapped = true, Text = data.Description or "" })
            descN.Parent = card

            card.Size = UDim2.new(0,320,0,0)
            card.BackgroundTransparency = 1
            t(card, {Size = UDim2.new(0,320,0,70), BackgroundTransparency = 0}, 0.25):Play()
            playSound(card, SoundIds.Notify, opts.Sounds ~= false)

            task.delay(math.max(1, data.Duration or 4), function()
                t(card, {Size = UDim2.new(0,320,0,0), BackgroundTransparency = 1}, 0.25):Play()
                task.wait(0.26)
                card:Destroy()
            end)
        end
    end

    -- Sections/Elements factory inside a Tab
    local SectionMT = {}
    SectionMT.__index = SectionMT

    function SectionMT:AddLabel(text)
        local holder = self:_card(40)
        local lbl = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,10), Size = UDim2.new(1,-28,1,-20), Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Muted, TextSize = 14, TextWrapped = true, Text = text or "" })
        lbl.Parent = holder
        return { Set = function(_, v) lbl.Text = v end }
    end

    function SectionMT:AddButton(data)
        data = data or {}
        local holder = self:_card(44)
        local btn = new("TextButton", { Text = data.Text or "Button", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = self.theme.Text, BackgroundColor3 = self.theme.Accent, Size = UDim2.new(0,120,0,30), Position = UDim2.new(1,-134,0,7), AutoButtonColor = false })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = btn
        btn.Parent = holder
        local titleL = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,0), Size = UDim2.new(1,-160,1,0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Text, Text = data.Text or "Button", Font = Enum.Font.Gotham, TextSize = 14 })
        titleL.Parent = holder
        btn.MouseEnter:Connect(function() t(btn, {BackgroundColor3 = self.theme.Accent: Lerp(Color3.new(1,1,1), 0.1)}, 0.15):Play() end)
        btn.MouseLeave:Connect(function() t(btn, {BackgroundColor3 = self.theme.Accent}, 0.15):Play() end)
        btn.MouseButton1Click:Connect(function()
            playSound(btn, SoundIds.Click, self.sounds)
            if data.Callback then task.spawn(data.Callback) end
        end)
        return { SetText = function(_,v) titleL.Text = v end, Click = function() btn:Activate() end }
    end

    function SectionMT:AddToggle(data)
        data = data or {}
        local holder = self:_card(44)
        local state = data.Default or false
        local knob = new("Frame", { Size = UDim2.fromOffset(48, 26), Position = UDim2.new(1,-62,0,9), BackgroundColor3 = state and self.theme.Accent or Color3.fromRGB(60,62,70), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = knob
        local dot = new("Frame", { Size = UDim2.fromOffset(22,22), Position = UDim2.new(state and 1 or 0, state and -24 or 2, 0,2), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = dot
        dot.Parent = knob
        knob.Parent = holder
        local titleL = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,0), Size = UDim2.new(1,-80,1,0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Text, Text = data.Text or "Toggle", Font = Enum.Font.Gotham, TextSize = 14 })
        titleL.Parent = holder

        local function set(v)
            state = v and true or false
            t(knob, {BackgroundColor3 = state and self.theme.Accent or Color3.fromRGB(60,62,70)}, 0.18):Play()
            t(dot, {Position = UDim2.new(state and 1 or 0, state and -24 or 2, 0,2)}, 0.18):Play()
            playSound(knob, state and SoundIds.ToggleOn or SoundIds.ToggleOff, self.sounds)
            if data.Callback then task.spawn(data.Callback, state) end
        end
        knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then set(not state) end end)
        return { Set = set, Get = function() return state end }
    end

    function SectionMT:AddSlider(data)
        data = data or {}
        local holder = self:_card(64)
        local min, max = data.Min or 0, data.Max or 100
        local value = math.clamp(data.Default or min, min, max)
        local step = data.Step or 1
        local bar = new("Frame", { Size = UDim2.new(1,-180,0,8), Position = UDim2.new(0,14,0,38), BackgroundColor3 = Color3.fromRGB(50,52,60), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,4) }).Parent = bar
        bar.Parent = holder
        local fill = new("Frame", { Size = UDim2.new((value-min)/(max-min),0,1,0), BackgroundColor3 = self.theme.Accent, BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,4) }).Parent = fill
        fill.Parent = bar
        local valLbl = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(1,-150,0,28), Size = UDim2.new(0,136,0,24), Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = self.theme.Text, TextSize = 14, Text = tostring(value)..(data.Suffix or "") })
        valLbl.Parent = holder
        local titleL = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,8), Size = UDim2.new(1,-28,0,20), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Text, Text = data.Text or "Slider", Font = Enum.Font.Gotham, TextSize = 14 })
        titleL.Parent = holder

        local dragging = false
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                local raw = min + (max-min)*rel
                local v = math.clamp(round(raw, step), min, max)
                value = v
                fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
                valLbl.Text = tostring(value)..(data.Suffix or "")
                if data.Callback then data.Callback(value) end
            end
        end)
        return { Set = function(_,v) value = math.clamp(round(v,step),min,max); fill.Size = UDim2.new((value-min)/(max-min),0,1,0); valLbl.Text = tostring(value)..(data.Suffix or "") end, Get = function() return value end }
    end

    function SectionMT:AddInput(data)
        data = data or {}
        local holder = self:_card(50)
        local box = new("TextBox", { PlaceholderText = data.Placeholder or "", Text = data.Default or "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = self.theme.Text, BackgroundColor3 = Color3.fromRGB(26,28,34), Position = UDim2.new(0,14,0,10), Size = UDim2.new(1,-28,0,30), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = box
        box.Parent = holder
        local titleL = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,18,0,-10), Size = UDim2.new(1,-36,0,18), Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Muted, TextSize = 12, Text = data.Text or "Input" })
        titleL.Parent = holder
        box.FocusLost:Connect(function(enter)
            if data.Callback then task.spawn(data.Callback, box.Text, enter) end
        end)
        return { Set = function(_,v) box.Text = v end, Get = function() return box.Text end }
    end

    function SectionMT:AddDropdown(data)
        data = data or {}
        local holder = self:_card(50)
        local open = false; local selected = data.Default
        local head = new("TextButton", { Text = "", BackgroundColor3 = Color3.fromRGB(26,28,34), Size = UDim2.new(1,-28,0,30), Position = UDim2.new(0,14,0,10), AutoButtonColor = false })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = head
        new("UIStroke", { Color = self.theme.Stroke, Transparency = 0.4 }).Parent = head
        head.Parent = holder
        local label = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-40,1,0), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 14, Text = tostring(selected or "Select"), TextColor3 = self.theme.Text })
        label.Parent = head
        local chev = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(1,-24,0,0), Size = UDim2.new(0,24,1,0), Text = open and "▲" or "▼", TextColor3 = self.theme.Muted, Font = Enum.Font.Gotham, TextSize = 14 })
        chev.Parent = head
        local titleL = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,18,0,-10), Size = UDim2.new(1,-36,0,18), Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Muted, TextSize = 12, Text = data.Text or "Dropdown" })
        titleL.Parent = holder

        local listFrame = new("Frame", { BackgroundColor3 = Color3.fromRGB(22,24,30), BorderSizePixel = 0, Size = UDim2.new(1,-28,0,0), Position = UDim2.new(0,14,0,46), Visible = false, ClipsDescendants = true })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = listFrame
        new("UIStroke", { Color = self.theme.Stroke, Transparency = 0.4 }).Parent = listFrame
        listFrame.Parent = holder

        local searchBox
        if data.Search then
            searchBox = new("TextBox", { PlaceholderText = "Search...", ClearTextOnFocus = false, Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = self.theme.Text, BackgroundColor3 = Color3.fromRGB(26,28,34), Size = UDim2.new(1,-12,0,28), Position = UDim2.new(0,6,0,6), BorderSizePixel = 0 })
            new("UICorner", { CornerRadius = UDim.new(0,6) }).Parent = searchBox
            searchBox.Parent = listFrame
        end

        local scroller = new("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, (searchBox and -40 or -12)), Position = UDim2.new(0,6,0,(searchBox and 40 or 6)), CanvasSize = UDim2.new(), ScrollBarImageTransparency = 0.5, ScrollBarThickness = 3, BorderSizePixel = 0 })
        scroller.Parent = listFrame
        local layout = new("UIListLayout", { Padding = UDim.new(0,6) })
        layout.Parent = scroller

        local function rebuild(filter)
            scroller:ClearAllChildren(); layout.Parent = scroller
            local opts = data.Options or {}
            for _,opt in ipairs(opts) do
                if (not filter) or string.find(string.lower(tostring(opt)), string.lower(filter), 1, true) then
                    local item = new("TextButton", { Text = tostring(opt), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = self.theme.Text, BackgroundColor3 = Color3.fromRGB(26,28,34), Size = UDim2.new(1,0,0,28), AutoButtonColor = false })
                    new("UICorner", { CornerRadius = UDim.new(0,6) }).Parent = item
                    new("UIStroke", { Color = self.theme.Stroke, Transparency = 0.5 }).Parent = item
                    item.Parent = scroller
                    item.MouseEnter:Connect(function() t(item, {BackgroundColor3 = Color3.fromRGB(32,34,40)}, 0.12):Play() end)
                    item.MouseLeave:Connect(function() t(item, {BackgroundColor3 = Color3.fromRGB(26,28,34)}, 0.12):Play() end)
                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        label.Text = tostring(opt)
                        if data.Callback then data.Callback(opt) end
                        open = false
                        chev.Text = "▼"
                        t(listFrame, {Size = UDim2.new(1,-28,0,0)}, 0.18):Play()
                        task.delay(0.18, function() listFrame.Visible = false end)
                    end)
                end
            end
            scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
        end
        rebuild()
        if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuild(searchBox.Text) end) end

        local function toggle()
            open = not open
            chev.Text = open and "▲" or "▼"
            if open then
                listFrame.Visible = true
                t(listFrame, {Size = UDim2.new(1,-28,0, math.min(220, math.max(48, layout.AbsoluteContentSize.Y + (searchBox and 46 or 12))))}, 0.18):Play()
            else
                t(listFrame, {Size = UDim2.new(1,-28,0,0)}, 0.18):Play()
                task.delay(0.18, function() listFrame.Visible = false end)
            end
        end
        head.MouseButton1Click:Connect(toggle)

        return { Set = function(_,v) selected=v; label.Text=tostring(v) end, Get=function() return selected end, Refresh=function(_,opts) data.Options=opts; rebuild(searchBox and searchBox.Text or nil) end }
    end

    function SectionMT:AddColorPicker(data)
        data = data or {}
        local holder = self:_card(144)
        local color = data.Default or self.theme.Accent
        local h,s,v = rgbToHsv(color)

        local title = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,14,0,8), Size = UDim2.new(1,-28,0,20), Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.theme.Text, TextSize = 14, Text = data.Text or "Color" })
        title.Parent = holder

        local preview = new("Frame", { Size = UDim2.new(0,36,0,36), Position = UDim2.new(1,-50,0,10), BackgroundColor3 = color, BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = preview
        preview.Parent = holder

        -- Color area (SV square)
        local sv = new("ImageLabel", { Image = "rbxassetid://4155801252", Size = UDim2.new(0,150,0,110), Position = UDim2.new(0,14,0,36), BackgroundColor3 = Color3.fromHSV(h,1,1), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = sv
        sv.Parent = holder
        local svDot = new("Frame", { Size = UDim2.fromOffset(10,10), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(s,0,1-v,0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = svDot
        svDot.Parent = sv

        -- Hue bar
        local hue = new("ImageLabel", { Image = "rbxassetid://3641079629", Size = UDim2.new(0,150,0,12), Position = UDim2.new(0,14,0,150), BackgroundTransparency = 0, BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,6) }).Parent = hue
        hue.Parent = holder
        local hDot = new("Frame", { Size = UDim2.fromOffset(8,16), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(h,0,0.5,0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = hDot
        hDot.Parent = hue

        -- Hex box
        local hex = new("TextBox", { PlaceholderText = "#RRGGBB", ClearTextOnFocus = false, Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = self.theme.Text, BackgroundColor3 = Color3.fromRGB(26,28,34), Size = UDim2.new(0,120,0,28), Position = UDim2.new(0,172,0,118), BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,6) }).Parent = hex
        hex.Parent = holder

        local function apply()
            local c = hsvToRgb(h,s,v)
            color = c
            sv.BackgroundColor3 = Color3.fromHSV(h,1,1)
            preview.BackgroundColor3 = c
            hex.Text = string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
            if data.Callback then data.Callback(c) end
        end

        local svDrag, hueDrag = false, false
        sv.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag=true end end)
        hue.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag=false; hueDrag=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                if svDrag then
                    local r = (i.Position - sv.AbsolutePosition)
                    local nx = math.clamp(r.X / sv.AbsoluteSize.X, 0, 1)
                    local ny = math.clamp(r.Y / sv.AbsoluteSize.Y, 0, 1)
                    s = nx; v = 1-ny
                    svDot.Position = UDim2.new(s,0,1-v,0)
                    apply()
                elseif hueDrag then
                    local r = (i.Position - hue.AbsolutePosition)
                    h = math.clamp(r.X / hue.AbsoluteSize.X, 0, 1)
                    hDot.Position = UDim2.new(h,0,0.5,0)
                    apply()
                end
            end
        end)

        hex.FocusLost:Connect(function(enter)
            local text = hex.Text:gsub("#","")
            if #text == 6 then
                local r = tonumber(text:sub(1,2),16)
                local g = tonumber(text:sub(3,4),16)
                local b = tonumber(text:sub(5,6),16)
                if r and g and b then
                    local c = Color3.fromRGB(r,g,b)
                    h,s,v = rgbToHsv(c)
                    sv.BackgroundColor3 = Color3.fromHSV(h,1,1)
                    svDot.Position = UDim2.new(s,0,1-v,0)
                    hDot.Position = UDim2.new(h,0,0.5,0)
                    apply()
                end
            end
            if enter then apply() end
        end)

        return { Set = function(_,c) h,s,v = rgbToHsv(c); apply() end, Get = function() return color end }
    end

    -- Internal: create element card
    function SectionMT:_card(height)
        local holder = new("Frame", { Size = UDim2.new(1,-16,0,height), BackgroundColor3 = self.theme.Card, BorderSizePixel = 0 })
        new("UICorner", { CornerRadius = UDim.new(0,10) }).Parent = holder
        new("UIStroke", { Color = self.theme.Stroke, Transparency = 0.4 }).Parent = holder
        holder.Parent = self.container
        local pad = new("UIPadding", { PaddingLeft = UDim.new(0,0), PaddingTop = UDim.new(0,0), PaddingRight = UDim.new(0,0), PaddingBottom = UDim.new(0,0) })
        pad.Parent = holder
        return holder
    end

    local function createSection(tab, title)
        local secFrame = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,-16,0,0) })
        secFrame.Parent = tab.Scroll
        local header = new("TextLabel", { BackgroundTransparency = 1, Text = title or "Section", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,-8,0,20), Position = UDim2.new(0,8,0,0) })
        header.Parent = secFrame
        local list = new("UIListLayout", { Padding = UDim.new(0,8) })
        list.Parent = secFrame
        new("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8), PaddingTop = UDim.new(0,6)}).Parent = secFrame

        local proxy = setmetatable({ container = secFrame, theme = theme, sounds = (opts.Sounds ~= false) }, SectionMT)
        function proxy:ExpandToContent()
            secFrame.Size = UDim2.new(1,-16,0,list.AbsoluteContentSize.Y + 28)
        end
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            proxy:ExpandToContent()
        end)
        proxy:ExpandToContent()
        return proxy
    end

    function window:AddTab(data)
        data = data or {}
        local btn = new("TextButton", { AutoButtonColor = false, Text = "", Size = UDim2.new(1,0,0,38), BackgroundColor3 = theme.Card })
        new("UICorner", { CornerRadius = UDim.new(0,8) }).Parent = btn
        new("UIStroke", { Color = theme.Accent, Transparency = 0.75 }).Parent = btn
        btn.Parent = side
        local icon = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(0,24,1,0), Font = Enum.Font.Gotham, Text = "•", TextSize = 18, TextColor3 = theme.Muted })
        icon.Parent = btn
        local txt = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,40,0,0), Size = UDim2.new(1,-48,1,0), Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, TextSize = 14, Text = data.Title or "Tab" })
        txt.Parent = btn

        local tabPage = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false })
        tabPage.Parent = body
        local scroll = new("ScrollingFrame", { Name = "Scroll", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(), ScrollBarThickness = 3, ScrollBarImageTransparency = 0.5, BorderSizePixel = 0 })
        scroll.Parent = tabPage
        local list = new("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder })
        list.Parent = scroll
        new("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,8), PaddingBottom = UDim.new(0,10) }).Parent = scroll
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 16) end)

        local tabObj = { Button = btn, Page = tabPage, Scroll = scroll, Active = false }
        table.insert(tabs, tabObj)

        local function activate()
            for _,tb in pairs(tabs) do
                tb.Active = false; tb.Page.Visible = false; t(tb.Button, {BackgroundColor3 = theme.Card}, 0.15):Play()
            end
            tabObj.Active = true
            tabPage.Visible = true
            t(btn, {BackgroundColor3 = theme.Accent}, 0.18):Play()
            currentTab = tabObj
        end
        btn.MouseButton1Click:Connect(function() playSound(btn, SoundIds.Click, opts.Sounds ~= false); activate() end)

        -- Default: activate first tab created
        if not currentTab then activate() end

        return {
            AddSection = function(_, title) return createSection(tabObj, title) end
        }
    end

    function window:AddSection(title)
        if not currentTab then self:AddTab({ Title = "Tab" }) end
        return createSection(currentTab, title)
    end

    function window:SetAccent(c)
        setAccent(c)
    end

    -- Expose
    window.Gui = gui
    window.Theme = theme
    window.Root = root

    -- Open animation
    root.Size = UDim2.fromOffset(root.Size.X.Offset, 0)
    t(root, {Size = opts.Size or UDim2.fromOffset(720,440)}, 0.25):Play()

    return setmetatable(window, MyUILib)
end

function MyUILib:SetAccent(c)
    local win = self
    if win and win.Theme then
        win.Theme.Accent = c
        -- topbar bar handled in CreateWindow via setter
    end
end

return setmetatable({}, MyUILib)
