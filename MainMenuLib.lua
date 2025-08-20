-- PremiumUI_v6.lua  |  Modern Tabbed UI + Draggable + Notif + Full ColorPicker
-- by u/ad  (free to use)
-- API:
--   local UI = PremiumUI:CreateWindow("Title")
--   local Tab = UI:AddTab("Main")  -> returns tab object
--   section = Tab:AddSection("Controls") -- optional section title
--   section:AddToggle({text="Auto Farm", default=false}, function(v) end)
--   section:AddButton({text="Do Something"}, function() end)
--   section:AddSlider({text="Radius", min=0, max=100, step=1, default=50}, function(v) end)
--   section:AddDropdown({text="Mode", options={"A","B"}, default="A"}, function(v) end)
--   section:AddTextbox({text="Webhook"}, function(txt) end)
--   section:AddKeybind({text="Start/Stop", default=Enum.KeyCode.G}, function(key) end)
--   section:AddColorPicker({text="Theme", default=Color3.fromRGB(76,228,219)}, function(c) end)
--   UI:Notify("Halo!", 3)  -- text, duration

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local PremiumUI = {}
PremiumUI.__index = PremiumUI

local function ti(t, style, dir) return TweenInfo.new(t or .25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out) end
local function tween(o, p, t, s, d) return TweenService:Create(o, ti(t,s,d), p):Play() end

-- Safe writefile (optional persistence)
local canfs = (typeof(writefile)=="function" and typeof(isfile)=="function")
local function save(path, data) if canfs then pcall(function() writefile(path, game:GetService("HttpService"):JSONEncode(data)) end) end end
local function load(path) if canfs and isfile(path) then local ok, j = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(path)) end) if ok then return j end end return nil end

-- Drag helper (PC & Touch)
local function makeDraggable(root, handle)
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; startInput=i.Position; startPos=root.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Utility
local function uiCorner(parent, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=parent; return c end
local function uiStroke(parent, th, col, tran) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Color=col or Color3.fromRGB(70,70,90); s.Transparency=tran or 0; s.Parent=parent; return s end
local function new(txt, props) local o=Instance.new(txt) for k,v in pairs(props or {}) do o[k]=v end return o end

-- ================== Window ==================
function PremiumUI:CreateWindow(title, opts)
    opts = opts or {}
    local self = setmetatable({}, PremiumUI)
    self._savePath = opts.savePath or "PremiumUI_Config.json"
    self._state = load(self._savePath) or {}

    local gui = new("ScreenGui", {Name="PremiumUI"; ResetOnSpawn=false; IgnoreGuiInset=true; Parent=LocalPlayer:WaitForChild("PlayerGui")})

    local root = new("Frame", {Size=UDim2.new(0, 700, 0, 470), Position=UDim2.new(.5,-350,.5,-235),
        BackgroundColor3=Color3.fromRGB(26,26,34), BorderSizePixel=0, ClipsDescendants=true, Parent=gui})
    uiCorner(root,16); uiStroke(root,1.4,Color3.fromRGB(80,80,100),.15)

    local top = new("Frame",{Size=UDim2.new(1,0,0,46), BackgroundColor3=Color3.fromRGB(40,40,54), Parent=root})
    uiCorner(top,16)
    local titleLbl = new("TextLabel",{Size=UDim2.new(1,-120,1,0), Position=UDim2.new(0,16,0,0),
        BackgroundTransparency=1, Text=(title or "⚡ Premium Menu"), TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold, TextSize=18, TextXAlignment=Enum.TextXAlignment.Left, Parent=top})

    local btnMin = new("TextButton",{Size=UDim2.new(0,34,0,34), Position=UDim2.new(1,-86,.5,-17),
        Text="–", Font=Enum.Font.GothamBold, TextSize=20, TextColor3=Color3.fromRGB(230,230,230),
        BackgroundColor3=Color3.fromRGB(55,55,70), Parent=top}); uiCorner(btnMin,10)
    local btnClose = new("TextButton",{Size=UDim2.new(0,34,0,34), Position=UDim2.new(1,-44,.5,-17),
        Text="✖", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=Color3.fromRGB(255,90,90),
        BackgroundColor3=Color3.fromRGB(55,55,70), Parent=top}); uiCorner(btnClose,10)

    local left = new("Frame",{Size=UDim2.new(0,160,1,-56), Position=UDim2.new(0,10,0,52), BackgroundColor3=Color3.fromRGB(33,33,44), Parent=root})
    uiCorner(left,12); uiStroke(left,1,Color3.fromRGB(70,70,90),.3)

    local right = new("Frame",{Size=UDim2.new(1,-190,1,-56), Position=UDim2.new(0,180,0,52),
        BackgroundTransparency=1, Parent=root})

    local tabList = new("UIListLayout",{Parent=left, Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder})

    local notifHolder = new("Frame",{Size=UDim2.new(0,320,1,0), Position=UDim2.new(1,-330,0,12), BackgroundTransparency=1, Parent=gui})

    self._gui, self._root, self._top, self._left, self._right, self._notif = gui, root, top, left, right, notifHolder
    self._tabs = {}
    self._activeTab = nil

    makeDraggable(root, top)
    root.Position = UDim2.new(.5,-350,1.2,0); tween(root,{Position=UDim2.new(.5,-350,.5,-235)},.45)

    btnClose.MouseButton1Click:Connect(function() tween(root,{Position=UDim2.new(.5,-350,1.2,0)},.4); task.delay(.4,function() gui:Destroy() end) end)

    -- Minimize + Dock
    local dock = new("TextButton",{Size=UDim2.new(0,44,0,44), Position=UDim2.new(0,14,1,-58), Text="⚡",
        Font=Enum.Font.GothamBold, TextSize=20, TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.fromRGB(90,130,255),
        Visible=false, Parent=gui}); uiCorner(dock,22)
    local minimized=false
    local function minimize()
        if minimized then return end; minimized=true
        dock.Visible=true; tween(root,{Size=UDim2.new(0,700,0,0)},.22); task.delay(.22,function() root.Visible=false end)
    end
    local function restore()
        if not minimized then return end; minimized=false
        root.Visible=true; tween(root,{Size=UDim2.new(0,700,0,470)},.22); dock.Visible=false
    end
    btnMin.MouseButton1Click:Connect(minimize); dock.MouseButton1Click:Connect(restore)
    self.Minimize = minimize; self.Restore = restore

    -- Public: Notify
    function self:Notify(text, duration, color)
        local n = new("TextLabel",{Size=UDim2.new(1,0,0,42), BackgroundColor3=color or Color3.fromRGB(45,45,58),
            Text=text or "Notification", TextSize=14, Font=Enum.Font.GothamSemibold, TextColor3=Color3.fromRGB(240,240,240),
            TextWrapped=true, Parent=notifHolder}); uiCorner(n,8)
        n.Position = UDim2.new(1,20,0,0); tween(n,{Position=UDim2.new(0,0,0,0)},.25)
        task.delay(duration or 3, function() tween(n,{Position=UDim2.new(1,20,0,0), BackgroundTransparency=1},.25); task.delay(.27,function() n:Destroy() end) end)
    end

    -- Save on destroy
    gui.AncestryChanged:Connect(function(_, p) if not p then save(self._savePath, self._state) end end)

    -- Tabs API
    function self:AddTab(tabName)
        local TabObj = {}
        TabObj.Name = tabName
        local btn = new("TextButton",{Size=UDim2.new(1,-12,0,36), Text=tabName, Font=Enum.Font.GothamBold, TextSize=14,
            TextColor3=Color3.fromRGB(220,220,230), BackgroundColor3=Color3.fromRGB(44,44,58), Parent=left})
        uiCorner(btn,10)
        local page = new("ScrollingFrame",{Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=4,
            BackgroundTransparency=1, Visible=false, Parent=right})
        local pgList = new("UIListLayout",{Parent=page, Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder})
        pgList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0, pgList.AbsoluteContentSize.Y + 20)
        end)

        local function select()
            if self._activeTab then self._activeTab.page.Visible=false; tween(self._activeTab.button,{BackgroundColor3=Color3.fromRGB(44,44,58)},.15) end
            self._activeTab = {page=page, button=btn}
            page.Visible=true; tween(btn,{BackgroundColor3=Color3.fromRGB(86,116,255)},.15)
        end
        btn.MouseButton1Click:Connect(select)
        if not self._activeTab then select() end

        -- Sections/Controls API for this Tab
        function TabObj:AddSection(titleText)
            local holder = new("Frame",{Size=UDim2.new(1,0,0,0), BackgroundColor3=Color3.fromRGB(36,36,48), Parent=page})
            uiCorner(holder,12); uiStroke(holder,1,Color3.fromRGB(70,70,90),.25)
            local inner = new("Frame",{Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10), BackgroundTransparency=1, Parent=holder})
            local il = new("UIListLayout",{Parent=inner, Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder})
            local title
            if titleText and titleText~="" then
                title = new("TextLabel",{Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Text=titleText,
                    Font=Enum.Font.GothamBold, TextSize=15, TextColor3=Color3.fromRGB(235,235,245), Parent=inner})
            end
            il:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                holder.Size = UDim2.new(1,0,0, il.AbsoluteContentSize.Y + 20)
            end)

            local SectionAPI = {}

            function SectionAPI:AddLabel(text)
                new("TextLabel",{Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Text=text,
                    Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(200,200,210), Parent=inner})
            end

            function SectionAPI:AddButton(opt, cb)
                local b = new("TextButton",{Size=UDim2.new(1,0,0,36), Text=opt.text or "Button", Font=Enum.Font.GothamBold,
                    TextSize=14, TextColor3=Color3.fromRGB(240,240,240), BackgroundColor3=Color3.fromRGB(50,50,64), Parent=inner})
                uiCorner(b,10)
                b.MouseButton1Click:Connect(function() tween(b,{BackgroundColor3=Color3.fromRGB(86,116,255)},.1); task.delay(.18,function() tween(b,{BackgroundColor3=Color3.fromRGB(50,50,64)},.15) end); if cb then cb() end end)
                return b
            end

            function SectionAPI:AddToggle(opt, cb)
                local state = (opt.default==true)
                local row = new("Frame",{Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Parent=inner})
                local txt = new("TextLabel",{Size=UDim2.new(1,-60,1,0), Text=opt.text or "Toggle", BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Color3.fromRGB(220,220,230), Parent=row})
                local box = new("TextButton",{Size=UDim2.new(0,46,0,26), Position=UDim2.new(1,-46,.5,-13), Text="", BackgroundColor3=state and Color3.fromRGB(86,116,255) or Color3.fromRGB(60,60,72), Parent=row}); uiCorner(box,13)
                local dot = new("Frame",{Size=UDim2.new(0,20,0,20), Position=UDim2.new(state and 1 or 0, state and -24 or 4,.5,-10), BackgroundColor3=Color3.new(1,1,1), Parent=box}); uiCorner(dot,10)
                local function set(v) state=v; tween(box,{BackgroundColor3=v and Color3.fromRGB(86,116,255) or Color3.fromRGB(60,60,72)},.15); tween(dot,{Position=UDim2.new(v and 1 or 0, v and -24 or 4,.5,-10)},.15); if cb then cb(state) end end
                box.MouseButton1Click:Connect(function() set(not state) end); if cb then cb(state) end
                return {Set=set, Get=function() return state end}
            end

            function SectionAPI:AddSlider(opt, cb)
                local val = opt.default or opt.min or 0
                local row = new("Frame",{Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, Parent=inner})
                new("TextLabel",{Size=UDim2.new(1,0,0,18), Text=(opt.text or "Slider").."  ("..tostring(val)..")", Name="Title",
                    BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(220,220,230), Parent=row})
                local bar = new("Frame",{Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,0,24), BackgroundColor3=Color3.fromRGB(50,50,62), Parent=row}); uiCorner(bar,6)
                local fill = new("Frame",{Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(86,116,255), Parent=bar}); uiCorner(fill,6)
                local knob = new("Frame",{Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,.5,-7), BackgroundColor3=Color3.new(1,1,1), Parent=bar}); uiCorner(knob,7)
                local min,max,step = opt.min or 0, opt.max or 100, opt.step or 1
                local function setFromX(x)
                    local a = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    local raw = min + a*(max-min); local snapped = math.round(raw/step)*step
                    local alpha = (snapped-min)/(max-min)
                    fill.Size = UDim2.new(alpha,0,1,0); knob.Position = UDim2.new(alpha,-7,.5,-7)
                    row.Title.Text = (opt.text or "Slider").."  ("..tostring(snapped)..")"
                    val = snapped; if cb then cb(val) end
                end
                bar.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        setFromX(i.Position.X)
                        local c; c = UserInputService.InputChanged:Connect(function(inp)
                            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then setFromX(inp.Position.X) end
                        end)
                        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then c:Disconnect() end end)
                    end
                end)
                setFromX(bar.AbsolutePosition.X) -- init
                return {Set=function(v) setFromX(bar.AbsolutePosition.X + (bar.AbsoluteSize.X*((v-min)/(max-min)))) end, Get=function() return val end}
            end

            function SectionAPI:AddDropdown(opt, cb)
                local val = opt.default or opt.options[1]
                local row = new("Frame",{Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=inner})
                local btn = new("TextButton",{Size=UDim2.new(1,0,1,0), Text=(opt.text or "Dropdown")..": "..tostring(val),
                    Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(240,240,240), BackgroundColor3=Color3.fromRGB(50,50,64), Parent=row}); uiCorner(btn,10)
                local listFrame = new("Frame",{Size=UDim2.new(1,0,0,0), BackgroundColor3=Color3.fromRGB(40,40,52), Visible=false, Parent=inner}); uiCorner(listFrame,10); uiStroke(listFrame,1,Color3.fromRGB(70,70,90),.25)
                local sf = new("UIListLayout",{Parent=listFrame, Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})
                local function open(v) listFrame.Visible=v; listFrame.Size=UDim2.new(1,0,0, v and (#opt.options*32+12) or 0) end
                for _,op in ipairs(opt.options) do
                    local o = new("TextButton",{Size=UDim2.new(1,-12,0,28), Position=UDim2.new(0,6,0,0), Text=tostring(op), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(230,230,230), BackgroundColor3=Color3.fromRGB(55,55,70), Parent=listFrame}); uiCorner(o,8)
                    o.MouseButton1Click:Connect(function() val=op; btn.Text=(opt.text or "Dropdown")..": "..tostring(val); open(false); if cb then cb(val) end end)
                end
                btn.MouseButton1Click:Connect(function() open(not listFrame.Visible) end)
                if cb then cb(val) end
                return {Set=function(v) val=v; btn.Text=(opt.text or "Dropdown")..": "..tostring(v); if cb then cb(v) end end, Get=function() return val end}
            end

            function SectionAPI:AddTextbox(opt, cb)
                local row = new("Frame",{Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=inner})
                local tb = new("TextBox",{Size=UDim2.new(1,0,1,0), Text=opt.placeholder or "", PlaceholderText=opt.text or "Input...",
                    Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(240,240,240), BackgroundColor3=Color3.fromRGB(50,50,64), Parent=row})
                uiCorner(tb,10)
                tb.FocusLost:Connect(function(enter) if cb then cb(tb.Text, enter) end end)
                return tb
            end

            function SectionAPI:AddKeybind(opt, cb)
                local key = opt.default or Enum.KeyCode.G
                local row = new("Frame",{Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=inner})
                local btn = new("TextButton",{Size=UDim2.new(1,0,1,0), Text=(opt.text or "Keybind")..": "..key.Name, Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(240,240,240), BackgroundColor3=Color3.fromRGB(50,50,64), Parent=row}); uiCorner(btn,10)
                local listening=false
                btn.MouseButton1Click:Connect(function()
                    if listening then return end; listening=true; btn.Text=(opt.text or "Keybind")..": ..."
                    local conn; conn=UserInputService.InputBegan:Connect(function(i,gp)
                        if gp then return end
                        if i.UserInputType==Enum.UserInputType.Keyboard then key=i.KeyCode; btn.Text=(opt.text or "Keybind")..": "..key.Name; listening=false; conn:Disconnect(); if cb then cb(key) end end
                    end)
                end)
                UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==key and cb then cb(key, true) end end)
                if cb then cb(key) end
                return {Set=function(k) key=k; btn.Text=(opt.text or "Keybind")..": "..key.Name end, Get=function() return key end}
            end

            -- === Full Color Picker (SV square + Hue bar + HEX/RGB) ===
            function SectionAPI:AddColorPicker(opt, cb)
                local default = opt.default or Color3.fromRGB(76,228,219)
                local h,s,v = default:ToHSV()
                local holder = new("Frame",{Size=UDim2.new(1,0,0,210), BackgroundColor3=Color3.fromRGB(50,50,64), Parent=inner})
                uiCorner(holder,12)

                new("TextLabel",{Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Text=opt.text or "Color",
                    Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(235,235,245), Parent=holder})

                local preview = new("Frame",{Size=UDim2.new(0,80,0,56), Position=UDim2.new(0,10,0,30), BackgroundColor3=default, Parent=holder}); uiCorner(preview,8); uiStroke(preview,1,Color3.fromRGB(255,255,255),.55)

                -- SV area
                local sv = new("ImageLabel",{Size=UDim2.new(0,180,0,160), Position=UDim2.new(0,110,0,30), Image="rbxassetid://4155801252", BackgroundColor3=Color3.fromHSV(h,1,1), ScaleType=Enum.ScaleType.Stretch, Parent=holder})
                local svDot = new("Frame",{Size=UDim2.new(0,10,0,10), BackgroundColor3=Color3.new(1,1,1), Parent=sv}); uiCorner(svDot,5)
                -- Hue bar
                local hue = new("ImageLabel",{Size=UDim2.new(0,20,0,160), Position=UDim2.new(0,300,0,30), Image="rbxassetid://3641079629", ScaleType=Enum.ScaleType.Stretch, Parent=holder})
                local hLine = new("Frame",{Size=UDim2.new(1,0,0,2), BackgroundColor3=Color3.new(1,1,1), Parent=hue})

                local hex = new("TextBox",{Size=UDim2.new(0,110,0,30), Position=UDim2.new(0,10,0,100), Text="#"..string.format("%02X%02X%02X", default.R*255, default.G*255, default.B*255), TextColor3=Color3.fromRGB(240,240,240), BackgroundColor3=Color3.fromRGB(35,35,46), Font=Enum.Font.Gotham, TextSize=14, Parent=holder}); uiCorner(hex,6)
                local rgb = new("TextBox",{Size=UDim2.new(0,110,0,30), Position=UDim2.new(0,10,0,140), Text=("%d,%d,%d"):format(default.R*255, default.G*255, default.B*255), TextColor3=Color3.fromRGB(240,240,240), BackgroundColor3=Color3.fromRGB(35,35,46), Font=Enum.Font.Gotham, TextSize=14, Parent=holder}); uiCorner(rgb,6)

                local function update()
                    local col = Color3.fromHSV(h,s,v)
                    preview.BackgroundColor3 = col
                    hex.Text = ("#%02X%02X%02X"):format(col.R*255, col.G*255, col.B*255)
                    rgb.Text = ("%d,%d,%d"):format(col.R*255, col.G*255, col.B*255)
                    sv.BackgroundColor3 = Color3.fromHSV(h,1,1)
                    svDot.Position = UDim2.new(s, -5, 1-v, -5)
                    hLine.Position = UDim2.new(0,0, h, -1)
                    if cb then cb(col) end
                end

                -- SV drag
                sv.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        local function move(ip)
                            local r = ip.Position - sv.AbsolutePosition
                            s = math.clamp(r.X/sv.AbsoluteSize.X,0,1)
                            v = 1 - math.clamp(r.Y/sv.AbsoluteSize.Y,0,1)
                            update()
                        end
                        move(i)
                        local c; c=UserInputService.InputChanged:Connect(function(ip)
                            if ip.UserInputType==Enum.UserInputType.MouseMovement or ip.UserInputType==Enum.UserInputType.Touch then move(ip) end
                        end)
                        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then c:Disconnect() end end)
                    end
                end)

                -- Hue drag
                hue.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        local function move(ip)
                            local relY = ip.Position.Y - hue.AbsolutePosition.Y
                            h = math.clamp(relY/hue.AbsoluteSize.Y,0,1)
                            update()
                        end
                        move(i)
                        local c; c=UserInputService.InputChanged:Connect(function(ip)
                            if ip.UserInputType==Enum.UserInputType.MouseMovement or ip.UserInputType==Enum.UserInputType.Touch then move(ip) end
                        end)
                        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then c:Disconnect() end end)
                    end
                end)

                -- HEX/RGB input
                hex.FocusLost:Connect(function()
                    local t = hex.Text:gsub("#","")
                    if #t==6 then
                        local r=tonumber(t:sub(1,2),16) or 255
                        local g=tonumber(t:sub(3,4),16) or 255
                        local b=tonumber(t:sub(5,6),16) or 255
                        local col = Color3.fromRGB(r,g,b); h,s,v = col:ToHSV(); update()
                    else hex.Text = ("#%02X%02X%02X"):format(Color3.fromHSV(h,s,v).R*255, Color3.fromHSV(h,s,v).G*255, Color3.fromHSV(h,s,v).B*255) end
                end)
                rgb.FocusLost:Connect(function()
                    local r,g,b = rgb.Text:match("(%d+)%s*[,;]%s*(%d+)%s*[,;]%s*(%d+)")
                    r=tonumber(r) or 255; g=tonumber(g) or 255; b=tonumber(b) or 255
                    r=math.clamp(r,0,255); g=math.clamp(g,0,255); b=math.clamp(b,0,255)
                    local col = Color3.fromRGB(r,g,b); h,s,v = col:ToHSV(); update()
                end)

                update()
                return {Set=function(col) h,s,v = col:ToHSV(); update() end, Get=function() return Color3.fromHSV(h,s,v) end}
            end

            return SectionAPI
        end

        table.insert(self._tabs, {button=btn, page=page})
        return TabObj
    end

    return self
end

return PremiumUI
