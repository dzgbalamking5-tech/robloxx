-- MainUILib.lua (Premium Version)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MainUI = {}
MainUI.__index = MainUI

-- buat window utama
function MainUI:CreateWindow(titleText)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "MainMenuUI"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 520, 0, 360)
    Frame.Position = UDim2.new(0.5, -260, 0.5, -180)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = Gui

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 18)
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Thickness = 1.2
    stroke.Color = Color3.fromRGB(60,60,70)

    local shadow = Instance.new("ImageLabel")
    shadow.ZIndex = -1
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5,0,0.5,0)
    shadow.Size = UDim2.new(1,30,1,30)
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageTransparency = 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24,24,276,276)
    shadow.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 44)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = titleText or "🚀 Premium Menu"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    -- tab container
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 38)
    TabBar.Position = UDim2.new(0, 10, 0, 60)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Frame

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -20, 1, -110)
    PageContainer.Position = UDim2.new(0, 10, 0, 100)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Frame

    local ui = {
        Gui = Gui,
        Frame = Frame,
        TabBar = TabBar,
        PageContainer = PageContainer,
        Tabs = {},
        Theme = {Main=Color3.fromRGB(0,150,90)}
    }
    setmetatable(ui, MainUI)

    -- hotkey F4
    UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F4 then
            Frame.Visible = not Frame.Visible
        end
    end)

    return ui
end

function MainUI:AddTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Position = UDim2.new(#self.Tabs*0, #self.Tabs*125, 0, 0)
    btn.Text = (icon or "📂").." "..name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,48)
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = self.TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.ScrollBarThickness = 4
    page.Parent = self.PageContainer

    table.insert(self.Tabs,{Btn=btn,Page=page})

    btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(self.Tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(40,40,48)
        end
        page.Visible = true
        btn.BackgroundColor3 = self.Theme.Main
    end)

    if #self.Tabs==1 then
        page.Visible = true
        btn.BackgroundColor3 = self.Theme.Main
    end

    return page
end

function MainUI:AddToggle(page,text,default,callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,36)
    frame.BackgroundTransparency = 1
    frame.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.Text = text
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,70,0,28)
    btn.Position = UDim2.new(1,-80,0.5,-14)
    btn.Text = default and "ON" or "OFF"
    btn.BackgroundColor3 = default and Color3.fromRGB(0,180,90) or Color3.fromRGB(100,30,30)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0,180,90) or Color3.fromRGB(100,30,30)
        if callback then callback(state) end
    end)
end

return MainUI
