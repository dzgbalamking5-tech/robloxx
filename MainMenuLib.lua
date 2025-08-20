-- MainMenuLib.lua
-- UI Library untuk Main Menu setelah verifikasi key
-- Gaya Premium + Modern

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu:Create(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MainMenuUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 500, 0, 300)
    Frame.Position = UDim2.new(0.5, -250, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", Frame).Thickness = 1.2

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = title or "⚡ Main Menu"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = Frame

    -- Container untuk tombol menu
    local MenuContainer = Instance.new("Frame")
    MenuContainer.Size = UDim2.new(1, -20, 1, -60)
    MenuContainer.Position = UDim2.new(0, 10, 0, 50)
    MenuContainer.BackgroundTransparency = 1
    MenuContainer.Parent = Frame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = MenuContainer

    self.Gui = ScreenGui
    self.Frame = Frame
    self.MenuContainer = MenuContainer
    return self
end

function MainMenu:AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.TextColor3 = Color3.fromRGB(230, 230, 236)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = self.MenuContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}):Play()
        task.delay(0.2, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 42)}):Play()
        end)
    end)
end

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

return MainMenu
