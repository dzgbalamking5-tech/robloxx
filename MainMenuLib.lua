-- uilibrarymain.lua
-- Premium Dark Modern UI Library

local UILibrary = {}
UILibrary.__index = UILibrary

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Buat Window
function UILibrary:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Premium Hub"
    local subtitle = options.Subtitle or ""
    local size = options.Size or UDim2.new(0, 600, 0, 400)
    local position = options.Position or UDim2.new(0.5, 0, 0.5, 0) -- ✅ tengah otomatis

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumMainUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = position
    MainFrame.AnchorPoint = Vector2.new(0.5,0.5) -- ✅ pusat di tengah
    MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0,12)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.Size = UDim2.new(1,40,1,40)
    Shadow.Position = UDim2.new(0,-20,0,-20)
    Shadow.ZIndex = 0
    Shadow.BackgroundTransparency = 1
    Shadow.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1,0,0,40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,40)
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-100,1,0)
    TitleLabel.Position = UDim2.new(0,10,0,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title .. (subtitle ~= "" and (" - "..subtitle) or "")
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Minimize & Close
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
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1,0,1,-40)
    ContentFrame.Position = UDim2.new(0,0,0,40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    -- Sidebar untuk Tab
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0,150,1,0)
    TabBar.BackgroundColor3 = Color3.fromRGB(25,25,35)
    TabBar.Parent = ContentFrame

    local UIList = Instance.new("UIListLayout", TabBar)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0,5)

    local TabContent = Instance.new("Frame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1,-150,1,0)
    TabContent.Position = UDim2.new(0,150,0,0)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentFrame

    -- Dragging system
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Close & Minimize
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimized and UDim2.new(0,600,0,40) or size
        }):Play()
    end)

    local window = setmetatable({
        MainFrame = MainFrame,
        TabBar = TabBar,
        TabContent = TabContent,
        Tabs = {}
    }, UILibrary)

    return window
end

-- Tambah Tab
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
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = 4
    content.Visible = false
    content.Parent = self.TabContent

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0,8)

    button.MouseButton1Click:Connect(function()
        for _,tab in pairs(self.Tabs) do
            tab.Content.Visible = false
        end
        content.Visible = true
    end)

    table.insert(self.Tabs, {Button=button, Content=content})
    if #self.Tabs == 1 then content.Visible = true end

    return content
end

-- Tambah Komponen
function UILibrary:MakeToggle(tab, text, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1,-10,0,30)
    toggle.Text = "☐ "..text
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14
    toggle.BackgroundColor3 = Color3.fromRGB(40,40,50)
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Parent = tab

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = (state and "☑ " or "☐ ")..text
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

function UILibrary:MakeInput(tab, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-10,0,30)
    box.PlaceholderText = placeholder
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.BackgroundColor3 = Color3.fromRGB(40,40,55)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Parent = tab
    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)
end

function UILibrary:MakeDropdown(tab, text, options, callback)
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1,-10,0,30)
    dropdown.Text = text.." ▼"
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 14
    dropdown.BackgroundColor3 = Color3.fromRGB(45,45,60)
    dropdown.TextColor3 = Color3.fromRGB(255,255,255)
    dropdown.Parent = tab

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,#options*25)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,50)
    frame.Visible = false
    frame.Parent = tab

    local layout = Instance.new("UIListLayout", frame)

    for _,opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,25)
        btn.Text = opt
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
            dropdown.Text = text..": "..opt
            frame.Visible = false
            if callback then callback(opt) end
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end

function UILibrary:MakeSlider(tab, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1,-10,0,50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = text..": "..default
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = sliderFrame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,10)
    bar.Position = UDim2.new(0,0,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,80)
    bar.Parent = sliderFrame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(100,100,255)
    fill.Parent = bar

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(pos,0,1,0)
            local value = math.floor(min + (max-min)*pos)
            label.Text = text..": "..value
            if callback then callback(value) end
        end
    end)
end

return UILibrary
