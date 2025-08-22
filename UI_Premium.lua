-- UI_Premium.lua — Rayfield-like Lightweight Library (no deps)
-- Fitur: Window, Tab, Section, Toggle, Button, Dropdown, Slider, Keybind, ColorPicker, Notif, Config (save/load/refresh/delete)
-- Dibuat untuk exploit env (tersedia: readfile, writefile, listfiles, isfolder, makefolder)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===== Utils =====
local function tween(o, t, props, style, dir)
    TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function ensureFolder(path)
    if not isfolder or not makefolder then return end
    local parts = string.split(path, "/")
    local cur = ""
    for _, p in ipairs(parts) do
        cur = (cur == "") and p or (cur.."/"..p)
        if not isfolder(cur) then
            makefolder(cur)
        end
    end
end

local function safeRead(path, defaultTbl)
    if not readfile then return defaultTbl end
    local ok, data = pcall(readfile, path)
    if not ok or not data or data == "" then return defaultTbl end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(data) end)
    if ok2 then return decoded else return defaultTbl end
end

local function safeWrite(path, tbl)
    if not writefile then return false end
    local ok, str = pcall(function() return HttpService:JSONEncode(tbl) end)
    if not ok then return false end
    local ok2 = pcall(writefile, path, str)
    return ok2 and true or false
end

local function map(x, inMin, inMax, outMin, outMax)
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

-- ===== Notif System =====
local function createNotifier(root)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "PremiumNotifier"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = root

    local function notify(text, color)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 280, 0, 50)
        f.Position = UDim2.new(1, 300, 0, 40)
        f.BackgroundColor3 = color or Color3.fromRGB(34, 34, 40)
        f.BorderSizePixel = 0
        f.BackgroundTransparency = 0.05
        f.Parent = Gui
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", f)
        stroke.Thickness = 1

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, -20, 1, 0)
        t.Position = UDim2.new(0, 10, 0, 0)
        t.Text = tostring(text)
        t.Font = Enum.Font.GothamSemibold
        t.TextColor3 = Color3.fromRGB(240,240,240)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextSize = 14
        t.Parent = f

        tween(f, 0.3, {Position = UDim2.new(1, -300, 0, 40)})
        task.delay(2.5, function()
            local tw = TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 300, 0, 40),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Once(function() f:Destroy() end)
        end)
    end

    return notify
end

-- ===== Library Core =====
local Library = {}
Library.__index = Library

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Library)

    -- Root GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumHub"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = PlayerGui

    -- Main Window
    local Main = Instance.new("Frame")
    Main.Name = "Window"
    Main.Size = UDim2.new(0, 560, 0, 360)
    Main.Position = UDim2.new(0.5, -280, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 42)
    Top.BackgroundColor3 = Color3.fromRGB(30,30,36)
    Top.BorderSizePixel = 0
    Top.Parent = Main
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.AnchorPoint = Vector2.new(0, 0.5)
    Title.Position = UDim2.new(0, 14, 0.5, 0)
    Title.Size = UDim2.new(1, -28, 0, 24)
    Title.BackgroundTransparency = 1
    Title.Text = cfg.Name or "🌟 Premium Hub"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top

    local HideHint = Instance.new("TextLabel")
    HideHint.AnchorPoint = Vector2.new(1, 0.5)
    HideHint.Position = UDim2.new(1, -12, 0.5, 0)
    HideHint.Size = UDim2.new(0, 180, 0, 20)
    HideHint.BackgroundTransparency = 1
    HideHint.Text = "Toggle: "..(cfg.Keybind and tostring(cfg.Keybind.Name) or "RightControl")
    HideHint.Font = Enum.Font.Gotham
    HideHint.TextSize = 13
    HideHint.TextColor3 = Color3.fromRGB(190,190,200)
    HideHint.TextXAlignment = Enum.TextXAlignment.Right
    HideHint.Parent = Top

    local LeftTabs = Instance.new("Frame")
    LeftTabs.Size = UDim2.new(0, 150, 1, -42)
    LeftTabs.Position = UDim2.new(0, 0, 0, 42)
    LeftTabs.BackgroundColor3 = Color3.fromRGB(28,28,34)
    LeftTabs.BorderSizePixel = 0
    LeftTabs.Parent = Main

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -150, 1, -52)
    Content.Position = UDim2.new(0, 150, 0, 52)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = Content

    local notify = createNotifier(ScreenGui)

    -- Show/Hide keybind
    local toggleKey = cfg.Keybind or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == toggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- Drag window
    do
        local dragging, dragStart, startPos
        Top.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = i.Position
                startPos = Main.Position
            end
        end)
        Top.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- Tab API
    self.__tabs = {}
    local selectedPage

    local function select(page)
        for _, pg in ipairs(Pages:GetChildren()) do
            pg.Visible = false
        end
        if page then page.Visible = true end
        selectedPage = page
    end

    function self:CreateTab(tabName, iconId)
        local TabObj = {}

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,46)
        btn.BorderSizePixel = 0
        btn.Text = (iconId and ("   <image>  ") or "") .. tabName
        btn.AutoButtonColor = true
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(230,230,230)
        btn.Parent = LeftTabs

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.BorderSizePixel = 0
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 5
        page.Visible = false
        page.Parent = Pages

        local UIList = Instance.new("UIListLayout", page)
        UIList.Padding = UDim.new(0, 8)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder

        btn.MouseButton1Click:Connect(function()
            select(page)
        end)

        -- First tab autoselect
        if not selectedPage then select(page) end

        function TabObj:CreateSection(secName)
            local Section = {}

            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -10, 0, 34)
            holder.BackgroundColor3 = Color3.fromRGB(35,35,40)
            holder.BorderSizePixel = 0
            holder.Parent = page
            Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

            local title = Instance.new("TextLabel")
            title.BackgroundTransparency = 1
            title.Position = UDim2.new(0, 10, 0, 0)
            title.Size = UDim2.new(1, -20, 1, 0)
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14
            title.Text = secName
            title.TextColor3 = Color3.fromRGB(200,200,210)
            title.Parent = holder

            -- container for controls
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -10, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = page

            local list = Instance.new("UIListLayout", container)
            list.Padding = UDim.new(0, 6)
            list.SortOrder = Enum.SortOrder.LayoutOrder

            local function controlBase(height)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -10, 0, height or 38)
                f.BackgroundColor3 = Color3.fromRGB(40,40,46)
                f.BorderSizePixel = 0
                f.Parent = container
                Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
                return f
            end

            local function updateCanvas()
                task.defer(function()
                    page.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 8)
                end)
            end
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
            updateCanvas()

            function Section:CreateToggle(name, default, callback, flag)
                local f = controlBase()
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.Size = UDim2.new(1, -100, 1, 0)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(230,230,236)
                lbl.Text = name
                lbl.Parent = f

                local btn = Instance.new("TextButton")
                btn.AnchorPoint = Vector2.new(1, 0.5)
                btn.Position = UDim2.new(1, -12, 0.5, 0)
                btn.Size = UDim2.new(0, 80, 0, 26)
                btn.Text = default and "ON" or "OFF"
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.BackgroundColor3 = default and Color3.fromRGB(0,180,100) or Color3.fromRGB(180,60,60)
                btn.Parent = f
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

                local state = default and true or false
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.Text = state and "ON" or "OFF"
                    tween(btn, 0.15, {BackgroundColor3 = state and Color3.fromRGB(0,180,100) or Color3.fromRGB(180,60,60)})
                    if callback then callback(state) end
                end)

                return {
                    Get = function() return state end,
                    Set = function(v)
                        state = not not v
                        btn.Text = state and "ON" or "OFF"
                        btn.BackgroundColor3 = state and Color3.fromRGB(0,180,100) or Color3.fromRGB(180,60,60)
                        if callback then callback(state) end
                    end,
                    Flag = flag or name
                }
            end

            function Section:CreateButton(name, callback)
                local f = controlBase()
                local btn = Instance.new("TextButton")
                btn.Position = UDim2.new(0, 8, 0, 6)
                btn.Size = UDim2.new(1, -16, 1, -12)
                btn.Text = name
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.BackgroundColor3 = Color3.fromRGB(60,120,220)
                btn.AutoButtonColor = true
                btn.Parent = f
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                return {}
            end

            function Section:CreateDropdown(name, options, default, callback, flag)
                options = options or {}
                default = default or (options[1] or "")
                local f = controlBase(70)

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, 12, 0, 6)
                lbl.Size = UDim2.new(1, -24, 0, 18)
                lbl.Text = name
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(230,230,236)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f

                local box = Instance.new("TextButton")
                box.Position = UDim2.new(0, 12, 0, 28)
                box.Size = UDim2.new(1, -24, 0, 28)
                box.Text = "▼ "..tostring(default)
                box.Font = Enum.Font.GothamBold
                box.TextSize = 14
                box.TextColor3 = Color3.fromRGB(255,255,255)
                box.BackgroundColor3 = Color3.fromRGB(55,55,65)
                box.Parent = f
                Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

                local chosen = default
                box.MouseButton1Click:Connect(function()
                    -- simple popup menu
                    local menu = Instance.new("Frame")
                    menu.Size = UDim2.new(1, -24, 0, math.clamp(#options*28 + 10, 38, 180))
                    menu.Position = UDim2.new(0, 12, 0, 60)
                    menu.BackgroundColor3 = Color3.fromRGB(40,40,46)
                    menu.BorderSizePixel = 0
                    menu.Parent = f
                    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
                    local l = Instance.new("UIListLayout", menu)
                    l.Padding = UDim.new(0, 4)
                    l.SortOrder = Enum.SortOrder.LayoutOrder

                    local function closeMenu()
                        if menu then menu:Destroy() end
                    end

                    for _, opt in ipairs(options) do
                        local b = Instance.new("TextButton")
                        b.Size = UDim2.new(1, -10, 0, 24)
                        b.Position = UDim2.new(0, 5, 0, 0)
                        b.BackgroundColor3 = Color3.fromRGB(55,55,65)
                        b.TextColor3 = Color3.fromRGB(255,255,255)
                        b.Font = Enum.Font.Gotham
                        b.TextSize = 13
                        b.Text = tostring(opt)
                        b.Parent = menu
                        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                        b.MouseButton1Click:Connect(function()
                            chosen = opt
                            box.Text = "✔ "..tostring(opt)
                            if callback then callback(opt) end
                            closeMenu()
                        end)
                    end

                    -- click outside to close
                    task.spawn(function()
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(i, g)
                            if g then return end
                            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                                closeMenu()
                                if conn then conn:Disconnect() end
                            end
                        end)
                    end)
                end)

                return {
                    Get = function() return chosen end,
                    Set = function(v)
                        chosen = v
                        box.Text = "✔ "..tostring(v)
                        if callback then callback(v) end
                    end,
                    Flag = flag or name
                }
            end

            function Section:CreateSlider(name, min, max, default, callback, flag, increment)
                min, max = min or 0, max or 100
                default = math.clamp(default or min, min, max)
                increment = increment or 1

                local f = controlBase(64)

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, 12, 0, 6)
                lbl.Size = UDim2.new(1, -24, 0, 18)
                lbl.Text = string.format("%s (%d - %d)", name, min, max)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(230,230,236)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f

                local bar = Instance.new("Frame")
                bar.Position = UDim2.new(0, 12, 0, 32)
                bar.Size = UDim2.new(1, -90, 0, 8)
                bar.BackgroundColor3 = Color3.fromRGB(55,55,65)
                bar.BorderSizePixel = 0
                bar.Parent = f
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(map(default, min, max, 0, 1), 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(60, 160, 240)
                fill.BorderSizePixel = 0
                fill.Parent = bar
                Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

                local val = Instance.new("TextLabel")
                val.AnchorPoint = Vector2.new(1, 0)
                val.Position = UDim2.new(1, -12, 0, 24)
                val.Size = UDim2.new(0, 60, 0, 24)
                val.BackgroundColor3 = Color3.fromRGB(50,50,58)
                val.Text = tostring(default)
                val.Font = Enum.Font.GothamBold
                val.TextSize = 14
                val.TextColor3 = Color3.fromRGB(255,255,255)
                val.Parent = f
                Instance.new("UICorner", val).CornerRadius = UDim.new(0, 6)

                local value = default
                local function setFromX(x)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local raw = min + (max - min) * rel
                    local stepped = math.floor((raw + increment * 0.5) / increment) * increment
                    value = math.clamp(stepped, min, max)
                    fill.Size = UDim2.new(map(value, min, max, 0, 1), 0, 1, 0)
                    val.Text = tostring(value)
                    if callback then callback(value) end
                end

                bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        setFromX(i.Position.X)
                    end
                end)
                bar.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        setFromX(i.Position.X)
                    end
                end)

                return {
                    Get = function() return value end,
                    Set = function(v)
                        value = math.clamp(v, min, max)
                        fill.Size = UDim2.new(map(value, min, max, 0, 1), 0, 1, 0)
                        val.Text = tostring(value)
                        if callback then callback(value) end
                    end,
                    Flag = flag or name
                }
            end

            function Section:CreateKeybind(name, defaultKeyCode, callback, flag)
                local f = controlBase()
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.Size = UDim2.new(1, -120, 1, 0)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(230,230,236)
                lbl.Text = name
                lbl.Parent = f

                local btn = Instance.new("TextButton")
                btn.AnchorPoint = Vector2.new(1, 0.5)
                btn.Position = UDim2.new(1, -12, 0.5, 0)
                btn.Size = UDim2.new(0, 120, 0, 26)
                btn.Text = (defaultKeyCode and defaultKeyCode.Name) or "Not Set"
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.BackgroundColor3 = Color3.fromRGB(55,55,65)
                btn.Parent = f
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

                local current = defaultKeyCode
                btn.MouseButton1Click:Connect(function()
                    btn.Text = "Press a key..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(i, gpe)
                        if gpe then return end
                        if i.KeyCode ~= Enum.KeyCode.Unknown then
                            current = i.KeyCode
                            btn.Text = current.Name
                            if callback then callback(current) end
                            conn:Disconnect()
                        end
                    end)
                end)

                return {
                    Get = function() return current end,
                    Set = function(kc)
                        current = kc
                        btn.Text = kc and kc.Name or "Not Set"
                        if kc and callback then callback(kc) end
                    end,
                    Flag = flag or name
                }
            end

            function Section:CreateColorPicker(name, defaultColor3, callback, flag)
                local f = controlBase(96)

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, 12, 0, 6)
                lbl.Size = UDim2.new(1, -24, 0, 18)
                lbl.Text = name
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(230,230,236)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f

                local preview = Instance.new("Frame")
                preview.Position = UDim2.new(1, -60, 0, 6)
                preview.Size = UDim2.new(0, 48, 0, 48)
                preview.BackgroundColor3 = defaultColor3 or Color3.fromRGB(255, 0, 0)
                preview.Parent = f
                Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", preview).Thickness = 1

                local function sliderLine(y, label)
                    local t = Instance.new("TextLabel")
                    t.BackgroundTransparency = 1
                    t.Position = UDim2.new(0, 12, 0, y - 4)
                    t.Size = UDim2.new(0, 16, 0, 16)
                    t.Text = label
                    t.Font = Enum.Font.Gotham
                    t.TextSize = 12
                    t.TextColor3 = Color3.fromRGB(200,200,210)
                    t.TextXAlignment = Enum.TextXAlignment.Left
                    t.Parent = f

                    local bar = Instance.new("Frame")
                    bar.Position = UDim2.new(0, 32, 0, y)
                    bar.Size = UDim2.new(1, -120, 0, 8)
                    bar.BackgroundColor3 = Color3.fromRGB(55,55,65)
                    bar.BorderSizePixel = 0
                    bar.Parent = f
                    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

                    local fill = Instance.new("Frame")
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(90, 90, 180)
                    fill.BorderSizePixel = 0
                    fill.Parent = bar
                    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

                    return bar, fill
                end

                local rBar, rFill = sliderLine(32, "R")
                local gBar, gFill = sliderLine(50, "G")
                local bBar, bFill = sliderLine(68, "B")

                local col = defaultColor3 or Color3.fromRGB(255, 0, 0)
                local r, g, b = math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255)

                local function update()
                    preview.BackgroundColor3 = Color3.fromRGB(r,g,b)
                    rFill.Size = UDim2.new(r/255, 0, 1, 0)
                    gFill.Size = UDim2.new(g/255, 0, 1, 0)
                    bFill.Size = UDim2.new(b/255, 0, 1, 0)
                    if callback then callback(preview.BackgroundColor3) end
                end
                update()

                local function bind(bar, which)
                    local function setFromX(x)
                        local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                        local v = math.floor(rel*255 + 0.5)
                        if which == "r" then r = v elseif which == "g" then g = v else b = v end
                        update()
                    end
                    bar.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then setFromX(i.Position.X) end
                    end)
                    bar.InputChanged:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            setFromX(i.Position.X)
                        end
                    end)
                end
                bind(rBar, "r"); bind(gBar, "g"); bind(bBar, "b")

                return {
                    Get = function() return Color3.fromRGB(r,g,b) end,
                    Set = function(c3)
                        r = math.floor(c3.R*255); g = math.floor(c3.G*255); b = math.floor(c3.B*255)
                        update()
                    end,
                    Flag = flag or name
                }
            end

            return Section
        end

        return TabObj
    end

    -- ===== Config System =====
    self.ConfigFolder = (cfg.ConfigFolder or "FlowHub").."/configs"
    ensureFolder(self.ConfigFolder)
    self.Flags = {}  -- map flag -> getter/setter

    function self:RegisterFlag(flagName, getter, setter)
        self.Flags[flagName] = {get = getter, set = setter}
    end

    function self:SaveConfig(name)
        if not name or name == "" then notify("Nama config kosong.", Color3.fromRGB(200,70,70)); return end
        local data = {}
        for flag, fn in pairs(self.Flags) do
            local ok, v = pcall(fn.get)
            if ok then data[flag] = v end
        end
        local path = self.ConfigFolder.."/"..name..".json"
        local ok = safeWrite(path, data)
        if ok then notify("Config tersimpan: "..name, Color3.fromRGB(0,160,100)) else notify("Gagal simpan config.", Color3.fromRGB(200,70,70)) end
    end

    function self:LoadConfig(name)
        if not name or name == "" then notify("Pilih nama config.", Color3.fromRGB(200,70,70)); return end
        local path = self.ConfigFolder.."/"..name..".json"
        local data = safeRead(path, nil)
        if not data then notify("Config tidak ditemukan.", Color3.fromRGB(200,70,70)); return end
        for flag, val in pairs(data) do
            local entry = self.Flags[flag]
            if entry and entry.set then
                pcall(entry.set, val)
            end
        end
        notify("Config diload: "..name, Color3.fromRGB(60,140,240))
    end

    function self:DeleteConfig(name)
        if not name or name == "" then notify("Pilih nama config.", Color3.fromRGB(200,70,70)); return end
        local path = self.ConfigFolder.."/"..name..".json"
        if delfile then
            local ok = pcall(delfile, path)
            notify(ok and ("Config dihapus: "..name) or "Gagal hapus config.", ok and Color3.fromRGB(200,100,60) or Color3.fromRGB(200,70,70))
        else
            notify("delfile() tidak tersedia di executor.", Color3.fromRGB(200,70,70))
        end
    end

    function self:ListConfigs()
        if not listfiles then return {} end
        local files = listfiles(self.ConfigFolder)
        local names = {}
        for _, p in ipairs(files) do
            local n = p:match("([^/\\]+)%.json$")
            if n then table.insert(names, n) end
        end
        table.sort(names)
        return names
    end

    -- Built-in "Config" tab UI
    local cfgTab = self:CreateTab("Config")
    do
        local sec = cfgTab:CreateSection("Manage Config")

        -- Name Input (simple)
        local nameBoxFrame = Instance.new("Frame")
        nameBoxFrame.Size = UDim2.new(1, -10, 0, 38)
        nameBoxFrame.BackgroundColor3 = Color3.fromRGB(40,40,46)
        nameBoxFrame.BorderSizePixel = 0
        nameBoxFrame.Parent = Content.Pages:GetChildren()[#Content.Pages:GetChildren()] -- current page (Config)
        Instance.new("UICorner", nameBoxFrame).CornerRadius = UDim.new(0, 8)

        local nameBox = Instance.new("TextBox")
        nameBox.BackgroundColor3 = Color3.fromRGB(55,55,65)
        nameBox.Position = UDim2.new(0, 12, 0, 6)
        nameBox.Size = UDim2.new(1, -24, 1, -12)
        nameBox.PlaceholderText = "Nama Config..."
        nameBox.Text = ""
        nameBox.TextColor3 = Color3.fromRGB(255,255,255)
        nameBox.Font = Enum.Font.Gotham
        nameBox.TextSize = 14
        nameBox.Parent = nameBoxFrame
        Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)

        -- Buttons row
        local function makeBtn(text)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 38)
            f.BackgroundColor3 = Color3.fromRGB(40,40,46)
            f.BorderSizePixel = 0
            f.Parent = nameBoxFrame.Parent
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

            local b = Instance.new("TextButton")
            b.Position = UDim2.new(0, 8, 0, 6)
            b.Size = UDim2.new(1, -16, 1, -12)
            b.Text = text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.TextColor3 = Color3.fromRGB(255,255,255)
            b.BackgroundColor3 = Color3.fromRGB(60,120,220)
            b.Parent = f
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end

        local btnSave = makeBtn("💾 Save Config")
        btnSave.MouseButton1Click:Connect(function() self:SaveConfig(nameBox.Text) end)

        local btnLoad = makeBtn("📂 Load Config (dari dropdown di bawah)")
        local btnRefresh = makeBtn("🔄 Refresh Daftar Config")
        local btnDelete = makeBtn("🗑️ Delete Config (dari dropdown di bawah)")

        -- Dropdown daftar config
        local dropSec = cfgTab:CreateSection("Daftar Config")
        local cfgList = self:ListConfigs()
        local chosenName = cfgList[1]

        local dd = dropSec:CreateDropdown("Configs", cfgList, chosenName, function(v)
            chosenName = v
        end)

        btnRefresh.MouseButton1Click:Connect(function()
            local list = self:ListConfigs()
            dd.Set(list[1] or "")
            notify("Daftar config di-refresh.", Color3.fromRGB(80,160,220))
        end)

        btnLoad.MouseButton1Click:Connect(function()
            self:LoadConfig(chosenName)
        end)

        btnDelete.MouseButton1Click:Connect(function()
            self:DeleteConfig(chosenName)
            task.wait(0.1)
            local list = self:ListConfigs()
            dd.Set(list[1] or "")
        end)
    end

    -- Public
    self.Gui = ScreenGui
    self.Main = Main
    self.Notify = notify

    return self
end

-- Utility to auto-register flags when control creators return objects with Get/Set/Flag
function Library:AutoRegister(window, controlObj)
    if controlObj and controlObj.Flag then
        window:RegisterFlag(controlObj.Flag, controlObj.Get, controlObj.Set)
    end
    return controlObj
end

return Library
