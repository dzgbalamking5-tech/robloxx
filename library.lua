-- =====================================================
-- PremiumLib.lua v3 - Premium UI Library
-- Modern Glassmorphism + Real ColorPicker + Fixed Dropdown
-- =====================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PremiumLib = {}
PremiumLib.__index = PremiumLib

-- 🎨 Tema
local theme = {
    bg = Color3.fromRGB(25,25,32),
    tab = Color3.fromRGB(35,35,42),
    section = Color3.fromRGB(30,30,38),
    accent = Color3.fromRGB(0,170,255),
    text = Color3.fromRGB(240,240,240),
    shadow = Color3.fromRGB(0,0,0),
}

-- Draggable
local function makeDraggable(frame)
    local dragging, startPos, startInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input
            startPos = input.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            frame.Position = frame.Position + UDim2.fromOffset(delta.X, delta.Y)
            startPos = input.Position
        end
    end)
end

-- 🔔 Notification
function PremiumLib:Notify(title,msg,dur)
    local gui = player.PlayerGui:FindFirstChild("PremiumLib")
    if not gui then return end

    local notif = Instance.new("Frame", gui)
    notif.Size = UDim2.new(0,260,0,70)
    notif.Position = UDim2.new(1,300,1,-120)
    notif.BackgroundColor3 = theme.tab
    notif.BackgroundTransparency = 0.1
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,10)

    local lbl = Instance.new("TextLabel", notif)
    lbl.Size = UDim2.new(1,-10,1,-10)
    lbl.Position = UDim2.new(0,5,0,5)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = theme.text
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.Text = title.."\n"..msg

    TweenService:Create(notif,TweenInfo.new(0.4),{Position=UDim2.new(1,-270,1,-120)}):Play()
    task.delay(dur or 3,function()
        TweenService:Create(notif,TweenInfo.new(0.4),{Position=UDim2.new(1,300,1,-120)}):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- 🪟 Window
function PremiumLib:MakeWindow(opts)
    opts = opts or {}
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "PremiumLib"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.new(0,580,0,380)
    Main.Position = UDim2.new(0.5,-290,0.5,-190)
    Main.BackgroundColor3 = theme.bg
    Main.BackgroundTransparency = 0.1
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)
    makeDraggable(Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = (opts.Title or "Premium Hub").."  "..(opts.SubTitle or "")
    Title.TextColor3 = theme.text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(0,150,1,-40)
    TabHolder.Position = UDim2.new(0,0,0,40)
    TabHolder.BackgroundColor3 = theme.tab
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0,12)
    local tlist = Instance.new("UIListLayout", TabHolder)
    tlist.SortOrder = Enum.SortOrder.LayoutOrder
    tlist.Padding = UDim.new(0,4)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1,-160,1,-50)
    Content.Position = UDim2.new(0,160,0,40)
    Content.BackgroundTransparency = 1

    local win = {Tabs = {}, Content = Content, TabHolder = TabHolder, Gui = gui}
    setmetatable(win,self)
    return win
end

-- 📑 Tab
function PremiumLib:MakeTab(opts)
    local btn = Instance.new("TextButton", self.TabHolder)
    btn.Size = UDim2.new(1,-10,0,32)
    btn.BackgroundColor3 = theme.section
    btn.TextColor3 = theme.text
    btn.Text = opts.Name or "Tab"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local page = Instance.new("ScrollingFrame", self.Content)
    page.Size = UDim2.new(1,0,1,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 6
    page.BackgroundTransparency = 1
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,6)
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0,6)

    if #self.Tabs == 0 then
        page.Visible = true
    end

    btn.MouseButton1Click:Connect(function()
        for _,child in pairs(self.Content:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible=false end
        end
        page.Visible = true
    end)

    local tab = {Page=page,Button=btn}
    table.insert(self.Tabs, tab)

    -- === Elemen ===
    function tab:AddSection(txt)
        local s = Instance.new("TextLabel", page)
        s.Size = UDim2.new(1,-10,0,24)
        s.BackgroundTransparency = 1
        s.Text = "— "..txt.." —"
        s.Font = Enum.Font.GothamBold
        s.TextColor3 = theme.text
        s.TextSize = 14
    end

    function tab:AddButton(txt,callback)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(1,-10,0,32)
        b.BackgroundColor3 = theme.accent
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        b.MouseButton1Click:Connect(callback)
        return b
    end

    function tab:AddToggle(txt,default,callback)
        local t = Instance.new("TextButton", page)
        t.Size = UDim2.new(1,-10,0,32)
        t.BackgroundColor3 = theme.section
        t.TextColor3 = theme.text
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        Instance.new("UICorner", t).CornerRadius = UDim.new(0,8)
        local state = default
        t.Text = (state and "[ON] " or "[OFF] ")..txt
        t.MouseButton1Click:Connect(function()
            state = not state
            t.Text = (state and "[ON] " or "[OFF] ")..txt
            callback(state)
        end)
        return t
    end

    -- 📝 Textbox
    function tab:AddTextbox(txt,default,callback)
        local box = Instance.new("TextBox", page)
        box.Size = UDim2.new(1,-10,0,32)
        box.BackgroundColor3 = theme.section
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
        box.Text = default or ""
        box.PlaceholderText = txt
        box.TextColor3 = theme.text
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
        return box
    end

    -- 🎨 Real Color Picker
    function tab:AddColorPicker(txt,default,callback)
        local frame = Instance.new("Frame", page)
        frame.Size = UDim2.new(1,-10,0,180)
        frame.BackgroundColor3 = theme.section
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1,0,0,20)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt
        lbl.TextColor3 = theme.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14

        -- Preview
        local preview = Instance.new("Frame", frame)
        preview.Size = UDim2.new(0,50,0,50)
        preview.Position = UDim2.new(0,10,0,30)
        preview.BackgroundColor3 = default or Color3.new(1,1,1)
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0,6)

        -- HEX box
        local hex = Instance.new("TextBox", frame)
        hex.Size = UDim2.new(0,100,0,24)
        hex.Position = UDim2.new(0,70,0,35)
        hex.BackgroundColor3 = theme.bg
        hex.Text = string.format("#%02X%02X%02X",
            math.floor(preview.BackgroundColor3.R*255),
            math.floor(preview.BackgroundColor3.G*255),
            math.floor(preview.BackgroundColor3.B*255))
        hex.TextColor3 = theme.text
        hex.Font = Enum.Font.Gotham
        hex.TextSize = 14
        Instance.new("UICorner", hex).CornerRadius = UDim.new(0,6)

        -- Hue bar
        local hue = Instance.new("Frame", frame)
        hue.Size = UDim2.new(0,20,1,-40)
        hue.Position = UDim2.new(1,-30,0,30)
        local grad = Instance.new("UIGradient", hue)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
            ColorSequenceKeypoint.new(0.17,Color3.fromHSV(0.17,1,1)),
            ColorSequenceKeypoint.new(0.33,Color3.fromHSV(0.33,1,1)),
            ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),
            ColorSequenceKeypoint.new(0.67,Color3.fromHSV(0.67,1,1)),
            ColorSequenceKeypoint.new(0.83,Color3.fromHSV(0.83,1,1)),
            ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))
        }

        -- Simple: klik hue → ganti warna preview
        hue.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local relY = (input.Position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y
                local c = Color3.fromHSV(relY,1,1)
                preview.BackgroundColor3 = c
                hex.Text = string.format("#%02X%02X%02X",
                    math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
                callback(c)
            end
        end)
    end

    -- ⬇️ Dropdown fix
    function tab:AddDropdown(txt,list,callback)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1,-10,0,32)
        f.BackgroundColor3 = theme.section
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = txt.." ▼"
        btn.TextColor3 = theme.text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14

        local dropFrame = Instance.new("ScrollingFrame", f)
        dropFrame.Size = UDim2.new(1,0,0,0)
        dropFrame.Position = UDim2.new(0,0,1,0)
        dropFrame.CanvasSize = UDim2.new(0,0,0,0)
        dropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        dropFrame.ScrollBarThickness = 4
        dropFrame.BackgroundColor3 = theme.bg
        dropFrame.Visible = false
        local dlist = Instance.new("UIListLayout", dropFrame)
        dlist.Padding = UDim.new(0,2)

        for _,item in ipairs(list) do
            local it = Instance.new("TextButton", dropFrame)
            it.Size = UDim2.new(1,0,0,28)
            it.BackgroundColor3 = theme.section
            it.Text = item
            it.TextColor3 = theme.text
            it.Font = Enum.Font.Gotham
            it.TextSize = 14
            Instance.new("UICorner", it).CornerRadius = UDim.new(0,6)
            it.MouseButton1Click:Connect(function()
                btn.Text = txt..": "..item.." ▼"
                dropFrame.Visible = false
                callback(item)
            end)
        end

        btn.MouseButton1Click:Connect(function()
            dropFrame.Visible = not dropFrame.Visible
            dropFrame.Size = dropFrame.Visible and UDim2.new(1,0,0,150) or UDim2.new(1,0,0,0)
        end)
    end

    return tab
end

return PremiumLib
