-- MainMenuLib_v3.lua
-- Premium Main Menu (Modern + Draggable Custom + Animasi + Notifikasi)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MainMenu = {}
MainMenu.__index = MainMenu

-- === Helper Animasi ===
local function tween(obj, props, time, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.35, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- === Draggable Custom ===
local function makeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- === Create Main Window ===
function MainMenu:Create(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MainMenuUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 540, 0, 340)
    Frame.Position = UDim2.new(0.5, -270, 0.5, -170)
    Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    Shadow.Size = UDim2.new(1, 60, 1, 60)
    Shadow.BackgroundTransparency = 1
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = Frame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(36, 36, 46)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Frame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "⚡ Premium Main Menu"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
    CloseBtn.Text = "✖"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    -- Menu Container
    local MenuContainer = Instance.new("Frame")
    MenuContainer.Size = UDim2.new(1, -20, 1, -60)
    MenuContainer.Position = UDim2.new(0, 10, 0, 50)
    MenuContainer.BackgroundTransparency = 1
    MenuContainer.Parent = Frame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = MenuContainer

    -- Notifikasi Container
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 300, 1, 0)
    NotifContainer.Position = UDim2.new(1, -310, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui

    -- Setup draggable
    makeDraggable(Frame, TopBar)

    -- Event Close
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Frame, {Position = UDim2.new(0.5, -270, 1.2, 0)}, 0.45)
        task.delay(0.45, function() ScreenGui:Destroy() end)
    end)

    -- Animasi masuk
    Frame.Position = UDim2.new(0.5, -270, 1.2, 0)
    tween(Frame, {Position = UDim2.new(0.5, -270, 0.5, -170)}, 0.55)

    self.Gui = ScreenGui
    self.Frame = Frame
    self.MenuContainer = MenuContainer
    self.NotifContainer = NotifContainer

    return self
end

-- === Button ===
function MainMenu:AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = self.MenuContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        tween(btn, {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}, 0.15)
        task.delay(0.25, function()
            tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2)
        end)
    end)
end

-- === Label ===
function MainMenu:AddLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Parent = self.MenuContainer
end

-- === Notifikasi ===
function MainMenu:Notify(msg, color)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(1, 0, 0, 40)
    notif.BackgroundColor3 = color or Color3.fromRGB(45, 45, 55)
    notif.TextColor3 = Color3.fromRGB(240, 240, 240)
    notif.Text = msg
    notif.Font = Enum.Font.GothamSemibold
    notif.TextSize = 14
    notif.TextWrapped = true
    notif.Parent = self.NotifContainer
    notif.BackgroundTransparency = 0.1
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

    notif.Position = UDim2.new(1, 20, 0, 0)
    tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)

    task.delay(3, function()
        tween(notif, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.35, function() notif:Destroy() end)
    end)
end

return MainMenu
