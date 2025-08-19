-- =====================================================
-- PremiumLib.lua v2 - Orion Remix Modern Premium
-- =====================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PremiumLib = {}
PremiumLib.__index = PremiumLib

local theme = {
    bg = Color3.fromRGB(20,20,26),
    tab = Color3.fromRGB(30,30,36),
    section = Color3.fromRGB(26,26,32),
    accent = Color3.fromRGB(14,118,255),
    text = Color3.fromRGB(240,240,240),
    shadow = Color3.fromRGB(0,0,0)
}

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

-- 🔥 Notification
function PremiumLib:Notify(title,msg,dur)
    local gui = player.PlayerGui:FindFirstChild("PremiumLib")
    if not gui then return end

    local notif = Instance.new("Frame", gui)
    notif.Size = UDim2.new(0,250,0,60)
    notif.Position = UDim2.new(1,-270,1,-100)
    notif.BackgroundColor3 = theme.tab
    notif.BackgroundTransparency = 0.1
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,10)
    notif.ClipsDescendants = true

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

    notif.Position = UDim2.new(1,0,1,-100)
    TweenService:Create(notif,TweenInfo.new(0.4),{Position=UDim2.new(1,-270,1,-100)}):Play()

    task.delay(dur or 3,function()
        TweenService:Create(notif,TweenInfo.new(0.4),{Position=UDim2.new(1,0,1,-100)}):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- Window
function PremiumLib:MakeWindow(opts)
    opts = opts or {}
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "PremiumLib"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.new(0,550,0,340)
    Main.Position = UDim2.new(0.5,-275,0.5,-170)
    Main.BackgroundColor3 = theme.bg
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
    TabHolder.Size = UDim2.new(0,140,1,-40)
    TabHolder.Position = UDim2.new(0,0,0,40)
    TabHolder.BackgroundColor3 = theme.tab
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0,12)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1,-150,1,-50)
    Content.Position = UDim2.new(0,150,0,40)
    Content.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0,4)

    local win = {Tabs = {}, Content = Content, TabHolder = TabHolder, Gui = gui}
    setmetatable(win,self)
    return win
end

-- Tab
function PremiumLib:MakeTab(opts)
    local btn = Instance.new("TextButton", self.TabHolder)
    btn.Size = UDim2.new(1,-10,0,30)
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

    -- Tab pertama auto aktif
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

    function tab:AddLabel(txt)
        local l = Instance.new("TextLabel", page)
        l.Size = UDim2.new(1,-10,0,22)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = theme.text
        l.Font = Enum.Font.Gotham
        l.TextSize = 14
        return l
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

    function tab:AddColorPicker(txt,default,callback)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1,-10,0,32)
        f.BackgroundColor3 = theme.section
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(0.6,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt
        lbl.TextColor3 = theme.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14

        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0.4,-4,1,-4)
        btn.Position = UDim2.new(0.6,2,0,2)
        btn.BackgroundColor3 = default or Color3.fromRGB(0,170,255)
        btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            local new = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
            btn.BackgroundColor3 = new
            callback(new)
        end)
    end

    function tab:AddKeybind(txt,key,callback)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(1,-10,0,32)
        b.BackgroundColor3 = theme.section
        b.TextColor3 = theme.text
        b.Text = txt.." ["..key.Name.."]"
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

        UserInputService.InputBegan:Connect(function(input,gpe)
            if not gpe and input.KeyCode == key then
                callback()
            end
        end)
    end

    function tab:AddSlider(txt,opts,callback)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1,-10,0,50)
        f.BackgroundColor3 = theme.section
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1,-10,0,20)
        lbl.Position = UDim2.new(0,5,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt..": "..opts.default
        lbl.TextColor3 = theme.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14

        local slider = Instance.new("TextButton", f)
        slider.Size = UDim2.new(1,-20,0,20)
        slider.Position = UDim2.new(0,10,0,25)
        slider.BackgroundColor3 = theme.accent
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0,6)
        slider.Text = ""

        local val = opts.default
        slider.MouseButton1Click:Connect(function()
            val = (val+1 > opts.max) and opts.min or val+1
            lbl.Text = txt..": "..val
            callback(val)
        end)
    end

    return tab
end

return PremiumLib
