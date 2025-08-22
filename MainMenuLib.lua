-- uilibrarymain.lua (Dark Premium Modern UI)
local UILib = {}
UILib.__index = UILib

local UIS = game:GetService("UserInputService")

-- Utility
local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function shadow(obj)
    local s = Instance.new("ImageLabel")
    s.ZIndex = obj.ZIndex - 1
    s.Image = "rbxassetid://5028857084"
    s.ImageTransparency = 0.4
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(24,24,276,276)
    s.Size = obj.Size + UDim2.new(0,20,0,20)
    s.Position = UDim2.new(0,-10,0,-10)
    s.BackgroundTransparency = 1
    s.Parent = obj
end

-- Create Window
function UILib:CreateWindow(options)
    local player = game.Players.LocalPlayer

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = options.Name or "UILibraryPremium"
    MainGui.Parent = player:WaitForChild("PlayerGui")

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 550, 0, 350)
    Window.Position = UDim2.new(0.5, -275, 0.5, -175)
    Window.BackgroundColor3 = Color3.fromRGB(20,20,30)
    Window.ZIndex = 5
    Window.Parent = MainGui
    round(Window, 12)
    shadow(Window)

    -- Titlebar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,45)
    TitleBar.Parent = Window
    round(TitleBar,12)

    local Title = Instance.new("TextLabel")
    Title.Text = options.Title or "🌙 Premium Hub"
    Title.Size = UDim2.new(1,-100,1,0)
    Title.Position = UDim2.new(0,15,0,0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Minimize & Close buttons (bundar)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,20,0,20)
    MinBtn.Position = UDim2.new(1,-55,0.5,-10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    MinBtn.Text = ""
    MinBtn.Parent = TitleBar
    round(MinBtn,10)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,20,0,20)
    CloseBtn.Position = UDim2.new(1,-30,0.5,-10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    CloseBtn.Text = ""
    CloseBtn.Parent = TitleBar
    round(CloseBtn,10)

    -- TabBar
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0,120,1,-40)
    TabBar.Position = UDim2.new(0,0,0,40)
    TabBar.BackgroundColor3 = Color3.fromRGB(35,35,50)
    TabBar.Parent = Window

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0,5)
    TabLayout.Parent = TabBar

    -- ContentFrame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1,-120,1,-40)
    ContentFrame.Position = UDim2.new(0,120,0,40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Window

    local tabs = {}

    local self = setmetatable({
        Gui = MainGui,
        Window = Window,
        Tabs = tabs,
        ContentFrame = ContentFrame,
        TabBar = TabBar
    }, UILib)

    -- Minimize
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ContentFrame.Visible = not minimized
        TabBar.Visible = not minimized
        Window.Size = minimized and UDim2.new(0,550,0,40) or UDim2.new(0,550,0,350)
    end)

    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        MainGui:Destroy()
    end)

    return self
end

-- Add Tab
function UILib:AddTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1,0,0,30)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TabBtn.BackgroundColor3 = Color3.fromRGB(60,60,85)
    TabBtn.Parent = self.TabBar
    round(TabBtn,6)

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1,0,1,0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 4
    TabPage.Visible = false
    TabPage.Parent = self.ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = TabPage

    self.Tabs[name] = TabPage

    TabBtn.MouseButton1Click:Connect(function()
        for _,tab in pairs(self.Tabs) do tab.Visible=false end
        TabPage.Visible=true
    end)

    if not self.ActiveTab then
        self.ActiveTab=TabPage
        TabPage.Visible=true
    end

    return TabPage
end

-- Components
function UILib:AddLabel(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,25)
    lbl.Text = text or "Label"
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.BackgroundTransparency = 1
    lbl.Parent = tab
end

function UILib:AddToggle(tab, options)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,-20,0,40)
    Btn.Text = (options.Text or "Toggle").." : OFF"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    Btn.Parent = tab
    round(Btn,8)

    local state=false
    Btn.MouseButton1Click:Connect(function()
        state=not state
        Btn.Text=(options.Text or "Toggle").." : "..(state and "ON" or "OFF")
        Btn.BackgroundColor3= state and Color3.fromRGB(0,180,120) or Color3.fromRGB(120,0,0)
        if options.Callback then options.Callback(state) end
    end)
end

function UILib:AddButton(tab, options)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,-20,0,40)
    Btn.Text = options.Text or "Button"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(0,120,220)
    Btn.Parent = tab
    round(Btn,8)

    Btn.MouseButton1Click:Connect(function()
        if options.Callback then options.Callback() end
    end)
end

function UILib:AddInput(tab, options)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1,-20,0,40)
    Box.PlaceholderText = options.Placeholder or "Type here..."
    Box.Text = ""
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.TextColor3 = Color3.fromRGB(255,255,255)
    Box.BackgroundColor3 = Color3.fromRGB(60,60,80)
    Box.Parent = tab
    round(Box,8)

    Box.FocusLost:Connect(function(enter)
        if enter and options.Callback then options.Callback(Box.Text) end
    end)
end

function UILib:AddDropdown(tab, options)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,-20,0,40)
    Btn.Text = options.Text or "Dropdown"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(80,80,100)
    Btn.Parent = tab
    round(Btn,8)

    local Open=false
    local ChoicesFrame=Instance.new("Frame")
    ChoicesFrame.Size=UDim2.new(1,-20,0,#options.Choices*35)
    ChoicesFrame.BackgroundColor3=Color3.fromRGB(50,50,70)
    ChoicesFrame.Visible=false
    ChoicesFrame.Parent=tab
    round(ChoicesFrame,8)

    local layout=Instance.new("UIListLayout")
    layout.Parent=ChoicesFrame

    for _,choice in ipairs(options.Choices or {}) do
        local cBtn=Instance.new("TextButton")
        cBtn.Size=UDim2.new(1,0,0,30)
        cBtn.Text=choice
        cBtn.BackgroundColor3=Color3.fromRGB(70,70,90)
        cBtn.TextColor3=Color3.fromRGB(255,255,255)
        cBtn.Font=Enum.Font.Gotham
        cBtn.TextSize=14
        cBtn.Parent=ChoicesFrame
        round(cBtn,6)
        cBtn.MouseButton1Click:Connect(function()
            Btn.Text=(options.Text or "Dropdown")..": "..choice
            ChoicesFrame.Visible=false
            Open=false
            if options.Callback then options.Callback(choice) end
        end)
    end

    Btn.MouseButton1Click:Connect(function()
        Open=not Open
        ChoicesFrame.Visible=Open
    end)
end

function UILib:AddSlider(tab, options)
    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.new(1,-20,0,50)
    Frame.BackgroundTransparency=1
    Frame.Parent=tab

    local Label=Instance.new("TextLabel")
    Label.Text=options.Text or "Slider"
    Label.Size=UDim2.new(1,-20,0,20)
    Label.BackgroundTransparency=1
    Label.Font=Enum.Font.GothamBold
    Label.TextSize=14
    Label.TextColor3=Color3.fromRGB(255,255,255)
    Label.Parent=Frame

    local SliderBack=Instance.new("Frame")
    SliderBack.Size=UDim2.new(1,-20,0,12)
    SliderBack.Position=UDim2.new(0,10,0,30)
    SliderBack.BackgroundColor3=Color3.fromRGB(70,70,90)
    SliderBack.Parent=Frame
    round(SliderBack,6)

    local Fill=Instance.new("Frame")
    Fill.Size=UDim2.new(0,0,1,0)
    Fill.BackgroundColor3=Color3.fromRGB(0,180,120)
    Fill.Parent=SliderBack
    round(Fill,6)

    local Value=Instance.new("TextLabel")
    Value.Text=tostring(options.Min or 0)
    Value.Size=UDim2.new(0,50,0,20)
    Value.Position=UDim2.new(1,-60,0,-5)
    Value.BackgroundTransparency=1
    Value.Font=Enum.Font.Gotham
    Value.TextSize=14
    Value.TextColor3=Color3.fromRGB(255,255,255)
    Value.Parent=Frame

    local dragging=false
    local min=options.Min or 0
    local max=options.Max or 100
    local current=min

    local function setValue(x)
        local percent=math.clamp((x-SliderBack.AbsolutePosition.X)/SliderBack.AbsoluteSize.X,0,1)
        current=math.floor(min+(max-min)*percent)
        Fill.Size=UDim2.new(percent,0,1,0)
        Value.Text=tostring(current)
        if options.Callback then options.Callback(current) end
    end

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            setValue(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            setValue(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)
end

return UILib
