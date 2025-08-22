-- uilibrarymain.lua (Dark Premium Full Modern UI)
local UILib = {}
UILib.__index = UILib

-- Helper untuk rounded corners
local function round(obj, radius)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, radius)
    uic.Parent = obj
end

-- Buat window utama
function UILib:CreateWindow(options)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = options.Name or "PremiumMainUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 500, 0, 300)
    Frame.Position = UDim2.new(0.5, -250, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    round(Frame, 12)

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    TitleBar.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = options.Title or "Premium Hub"
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 14
    Title.Parent = TitleBar

    -- Minimize & Close button (bundar)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -25, 0.5, -10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseBtn.Text = ""
    CloseBtn.Parent = TitleBar
    round(CloseBtn, 10)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Position = UDim2.new(1, -50, 0.5, -10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    MinBtn.Text = ""
    MinBtn.Parent = TitleBar
    round(MinBtn, 10)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 120, 1, -30)
    TabBar.Position = UDim2.new(0, 0, 0, 30)
    TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBar.Parent = Frame

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -120, 1, -30)
    Content.Position = UDim2.new(0, 120, 0, 30)
    Content.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Content.Parent = Frame
    round(Content, 8)

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = TabBar

    local window = setmetatable({
        Frame = Frame,
        Content = Content,
        Tabs = {},
        CurrentTab = nil
    }, UILib)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Content.Visible = not minimized
    end)

    return window
end

-- Add Tab
function UILib:AddTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = Color3.fromRGB(35,35,50)
    TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 14
    TabBtn.Parent = self.Frame:FindFirstChild("Frame") or self.Frame:FindFirstChild("TabBar") or self.Frame

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1,0,1,0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 4
    TabContent.Visible = false
    TabContent.Parent = self.Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,6)
    Layout.Parent = TabContent

    self.Tabs[name] = TabContent

    TabBtn.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            self.CurrentTab.Visible = false
        end
        TabContent.Visible = true
        self.CurrentTab = TabContent
    end)

    if not self.CurrentTab then
        self.CurrentTab = TabContent
        TabContent.Visible = true
    end

    return TabContent
end

-- Components
function UILib:AddLabel(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1,-20,0,30)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Parent = tab
    return lbl
end

function UILib:AddToggle(tab, options)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Text = "□ "..options.Text
    btn.BackgroundColor3 = Color3.fromRGB(45,45,65)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = tab
    round(btn,6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "☑ " or "□ ")..options.Text
        if options.Callback then options.Callback(state) end
    end)
    return btn
end

function UILib:AddButton(tab, options)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Text = options.Text
    btn.BackgroundColor3 = Color3.fromRGB(60,60,90)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = tab
    round(btn,6)

    btn.MouseButton1Click:Connect(function()
        if options.Callback then options.Callback() end
    end)
    return btn
end

function UILib:AddInput(tab, options)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-20,0,30)
    box.PlaceholderText = options.Placeholder or ""
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(40,40,60)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.Parent = tab
    round(box,6)

    box.FocusLost:Connect(function()
        if options.Callback then options.Callback(box.Text) end
    end)
    return box
end

function UILib:AddDropdown(tab, options)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Text = options.Text or "Dropdown"
    btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = tab
    round(btn,6)

    local choices = options.Choices or {}
    local open = false

    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            for _,choice in ipairs(choices) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1,-40,0,25)
                opt.Text = choice
                opt.BackgroundColor3 = Color3.fromRGB(35,35,55)
                opt.TextColor3 = Color3.fromRGB(255,255,255)
                opt.Font = Enum.Font.Gotham
                opt.TextSize = 13
                opt.Parent = tab
                round(opt,4)

                opt.MouseButton1Click:Connect(function()
                    btn.Text = choice
                    if options.Callback then options.Callback(choice) end
                    for _,c in ipairs(tab:GetChildren()) do
                        if c ~= btn and c:IsA("TextButton") and c.Size.Y.Offset==25 then
                            c:Destroy()
                        end
                    end
                    open = false
                end)
            end
        else
            for _,c in ipairs(tab:GetChildren()) do
                if c ~= btn and c:IsA("TextButton") and c.Size.Y.Offset==25 then
                    c:Destroy()
                end
            end
        end
    end)
    return btn
end

function UILib:AddSlider(tab, options)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,-20,0,40)
    Frame.BackgroundTransparency = 1
    Frame.Parent = tab

    local label = Instance.new("TextLabel")
    label.Text = options.Text or "Slider"
    label.Size = UDim2.new(1,0,0,15)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Parent = Frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,10)
    bar.Position = UDim2.new(0,0,0,20)
    bar.BackgroundColor3 = Color3.fromRGB(50,50,70)
    bar.Parent = Frame
    round(bar,5)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(100,100,220)
    fill.Parent = bar
    round(fill,5)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor((options.Min or 0) + rel * ((options.Max or 100)-(options.Min or 0)))
            if options.Callback then options.Callback(val) end
        end
    end)

    return Frame
end

return UILib
