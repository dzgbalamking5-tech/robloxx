-- PremiumLib.lua v2 — Orion-style Modern Remix
-- Anti-numpuk (UIListLayout + autosize), draggable, minimize, animasi halus,
-- elemen: Button, Toggle, Slider (draggable), Dropdown, Textbox, ColorPicker, Keybind, Label

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function tween(o, t, props, style, dir)
    return TweenService:Create(o, TweenInfo.new(t or .2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local Theme = {
    Bg         = Color3.fromRGB(18,18,24),
    Panel      = Color3.fromRGB(26,26,32),
    Panel2     = Color3.fromRGB(33,33,40),
    Stroke     = Color3.fromRGB(52,52,62),
    Accent     = Color3.fromRGB(14,118,255),
    Accent2    = Color3.fromRGB(0,190,120),
    Text       = Color3.fromRGB(240,240,240),
    TextDim    = Color3.fromRGB(190,190,200),
    Danger     = Color3.fromRGB(220,70,70),
    Shadow     = Color3.fromRGB(0,0,0)
}

local function corner(parent, r) local u=Instance.new("UICorner", parent); u.CornerRadius = UDim.new(0, r or 10); return u end
local function stroke(parent, th, c, a) local s=Instance.new("UIStroke", parent); s.Thickness=th or 1; s.Color=c or Theme.Stroke; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Transparency=a or .25; return s end
local function padding(parent, l,t,r,b) local p=Instance.new("UIPadding", parent); p.PaddingLeft=UDim.new(0,l or 10); p.PaddingRight=UDim.new(0,r or 10); p.PaddingTop=UDim.new(0,t or 10); p.PaddingBottom=UDim.new(0,b or 10); return p end

local function makeShadow(parent)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.Image = "rbxassetid://5028857084"
    s.ImageColor3 = Theme.Shadow
    s.ImageTransparency = 0.4
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(24,24,276,276)
    s.BackgroundTransparency = 1
    s.Size = UDim2.new(1, 36, 1, 36)
    s.Position = UDim2.new(0, -18, 0, -18)
    s.ZIndex = 0
    s.Parent = parent
    return s
end

local function makeDrag(handle, target)
    local dragging, start, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = i.Position
            startPos = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - start
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function autosize(scroll, list, pad)
    local function update()
        local h = list.AbsoluteContentSize.Y + (pad and (pad.PaddingTop.Offset + pad.PaddingBottom.Offset) or 0)
        scroll.CanvasSize = UDim2.new(0, 0, 0, h)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    scroll.ChildAdded:Connect(update)
    scroll.ChildRemoved:Connect(update)
    update()
end

local Lib = {}
Lib.__index = Lib

function Lib:MakeWindow(opt)
    opt = opt or {}
    local gui = Instance.new("ScreenGui")
    gui.Name = "PremiumLibV2"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local root = Instance.new("Frame")
    root.Size = UDim2.new(0, 640, 0, 380)
    root.Position = UDim2.new(.5, -320, .5, -190)
    root.BackgroundColor3 = Theme.Bg
    root.BorderSizePixel = 0
    root.Parent = gui
    root.ZIndex = 2
    corner(root, 14); stroke(root, 1.2)

    makeShadow(root)

    -- topbar
    local top = Instance.new("Frame", root)
    top.Size = UDim2.new(1, 0, 0, 44)
    top.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", top)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Theme.Text
    title.Text = (opt.Title or "Premium Hub") .. (opt.SubTitle and ("  ·  "..opt.SubTitle) or "")

    local btnClose = Instance.new("TextButton", top)
    btnClose.Size = UDim2.new(0, 36, 0, 28)
    btnClose.Position = UDim2.new(1, -44, 0, 8)
    btnClose.BackgroundColor3 = Theme.Panel
    btnClose.Text = "✕"
    btnClose.TextColor3 = Theme.Danger
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 16
    corner(btnClose, 8)
    stroke(btnClose, 1)

    local btnMin = Instance.new("TextButton", top)
    btnMin.Size = UDim2.new(0, 36, 0, 28)
    btnMin.Position = UDim2.new(1, -88, 0, 8)
    btnMin.BackgroundColor3 = Theme.Panel
    btnMin.Text = "—"
    btnMin.TextColor3 = Theme.Text
    btnMin.Font = Enum.Font.GothamBold
    btnMin.TextSize = 16
    corner(btnMin, 8)
    stroke(btnMin, 1)

    makeDrag(top, root)

    -- left tabs
    local tabs = Instance.new("Frame", root)
    tabs.Size = UDim2.new(0, 170, 1, -56)
    tabs.Position = UDim2.new(0, 12, 0, 52)
    tabs.BackgroundColor3 = Theme.Panel
    corner(tabs, 12)
    stroke(tabs, 1)

    local tabsList = Instance.new("UIListLayout", tabs)
    tabsList.Padding = UDim.new(0, 6)
    tabsList.SortOrder = Enum.SortOrder.LayoutOrder
    padding(tabs, 8, 10, 8, 10)

    -- content area
    local content = Instance.new("Frame", root)
    content.Size = UDim2.new(1, -206, 1, -56)
    content.Position = UDim2.new(0, 194, 0, 52)
    content.BackgroundColor3 = Theme.Panel2
    corner(content, 12)
    stroke(content, 1)

    local win = { _gui=gui, _root=root, _tabs=tabs, _content=content, _activePage=nil }
    setmetatable(win, self)

    -- anim datang
    root.Position = UDim2.new(.5, -320, 1.1, 0)
    tween(root, .45, {Position = UDim2.new(.5, -320, .5, -190)}):Play()

    btnClose.MouseButton1Click:Connect(function()
        tween(root, .35, {Position = UDim2.new(.5, -320, 1.2, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        task.delay(.36, function() gui:Destroy() end)
    end)
    btnMin.MouseButton1Click:Connect(function()
        if content.Visible then
            tween(root, .25, {Size = UDim2.new(0, 640, 0, 60)}):Play()
            content.Visible = false; tabs.Visible=false
        else
            tween(root, .25, {Size = UDim2.new(0, 640, 0, 380)}):Play()
            task.delay(.12, function() content.Visible = true; tabs.Visible = true end)
        end
    end)

    function win:Notify(text, t)
        t = t or 2.5
        local n = Instance.new("Frame", self._gui)
        n.Size = UDim2.new(0, 300, 0, 42)
        n.Position = UDim2.new(1, 320, 0, 80)
        n.BackgroundColor3 = Theme.Panel2
        n.BorderSizePixel = 0
        n.ZIndex = 10
        corner(n, 10); stroke(n, 1)

        local l = Instance.new("TextLabel", n)
        l.Size = UDim2.new(1, -16, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextColor3 = Theme.Text
        l.Text = text

        tween(n, .3, {Position = UDim2.new(1, -320, 0, 80)}):Play()
        task.delay(t, function()
            local tw = tween(n, .25, {Position = UDim2.new(1, 320, 0, 80)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tw.Completed:Connect(function() n:Destroy() end)
            tw:Play()
        end)
    end

    function win:MakeTab(o)
        o = o or {}
        local tabBtn = Instance.new("TextButton", tabs)
        tabBtn.Size = UDim2.new(1, 0, 0, 34)
        tabBtn.BackgroundColor3 = Theme.Panel2
        tabBtn.TextColor3 = Theme.Text
        tabBtn.AutoButtonColor = false
        tabBtn.Text = (o.Icon and (o.Icon.."  ") or "") .. (o.Name or "Tab")
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        corner(tabBtn, 10)
        stroke(tabBtn, 1)

        local page = Instance.new("ScrollingFrame", content)
        page.BackgroundTransparency = 1
        page.Size = UDim2.new(1, -20, 1, -20)
        page.Position = UDim2.new(0, 10, 0, 10)
        page.ScrollBarThickness = 4
        page.Visible = false

        local list = Instance.new("UIListLayout", page)
        list.Padding = UDim.new(0,8)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = padding(page, 8, 8, 8, 8)
        autosize(page, list, pad)

        local function setActive()
            for _,v in ipairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _,b in ipairs(tabs:GetChildren()) do
                if b:IsA("TextButton") then tween(b, .15, {BackgroundColor3 = Theme.Panel2}) end
            end
            page.Visible = true
            tween(tabBtn, .15, {BackgroundColor3 = Theme.Accent})
        end

        tabBtn.MouseEnter:Connect(function() tween(tabBtn, .12, {BackgroundColor3 = Theme.Panel}) end)
        tabBtn.MouseLeave:Connect(function()
            if page.Visible then
                tween(tabBtn, .12, {BackgroundColor3 = Theme.Accent})
            else
                tween(tabBtn, .12, {BackgroundColor3 = Theme.Panel2})
            end
        end)
        tabBtn.MouseButton1Click:Connect(setActive)

        if not self._activePage then setActive(); self._activePage = page end

        local tab = {}
        tab._page = page

        local function makeItemBase(h)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, h or 38)
            f.BackgroundColor3 = Theme.Panel
            f.BorderSizePixel = 0
            corner(f, 10); stroke(f, 1)
            f.Parent = page
            return f
        end

        function tab:AddSection(title)
            local s = makeItemBase(40)
            local t = Instance.new("TextLabel", s)
            t.BackgroundTransparency = 1
            t.Size = UDim2.new(1, -16, 1, 0)
            t.Position = UDim2.new(0, 8, 0, 0)
            t.Font = Enum.Font.GothamSemibold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextSize = 14
            t.TextColor3 = Theme.TextDim
            t.Text = title or "Section"
            return s
        end

        function tab:AddLabel(text)
            local s = makeItemBase(32)
            s.BackgroundTransparency = 1
            s.BorderSizePixel = 0
            local l = Instance.new("TextLabel", s)
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, -6, 1, 0)
            l.Position = UDim2.new(0, 6, 0, 0)
            l.Font = Enum.Font.Gotham
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextSize = 14
            l.TextColor3 = Theme.Text
            l.Text = text or ""
            return l
        end

        function tab:AddButton(text, callback)
            local b = makeItemBase(38)
            b.BackgroundColor3 = Theme.Accent
            local t = Instance.new("TextButton", b)
            t.BackgroundTransparency = 1
            t.Size = UDim2.new(1, 0, 1, 0)
            t.Text = text or "Button"
            t.TextColor3 = Color3.new(1,1,1)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 14
            t.AutoButtonColor = false
            t.MouseButton1Click:Connect(function() if callback then callback() end end)
            t.MouseEnter:Connect(function() tween(b, .07, {BackgroundColor3 = Theme.Accent:lerp(Color3.new(1,1,1), .06)}):Play() end)
            t.MouseLeave:Connect(function() tween(b, .15, {BackgroundColor3 = Theme.Accent}):Play() end)
            return t
        end

        function tab:AddToggle(text, default, callback)
            local f = makeItemBase(38)
            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 14
            lbl.TextColor3 = Theme.Text
            lbl.Text = text or "Toggle"

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(0, 46, 0, 22)
            btn.Position = UDim2.new(1, -58, .5, -11)
            btn.BackgroundColor3 = Theme.Panel2
            btn.AutoButtonColor = false
            corner(btn, 12); stroke(btn, 1)

            local dot = Instance.new("Frame", btn)
            dot.Size = UDim2.new(0, 18, 0, 18)
            dot.Position = UDim2.new(0, 2, .5, -9)
            dot.BackgroundColor3 = Theme.Stroke
            dot.BorderSizePixel = 0
            corner(dot, 9)

            local state = not not default
            local function set(v, fire)
                state = v
                tween(btn, .12, {BackgroundColor3 = v and Theme.Accent2 or Theme.Panel2}):Play()
                tween(dot, .12, {Position = v and UDim2.new(1, -20, .5, -9) or UDim2.new(0, 2, .5, -9), BackgroundColor3 = v and Color3.new(1,1,1) or Theme.Stroke}):Play()
                if fire and callback then callback(state) end
            end
            set(state, false)
            btn.MouseButton1Click:Connect(function() set(not state, true) end)

            return {
                Set = function(_, v) set(v, false) end,
                Get = function() return state end
            }
        end

        function tab:AddSlider(text, opts, callback)
            opts = opts or {min=0,max=100,default=0,prec=0}
            local f = makeItemBase(54)

            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -12, 0, 20)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Theme.Text
            lbl.Text = text or "Slider"

            local track = Instance.new("Frame", f)
            track.Size = UDim2.new(1, -24, 0, 10)
            track.Position = UDim2.new(0, 12, 1, -22)
            track.BackgroundColor3 = Theme.Panel2
            track.BorderSizePixel = 0
            corner(track, 6)

            local fill = Instance.new("Frame", track)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0
            corner(fill, 6)

            local val = opts.default or opts.min or 0
            local function apply(fire)
                local a = (val - opts.min) / (opts.max - opts.min)
                fill.Size = UDim2.new(math.clamp(a,0,1), 0, 1, 0)
                lbl.Text = string.format("%s: %s", text or "Slider", opts.prec and (("%."..opts.prec.."f"):format(val)) or tostring(math.floor(val)))
                if fire and callback then callback(val) end
            end

            local function setFromX(x, fire)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = opts.min + (opts.max - opts.min) * rel
                if not opts.prec or opts.prec == 0 then val = math.floor(val + .5) end
                apply(fire)
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    setFromX(i.Position.X, true)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    setFromX(i.Position.X, true)
                end
            end)

            apply(false)
            return {
                Set = function(_, v) val = math.clamp(v, opts.min, opts.max); apply(true) end,
                Get = function() return val end
            }
        end

        function tab:AddDropdown(text, list, callback)
            list = list or {}
            local f = makeItemBase(38)
            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 14
            lbl.TextColor3 = Theme.Text
            lbl.Text = text or "Dropdown"

            local dd = Instance.new("TextButton", f)
            dd.Size = UDim2.new(0, 36, 0, 24)
            dd.Position = UDim2.new(1, -48, .5, -12)
            dd.BackgroundColor3 = Theme.Panel2
            dd.Text = "▼"
            dd.TextColor3 = Theme.Text
            dd.Font = Enum.Font.GothamBold
            dd.TextSize = 14
            dd.AutoButtonColor = false
            corner(dd, 8); stroke(dd,1)

            local expanded = false
            local panel
            local function toggle()
                expanded = not expanded
                if expanded then
                    panel = Instance.new("Frame", page)
                    panel.BackgroundColor3 = Theme.Panel
                    panel.Size = UDim2.new(1, 0, 0, #list*30 + 10)
                    corner(panel, 10); stroke(panel,1)
                    padding(panel, 8,6,8,6)
                    panel.LayoutOrder = f.LayoutOrder + 1

                    local l = Instance.new("UIListLayout", panel)
                    l.Padding = UDim.new(0,6)
                    for _,opt in ipairs(list) do
                        local o = Instance.new("TextButton", panel)
                        o.Size = UDim2.new(1,0,0,26)
                        o.BackgroundColor3 = Theme.Panel2
                        o.TextColor3 = Theme.Text
                        o.Text = tostring(opt)
                        o.AutoButtonColor = false
                        o.Font = Enum.Font.Gotham
                        o.TextSize = 14
                        corner(o,8); stroke(o,1)
                        o.MouseButton1Click:Connect(function()
                            lbl.Text = (text or "Dropdown").." : "..tostring(opt)
                            if callback then callback(opt) end
                            toggle()
                        end)
                    end
                else
                    if panel then panel:Destroy() panel=nil end
                end
            end
            dd.MouseButton1Click:Connect(toggle)

            return {
                Set = function(_, items) list = items or {}; if panel then panel:Destroy(); panel=nil; expanded=false end end
            }
        end

        function tab:AddTextbox(text, default, callback)
            local f = makeItemBase(38)
            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.5, -12, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 14
            lbl.TextColor3 = Theme.Text
            lbl.Text = text or "Input"

            local tb = Instance.new("TextBox", f)
            tb.Size = UDim2.new(0.5, -16, 0, 26)
            tb.Position = UDim2.new(0.5, 4, .5, -13)
            tb.BackgroundColor3 = Theme.Panel2
            tb.PlaceholderText = ""
            tb.ClearTextOnFocus = false
            tb.Text = default or ""
            tb.TextColor3 = Theme.Text
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 14
            corner(tb, 8); stroke(tb,1)

            tb.FocusLost:Connect(function(enter)
                if callback and (enter or true) then callback(tb.Text) end
            end)
            return tb
        end

        function tab:AddColorPicker(text, default, callback)
            local f = makeItemBase(66)

            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -12, 0, 20)
            lbl.Position = UDim2.new(0, 12, 0, 8)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Theme.Text
            lbl.Text = text or "Color"

            local preview = Instance.new("Frame", f)
            preview.Size = UDim2.new(0, 36, 0, 20)
            preview.Position = UDim2.new(1, -48, 0, 8)
            preview.BackgroundColor3 = default or Theme.Accent
            corner(preview, 6); stroke(preview,1)

            local r = tab:AddSlider("R", {min=0,max=255,default=math.floor((default and default.R or Theme.Accent.R)*255)}, function() end)
            local g = tab:AddSlider("G", {min=0,max=255,default=math.floor((default and default.G or Theme.Accent.G)*255)}, function() end)
            local b = tab:AddSlider("B", {min=0,max=255,default=math.floor((default and default.B or Theme.Accent.B)*255)}, function() end)

            -- move the three sliders under this picker visually
            local baseIndex = f.LayoutOrder
            r = r; g = g; b = b -- keep refs
            -- grab their frames (last 3 children are those sliders' frames)
            local function lastFrames(n)
                local all = {}
                for _,c in ipairs(page:GetChildren()) do if c:IsA("Frame") and c ~= f then table.insert(all, c) end end
                table.sort(all, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
                local out = {}
                for i = #all, math.max(#all-n+1,1), -1 do table.insert(out, 1, all[i]) end
                return out
            end
            local frames = lastFrames(3)
            for i,fr in ipairs(frames) do
                fr.Parent = f
                fr.LayoutOrder = baseIndex + i
            end

            local function emit()
                local col = Color3.fromRGB(frames[1]:FindFirstChildOfClass("TextLabel").Text:match("(%d+)") or 0,
                                           frames[2]:FindFirstChildOfClass("TextLabel").Text:match("(%d+)") or 0,
                                           frames[3]:FindFirstChildOfClass("TextLabel").Text:match("(%d+)") or 0)
                preview.BackgroundColor3 = col
                if callback then callback(col) end
            end

            -- hook changes by scanning fill width (simple timer)
            task.spawn(function()
                while f.Parent do
                    emit()
                    task.wait(0.06)
                end
            end)

            return {
                Set = function(_, col)
                    preview.BackgroundColor3 = col
                end
            }
        end

        function tab:AddKeybind(text, defaultKey, callback)
            local f = makeItemBase(38)
            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -120, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 14
            lbl.TextColor3 = Theme.Text
            lbl.Text = text or "Keybind"

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(0, 90, 0, 24)
            btn.Position = UDim2.new(1, -102, .5, -12)
            btn.BackgroundColor3 = Theme.Panel2
            btn.TextColor3 = Theme.Text
            btn.Text = (defaultKey and defaultKey.Name) or "None"
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.AutoButtonColor = false
            corner(btn, 8); stroke(btn,1)

            local listening = false
            btn.MouseButton1Click:Connect(function()
                listening = true
                btn.Text = "Press..."
            end)
            UserInputService.InputBegan:Connect(function(i, gp)
                if gp then return end
                if listening and i.KeyCode ~= Enum.KeyCode.Unknown then
                    listening = false
                    btn.Text = i.KeyCode.Name
                    defaultKey = i.KeyCode
                end
                if defaultKey and i.KeyCode == defaultKey then
                    if callback then callback() end
                end
            end)

            return {
                Set = function(_, key) defaultKey = key; btn.Text = key and key.Name or "None" end,
                Get = function() return defaultKey end
            }
        end

        return tab
    end

    return win
end

return setmetatable({}, Lib)
