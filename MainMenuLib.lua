-- ========= MainMenuLib_Inline (premium + draggable + minimize + notif) =========
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function tween(obj, props, t, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.35, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function makeDraggable(frame, handle)
    local dragging, startPos, startInputPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInputPos = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu:Create(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "PremiumMainMenu"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local root = Instance.new("Frame")
    root.Size = UDim2.new(0, 560, 0, 360)
    root.Position = UDim2.new(0.5, -280, 0.5, -180)
    root.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    root.BorderSizePixel = 0
    root.ClipsDescendants = true
    root.Active = true
    root.Parent = gui
    Instance.new("UICorner", root).CornerRadius = UDim.new(0, 16)

    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    shadow.Size = UDim2.new(1, 70, 1, 70)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.52
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 0
    shadow.Parent = root

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 44)
    top.BackgroundColor3 = Color3.fromRGB(36, 36, 46)
    top.BorderSizePixel = 0
    top.Parent = root
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 16)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -96, 1, 0)
    titleLbl.Position = UDim2.new(0, 16, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "⚡ Premium Main Menu"
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.TextSize = 18
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = top

    local btnMin = Instance.new("TextButton")
    btnMin.Size = UDim2.new(0, 32, 0, 32)
    btnMin.Position = UDim2.new(1, -76, 0.5, -16)
    btnMin.Text = "–"
    btnMin.Font = Enum.Font.GothamBold
    btnMin.TextSize = 18
    btnMin.TextColor3 = Color3.fromRGB(220,220,220)
    btnMin.BackgroundColor3 = Color3.fromRGB(50,50,56)
    btnMin.Parent = top
    Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 8)

    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(0, 32, 0, 32)
    btnClose.Position = UDim2.new(1, -40, 0.5, -16)
    btnClose.Text = "✖"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 16
    btnClose.TextColor3 = Color3.fromRGB(255, 90, 90)
    btnClose.BackgroundColor3 = Color3.fromRGB(50,50,56)
    btnClose.Parent = top
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 8)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -22, 1, -70)
    container.Position = UDim2.new(0, 11, 0, 54)
    container.BackgroundTransparency = 1
    container.Parent = root

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = container

    local notifHolder = Instance.new("Frame")
    notifHolder.Size = UDim2.new(0, 320, 1, 0)
    notifHolder.Position = UDim2.new(1, -330, 0, 10)
    notifHolder.BackgroundTransparency = 1
    notifHolder.Parent = gui

    -- floating dock (untuk restore saat minimize, cocok HP)
    local dock = Instance.new("TextButton")
    dock.Size = UDim2.new(0, 44, 0, 44)
    dock.Position = UDim2.new(0, 14, 1, -58)
    dock.Text = "⚡"
    dock.TextSize = 20
    dock.Font = Enum.Font.GothamBold
    dock.TextColor3 = Color3.fromRGB(255,255,255)
    dock.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    dock.Visible = false
    dock.AutoButtonColor = true
    dock.Parent = gui
    Instance.new("UICorner", dock).CornerRadius = UDim.new(1, 0)

    makeDraggable(root, top)

    -- show animation
    root.Position = UDim2.new(0.5, -280, 1.2, 0)
    tween(root, {Position = UDim2.new(0.5, -280, 0.5, -180)}, 0.5)

    btnClose.MouseButton1Click:Connect(function()
        tween(root, {Position = UDim2.new(0.5, -280, 1.2, 0)}, 0.45)
        task.delay(0.45, function() gui:Destroy() end)
    end)

    local minimized = false
    local function minimize()
        if minimized then return end
        minimized = true
        dock.Visible = true
        tween(root, {Size = UDim2.new(0, 560, 0, 0)}, 0.25)
        task.delay(0.25, function() root.Visible = false end)
    end
    local function restore()
        if not minimized then return end
        minimized = false
        root.Visible = true
        tween(root, {Size = UDim2.new(0, 560, 0, 360)}, 0.25)
        dock.Visible = false
    end

    btnMin.MouseButton1Click:Connect(minimize)
    dock.MouseButton1Click:Connect(restore)

    local self = setmetatable({}, MainMenu)
    self.Gui = gui
    self.Frame = root
    self.MenuContainer = container
    self.NotifContainer = notifHolder
    self.Minimize = minimize
    self.Restore = restore
    return self
end

function MainMenu:AddButton(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 46)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Parent = self.MenuContainer
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    b.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback)
        end
        tween(b, {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}, 0.12)
        task.delay(0.2, function()
            tween(b, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.18)
        end)
    end)
    return b
end

function MainMenu:AddLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 28)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.Parent = self.MenuContainer
    return l
end

function MainMenu:Notify(msg, color)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1, 0, 0, 42)
    n.BackgroundColor3 = color or Color3.fromRGB(45, 45, 55)
    n.TextColor3 = Color3.fromRGB(240, 240, 240)
    n.Text = msg
    n.Font = Enum.Font.GothamSemibold
    n.TextSize = 14
    n.TextWrapped = true
    n.BackgroundTransparency = 0.1
    n.Parent = self.NotifContainer
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)

    n.Position = UDim2.new(1, 20, 0, 0)
    tween(n, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    task.delay(3, function()
        tween(n, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.delay(0.27, function() n:Destroy() end)
    end)
end

return MainMenu
-- ============================ /MainMenuLib_Inline =============================
