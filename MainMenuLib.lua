-- MainMenuLib_v2.lua
-- Premium Main Menu Library (Modern + Draggable + Animasi + Notifikasi)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MainMenu = {}
MainMenu.__index = MainMenu

-- === Helper Animasi ===
local function tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.35, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

-- === Create Main Window ===
function MainMenu:Create(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MainMenuUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 520, 0, 320)
    Frame.Position = UDim2.new(0.5, -260, 0.5, -160)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true -- draggable UI
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", Frame).Thickness = 1.4

    -- Title bar
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = title or "⚡ Premium Main Menu"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = Frame

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.Text = "✖"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = Frame
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    -- Container Menu
    local MenuContainer = Instance.new("Frame")
    MenuContainer.Size = UDim2.new(1, -20, 1, -70)
    MenuContainer.Position = UDim2.new(0, 10, 0, 55)
    MenuContainer.BackgroundTransparency = 1
    MenuContainer.Parent = Frame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
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

    self.Gui = ScreenGui
    self.Frame = Frame
    self.MenuContainer = MenuContainer
    self.CloseBtn = CloseBtn
    self.NotifContainer = NotifContainer

    -- Event close
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Frame, {Position = UDim2.new(0.5, -260, 1.2, 0)}, 0.4)
        task.delay(0.4, function() ScreenGui:Destroy() end)
    end)

    -- Animasi masuk
    Frame.Position = UDim2.new(0.5, -260, 1.2, 0)
    tween(Frame, {Position = UDim2.new(0.5, -260, 0.5, -160)}, 0.5)

    return self
end

-- === Button ===
function MainMenu:AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.TextColor3 = Color3.fromRGB(230, 230, 236)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = self.MenuContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        tween(btn, {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}, 0.15)
        task.delay(0.2, function()
            tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 42)}, 0.15)
        end)
    end)
end

-- === Label ===
function MainMenu:AddLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 30)
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
    notif.BackgroundColor3 = color or Color3.fromRGB(40, 40, 46)
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
