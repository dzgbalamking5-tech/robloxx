-- =========================================================
-- PremiumLib.lua - OrionLib Remix Modern
-- =========================================================
-- Buat UI modern premium (Tabs, Buttons, Toggles, Sliders, Dropdowns, Labels, Keybinds)
-- =========================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PremiumLib = {}
PremiumLib.__index = PremiumLib

-- UI Theme
local theme = {
    bgColor = Color3.fromRGB(20,20,26),
    tabColor = Color3.fromRGB(30,30,36),
    accent = Color3.fromRGB(14,118,255),
    textColor = Color3.fromRGB(240,240,240),
    sectionColor = Color3.fromRGB(26,26,32)
}

-- Util
local function makeDraggable(frame)
    local dragging, dragInput, startPos, startInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input
            startPos = input.Position
            frame.Position = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - startPos
            frame.Position = frame.Position + UDim2.fromOffset(delta.X, delta.Y)
            startPos = input.Position
        end
    end)
end

-- Create Window
function PremiumLib:MakeWindow(opts)
    opts = opts or {}
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "PremiumLib"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 500, 0, 320)
    Main.Position = UDim2.new(0.5, -250, 0.5, -160)
    Main.BackgroundColor3 = theme.bgColor
    Main.BorderSizePixel = 0
    Main.Parent = gui
    makeDraggable(Main)

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0,10,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = opts.Title or "Premium Hub"
    Title.TextColor3 = theme.textColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(0,130,1,-40)
    TabHolder.Position = UDim2.new(0,0,0,40)
    TabHolder.BackgroundColor3 = theme.tabColor
    TabHolder.BorderSizePixel = 0
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0,12)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1,-150,1,-50)
    Content.Position = UDim2.new(0,140,0,40)
    Content.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0,5)

    local win = {}
    win.Tabs = {}
    win.Content = Content
    win.TabHolder = TabHolder
    win.Gui = gui
    setmetatable(win,self)

    return win
end

-- Make Tab
function PremiumLib:MakeTab(opts)
    local btn = Instance.new("TextButton", self.TabHolder)
    btn.Size = UDim2.new(1,-10,0,32)
    btn.BackgroundColor3 = theme.sectionColor
    btn.TextColor3 = theme.textColor
    btn.Text = opts.Name or "Tab"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local page = Instance.new("ScrollingFrame", self.Content)
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    Instance.new("UIListLayout", page).Padding = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        for _,tab in pairs(self.Content:GetChildren()) do
            if tab:IsA("ScrollingFrame") then tab.Visible = false end
        end
        page.Visible = true
    end)

    local tab = {}
    tab.Page = page
    tab.Button = btn

    function tab:AddLabel(txt)
        local lbl = Instance.new("TextLabel", page)
        lbl.Size = UDim2.new(1,-10,0,28)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt
        lbl.TextColor3 = theme.textColor
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        return lbl
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
        t.BackgroundColor3 = theme.sectionColor
        t.Text = (default and "[ON] " or "[OFF] ")..txt
        t.TextColor3 = theme.textColor
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        Instance.new("UICorner", t).CornerRadius = UDim.new(0,8)
        local state = default
        t.MouseButton1Click:Connect(function()
            state = not state
            t.Text = (state and "[ON] " or "[OFF] ")..txt
            callback(state)
        end)
        return t
    end

    function tab:AddSlider(txt,opts,callback)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1,-10,0,50)
        f.BackgroundColor3 = theme.sectionColor
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1,-10,0,20)
        lbl.Position = UDim2.new(0,5,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt..": "..opts.default
        lbl.TextColor3 = theme.textColor
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
            val = (val + 1 > opts.max) and opts.min or val+1
            lbl.Text = txt..": "..val
            callback(val)
        end)
    end

    function tab:AddDropdown(txt,list,callback)
        local dd = Instance.new("TextButton", page)
        dd.Size = UDim2.new(1,-10,0,32)
        dd.BackgroundColor3 = theme.sectionColor
        dd.Text = txt.." ▼"
        dd.TextColor3 = theme.textColor
        dd.Font = Enum.Font.GothamBold
        dd.TextSize = 14
        Instance.new("UICorner", dd).CornerRadius = UDim.new(0,8)

        local expanded = false
        local optsFrame
        dd.MouseButton1Click:Connect(function()
            if expanded then
                if optsFrame then optsFrame:Destroy() end
                expanded = false
            else
                optsFrame = Instance.new("Frame", page)
                optsFrame.Size = UDim2.new(1,-10,0,#list*28)
                optsFrame.BackgroundTransparency = 1
                for _,opt in pairs(list) do
                    local o = Instance.new("TextButton", optsFrame)
                    o.Size = UDim2.new(1,0,0,28)
                    o.Text = opt
                    o.BackgroundTransparency = 1
                    o.TextColor3 = theme.textColor
                    o.Font = Enum.Font.Gotham
                    o.TextSize = 14
                    o.MouseButton1Click:Connect(function()
                        callback(opt)
                        if optsFrame then optsFrame:Destroy() end
                        expanded=false
                    end)
                end
                expanded = true
            end
        end)
    end

    return tab
end

return PremiumLib
