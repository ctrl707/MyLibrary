--==[ Anti double-load ]==--
if shared.__DivaUI_Destroy then
    pcall(shared.__DivaUI_Destroy)
    shared.__DivaUI_Destroy = nil
    task.wait(0.2)
end

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"
Library.Flags   = {}
Library.Windows = {}

--==[ Services ]==--
local Services = {
    Players          = game:GetService("Players"),
    RunService       = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService     = game:GetService("TweenService"),
    StarterGui       = game:GetService("StarterGui"),
    HttpService      = game:GetService("HttpService"),
    CoreGui          = game:GetService("CoreGui"),
}

local LocalPlayer = Services.Players.LocalPlayer
local isMobile    = Services.UserInputService.TouchEnabled

--==[ Utility ]==--
local function GenStr(len)
    len = len or math.random(18, 35)
    local c = "abcdefghijklmnopqrstuvwxyz0123456789"
    local r = {}
    for i = 1, len do
        local p = math.random(1, #c)
        r[i] = c:sub(p, p)
    end
    return table.concat(r)
end

local function ContrastText(bg)
    local l = bg.R * 0.299 + bg.G * 0.587 + bg.B * 0.114
    return l > 0.62 and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(245, 245, 245)
end

local function Tween(obj, props, time, style)
    return Services.TweenService:Create(
        obj,
        TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad),
        props
    ):Play()
end

--==[ Themes ]==--
Library.Themes = {
    Dark = {
        BG=Color3.fromRGB(25,25,30), SB=Color3.fromRGB(30,30,35), Top=Color3.fromRGB(20,20,25),
        Panel=Color3.fromRGB(28,28,34), Field=Color3.fromRGB(38,38,44), Track=Color3.fromRGB(62,62,70),
        Border=Color3.fromRGB(78,78,90), Button=Color3.fromRGB(42,42,50),
        ButtonOn=Color3.fromRGB(72,118,92), ButtonOff=Color3.fromRGB(114,80,80),
        Accent=Color3.fromRGB(90,160,255), Text=Color3.fromRGB(220,220,220), Sub=Color3.fromRGB(180,180,180)
    },
    Midnight = {
        BG=Color3.fromRGB(10,15,35), SB=Color3.fromRGB(15,20,45), Top=Color3.fromRGB(8,10,28),
        Panel=Color3.fromRGB(18,24,50), Field=Color3.fromRGB(25,32,60), Track=Color3.fromRGB(52,72,112),
        Border=Color3.fromRGB(76,94,135), Button=Color3.fromRGB(24,34,64),
        ButtonOn=Color3.fromRGB(52,115,132), ButtonOff=Color3.fromRGB(108,74,90),
        Accent=Color3.fromRGB(95,175,255), Text=Color3.fromRGB(190,210,255), Sub=Color3.fromRGB(145,165,220)
    },
    Crimson = {
        BG=Color3.fromRGB(30,15,15), SB=Color3.fromRGB(38,18,18), Top=Color3.fromRGB(22,10,10),
        Panel=Color3.fromRGB(42,22,22), Field=Color3.fromRGB(55,28,28), Track=Color3.fromRGB(88,46,46),
        Border=Color3.fromRGB(118,72,72), Button=Color3.fromRGB(60,32,32),
        ButtonOn=Color3.fromRGB(88,120,88), ButtonOff=Color3.fromRGB(138,72,88),
        Accent=Color3.fromRGB(255,110,110), Text=Color3.fromRGB(255,215,215), Sub=Color3.fromRGB(220,170,170)
    },
    Hacker = {
        BG=Color3.fromRGB(0,15,0), SB=Color3.fromRGB(0,20,5), Top=Color3.fromRGB(0,10,0),
        Panel=Color3.fromRGB(5,26,8), Field=Color3.fromRGB(8,34,12), Track=Color3.fromRGB(20,60,26),
        Border=Color3.fromRGB(40,96,45), Button=Color3.fromRGB(10,40,14),
        ButtonOn=Color3.fromRGB(22,88,34), ButtonOff=Color3.fromRGB(80,42,42),
        Accent=Color3.fromRGB(0,255,110), Text=Color3.fromRGB(120,255,160), Sub=Color3.fromRGB(80,210,120)
    },
    Purple = {
        BG=Color3.fromRGB(20,10,35), SB=Color3.fromRGB(28,15,45), Top=Color3.fromRGB(15,8,28),
        Panel=Color3.fromRGB(34,20,52), Field=Color3.fromRGB(44,28,66), Track=Color3.fromRGB(70,52,102),
        Border=Color3.fromRGB(104,82,142), Button=Color3.fromRGB(48,30,70),
        ButtonOn=Color3.fromRGB(82,116,102), ButtonOff=Color3.fromRGB(118,74,118),
        Accent=Color3.fromRGB(185,120,255), Text=Color3.fromRGB(230,205,255), Sub=Color3.fromRGB(185,155,220)
    },
    Light = {
        BG=Color3.fromRGB(242,243,247), SB=Color3.fromRGB(232,234,240), Top=Color3.fromRGB(223,226,234),
        Panel=Color3.fromRGB(236,238,244), Field=Color3.fromRGB(248,249,252), Track=Color3.fromRGB(210,214,224),
        Border=Color3.fromRGB(188,194,206), Button=Color3.fromRGB(227,230,236),
        ButtonOn=Color3.fromRGB(177,220,190), ButtonOff=Color3.fromRGB(232,192,192),
        Accent=Color3.fromRGB(78,128,220), Text=Color3.fromRGB(34,36,44), Sub=Color3.fromRGB(92,96,108)
    },
}

Library.Fonts = {
    Gotham = {Font=Enum.Font.Gotham, Bold=Enum.Font.GothamBold, Semi=Enum.Font.GothamSemibold},
    Code   = {Font=Enum.Font.Code, Bold=Enum.Font.Code, Semi=Enum.Font.Code},
    Arcade = {Font=Enum.Font.Arcade, Bold=Enum.Font.Arcade, Semi=Enum.Font.Arcade},
}

Library.WindowSizes = {
    Small  = {W=420, H=290},
    Normal = {W=560, H=370},
    Large  = {W=700, H=460},
    XLarge = {W=850, H=560},
}

Library.HighlightColors = {
    {Name="Black",  Color=Color3.fromRGB(0,0,0)},
    {Name="Gray",   Color=Color3.fromRGB(128,128,128)},
    {Name="White",  Color=Color3.fromRGB(255,255,255)},
    {Name="Red",    Color=Color3.fromRGB(255,0,0)},
    {Name="Orange", Color=Color3.fromRGB(255,127,0)},
    {Name="Yellow", Color=Color3.fromRGB(255,255,0)},
    {Name="Lime",   Color=Color3.fromRGB(0,255,0)},
    {Name="Cyan",   Color=Color3.fromRGB(0,255,255)},
    {Name="Blue",   Color=Color3.fromRGB(0,0,255)},
    {Name="Purple", Color=Color3.fromRGB(127,0,255)},
    {Name="Pink",   Color=Color3.fromRGB(255,0,255)},
    {Name="Rose",   Color=Color3.fromRGB(255,0,127)},
}

Library.CornerRadii   = {0, 2, 4, 6, 8, 12}
Library.OpacityLevels = {
    {Name="Solid",   Value=0},
    {Name="Glass 1", Value=0.1},
    {Name="Glass 2", Value=0.25},
    {Name="Glass 3", Value=0.45},
    {Name="Ghost",   Value=0.65},
}

--==[ Notify ]==--
function Library:Notify(config)
    config = config or {}
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title    = config.Title or "DivaUI",
            Text     = config.Content or config.Text or "",
            Duration = config.Duration or 3,
        })
    end)
end

--==[ Expose utility ]==--
Library._Utils = {
    GenStr       = GenStr,
    ContrastText = ContrastText,
    Tween        = Tween,
    Services     = Services,
    LocalPlayer  = LocalPlayer,
    isMobile     = isMobile,
}

--==[ Theme Registry (global for all elements) ]==--
local function CreateThemeRegistry()
    return {
        BGs={}, Sidebars={}, TopBars={}, Panels={}, Fields={},
        Tracks={}, Buttons={}, Sliders={}, Texts={}, Separators={},
        Scrolls={}, Corners={}, MainFrame=nil, RefreshTabs=nil,
    }
end

--==[ CreateWindow ]==--
function Library:CreateWindow(config)
    config = config or {}
    
    local Window = {}
    Window.__index = Window
    
    -- Config
    Window.Name      = config.Name or "DivaUI"
    Window.ThemeName = config.Theme or "Dark"
    Window.SizeName  = config.Size or "Normal"
    Window.FontName  = config.Font or "Gotham"
    Window.CornerIdx = config.CornerIdx or 3
    Window.OpacityIdx= config.OpacityIdx or 1
    
    -- Validate
    if not Library.Themes[Window.ThemeName] then Window.ThemeName = "Dark" end
    if not Library.WindowSizes[Window.SizeName] then Window.SizeName = "Normal" end
    if not Library.Fonts[Window.FontName] then Window.FontName = "Gotham" end
    
    -- State
    Window.Tabs       = {}
    Window.TabBtns    = {}
    Window.TabPages   = {}
    Window.ActiveTab  = 1
    Window.Collapsed  = false
    Window.CustOpen   = false
    Window.Registry   = CreateThemeRegistry()
    
    -- Helpers for theme
    local function CurTheme()  return Library.Themes[Window.ThemeName] end
    local function CurFont()   return Library.Fonts[Window.FontName]  end
    local function CurSize()   return Library.WindowSizes[Window.SizeName] end
    local function CurCorner() return Library.CornerRadii[Window.CornerIdx] end
    local function CurOpacity()return Library.OpacityLevels[Window.OpacityIdx].Value end
    
    Window.CurTheme   = CurTheme
    Window.CurFont    = CurFont
    Window.CurSize    = CurSize
    Window.CurCorner  = CurCorner
    Window.CurOpacity = CurOpacity
    
    -- Registry helpers
    local R = Window.Registry
    local function RegBG(o)        table.insert(R.BGs,o) end
    local function RegSidebar(o)   table.insert(R.Sidebars,o) end
    local function RegTopBar(o)    table.insert(R.TopBars,o) end
    local function RegPanel(o)     table.insert(R.Panels,o) end
    local function RegField(o)     table.insert(R.Fields,o) end
    local function RegTrack(o)     table.insert(R.Tracks,o) end
    local function RegSlider(o)    table.insert(R.Sliders,o) end
    local function RegSeparator(o) table.insert(R.Separators,o) end
    local function RegScroll(o)    table.insert(R.Scrolls,o) end
    local function RegText(o,pri)  table.insert(R.Texts,{o,pri}) end
    local function RegCorner(o)    table.insert(R.Corners,o) end
    local function RegBtn(btn, isToggle, isOnFn)
        table.insert(R.Buttons,{btn=btn, isToggle=isToggle or false, isOnFn=isOnFn})
    end
    
    Window._Reg = {
        BG=RegBG, Sidebar=RegSidebar, TopBar=RegTopBar, Panel=RegPanel,
        Field=RegField, Track=RegTrack, Slider=RegSlider, Separator=RegSeparator,
        Scroll=RegScroll, Text=RegText, Corner=RegCorner, Btn=RegBtn,
    }
    
    --==[ Apply theme to all elements ]==--
    function Window:ApplyTheme()
        local th = CurTheme()
        local fn = CurFont()
        local cr = UDim.new(0, CurCorner())
        local op = CurOpacity()
        
        for _, o in ipairs(R.BGs) do
            if o and o.Parent then
                o.BackgroundColor3       = th.BG
                o.BackgroundTransparency = op
            end
        end
        for _, o in ipairs(R.Sidebars) do
            if o and o.Parent then
                o.BackgroundColor3       = th.SB
                o.BackgroundTransparency = op
            end
        end
        for _, o in ipairs(R.TopBars) do
            if o and o.Parent then o.BackgroundColor3 = th.Top end
        end
        for _, o in ipairs(R.Panels) do
            if o and o.Parent then
                o.BackgroundColor3       = th.Panel
                o.BackgroundTransparency = op
            end
        end
        for _, o in ipairs(R.Fields) do
            if o and o.Parent then
                if o:IsA("GuiObject") then o.BackgroundColor3 = th.Field end
                if o:IsA("TextBox") or o:IsA("TextButton") or o:IsA("TextLabel") then
                    o.TextColor3 = th.Text
                    o.Font       = fn.Font
                end
                if o:IsA("TextBox") then o.PlaceholderColor3 = th.Sub end
            end
        end
        for _, o in ipairs(R.Tracks) do
            if o and o.Parent then o.BackgroundColor3 = th.Track end
        end
        for _, entry in ipairs(R.Buttons) do
            local b = entry.btn
            if b and b.Parent then
                local bg = th.Button
                if entry.isToggle and entry.isOnFn then
                    bg = entry.isOnFn() and th.ButtonOn or th.ButtonOff
                end
                b.BackgroundColor3 = bg
                b.TextColor3       = ContrastText(bg)
                b.Font             = fn.Semi
            end
        end
        for _, o in ipairs(R.Sliders) do
            if o and o.Parent then o.BackgroundColor3 = th.Accent end
        end
        for _, entry in ipairs(R.Texts) do
            local lbl, isPrimary = entry[1], entry[2]
            if lbl and lbl.Parent then
                lbl.TextColor3 = isPrimary and th.Text or th.Sub
                lbl.Font       = isPrimary and fn.Semi or fn.Font
            end
        end
        for _, o in ipairs(R.Separators) do
            if o and o.Parent then o.BackgroundColor3 = th.Border end
        end
        for _, o in ipairs(R.Scrolls) do
            if o and o.Parent then o.ScrollBarImageColor3 = th.Border end
        end
        for _, o in ipairs(R.Corners) do
            if o and o.Parent then o.CornerRadius = cr end
        end
        
        if R.MainFrame and R.MainFrame.Parent then
            local sz = CurSize()
            Tween(R.MainFrame, {Size=UDim2.new(0, sz.W, 0, sz.H)}, 0.25)
        end
        
        if R.RefreshTabs then R.RefreshTabs() end
    end
    
    --==[ Build GUI ]==--
    local guiName = GenStr(20)
    
    local SG = Instance.new("ScreenGui")
    SG.Name           = guiName
    SG.Parent         = Services.CoreGui
    SG.DisplayOrder   = 10
    SG.ResetOnSpawn   = false
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Window.ScreenGui  = SG
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name                   = GenStr(5)
    Shadow.Image                  = "rbxassetid://5554236805"
    Shadow.BackgroundTransparency = 1
    Shadow.ZIndex                 = 0
    Shadow.ScaleType              = Enum.ScaleType.Slice
    Shadow.SliceCenter            = Rect.new(10,10,20,20)
    Shadow.ImageColor3            = Color3.new(0,0,0)
    Shadow.ImageTransparency      = 0.5
    Shadow.Parent                 = SG
    
    local sz = CurSize()
    local th = CurTheme()
    
    -- Main Frame
    local MF = Instance.new("Frame")
    MF.Name             = GenStr(8)
    MF.Size             = UDim2.new(0, sz.W, 0, sz.H)
    MF.Position         = isMobile
        and UDim2.new(0,50,0,50)
        or  UDim2.new(0.5,-sz.W/2,0.5,-sz.H/2)
    MF.BackgroundColor3 = th.BG
    MF.BorderSizePixel  = 0
    MF.Active           = true
    MF.Draggable        = true
    MF.ClipsDescendants = true
    MF.ZIndex           = 1
    MF.Parent           = SG
    RegBG(MF)
    R.MainFrame  = MF
    Window.MainFrame = MF
    
    local mfCorner = Instance.new("UICorner")
    mfCorner.Parent = MF
    RegCorner(mfCorner)
    
    MF:GetPropertyChangedSignal("Position"):Connect(function()
        Shadow.Position = MF.Position - UDim2.new(0,10,0,10)
    end)
    MF:GetPropertyChangedSignal("Size"):Connect(function()
        Shadow.Size = MF.Size + UDim2.new(0,20,0,20)
    end)
    Shadow.Position = MF.Position - UDim2.new(0,10,0,10)
    Shadow.Size     = MF.Size + UDim2.new(0,20,0,20)
    
    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size            = UDim2.new(1,0,0,30)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex          = 3
    TopBar.Parent          = MF
    RegTopBar(TopBar)
    
    local Title = Instance.new("TextLabel")
    Title.Size                   = UDim2.new(1,-80,1,0)
    Title.Position               = UDim2.new(0,10,0,0)
    Title.BackgroundTransparency = 1
    Title.Text                   = Window.Name .. (isMobile and " [Mobile]" or " [PC]")
    Title.TextSize               = 13
    Title.TextXAlignment         = Enum.TextXAlignment.Left
    Title.ZIndex                 = 4
    Title.Parent                 = TopBar
    RegText(Title, true)
    
    -- Collapse button
    local ColBtn = Instance.new("TextButton")
    ColBtn.Size                   = UDim2.new(0,30,0,30)
    ColBtn.Position               = UDim2.new(1,-30,0,0)
    ColBtn.BackgroundTransparency = 1
    ColBtn.Text                   = "-"
    ColBtn.TextSize               = 18
    ColBtn.ZIndex                 = 4
    ColBtn.Parent                 = TopBar
    RegText(ColBtn, true)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size            = UDim2.new(0,130,1,-30)
    Sidebar.Position        = UDim2.new(0,0,0,30)
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex          = 2
    Sidebar.Parent          = MF
    RegSidebar(Sidebar)
    Window.Sidebar = Sidebar
    
    local SBSep = Instance.new("Frame")
    SBSep.Size            = UDim2.new(0,1,1,-30)
    SBSep.Position        = UDim2.new(0,130,0,30)
    SBSep.BorderSizePixel = 0
    SBSep.ZIndex          = 3
    SBSep.Parent          = MF
    RegSeparator(SBSep)
    Window.SBSep = SBSep
    
    -- Content Area
    local CA = Instance.new("Frame")
    CA.Size                   = UDim2.new(1,-131,1,-30)
    CA.Position               = UDim2.new(0,131,0,30)
    CA.BackgroundTransparency = 1
    CA.Parent                 = MF
    Window.ContentArea = CA
    
    -- Sidebar Layout
    local sbl = Instance.new("UIListLayout")
    sbl.SortOrder = Enum.SortOrder.LayoutOrder
    sbl.Padding   = UDim.new(0,2)
    sbl.Parent    = Sidebar
    
    local sbp = Instance.new("UIPadding")
    sbp.PaddingTop    = UDim.new(0,8)
    sbp.PaddingBottom = UDim.new(0,8)
    sbp.PaddingLeft   = UDim.new(0,6)
    sbp.PaddingRight  = UDim.new(0,6)
    sbp.Parent        = Sidebar
    
    --==[ Tab management ]==--
    local function StyleSidebarTab(tb, selected)
        local th2 = CurTheme()
        tb.BackgroundTransparency = selected and 0 or 1
        tb.BackgroundColor3       = th2.Field
        tb.TextColor3             = selected and th2.Text or th2.Sub
        tb.Font                   = CurFont().Semi
    end
    
    local function RefreshTabs()
        for i, p in ipairs(Window.TabPages) do p.Visible = (i == Window.ActiveTab) end
        for i, b in ipairs(Window.TabBtns)  do StyleSidebarTab(b, i == Window.ActiveTab) end
    end
    R.RefreshTabs = RefreshTabs
    Window.RefreshTabs = RefreshTabs
    
    --==[ Collapse logic ]==--
    ColBtn.MouseButton1Click:Connect(function()
        if Window.Collapsed then
            Window.Collapsed = false
            ColBtn.Text = "-"
            local sz2 = CurSize()
            Tween(MF, {Size=UDim2.new(0,sz2.W,0,sz2.H)}, 0.3)
            Tween(Shadow, {Size=UDim2.new(0,sz2.W+20,0,sz2.H+20)}, 0.3)
            task.delay(0.2, function()
                if not Window.Collapsed then
                    Sidebar.Visible = true
                    SBSep.Visible   = true
                    CA.Visible      = true
                end
            end)
        else
            Window.Collapsed = true
            ColBtn.Text = "+"
            Sidebar.Visible = false
            SBSep.Visible   = false
            CA.Visible      = false
            Tween(MF, {Size=UDim2.new(0,CurSize().W,0,30)}, 0.3)
            Tween(Shadow, {Size=UDim2.new(0,CurSize().W+20,0,50)}, 0.3)
        end
    end)
    
    --==[ CreateTab method ]==--
    function Window:CreateTab(name, layoutOrder)
        local idx = #self.TabBtns + 1
        
        local tb = Instance.new("TextButton")
        tb.Size                   = UDim2.new(1,0,0,28)
        tb.BackgroundTransparency = 1
        tb.Text                   = name
        tb.TextSize               = 12
        tb.TextXAlignment         = Enum.TextXAlignment.Left
        tb.ZIndex                 = 3
        tb.LayoutOrder            = layoutOrder or idx
        tb.Parent                 = self.Sidebar
        
        local tbc = Instance.new("UICorner")
        tbc.Parent = tb
        RegCorner(tbc)
        
        local tbp = Instance.new("UIPadding")
        tbp.PaddingLeft = UDim.new(0, 8)
        tbp.Parent      = tb
        
        local pg = Instance.new("ScrollingFrame")
        pg.Size                   = UDim2.new(1,0,1,0)
        pg.BackgroundTransparency = 1
        pg.BorderSizePixel        = 0
        pg.ScrollBarThickness     = 4
        pg.Visible                = false
        pg.Parent                 = self.ContentArea
        RegScroll(pg)
        
        local pl = Instance.new("UIListLayout")
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.Padding   = UDim.new(0,6)
        pl.Parent    = pg
        
        local pp = Instance.new("UIPadding")
        pp.PaddingTop    = UDim.new(0,10)
        pp.PaddingBottom = UDim.new(0,10)
        pp.PaddingLeft   = UDim.new(0,10)
        pp.PaddingRight  = UDim.new(0,15)
        pp.Parent        = pg
        
        pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pg.CanvasSize = UDim2.new(0,0,0, pl.AbsoluteContentSize.Y+20)
        end)
        
        table.insert(self.TabBtns, tb)
        table.insert(self.TabPages, pg)
        
        tb.MouseButton1Click:Connect(function()
            self.ActiveTab = idx
            self.RefreshTabs()
        end)
        
        -- Tab object
        local Tab = {}
        Tab.Window = self
        Tab.Page   = pg
        Tab.Name   = name
        Tab.Index  = idx
        
        -- Store internal helpers for components (used in Part 3)
        Tab._RegBtn       = RegBtn
        Tab._RegText      = RegText
        Tab._RegCorner    = RegCorner
        Tab._RegTrack     = RegTrack
        Tab._RegSlider    = RegSlider
        Tab._RegField     = RegField
        Tab._RegSeparator = RegSeparator
        Tab._CurTheme     = CurTheme
        Tab._CurFont      = CurFont
        Tab._ApplyTheme   = function() Window:ApplyTheme() end
        
        table.insert(self.Tabs, Tab)
        
        -- Make first tab active automatically
        if idx == 1 then
            self.ActiveTab = 1
            self.RefreshTabs()
        end
        
        -- Inject component methods (defined in Part 3)
        for methodName, methodFn in pairs(Library._TabMethods or {}) do
            Tab[methodName] = methodFn
        end
        
        return Tab
    end
    
    --==[ Apply initial theme ]==--
    Window:ApplyTheme()
    
    --==[ Destroy method ]==--
    function Window:Destroy()
        if self.ScreenGui and self.ScreenGui.Parent then
            self.ScreenGui:Destroy()
        end
    end
    
    table.insert(Library.Windows, Window)
    return Window
end

--==[ Tab methods table (filled in Part 3) ]==--
Library._TabMethods = {}

--==[ Internal helpers for components ]==--
local function CreateWrap(parent, name, h)
    local w = Instance.new("Frame")
    w.Name                   = name or "Wrap"
    w.BackgroundTransparency = 1
    w.Size                   = UDim2.new(1,0,0,h)
    w.Parent                 = parent
    return w
end

--==[ CreateSection ]==--
function Library._TabMethods:CreateSection(name)
    local w = CreateWrap(self.Page, "Section", 22)
    
    local hdr = Instance.new("TextLabel")
    hdr.Size                   = UDim2.new(1,0,1,0)
    hdr.BackgroundTransparency = 1
    hdr.Text                   = name or "Section"
    hdr.TextSize               = 12
    hdr.Font                   = Enum.Font.GothamBold
    hdr.TextXAlignment         = Enum.TextXAlignment.Left
    hdr.Parent                 = w
    self._RegText(hdr, true)
    
    self._ApplyTheme()
    return hdr
end

--==[ CreateDivider ]==--
function Library._TabMethods:CreateDivider()
    local w = CreateWrap(self.Page, "Divider", 10)
    
    local line = Instance.new("Frame")
    line.Size            = UDim2.new(1,0,0,1)
    line.Position        = UDim2.new(0,0,0.5,0)
    line.BorderSizePixel = 0
    line.Parent          = w
    self._RegSeparator(line)
    
    self._ApplyTheme()
    return line
end

--==[ CreateLabel ]==--
function Library._TabMethods:CreateLabel(config)
    config = config or {}
    if type(config) == "string" then config = {Text = config} end
    
    local w = CreateWrap(self.Page, "Label", 20)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = config.Text or "Label"
    lbl.TextSize               = config.TextSize or 12
    lbl.TextXAlignment         = config.TextXAlignment or Enum.TextXAlignment.Left
    lbl.TextWrapped            = config.Wrapped or false
    lbl.Parent                 = w
    self._RegText(lbl, config.Primary == true)
    
    self._ApplyTheme()
    
    local LabelObj = {Instance = lbl}
    function LabelObj:Set(text)
        lbl.Text = tostring(text)
    end
    return LabelObj
end

--==[ CreateParagraph ]==--
function Library._TabMethods:CreateParagraph(config)
    config = config or {}
    
    local title = config.Title or "Paragraph"
    local content = config.Content or config.Text or ""
    
    local w = CreateWrap(self.Page, "Paragraph", 50)
    w.Size = UDim2.new(1,0,0,50)
    
    local th = self._CurTheme()
    w.BackgroundColor3 = th.Field
    w.BackgroundTransparency = 0
    self._RegField(w)
    
    local corner = Instance.new("UICorner")
    corner.Parent = w
    self._RegCorner(corner)
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft   = UDim.new(0, 8)
    padding.PaddingRight  = UDim.new(0, 8)
    padding.PaddingTop    = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent        = w
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size                   = UDim2.new(1,0,0,16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                   = title
    titleLbl.TextSize               = 12
    titleLbl.Font                   = Enum.Font.GothamBold
    titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
    titleLbl.Parent                 = w
    self._RegText(titleLbl, true)
    
    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size                   = UDim2.new(1,0,1,-18)
    contentLbl.Position               = UDim2.new(0,0,0,18)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Text                   = content
    contentLbl.TextSize               = 11
    contentLbl.TextXAlignment         = Enum.TextXAlignment.Left
    contentLbl.TextYAlignment         = Enum.TextYAlignment.Top
    contentLbl.TextWrapped            = true
    contentLbl.Parent                 = w
    self._RegText(contentLbl, false)
    
    -- Auto-resize
    task.defer(function()
        local textBounds = game:GetService("TextService"):GetTextSize(
            content, 11, Enum.Font.Gotham,
            Vector2.new(w.AbsoluteSize.X - 16, math.huge)
        )
        w.Size = UDim2.new(1,0,0, 18 + textBounds.Y + 12)
        contentLbl.Size = UDim2.new(1,0,0, textBounds.Y)
    end)
    
    self._ApplyTheme()
    
    local ParagraphObj = {Instance = w, Title = titleLbl, Content = contentLbl}
    function ParagraphObj:Set(newTitle, newContent)
        if newTitle then titleLbl.Text = tostring(newTitle) end
        if newContent then contentLbl.Text = tostring(newContent) end
    end
    return ParagraphObj
end

--==[ CreateButton ]==--
function Library._TabMethods:CreateButton(config)
    config = config or {}
    
    local w = CreateWrap(self.Page, config.Name or "Button", 32)
    
    local btn = Instance.new("TextButton")
    btn.Name     = "Button"
    btn.Size     = UDim2.new(1,0,1,0)
    btn.Text     = config.Name or "Button"
    btn.TextSize = 13
    btn.Parent   = w
    self._RegBtn(btn, false)
    
    local bc = Instance.new("UICorner")
    bc.Parent = btn
    self._RegCorner(bc)
    
    btn.MouseButton1Click:Connect(function()
        if config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback)
                if not ok then warn("[DivaUI] Button callback error: "..tostring(err)) end
            end)
        end
    end)
    
    self._ApplyTheme()
    
    local ButtonObj = {Instance = btn}
    function ButtonObj:Set(text)
        btn.Text = tostring(text)
    end
    function ButtonObj:SetCallback(fn)
        config.Callback = fn
    end
    return ButtonObj
end

--==[ CreateToggle ]==--
function Library._TabMethods:CreateToggle(config)
    config = config or {}
    
    local state = config.Default or false
    local flag  = config.Flag or config.Name
    
    local w = CreateWrap(self.Page, config.Name or "Toggle", 32)
    
    local btn = Instance.new("TextButton")
    btn.Name     = "Toggle"
    btn.Size     = UDim2.new(1,0,1,0)
    btn.Text     = (config.Name or "Toggle")..": "..(state and "ON" or "OFF")
    btn.TextSize = 13
    btn.Parent   = w
    self._RegBtn(btn, true, function() return state end)
    
    local bc = Instance.new("UICorner")
    bc.Parent = btn
    self._RegCorner(bc)
    
    local function UpdateVisual()
        local th = self._CurTheme()
        local bg = state and th.ButtonOn or th.ButtonOff
        btn.BackgroundColor3 = bg
        btn.TextColor3       = Library._Utils.ContrastText(bg)
        btn.Text             = (config.Name or "Toggle")..": "..(state and "ON" or "OFF")
    end
    
    local ToggleObj = {Instance = btn}
    
    function ToggleObj:Set(value)
        state = value and true or false
        if flag then Library.Flags[flag] = state end
        UpdateVisual()
        if config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback, state)
                if not ok then warn("[DivaUI] Toggle callback error: "..tostring(err)) end
            end)
        end
    end
    
    function ToggleObj:Get() return state end
    
    btn.MouseButton1Click:Connect(function()
        ToggleObj:Set(not state)
    end)
    
    -- Init
    if flag then Library.Flags[flag] = state end
    UpdateVisual()
    self._ApplyTheme()
    
    -- Fire callback once on init if needed
    if config.Default ~= nil and config.Callback then
        task.spawn(function()
            local ok, err = pcall(config.Callback, state)
            if not ok then warn("[DivaUI] Toggle init callback error: "..tostring(err)) end
        end)
    end
    
    return ToggleObj
end

--==[ CreateSlider ]==--
function Library._TabMethods:CreateSlider(config)
    config = config or {}
    
    local name    = config.Name or "Slider"
    local mn      = config.Min or 0
    local mx      = config.Max or 100
    local init    = config.Default or mn
    local flag    = config.Flag or name
    local fmt     = config.Format or "%.1f"
    local round   = config.Round
    
    -- Round function
    local function ff(v)
        if round then
            return math.floor(v / round + 0.5) * round
        elseif fmt:find("%%d") then
            return math.floor(v + 0.5)
        else
            return math.floor(v * 100) / 100
        end
    end
    
    init = ff(init)
    init = math.clamp(init, mn, mx)
    
    local w = CreateWrap(self.Page, name, 45)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = name..": "..string.format(fmt, init)
    lbl.TextSize               = 12
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = w
    self._RegText(lbl, false)
    
    local sf = Instance.new("Frame")
    sf.Size                   = UDim2.new(1,0,0,20)
    sf.Position               = UDim2.new(0,0,0,20)
    sf.BackgroundTransparency = 1
    sf.Parent                 = w
    
    local st = Instance.new("Frame")
    st.Size            = UDim2.new(1,0,0,6)
    st.Position        = UDim2.new(0,0,0.5,-3)
    st.BorderSizePixel = 0
    st.Parent          = sf
    self._RegTrack(st)
    
    local stc = Instance.new("UICorner")
    stc.CornerRadius = UDim.new(1,0)
    stc.Parent       = st
    
    local fl = Instance.new("Frame")
    fl.Size            = UDim2.new((init-mn)/(mx-mn),0,1,0)
    fl.BorderSizePixel = 0
    fl.Parent          = st
    self._RegSlider(fl)
    
    local flc = Instance.new("UICorner")
    flc.CornerRadius = UDim.new(1,0)
    flc.Parent       = fl
    
    local trig = Instance.new("TextButton")
    trig.Size                   = UDim2.new(1,0,1,0)
    trig.BackgroundTransparency = 1
    trig.Text                   = ""
    trig.Parent                 = sf
    
    local currentValue = init
    local drag = false
    
    local SliderObj = {Instance = w}
    
    local function setValue(v, fireCallback)
        v = math.clamp(v, mn, mx)
        v = ff(v)
        currentValue = v
        local pct = (v - mn) / (mx - mn)
        fl.Size = UDim2.new(pct, 0, 1, 0)
        lbl.Text = name..": "..string.format(fmt, v)
        if flag then Library.Flags[flag] = v end
        if fireCallback and config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback, v)
                if not ok then warn("[DivaUI] Slider callback error: "..tostring(err)) end
            end)
        end
    end
    
    function SliderObj:Set(v) setValue(v, true) end
    function SliderObj:Get() return currentValue end
    
    local function upd(input)
        local pct = math.clamp(
            (input.Position.X - st.AbsolutePosition.X) / st.AbsoluteSize.X,
            0, 1
        )
        local v = mn + (mx - mn) * pct
        setValue(v, true)
    end
    
    trig.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(i)
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    
    -- Init
    if flag then Library.Flags[flag] = init end
    self._ApplyTheme()
    
    return SliderObj
end

--==[ CreateDropdown ]==--
--==[ CreateDropdown ]==--
function Library._TabMethods:CreateDropdown(config)
    config = config or {}
    
    local TabRef = self  -- сохраняем ссылку на Tab
    
    local name    = config.Name or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or options[1]
    local flag    = config.Flag or name
    
    local selectedIdx = 1
    for i, opt in ipairs(options) do
        if opt == default then selectedIdx = i break end
    end
    
    local w = CreateWrap(TabRef.Page, name, 32)
    
    local btn = Instance.new("TextButton")
    btn.Name             = "Dropdown"
    btn.Size             = UDim2.new(1,0,1,0)
    btn.Text             = "▼  "..name..": "..tostring(options[selectedIdx] or "None")
    btn.TextSize         = 12
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.Parent           = w
    TabRef._RegField(btn)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    TabRef._RegCorner(btnCorner)
    
    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 8)
    btnPad.Parent      = btn
    
    local listW = CreateWrap(TabRef.Page, name.."_List", 0)
    
    local list = Instance.new("ScrollingFrame")
    list.Size               = UDim2.new(1,0,0,0)
    list.BorderSizePixel    = 0
    list.ScrollBarThickness = 3
    list.CanvasSize         = UDim2.new(0,0,0,#options*28)
    list.Visible            = false
    list.ZIndex             = 10
    list.BackgroundColor3   = TabRef._CurTheme().SB
    list.Parent             = listW
    
    local listCorner = Instance.new("UICorner")
    listCorner.Parent = list
    TabRef._RegCorner(listCorner)
    
    local itemBtns = {}
    local open     = false
    local DropdownObj = {Instance = btn}
    
    local function rebuildItems()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        itemBtns = {}
        
        local th = TabRef._CurTheme()
        local fn = TabRef._CurFont()
        
        for i, opt in ipairs(options) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Name             = "Item_"..i
            itemBtn.Size             = UDim2.new(1,0,0,26)
            itemBtn.Position         = UDim2.new(0,0,0,(i-1)*28)
            itemBtn.BackgroundColor3 = (i == selectedIdx) and th.Panel or th.Field
            itemBtn.Text             = tostring(opt)
            itemBtn.TextColor3       = th.Text
            itemBtn.TextSize         = 11
            itemBtn.Font             = fn.Font
            itemBtn.TextXAlignment   = Enum.TextXAlignment.Left
            itemBtn.BorderSizePixel  = 0
            itemBtn.ZIndex           = 11
            itemBtn.Parent           = list
            
            local ic = Instance.new("UICorner")
            ic.CornerRadius = UDim.new(0,3)
            ic.Parent       = itemBtn
            
            local ip = Instance.new("UIPadding")
            ip.PaddingLeft = UDim.new(0,6)
            ip.Parent      = itemBtn
            
            itemBtn:SetAttribute("Idx", i)
            table.insert(itemBtns, itemBtn)
            
            local capturedI = i
            itemBtn.MouseButton1Click:Connect(function()
                DropdownObj:Set(options[capturedI])
                open = false
                Library._Utils.Tween(list, {Size=UDim2.new(1,0,0,0)}, 0.15)
                task.delay(0.15, function()
                    list.Visible = false
                    listW.Size   = UDim2.new(1,0,0,0)
                end)
            end)
        end
        list.CanvasSize = UDim2.new(0,0,0,#options*28)
    end
    
    function DropdownObj:Set(value)
        for i, opt in ipairs(options) do
            if opt == value then
                selectedIdx = i
                btn.Text = (open and "▲  " or "▼  ")..name..": "..tostring(opt)
                if flag then Library.Flags[flag] = opt end
                local th = TabRef._CurTheme()
                for _, ib in ipairs(itemBtns) do
                    ib.BackgroundColor3 = (ib:GetAttribute("Idx") == i) and th.Panel or th.Field
                end
                if config.Callback then
                    task.spawn(function()
                        local ok, err = pcall(config.Callback, opt)
                        if not ok then warn("[NovaUI] Dropdown callback error: "..tostring(err)) end
                    end)
                end
                return
            end
        end
    end
    
    function DropdownObj:Get() return options[selectedIdx] end
    
    function DropdownObj:Refresh(newOptions, newDefault)
        options = newOptions or options
        selectedIdx = 1
        if newDefault then
            for i, opt in ipairs(options) do
                if opt == newDefault then selectedIdx = i break end
            end
        end
        rebuildItems()
        btn.Text = "▼  "..name..": "..tostring(options[selectedIdx] or "None")
        if flag then Library.Flags[flag] = options[selectedIdx] end
    end
    
    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local listH = math.min(#options*28, 150)
            list.Visible = true
            Library._Utils.Tween(list, {Size=UDim2.new(1,0,0,listH)}, 0.2)
            listW.Size   = UDim2.new(1,0,0,listH)
            btn.Text     = "▲  "..name..": "..tostring(options[selectedIdx])
        else
            Library._Utils.Tween(list, {Size=UDim2.new(1,0,0,0)}, 0.15)
            task.delay(0.15, function()
                list.Visible = false
                listW.Size   = UDim2.new(1,0,0,0)
            end)
            btn.Text = "▼  "..name..": "..tostring(options[selectedIdx])
        end
    end)
    
    rebuildItems()
    if flag then Library.Flags[flag] = options[selectedIdx] end
    TabRef._ApplyTheme()
    
    return DropdownObj
end

--==[ CreateTextBox ]==--
function Library._TabMethods:CreateTextBox(config)
    config = config or {}
    
    local name        = config.Name or "TextBox"
    local default     = config.Default or ""
    local placeholder = config.Placeholder or ""
    local flag        = config.Flag or name
    
    local w = CreateWrap(self.Page, name, 44)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1,0,0,16)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = name
    lbl.TextSize               = 11
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = w
    self._RegText(lbl, false)
    
    local tb = Instance.new("TextBox")
    tb.Size             = UDim2.new(1,0,0,26)
    tb.Position         = UDim2.new(0,0,0,18)
    tb.Text             = default
    tb.PlaceholderText  = placeholder
    tb.TextSize         = 12
    tb.ClearTextOnFocus = false
    tb.Parent           = w
    self._RegField(tb)
    
    local tbc = Instance.new("UICorner")
    tbc.Parent = tb
    self._RegCorner(tbc)
    
    local tbp = Instance.new("UIPadding")
    tbp.PaddingLeft  = UDim.new(0, 8)
    tbp.PaddingRight = UDim.new(0, 8)
    tbp.Parent       = tb
    
    local TextBoxObj = {Instance = tb}
    
    function TextBoxObj:Set(text)
        tb.Text = tostring(text)
        if flag then Library.Flags[flag] = tb.Text end
    end
    function TextBoxObj:Get() return tb.Text end
    
    tb.FocusLost:Connect(function(enterPressed)
        local val = tb.Text:gsub("^%s+",""):gsub("%s+$","")
        tb.Text = val
        if flag then Library.Flags[flag] = val end
        if config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback, val, enterPressed)
                if not ok then warn("[DivaUI] TextBox callback error: "..tostring(err)) end
            end)
        end
    end)
    
    if flag then Library.Flags[flag] = default end
    self._ApplyTheme()
    return TextBoxObj
end

--==[ CreateColorPicker (swatch-based) ]==--
function Library._TabMethods:CreateColorPicker(config)
    config = config or {}
    
    local name    = config.Name or "Color"
    local flag    = config.Flag or name
    local colors  = config.Colors or Library.HighlightColors
    local default = config.Default or colors[1].Color
    
    local selectedIdx = 1
    for i, c in ipairs(colors) do
        if c.Color == default then selectedIdx = i break end
    end
    
    -- Wrapper
    local w = CreateWrap(self.Page, name, 50)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1,0,0,16)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = name
    lbl.TextSize               = 11
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = w
    self._RegText(lbl, false)
    
    -- Container for swatches
    local container = Instance.new("Frame")
    container.Size                   = UDim2.new(1,0,0,30)
    container.Position               = UDim2.new(0,0,0,18)
    container.BackgroundTransparency = 1
    container.Parent                 = w
    
    local layout = Instance.new("UIGridLayout")
    layout.CellSize            = UDim2.new(0,22,0,22)
    layout.CellPadding         = UDim2.new(0,4,0,4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Parent              = container
    
    local btns = {}
    local ColorPickerObj = {Instance = container}
    
    local function selectIdx(i, fireCallback)
        selectedIdx = i
        for j, entry in ipairs(btns) do
            entry.ring.Enabled = (j == i)
        end
        if flag then Library.Flags[flag] = colors[i].Color end
        if fireCallback and config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback, colors[i].Color, colors[i].Name)
                if not ok then warn("[DivaUI] ColorPicker callback error: "..tostring(err)) end
            end)
        end
    end
    
    function ColorPickerObj:Set(color)
        for i, c in ipairs(colors) do
            if c.Color == color then
                selectIdx(i, true)
                return
            end
        end
    end
    function ColorPickerObj:Get() return colors[selectedIdx].Color end
    
    for i, colorEntry in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.Size             = UDim2.new(0,22,0,22)
        b.BackgroundColor3 = colorEntry.Color
        b.Text             = ""
        b.BorderSizePixel  = 0
        b.AutoButtonColor  = false
        b.Parent           = container
        
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0,4)
        bc.Parent       = b
        
        local ring = Instance.new("UIStroke")
        ring.Thickness = 2
        ring.Color     = Color3.new(1,1,1)
        ring.Enabled   = (i == selectedIdx)
        ring.Parent    = b
        
        btns[i] = {btn=b, ring=ring}
        
        local capturedI = i
        b.MouseButton1Click:Connect(function()
            selectIdx(capturedI, true)
        end)
    end
    
    if flag then Library.Flags[flag] = colors[selectedIdx].Color end
    self._ApplyTheme()
    return ColorPickerObj
end

--==[ CreateKeybind ]==--
function Library._TabMethods:CreateKeybind(config)
    config = config or {}
    
    local name    = config.Name or "Keybind"
    local default = config.Default or Enum.KeyCode.E
    local flag    = config.Flag or name
    
    local currentKey = default
    local listening  = false
    
    local w = CreateWrap(self.Page, name, 32)
    
    local btn = Instance.new("TextButton")
    btn.Name     = "Keybind"
    btn.Size     = UDim2.new(1,0,1,0)
    btn.Text     = name.." : ["..tostring(currentKey.Name).."]"
    btn.TextSize = 12
    btn.Parent   = w
    self._RegBtn(btn, false)
    
    local bc = Instance.new("UICorner")
    bc.Parent = btn
    self._RegCorner(bc)
    
    local KeybindObj = {Instance = btn}
    
    function KeybindObj:Set(keycode)
        currentKey = keycode
        btn.Text = name.." : ["..tostring(currentKey.Name).."]"
        if flag then Library.Flags[flag] = currentKey end
    end
    function KeybindObj:Get() return currentKey end
    
    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        btn.Text = name.." : [Press a key...]"
        
        local conn
        conn = Services.UserInputService.InputBegan:Connect(function(input, gp)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            
            if input.KeyCode == Enum.KeyCode.Escape then
                listening = false
                btn.Text = name.." : ["..tostring(currentKey.Name).."]"
                conn:Disconnect()
                return
            end
            
            currentKey = input.KeyCode
            btn.Text = name.." : ["..tostring(currentKey.Name).."]"
            if flag then Library.Flags[flag] = currentKey end
            listening = false
            conn:Disconnect()
        end)
    end)
    
    -- Listen for the keybind press globally
    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp or listening then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == currentKey and config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback, currentKey)
                if not ok then warn("[DivaUI] Keybind callback error: "..tostring(err)) end
            end)
        end
    end)
    
    if flag then Library.Flags[flag] = currentKey end
    self._ApplyTheme()
    return KeybindObj
end

--==[ CreateMobileButton (плавающая кнопка на экране) ]==--
function Library:CreateMobileButton(config)
    config = config or {}
    
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name           = GenStr(10)
    btnGui.ResetOnSpawn   = false
    btnGui.IgnoreGuiInset = true
    btnGui.DisplayOrder   = 9
    btnGui.Parent         = Services.CoreGui
    
    local btn = Instance.new("TextButton")
    btn.Name                   = config.Name or "MobileBtn"
    btn.Size                   = UDim2.new(0, config.Size or 55, 0, config.Size or 55)
    btn.Position               = config.Position or UDim2.new(1,-75,0.5,-27)
    btn.BackgroundColor3       = config.Color or Color3.fromRGB(40,40,50)
    btn.BackgroundTransparency = 0.25
    btn.Text                   = config.Icon or "⚙"
    btn.TextColor3             = Color3.new(1,1,1)
    btn.TextSize               = config.TextSize or 26
    btn.Font                   = Enum.Font.GothamBold
    btn.BorderSizePixel        = 0
    btn.AutoButtonColor        = false
    btn.Parent                 = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color        = Color3.fromRGB(255,255,255)
    stroke.Thickness    = 2
    stroke.Transparency = 0.4
    stroke.Parent       = btn
    
    -- Drag + click logic
    local touching, moved = false, false
    local startTouchPos, startBtnPos
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            touching      = true
            moved         = false
            startTouchPos = input.Position
            startBtnPos   = btn.Position
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if touching and (input.UserInputType == Enum.UserInputType.Touch
                      or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - startTouchPos
            if delta.Magnitude > 15 then
                moved = true
                btn.Position = UDim2.new(
                    startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X,
                    startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if touching then
                touching = false
                if not moved and config.Callback then
                    task.spawn(function()
                        local ok, err = pcall(config.Callback, btn)
                        if not ok then warn("[DivaUI] MobileBtn callback error: "..tostring(err)) end
                    end)
                end
            end
        end
    end)
    
    local MobileBtnObj = {Instance = btn, Gui = btnGui}
    function MobileBtnObj:SetIcon(text) btn.Text = tostring(text) end
    function MobileBtnObj:SetColor(c)   btn.BackgroundColor3 = c end
    function MobileBtnObj:Destroy()     btnGui:Destroy() end
    return MobileBtnObj
end

--==[ Destroy entire library ]==--
function Library:Destroy()
    for _, win in ipairs(self.Windows) do
        pcall(function() win:Destroy() end)
    end
    self.Windows = {}
    self.Flags   = {}
    shared.__DivaUI_Destroy = nil
end

--==[ Register destroy for anti-double-load ]==--
shared.__DivaUI_Destroy = function() Library:Destroy() end

--==[ Expose globally for easy access ]==--
getgenv().DivaUI = Library

--==[ Return ]==--
return Library
