-- MainMenuLib_v5.lua
-- Premium Main Menu + PRO Color Picker (modern)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local MainMenu = {}
MainMenu.__index = MainMenu

-- Helper tween
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

-- Draggable
local function makeDraggable(frame, handle)
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

-- HSV to Color3
local function HSVtoColor3(h, s, v)
    local i = math.floor(h*6)
    local f = h*6 - i
    local p = v * (1 - s)
    local q = v * (1 - f*s)
    local t = v * (1 - (1-f)*s)
    local r,g,b
    if i % 6 == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    elseif i == 5 then r,g,b = v,p,q end
    return Color3.new(r,g,b)
end

-- Create Window
function MainMenu:Create(title)
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 420)
    frame.Position = UDim2.new(0.5, -300, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(80,80,100)

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 44)
    topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
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
    closeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
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
        tween(frame, {Position = UDim2.new(0.5, -300, 1.3, 0)}, 0.4)
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
        tween(b, {BackgroundColor3 = Color3.fromRGB(90, 150, 255)}, 0.12)
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

-- === PRO Color Picker ===
function MainMenu:AddColorPicker(defaultColor, callback)
    local cp = Instance.new("Frame")
    cp.Size = UDim2.new(1, 0, 0, 200)
    cp.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    cp.Parent = self.Container
    Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 12)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 60, 0, 60)
    preview.Position = UDim2.new(0, 10, 0, 10)
    preview.BackgroundColor3 = defaultColor or Color3.fromRGB(255,0,0)
    preview.Parent = cp
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)

    local hexBox = Instance.new("TextBox")
    hexBox.Size = UDim2.new(0, 100, 0, 28)
    hexBox.Position = UDim2.new(0, 80, 0, 26)
    hexBox.Text = "#FF0000"
    hexBox.TextColor3 = Color3.fromRGB(240,240,240)
    hexBox.BackgroundColor3 = Color3.fromRGB(25,25,32)
    hexBox.Font = Enum.Font.Gotham
    hexBox.TextSize = 14
    hexBox.Parent = cp
    Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)

    -- Gradient area (saturation/brightness)
    local satVal = Instance.new("ImageLabel")
    satVal.Size = UDim2.new(0, 140, 0, 140)
    satVal.Position = UDim2.new(0, 200, 0, 20)
    satVal.Image = "rbxassetid://4155801252" -- gradient square
    satVal.BackgroundColor3 = Color3.fromRGB(255,0,0)
    satVal.ScaleType = Enum.ScaleType.Stretch
    satVal.Parent = cp
    local svCursor = Instance.new("Frame", satVal)
    svCursor.Size = UDim2.new(0,8,0,8)
    svCursor.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1,0)

    -- Hue bar
    local hue = Instance.new("ImageLabel")
    hue.Size = UDim2.new(0, 20, 0, 140)
    hue.Position = UDim2.new(0, 350, 0, 20)
    hue.Image = "rbxassetid://3641079629" -- rainbow gradient
    hue.ScaleType = Enum.ScaleType.Stretch
    hue.Parent = cp
    local hueCursor = Instance.new("Frame", hue)
    hueCursor.Size = UDim2.new(1,0,0,2)
    hueCursor.BackgroundColor3 = Color3.new(1,1,1)

    local h,s,v = 0,1,1
    local function update()
        local col = HSVtoColor3(h,s,v)
        preview.BackgroundColor3 = col
        hexBox.Text = string.format("#%02X%02X%02X", col.R*255, col.G*255, col.B*255)
        satVal.BackgroundColor3 = HSVtoColor3(h,1,1)
        if callback then callback(col) end
    end
    update()

    -- Drag SV
    satVal.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local function move(input)
                local rel = (input.Position - satVal.AbsolutePosition)
                s = math.clamp(rel.X / satVal.AbsoluteSize.X,0,1)
                v = 1 - math.clamp(rel.Y / satVal.AbsoluteSize.Y,0,1)
                svCursor.Position = UDim2.new(s, -4, 1-v, -4)
                update()
            end
            move(i)
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    move(inp)
                end
            end)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then conn:Disconnect() end
            end)
        end
    end)

    -- Drag Hue
    hue.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local function move(input)
                local relY = (input.Position.Y - hue.AbsolutePosition.Y)
                h = math.clamp(relY / hue.AbsoluteSize.Y,0,1)
                hueCursor.Position = UDim2.new(0,0, h, -1)
                update()
            end
            move(i)
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    move(inp)
                end
            end)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then conn:Disconnect() end
            end)
        end
    end)

    -- Hex input
    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text:gsub("#","")
        if #txt==6 then
            local r=tonumber(txt:sub(1,2),16) or 0
            local g=tonumber(txt:sub(3,4),16) or 0
            local b=tonumber(txt:sub(5,6),16) or 0
            preview.BackgroundColor3 = Color3.fromRGB(r,g,b)
        end
    end)
end

return MainMenu
