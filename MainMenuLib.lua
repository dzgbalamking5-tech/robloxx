-- MainMenuLib_v4.lua
-- Premium Main Menu + Color Picker (modern style)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local MainMenu = {}
MainMenu.__index = MainMenu

-- tween helper
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

-- draggable helper
local function makeDraggable(frame, handle)
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
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
            local delta = input.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- create main window
function MainMenu:Create(title)
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 580, 0, 380)
    frame.Position = UDim2.new(0.5, -290, 0.5, -190)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 44)
    topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    topbar.Parent = frame
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 16)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -100, 1, 0)
    titleLbl.Position = UDim2.new(0, 16, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "⚡ Premium Main Menu"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = topbar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
    closeBtn.Text = "✖"
    closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    closeBtn.Parent = topbar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -60)
    container.Position = UDim2.new(0, 10, 0, 54)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = container

    makeDraggable(frame, topbar)

    closeBtn.MouseButton1Click:Connect(function()
        tween(frame, {Position = UDim2.new(0.5, -290, 1.2, 0)}, 0.4)
        task.delay(0.4, function() gui:Destroy() end)
    end)

    self.Gui = gui
    self.Frame = frame
    self.Container = container
    return setmetatable(self, MainMenu)
end

function MainMenu:AddButton(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 44)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Parent = self.Container
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(function()
        if callback then callback() end
        tween(b, {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}, 0.12)
        task.delay(0.2, function() tween(b, {BackgroundColor3 = Color3.fromRGB(50, 50, 62)}, 0.18) end)
    end)
end

function MainMenu:AddLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 28)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.Parent = self.Container
end

-- === Color Picker ===
function MainMenu:AddColorPicker(defaultColor, callback)
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(1, 0, 0, 90)
    picker.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    picker.Parent = self.Container
    Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 10)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 80, 0, 60)
    preview.Position = UDim2.new(0, 10, 0.5, -30)
    preview.BackgroundColor3 = defaultColor or Color3.fromRGB(76,228,219)
    preview.Parent = picker
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)

    local hexBox = Instance.new("TextBox")
    hexBox.Size = UDim2.new(0, 120, 0, 32)
    hexBox.Position = UDim2.new(0, 100, 0.5, -16)
    hexBox.Text = string.format("#%02X%02X%02X", preview.BackgroundColor3.R*255, preview.BackgroundColor3.G*255, preview.BackgroundColor3.B*255)
    hexBox.PlaceholderText = "#HEX"
    hexBox.TextColor3 = Color3.fromRGB(230,230,230)
    hexBox.BackgroundColor3 = Color3.fromRGB(30,30,36)
    hexBox.Font = Enum.Font.Gotham
    hexBox.TextSize = 14
    hexBox.Parent = picker
    Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)

    local function updateColor(col)
        preview.BackgroundColor3 = col
        hexBox.Text = string.format("#%02X%02X%02X", col.R*255, col.G*255, col.B*255)
        if callback then callback(col) end
    end

    -- hex input
    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text:gsub("#","")
        if #txt == 6 then
            local r = tonumber(txt:sub(1,2),16) or 255
            local g = tonumber(txt:sub(3,4),16) or 255
            local b = tonumber(txt:sub(5,6),16) or 255
            updateColor(Color3.fromRGB(r,g,b))
        end
    end)

    return picker
end

return MainMenu
