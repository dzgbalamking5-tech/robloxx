-- uilibrarymain.lua
local UILib = {}
UILib.__index = UILib

-- Utility buat bikin UI element dengan gaya premium
local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function padding(parent, px)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, px)
    p.PaddingRight = UDim.new(0, px)
    p.PaddingTop = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.Parent = parent
end

-- ===== Create Window =====
function UILib:CreateWindow(options)
    local player = game.Players.LocalPlayer

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = options.Name or "UILibraryPremium"
    MainGui.Parent = player:WaitForChild("PlayerGui")

    -- Main window
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 500, 0, 320)
    Window.Position = UDim2.new(0.5, -250, 0.5, -160)
    Window.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Window.Parent = MainGui
    round(Window, 12)

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    TitleBar.Parent = Window
    round(TitleBar, 12)

    local Title = Instance.new("TextLabel")
    Title.Text = options.Title or "🌟 Premium Hub"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "_"
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
    MinBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)
    MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.Parent = TitleBar
    round(MinBtn, 6)

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TitleBar
    round(CloseBtn, 6)

    -- Tab buttons area
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 120, 1, -40)
    TabBar.Position = UDim2.new(0, 0, 0, 40)
    TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TabBar.Parent = Window

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabBar

    -- Tab content area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -120, 1, -40)
    ContentFrame.Position = UDim2.new(0, 120, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Window

    local tabs = {}

    -- Window object
    local self = setmetatable({
        Gui = MainGui,
        Window = Window,
        Tabs = tabs,
        ContentFrame = ContentFrame
    }, UILib)

    -- Minimize logic
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ContentFrame.Visible = not minimized
        TabBar.Visible = not minimized
        Window.Size = minimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 320)
    end)

    -- Close logic
    CloseBtn.MouseButton1Click:Connect(function()
        MainGui:Destroy()
    end)

    return self
end

-- ===== Add Tab =====
function UILib:AddTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TabBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    TabBtn.Parent = self.Window.TabBar or self.Window:FindFirstChild("TabBar")
    round(TabBtn, 6)

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 4
    TabPage.Visible = false
    TabPage.Parent = self.ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = TabPage

    self.Tabs[name] = TabPage

    TabBtn.MouseButton1Click:Connect(function()
        for _,tab in pairs(self.Tabs) do
            tab.Visible = false
        end
        TabPage.Visible = true
    end)

    if not self.ActiveTab then
        self.ActiveTab = TabPage
        TabPage.Visible = true
    end

    return TabPage
end

-- ===== Components =====
function UILib:AddToggle(tab, options)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Text = (options.Text or "Toggle") .. " : OFF"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    Btn.Parent = tab
    round(Btn, 8)

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = (options.Text or "Toggle") .. " : " .. (state and "ON" or "OFF")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0,180,90) or Color3.fromRGB(120,0,0)
        if options.Callback then options.Callback(state) end
    end)
end

function UILib:AddButton(tab, options)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Text = options.Text or "Button"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(0,120,220)
    Btn.Parent = tab
    round(Btn, 8)

    Btn.MouseButton1Click:Connect(function()
        if options.Callback then options.Callback() end
    end)
end

function UILib:AddInput(tab, options)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 0, 40)
    Box.PlaceholderText = options.Placeholder or "Type here..."
    Box.Text = ""
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.TextColor3 = Color3.fromRGB(255,255,255)
    Box.BackgroundColor3 = Color3.fromRGB(60,60,80)
    Box.Parent = tab
    round(Box, 8)

    Box.FocusLost:Connect(function(enter)
        if enter and options.Callback then
            options.Callback(Box.Text)
        end
    end)
end

function UILib:AddDropdown(tab, options)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Text = options.Text or "Dropdown"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(80,80,100)
    Btn.Parent = tab
    round(Btn, 8)

    local Open = false
    local ChoicesFrame = Instance.new("Frame")
    ChoicesFrame.Size = UDim2.new(1, -20, 0, #options.Choices * 35)
    ChoicesFrame.BackgroundColor3 = Color3.fromRGB(50,50,70)
    ChoicesFrame.Visible = false
    ChoicesFrame.Parent = tab
    round(ChoicesFrame, 8)

    local layout = Instance.new("UIListLayout")
    layout.Parent = ChoicesFrame

    for _,choice in ipairs(options.Choices or {}) do
        local cBtn = Instance.new("TextButton")
        cBtn.Size = UDim2.new(1, 0, 0, 30)
        cBtn.Text = choice
        cBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)
        cBtn.TextColor3 = Color3.fromRGB(255,255,255)
        cBtn.Font = Enum.Font.Gotham
        cBtn.TextSize = 14
        cBtn.Parent = ChoicesFrame
        round(cBtn, 6)

        cBtn.MouseButton1Click:Connect(function()
            Btn.Text = (options.Text or "Dropdown")..": "..choice
            ChoicesFrame.Visible = false
            Open = false
            if options.Callback then options.Callback(choice) end
        end)
    end

    Btn.MouseButton1Click:Connect(function()
        Open = not Open
        ChoicesFrame.Visible = Open
    end)
end

return UILib
