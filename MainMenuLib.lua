-- uilibrarymain.lua
local UILib = {}
UILib.__index = UILib

function UILib:CreateWindow(options)
    local player = game.Players.LocalPlayer

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = options.Name or "CustomUILib"
    MainGui.Parent = player:WaitForChild("PlayerGui")

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 450, 0, 300)
    Window.Position = UDim2.new(0.5, -225, 0.5, -150)
    Window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Window.Parent = MainGui
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Text = options.Title or "Premium Hub"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Parent = Window

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = Window

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = content

    local self = setmetatable({
        Gui = MainGui,
        Window = Window,
        Content = content,
    }, UILib)

    return self
end

function UILib:AddToggle(options)
    local Btn = Instance.new("TextButton")
    Btn.Name = options.Name
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Text = (options.Text or "Toggle") .. " : OFF"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    Btn.Parent = self.Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = (options.Text or "Toggle") .. " : " .. (state and "ON" or "OFF")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0,180,90) or Color3.fromRGB(120,0,0)
        if options.Callback then
            options.Callback(state)
        end
    end)
end

function UILib:AddButton(options)
    local Btn = Instance.new("TextButton")
    Btn.Name = options.Name
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Text = options.Text or "Button"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(0,120,220)
    Btn.Parent = self.Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)
end

return UILib
