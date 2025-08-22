-- uilibrarymain.lua
-- Premium Dark Modern UI Library (Full Redesign)

local UILibrary = {}
UILibrary.__index = UILibrary

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ===== Utility =====
local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ===== Notifications =====
local function createNotify(msg)
    local gui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PremiumMainUI")
    if not gui then return end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 40)
    NotifFrame.Position = UDim2.new(1, -260, 1, -60)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.BackgroundTransparency = 0
    NotifFrame.Parent = gui

    local UICorner = Instance.new("UICorner", NotifFrame)
    UICorner.CornerRadius = UDim.new(0,8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,-10,1,0)
    Label.Position = UDim2.new(0,5,0,0)
    Label.BackgroundTransparency = 1
    Label.Text = msg
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = NotifFrame

    tween(NotifFrame, {Position = UDim2.new(1,-260,1,-110)}, 0.3)
    task.delay(3, function()
        tween(NotifFrame, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        NotifFrame:Destroy()
    end)
end

-- ===== Create Window =====
function UILibrary:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Premium Hub"
    local subtitle = options.Subtitle or "Dark Edition"
    local size = options.Size or UDim2.new(0, 600, 0, 400)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumMainUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = size
    MainFrame.Position = UDim2.new(0.5,0,0.5,0)
    MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,40)
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-100,1,0)
    TitleLabel.Position = UDim2.new(0,10,0,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title.." - "..subtitle
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Close & Minimize
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,30,0,30)
    MinBtn.Position = UDim2.new(1,-70,0,5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "–"
    MinBtn.TextSize = 22
    MinBtn.TextColor3 = Color3.fromRGB(200,200,200)
    MinBtn.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,30,0,30)
    CloseBtn.Position = UDim2.new(1,-35,0,5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextSize = 20
    CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
    CloseBtn.Parent = TitleBar

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1,0,1,-40)
    ContentFrame.Position = UDim2.new(0,0,0,40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    -- Sidebar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0,150,1,0)
    TabBar.BackgroundColor3 = Color3.fromRGB(25,25,35)
    TabBar.Parent = ContentFrame
    Instance.new("UIListLayout", TabBar).Padding = UDim.new(0,5)

    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1,-150,1,0)
    TabContent.Position = UDim2.new(0,150,0,0)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentFrame

    -- Dragging
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Close & Minimize
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.new(0,600,0,40)}, 0.3)
    end)

    local window = setmetatable({
        MainFrame = MainFrame,
        TabBar = TabBar,
        TabContent = TabContent,
        Tabs = {}
    }, UILibrary)

    -- Toggle hotkey
    UserInputService.InputBegan:Connect(function(input,gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    return window
end

-- ===== Tab =====
function UILibrary:AddTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,35)
    button.Text = name
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.BackgroundColor3 = Color3.fromRGB(35,35,45)
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Parent = self.TabBar

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.Visible = false
    content.Parent = self.TabContent
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    button.MouseButton1Click:Connect(function()
        for _,tab in pairs(self.Tabs) do tab.Content.Visible = false end
        content.Visible = true
    end)

    table.insert(self.Tabs, {Button=button, Content=content})
    if #self.Tabs == 1 then content.Visible = true end

    return content
end

-- ===== Components =====
function UILibrary:MakeToggle(tab, text, callback, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = (default and "☑ " or "☐ ")..text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = tab

    local state = default or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "☑ " or "☐ ")..text
        if callback then callback(state) end
    end)
end

function UILibrary:MakeButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = tab
    btn.MouseButton1Click:Connect(callback)
end

function UILibrary:MakeInput(tab, placeholder, callback, default)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-10,0,30)
    box.PlaceholderText = placeholder
    box.Text = default or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.BackgroundColor3 = Color3.fromRGB(40,40,55)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Parent = tab
    box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
end

function UILibrary:MakeDropdown(tab, text, options, callback, default)
    local dd = Instance.new("TextButton")
    dd.Size = UDim2.new(1,-10,0,30)
    dd.Text = text.." ▼"
    dd.Font = Enum.Font.Gotham
    dd.TextSize = 14
    dd.BackgroundColor3 = Color3.fromRGB(45,45,60)
    dd.TextColor3 = Color3.fromRGB(255,255,255)
    dd.Parent = tab

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,#options*25)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,50)
    frame.Visible = false
    frame.Parent = tab
    Instance.new("UIListLayout", frame)

    for _,opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,25)
        b.Text = opt
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.BackgroundColor3 = Color3.fromRGB(50,50,70)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Parent = frame
        b.MouseButton1Click:Connect(function()
            dd.Text = text..": "..opt
            frame.Visible = false
            if callback then callback(opt) end
        end)
        if default and default == opt then
            dd.Text = text..": "..opt
        end
    end

    dd.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
end

function UILibrary:MakeSlider(tab, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,50)
    frame.BackgroundTransparency = 1
    frame.Parent = tab

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = text..": "..default
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,10)
    bar.Position = UDim2.new(0,0,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,80)
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(100,100,255)
    fill.Parent = bar

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(pos,0,1,0)
            local value = math.floor(min+(max-min)*pos)
            label.Text = text..": "..value
            if callback then callback(value) end
        end
    end)
end

-- Section
function UILibrary:Section(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,25)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200,200,255)
    lbl.Parent = tab
end

-- Notify
function UILibrary:Notify(msg) createNotify(msg) end

return UILibrary
