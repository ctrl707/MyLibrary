local DivaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ctrl707/MyLibrary/main/loader.lua"))()

local Services = {
    Players          = game:GetService("Players"),
    RunService       = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService     = game:GetService("TweenService"),
    StarterGui       = game:GetService("StarterGui"),
    HttpService      = game:GetService("HttpService"),
    CoreGui          = game:GetService("CoreGui"),
    Lighting         = game:GetService("Lighting"),
    ContextActionService = game:GetService("ContextActionService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local isMobile    = Services.UserInputService.TouchEnabled

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local function GenStr(len)
    len = len or math.random(18, 35)
    local c = "abcdefghijklmnopqrstuvwxyz0123456789"
    local r = {}
    for i = 1, len do local p = math.random(1,#c) r[i] = c:sub(p,p) end
    return table.concat(r)
end

local function Notify(t, txt, dur)
    DivaUI:Notify({Title=t, Content=txt, Duration=dur or 3})
end

local DIVA_MARKER = "_DIVA_RUNNING"
if shared[DIVA_MARKER] then
    local oldDestroy = shared[DIVA_MARKER]
    if type(oldDestroy) == "function" then pcall(oldDestroy) end
    task.wait(0.3)
end

local GlobalHLFolder = Instance.new("Folder")
GlobalHLFolder.Name = GenStr()
GlobalHLFolder.Parent = Services.CoreGui

local GlobalInputConns = {Changed=nil, Ended=nil, TouchEnded=nil}
local InputListeners = {Changed={}, Ended={}, TouchEnded={}}

local function AddInputListener(eventName, fn)
    table.insert(InputListeners[eventName], fn)
end
local function RemoveInputListener(eventName, fn)
    for i = #InputListeners[eventName], 1, -1 do
        if InputListeners[eventName][i] == fn then
            table.remove(InputListeners[eventName], i)
        end
    end
end

GlobalInputConns.Changed = Services.UserInputService.InputChanged:Connect(function(input)
    for _, fn in ipairs(InputListeners.Changed) do pcall(fn, input) end
end)
GlobalInputConns.Ended = Services.UserInputService.InputEnded:Connect(function(input)
    for _, fn in ipairs(InputListeners.Ended) do pcall(fn, input) end
end)
GlobalInputConns.TouchEnded = Services.UserInputService.TouchEnded:Connect(function(touch, processed)
    for _, fn in ipairs(InputListeners.TouchEnded) do pcall(fn, touch, processed) end
end)

local S = {
    Enabled=false, TargetPart="Head", Sensitivity=0.2, FOV=150,
    TeamCheck=false, ThroughWalls=false, FlyEnabled=false, NoClipEnabled=false,
    FlySpeed=20.0, WalkSpeed=16, JumpPower=50, CameraFOV=70,
    EspEnabled=false, TargetColor=Color3.fromRGB(255,0,0),
    EspHealthColor=Color3.fromRGB(0,255,0),
    EspFillTransparency=0.5, EspMaxDistance=5000, TargetNPCs=false,
    EspNPCEnabled=false, EspNPCAlias="NPC", OffsetX=0, OffsetY=0,
    NameDisplayMode="DisplayName", XrayEnabled=false, ToolNotifyEnabled=false,
    XrayPlayers=false, HighlightMode="OFF",
    HighlightColor=Color3.fromRGB(255,255,255),
    UseTeamColor=false, TeamCheckHL=false,
    NPCHighlightMode="OFF", FullBrightEnabled=false,
    TriggerWordsEnabled=false, TriggerWords={},
    TriggerFuzzy=false, TriggerDisplayMode="Hint",
    ShowRobloxNames=false,
    CarFlyEnabled=false, CarFlySpeed=50,
    ForceSpeedEnabled=false, ForceSpeedValue=16, ForceSpeedMethod=1,
    ForceSpeedMethodName="Velocity",
    ShiftLockEnabled=false,
    ZoomMin=0.5, ZoomMax=128,
    ScaffoldEnabled=false, ScaffoldX=2, ScaffoldY=1, ScaffoldZ=2,
    TriggerbotEnabled=false, TriggerbotKey="MouseButton1", TriggerbotDelay=0.1,
    AutoSaveEnabled=false,
    FlingInvis=false, AntiSlipEnabled=false, AntiSlipMode="StopOnly",
    WaterBlockEnabled=false, WalkOnWater=false, SwimUnder=false,
    ForceApplyEnabled=false,
}

local AntiSlipModes = {"StopOnly","Full"}

local R = {
    LockedTarget=nil,
    FlingActive=false, FlingTargets={}, FlingInvis=false,
    SaveEnabled=false, SaveIntIdx=1, SaveInterval=60,
    SaveDir="diva_saves", CurSlot=1,
    OldPos=nil, FPDH=workspace.FallenPartsDestroyHeight,
    FlyBV=nil, FlyPos=nil, FlyGyro=nil, CharParts={},
    MobileAiming=false, RenderName=nil,
    CarFlyBV=nil, CarFlyBG=nil, CarFlyConn=nil,
    ForceSpeedConn=nil, ForceBV=nil,
    ShiftLockActive=nil, ShiftLockEnabledByUser=false,
    ShiftPCConn=nil,
    MobileShiftBtn=nil, MobileShiftGui=nil,
    MobileShiftCASBound=false,
    MobileAimGui=nil,
    ForceApplyConn=nil,
    ScaffoldPart=nil, ScaffoldConn=nil,
    TriggerbotRunning=false, AntiSlipConn=nil,
}

local AS = {
    Running=false, Jumping=false, Freefall=false, Landed=false,
    Climbing=false, Swimming=false, Seated=false, Dead=false,
    FallingDown=false, Ragdoll=false, GettingUp=false,
    PlatformStanding=false, Flying=false, Physics=false,
}

local AntiStateList = {
    {Key="Running",          Enum=Enum.HumanoidStateType.Running,          Label="Anti-Running"},
    {Key="Jumping",          Enum=Enum.HumanoidStateType.Jumping,          Label="Anti-Jump"},
    {Key="Freefall",         Enum=Enum.HumanoidStateType.Freefall,         Label="Anti-Freefall"},
    {Key="Landed",           Enum=Enum.HumanoidStateType.Landed,           Label="Anti-Landed"},
    {Key="Climbing",         Enum=Enum.HumanoidStateType.Climbing,         Label="Anti-Climb"},
    {Key="Swimming",         Enum=Enum.HumanoidStateType.Swimming,         Label="Anti-Swim"},
    {Key="Seated",           Enum=Enum.HumanoidStateType.Seated,           Label="Anti-Sit"},
    {Key="Dead",             Enum=Enum.HumanoidStateType.Dead,             Label="Anti-Dead"},
    {Key="FallingDown",      Enum=Enum.HumanoidStateType.FallingDown,      Label="Anti-FallDown"},
    {Key="Ragdoll",          Enum=Enum.HumanoidStateType.Ragdoll,          Label="Anti-Ragdoll"},
    {Key="GettingUp",        Enum=Enum.HumanoidStateType.GettingUp,        Label="Anti-GettingUp"},
    {Key="PlatformStanding", Enum=Enum.HumanoidStateType.PlatformStanding, Label="Anti-Platform"},
    {Key="Flying",           Enum=Enum.HumanoidStateType.Flying,           Label="Anti-Fly"},
    {Key="Physics",          Enum=Enum.HumanoidStateType.Physics,          Label="Anti-Physics"},
}

local HighlightColors = DivaUI.HighlightColors

local SaveIntervals = {
    {Name="1 min",  Time=60},
    {Name="5 min",  Time=300},
    {Name="1 hour", Time=3600},
}

local FOVStyles = {"Normal","Thick","Filled"}
local FOVStyleIdx = 1

local TriggerbotKeys = {
    "MouseButton1","MouseButton2","E","F","Q","R","T","Z","X","C","V","B","G","H"
}

local ForceSpeedMethodNames = {"Velocity","CFrame","BodyVelocity","All Methods"}

local char     = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root     = char:WaitForChild("HumanoidRootPart", 10)
local humanoid = char:WaitForChild("Humanoid", 10)
if humanoid then
    S.WalkSpeed = humanoid.WalkSpeed
    S.JumpPower = humanoid.JumpPower
end

local function UpdateCharCache(c)
    R.CharParts = {}
    if not c then return end
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(R.CharParts, v) end
    end
end
UpdateCharCache(char)

local Scheduler = {_tasks={}}
function Scheduler:Register(n, fn) self._tasks[n] = fn end
function Scheduler:Unregister(n) self._tasks[n] = nil end
function Scheduler:Update(dt) for _, fn in pairs(self._tasks) do fn(dt) end end

local DrawPool = {_s={}, _t={}, _l={}, LIMIT=40}
function DrawPool:Get(d)
    local p = d=="Square" and self._s or d=="Text" and self._t or self._l
    if #p > 0 then local o=table.remove(p) o.Visible=false return o end
    local o = Drawing.new(d) o.Visible=false return o
end
function DrawPool:Return(d, o)
    if not o then return end
    o.Visible=false
    local p = d=="Square" and self._s or d=="Text" and self._t or self._l
    if #p < self.LIMIT then table.insert(p,o)
    else pcall(function() o:Remove() end) end
end
function DrawPool:Clear()
    for _, pool in pairs({self._s, self._t, self._l}) do
        for _, o in ipairs(pool) do pcall(function() o:Remove() end) end
    end
    self._s={} self._t={} self._l={}
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible=false FOVCircle.Radius=S.FOV
FOVCircle.Thickness=1 FOVCircle.Color=S.TargetColor FOVCircle.Filled=false

local function ApplyFOVStyle()
    local st = FOVStyles[FOVStyleIdx]
    if st == "Normal" then FOVCircle.Thickness=1 FOVCircle.Filled=false
    elseif st == "Thick" then FOVCircle.Thickness=3 FOVCircle.Filled=false
    elseif st == "Filled" then FOVCircle.Thickness=1 FOVCircle.Filled=true end
end
ApplyFOVStyle()

local FPSData = {samples={}, idx=0, accum=0, current=60, count=30}
local function UpdateFPS(dt)
    FPSData.idx = (FPSData.idx % FPSData.count) + 1
    FPSData.samples[FPSData.idx] = dt
    FPSData.accum = FPSData.accum + dt
    if FPSData.accum >= 0.5 then
        FPSData.accum = 0
        local t, n = 0, math.min(#FPSData.samples, FPSData.count)
        for i=1,n do t = t + FPSData.samples[i] end
        if n>0 and t>0 then FPSData.current = n/t end
    end
end

local function IsVisible(targetPart)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent, cam}
    local origin = cam.CFrame.Position
    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, params)
    if not result then return true end
    if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return (result.Position - origin).Magnitude > direction.Magnitude - 0.5
end

local ESP = {
    Tracked  = setmetatable({},{__mode="k"}),
    DrawData = setmetatable({},{__mode="k"}),
    R15 = {"Head","HumanoidRootPart","LeftFoot","RightFoot","LeftHand","RightHand"},
    R6  = {"Head","Torso","Left Leg","Right Leg","Left Arm","Right Arm"},
}

function ESP:GetParts(chr) return chr:FindFirstChild("UpperTorso") and self.R15 or self.R6 end

function ESP:CreateDraw(chr)
    if self.DrawData[chr] then return end
    local d = {
        Box=DrawPool:Get("Square"), Name=DrawPool:Get("Text"),
        HP=DrawPool:Get("Text"), Dist=DrawPool:Get("Text"),
        Tracer=DrawPool:Get("Line"),
    }
    d.Name.Center=true d.Name.Font=Drawing.Fonts.UI d.Name.Size=13
    d.HP.Center=true   d.HP.Font=Drawing.Fonts.UI   d.HP.Size=12
    d.Dist.Center=true d.Dist.Font=Drawing.Fonts.UI d.Dist.Size=11
    self.DrawData[chr] = d
end

function ESP:RemoveDraw(chr)
    local d = self.DrawData[chr]
    if not d then return end
    DrawPool:Return("Square",d.Box) DrawPool:Return("Text",d.Name)
    DrawPool:Return("Text",d.HP) DrawPool:Return("Text",d.Dist)
    DrawPool:Return("Line",d.Tracer)
    self.DrawData[chr] = nil
end

function ESP:Hide(chr)
    local d = self.DrawData[chr]
    if not d then return end
    d.Box.Visible=false d.Name.Visible=false
    d.HP.Visible=false d.Dist.Visible=false d.Tracer.Visible=false
end

function ESP:UpdateDraw(chr, data, isTarget)
    if not chr or not chr.Parent then self:Hide(chr) return end
    local d = self.DrawData[chr]
    if not d then return end
    local wantESP
    if data.IsNPC then wantESP = S.EspNPCEnabled else wantESP = S.EspEnabled end
    if not wantESP then self:Hide(chr) if data.Highlight then data.Highlight.Enabled = false end return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    local hum = data.Humanoid
    if not hrp or not hum or not hum.Parent or hum.Health <= 0 then self:Hide(chr) return end
    local camPos = Camera.CFrame.Position
    local dist = (hrp.Position - camPos).Magnitude
    if dist > S.EspMaxDistance then self:Hide(chr) return end

    local minX,minY,maxX,maxY = math.huge,math.huge,-math.huge,-math.huge
    local any = false
    local MAX_PART_SIZE = 15
    for _, pn in ipairs(self:GetParts(chr)) do
        local part = chr:FindFirstChild(pn)
        if part and part:IsA("BasePart") then
            local sz = part.Size
            if part.Transparency < 0.95 and sz.X <= MAX_PART_SIZE and sz.Y <= MAX_PART_SIZE and sz.Z <= MAX_PART_SIZE then
                local cf = part.CFrame
                local hx,hy,hz = sz.X*0.5, sz.Y*0.5, sz.Z*0.5
                local corners = {
                    cf:PointToWorldSpace(Vector3.new( hx, hy, hz)),
                    cf:PointToWorldSpace(Vector3.new(-hx, hy, hz)),
                    cf:PointToWorldSpace(Vector3.new( hx,-hy, hz)),
                    cf:PointToWorldSpace(Vector3.new(-hx,-hy, hz)),
                    cf:PointToWorldSpace(Vector3.new( hx, hy,-hz)),
                    cf:PointToWorldSpace(Vector3.new(-hx, hy,-hz)),
                    cf:PointToWorldSpace(Vector3.new( hx,-hy,-hz)),
                    cf:PointToWorldSpace(Vector3.new(-hx,-hy,-hz)),
                }
                for _, c in ipairs(corners) do
                    local sv, on = Camera:WorldToViewportPoint(c)
                    if on then any=true
                        minX=math.min(minX,sv.X) minY=math.min(minY,sv.Y)
                        maxX=math.max(maxX,sv.X) maxY=math.max(maxY,sv.Y)
                    end
                end
            end
        end
    end
    if not any then
        local cf = hrp.CFrame
        local corners = {
            cf:PointToWorldSpace(Vector3.new( 1, 1, 0.5)),
            cf:PointToWorldSpace(Vector3.new(-1, 1, 0.5)),
            cf:PointToWorldSpace(Vector3.new( 1,-1, 0.5)),
            cf:PointToWorldSpace(Vector3.new(-1,-1, 0.5)),
            cf:PointToWorldSpace(Vector3.new( 1, 1,-0.5)),
            cf:PointToWorldSpace(Vector3.new(-1, 1,-0.5)),
            cf:PointToWorldSpace(Vector3.new( 1,-1,-0.5)),
            cf:PointToWorldSpace(Vector3.new(-1,-1,-0.5)),
        }
        for _, c in ipairs(corners) do
            local sv, on = Camera:WorldToViewportPoint(c)
            if on then any=true
                minX=math.min(minX,sv.X) minY=math.min(minY,sv.Y)
                maxX=math.max(maxX,sv.X) maxY=math.max(maxY,sv.Y)
            end
        end
    end
    if not any or minX >= maxX or minY >= maxY then self:Hide(chr) return end
    if (maxX-minX) > 400 or (maxY-minY) > 400 then self:Hide(chr) return end

    minX,minY,maxX,maxY = minX-3,minY-3,maxX+3,maxY+3
    local w  = maxX-minX
    local cx = (minX+maxX)*0.5

    d.Box.Size     = Vector2.new(w, maxY-minY)
    d.Box.Position = Vector2.new(minX, minY)
    d.Box.Color    = isTarget and S.TargetColor or Color3.new(1,1,1)
    d.Box.Visible  = true

    local dn = ""
    if data.Player then
        if S.NameDisplayMode == "DisplayName" then
            dn = "["..(data.Player.DisplayName or data.Player.Name).."]"
        elseif S.NameDisplayMode == "Both" then
            dn = "["..(data.Player.DisplayName or data.Player.Name).."] "..data.Player.Name
        else dn = data.Player.Name end
    else dn = S.EspNPCAlias end
    if isTarget then dn = dn.." [Target]" end

    d.Name.Text     = dn
    d.Name.Position = Vector2.new(cx, minY-18)
    d.Name.Color    = isTarget and S.TargetColor or Color3.new(1,1,1)
    d.Name.Visible  = true

    if FPSData.current < 10 then
        d.HP.Visible=false d.Dist.Visible=false d.Tracer.Visible=false return
    end

    local hp  = math.floor(hum.Health)
    local mhp = hum.MaxHealth
    if mhp <= 0 then mhp = 100 end
    if hp > mhp then mhp = hp end

    d.HP.Text     = hp.."/"..math.floor(mhp)
    d.HP.Position = Vector2.new(cx, maxY+4)
    d.HP.Color    = S.EspHealthColor d.HP.Visible = true

    d.Dist.Text     = math.floor(dist).."m"
    d.Dist.Position = Vector2.new(cx, maxY+18)
    d.Dist.Color    = Color3.fromRGB(200,200,200)
    d.Dist.Visible  = true

    local localChar = LocalPlayer.Character
    local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local tracerFrom, showTracer = nil, true
    if localHRP then
        local camDist = (Camera.CFrame.Position - localHRP.Position).Magnitude
        if camDist < 2 then
            tracerFrom = Vector2.new(math.floor(Camera.ViewportSize.X*0.5), math.floor(Camera.ViewportSize.Y))
        else
            local fp, fon = Camera:WorldToViewportPoint(localHRP.Position)
            if fon then tracerFrom = Vector2.new(math.floor(fp.X), math.floor(fp.Y))
            else showTracer = false end
        end
    else showTracer = false end
    if showTracer and tracerFrom then
        d.Tracer.From      = tracerFrom
        d.Tracer.To        = Vector2.new(math.floor(cx), math.floor(maxY))
        d.Tracer.Color     = isTarget and S.TargetColor or Color3.fromRGB(160,160,160)
        d.Tracer.Thickness = 1 d.Tracer.Visible = true
    else d.Tracer.Visible = false end
end

function ESP:Track(chr, player)
    if chr == LocalPlayer.Character or self.Tracked[chr] then return end
    if not player and Services.Players:GetPlayerFromCharacter(chr) then return end
    local hrp, hum
    if player then
        hrp = chr:WaitForChild("HumanoidRootPart", 10)
        hum = chr:WaitForChild("Humanoid", 10)
    else
        hrp = chr:FindFirstChild("HumanoidRootPart")
        hum = chr:FindFirstChildOfClass("Humanoid")
    end
    if not hrp or not hum or not hum.Parent then return end
    local data = {Humanoid=hum, IsNPC=not player, Player=player, Highlight=nil, Conns={}, NextUpdate=0}
    self.Tracked[chr] = data
    self:CreateDraw(chr)
    data.Conns.died = hum.Died:Connect(function()
        task.defer(function()
            self:Hide(chr)
            if data.Highlight then data.Highlight.Enabled = false end
            data.NextUpdate = math.huge
            task.wait(0.5)
            self:Untrack(chr)
        end)
    end)
    data.Conns.ancestry = chr.AncestryChanged:Connect(function(_,np)
        if np == nil then task.defer(function() self:Untrack(chr) end) end
    end)
end

function ESP:Untrack(chr)
    local data = self.Tracked[chr]
    if not data then return end
    for _, c in pairs(data.Conns) do
        if c then pcall(function() c:Disconnect() end) end
    end
    self:RemoveDraw(chr)
    if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
    self.Tracked[chr] = nil
end

function ESP:ApplyHL(hl, mode, color)
    if not hl then return end
    local newFill, newOutline, newFillT, newOutlineT
    if mode == "HIGHLIGHT" then
        newFill = color newOutline = color
        newFillT = S.EspFillTransparency newOutlineT = 0
    elseif mode == "WO_CHAMS" then
        newFill = color newOutline = color
        newFillT = 0 newOutlineT = 1
    elseif mode == "CHAMS" then
        newFill = color newOutline = Color3.new(0,0,0)
        newFillT = 0 newOutlineT = 0
    else return end
    if hl.FillColor ~= newFill then hl.FillColor = newFill end
    if hl.OutlineColor ~= newOutline then hl.OutlineColor = newOutline end
    if hl.FillTransparency ~= newFillT then hl.FillTransparency = newFillT end
    if hl.OutlineTransparency ~= newOutlineT then hl.OutlineTransparency = newOutlineT end
end

function ESP:CreateHL(chr, data)
    if data.Highlight then
        pcall(function() data.Highlight:Destroy() end)
        data.Highlight = nil
    end
    local hl = Instance.new("Highlight")
    hl.Name = GenStr()
    hl.Adornee = chr
    hl.Enabled = false
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = S.EspFillTransparency
    hl.OutlineTransparency = 0
    hl.Parent = GlobalHLFolder
    data.Highlight = hl
end

function ESP:UpdateHL(chr, data, isTarget)
    if not data then return end
    local mode = data.IsNPC and S.NPCHighlightMode or S.HighlightMode
    if mode == "OFF" then
        if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
        return
    end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp or not data.Humanoid or data.Humanoid.Health <= 0 then
        if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
        return
    end
    if (hrp.Position - Camera.CFrame.Position).Magnitude > S.EspMaxDistance then
        if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
        return
    end
    if not data.Highlight or not data.Highlight.Parent then self:CreateHL(chr, data) end
    local hl = data.Highlight
    if hl.Adornee ~= chr then hl.Adornee = chr end
    local color
    if isTarget then color = S.TargetColor
    elseif not data.IsNPC and data.Player and data.Player.Team then
        if S.UseTeamColor then color = data.Player.TeamColor.Color
        elseif data.Player.Team == LocalPlayer.Team then color = Color3.fromRGB(0,255,0)
        else color = S.HighlightColor end
    else color = S.HighlightColor end
    local fillT = (mode == "HIGHLIGHT") and S.EspFillTransparency or 0
    local outT  = (mode == "WO_CHAMS") and 1 or 0
    if hl.FillColor ~= color then hl.FillColor = color end
    if hl.OutlineColor ~= color then hl.OutlineColor = color end
    if hl.FillTransparency ~= fillT then hl.FillTransparency = fillT end
    if hl.OutlineTransparency ~= outT then hl.OutlineTransparency = outT end
    if not hl.Enabled then hl.Enabled = true end
end

function ESP:Update(dt)
    local now = tick()
    local camPos = Camera.CFrame.Position
    local sorted = {}
    for chr, data in pairs(self.Tracked) do
        if not chr.Parent then
            task.defer(function() self:Untrack(chr) end)
        else
            local isT = (chr == R.LockedTarget)
            self:UpdateDraw(chr, data, isT)
            local hrp = chr:FindFirstChild("HumanoidRootPart")
            local d = hrp and (hrp.Position - camPos).Magnitude or 9999
            table.insert(sorted, {chr=chr, data=data, isT=isT, dist=d})
        end
    end
    table.sort(sorted, function(a, b) return a.dist < b.dist end)
    local hlCount = 0
    local HL_LIMIT = 255
    for _, entry in ipairs(sorted) do
        if hlCount < HL_LIMIT or entry.isT then
            self:UpdateHL(entry.chr, entry.data, entry.isT)
            if entry.data.Highlight and entry.data.Highlight.Enabled then hlCount = hlCount + 1 end
        else
            if entry.data.Highlight and entry.data.Highlight.Enabled then entry.data.Highlight.Enabled = false end
        end
    end
end

function ESP:Destroy()
    for chr in pairs(self.Tracked) do self:Untrack(chr) end
    pcall(function() GlobalHLFolder:ClearAllChildren() end)
end

local AntiStateConns = {}
local AntiThingAdded = {}

local function ApplyAntiStates()
    local c = LocalPlayer.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, conn in pairs(AntiStateConns) do if conn then conn:Disconnect() end end
    AntiStateConns = {}
    for _, entry in ipairs(AntiThingAdded) do
        local enabled = AS[entry.Key]
        pcall(function() hum:SetStateEnabled(entry.Enum, not enabled) end)
    end
    if AS.Seated then
        pcall(function()
            if hum.Sit then hum.Sit=false end
            if hum.SeatPart then hum.Jump=true end
        end)
        AntiStateConns.sitChanged = hum:GetPropertyChangedSignal("Sit"):Connect(function()
            if AS.Seated and hum.Sit then hum.Sit=false end
        end)
        AntiStateConns.seatChanged = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
            if AS.Seated and hum.SeatPart then hum.Jump=true end
        end)
    end
end

local NameProtectConns = setmetatable({},{__mode="k"})
local function ProtectHumanoidName(hum)
    if not hum or NameProtectConns[hum] then return end
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    NameProtectConns[hum] = hum:GetPropertyChangedSignal("DisplayDistanceType"):Connect(function()
        if not S.ShowRobloxNames and hum.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end)
end

local function SetDefaultNamesVisible(visible)
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if visible then
                    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
                    if NameProtectConns[hum] then
                        NameProtectConns[hum]:Disconnect() NameProtectConns[hum]=nil
                    end
                else ProtectHumanoidName(hum) end
            end
        end
    end
end

local Trigger = {}
function Trigger:Check(toolName)
    if not S.TriggerWordsEnabled or #S.TriggerWords == 0 then return false end
    local lower = toolName:lower()
    for _, word in ipairs(S.TriggerWords) do
        local lw = word:lower()
        if lower == lw then return true, word end
        if S.TriggerFuzzy and lower:find(lw,1,true) then return true, word end
    end
    return false
end
function Trigger:Alert(pName, toolName, matched)
    local text = pName.." has ["..toolName.."] (trigger: "..matched..")"
    if S.TriggerDisplayMode == "Hint" then
        local h = Instance.new("Hint") h.Text=text h.Parent=workspace
        task.delay(4, function() if h and h.Parent then h:Destroy() end end)
    elseif S.TriggerDisplayMode == "Message" then
        local m = Instance.new("Message") m.Text=text m.Parent=workspace
        task.delay(4, function() if m and m.Parent then m:Destroy() end end)
    else Notify("TRIGGER", text, 5) end
end

local Xray = {
    Conns={},
    OrigT=setmetatable({},{__mode="k"}),
    OrigI=setmetatable({},{__mode="k"}),
    OrigB=setmetatable({},{__mode="k"}),
}
function Xray:SetObj(obj, apply)
    if not obj then return end
    local lc = LocalPlayer.Character
    if lc and obj:IsDescendantOf(lc) then return end
    if not S.XrayPlayers then
        local p = obj.Parent
        while p and p ~= workspace do
            if Services.Players:GetPlayerFromCharacter(p) then return end
            p = p.Parent
        end
    end
    if obj:IsA("BasePart") and obj.Transparency < 0.5 then
        if apply and not self.OrigT[obj] then self.OrigT[obj]=obj.Transparency end
        obj.Transparency = apply and 0.5 or (self.OrigT[obj] or 0)
    elseif (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.ImageTransparency < 0.5 then
        if apply and not self.OrigI[obj] then self.OrigI[obj]=obj.ImageTransparency end
        obj.ImageTransparency = apply and 0.5 or (self.OrigI[obj] or 0)
    elseif (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("Frame")) and obj.BackgroundTransparency < 0.5 then
        if apply and not self.OrigB[obj] then self.OrigB[obj]=obj.BackgroundTransparency end
        obj.BackgroundTransparency = apply and 0.5 or (self.OrigB[obj] or 0)
    end
end
function Xray:Apply()
    if not S.XrayEnabled then return end
    self:Cleanup()
    for _, obj in ipairs(workspace:GetDescendants()) do self:SetObj(obj,true) end
    self.Conns.added = workspace.DescendantAdded:Connect(function(d)
        if S.XrayEnabled then task.defer(function() task.wait(0.02) self:SetObj(d,true) end) end
    end)
    self.Conns.removing = workspace.DescendantRemoving:Connect(function(d)
        self.OrigT[d]=nil self.OrigI[d]=nil self.OrigB[d]=nil
    end)
end
function Xray:Cleanup()
    for k, c in pairs(self.Conns) do
        if c then pcall(function() c:Disconnect() end) end
        self.Conns[k] = nil
    end
end
function Xray:Remove()
    self:Cleanup()
    for o,t in pairs(self.OrigT) do if o and o.Parent then o.Transparency=t end end
    for o,t in pairs(self.OrigI) do if o and o.Parent then o.ImageTransparency=t end end
    for o,t in pairs(self.OrigB) do if o and o.Parent then o.BackgroundTransparency=t end end
    self.OrigT=setmetatable({},{__mode="k"})
    self.OrigI=setmetatable({},{__mode="k"})
    self.OrigB=setmetatable({},{__mode="k"})
end

local FullBright = { Conns = {}, GameLighting = {}, EffectData = setmetatable({}, {__mode = "k"}) }

function FullBright:CaptureGameState()
    local L = Services.Lighting

    self.GameLighting.Ambient = L.Ambient
    self.GameLighting.Brightness = L.Brightness
    self.GameLighting.ClockTime = L.ClockTime
    self.GameLighting.FogEnd = L.FogEnd
    self.GameLighting.GlobalShadows = L.GlobalShadows

    self.EffectData = setmetatable({}, {__mode = "k"})

    for _, fx in ipairs(L:GetChildren()) do
        if fx:IsA("Atmosphere") then
            self.EffectData[fx] = {
                Density = fx.Density,
                Offset = fx.Offset,
                Color = fx.Color,
                Decay = fx.Decay,
                Glare = fx.Glare,
                Haze = fx.Haze,
            }
        elseif fx:IsA("ColorCorrectionEffect") then
            self.EffectData[fx] = {
                Enabled = fx.Enabled,
                Brightness = fx.Brightness,
                Contrast = fx.Contrast,
                Saturation = fx.Saturation,
                TintColor = fx.TintColor,
            }
        elseif fx:IsA("BloomEffect") then
            self.EffectData[fx] = {
                Enabled = fx.Enabled,
                Intensity = fx.Intensity,
                Size = fx.Size,
                Threshold = fx.Threshold,
            }
        end
    end
end

function FullBright:ApplyFullBright()
    local L = Services.Lighting

    L.Ambient = Color3.fromRGB(255,255,255)
    L.Brightness = 2
    L.ClockTime = 14
    L.FogEnd = 100000
    L.GlobalShadows = false

    for _, fx in ipairs(L:GetChildren()) do
        if fx:IsA("Atmosphere") then
            fx.Density = 0
        elseif fx:IsA("ColorCorrectionEffect") then
            fx.Brightness = 0
            fx.Contrast = 0
        elseif fx:IsA("BloomEffect") then
            fx.Enabled = false
        end
    end
end

function FullBright:Apply()
    local L = Services.Lighting

    self:Cleanup()

    self:CaptureGameState()
    self:ApplyFullBright()

    local function WatchProperty(prop)
        self.Conns[prop] = L:GetPropertyChangedSignal(prop):Connect(function()
            if S.FullBrightEnabled then
                self.GameLighting[prop] = L[prop]
                task.defer(function()
                    if S.FullBrightEnabled then
                        self:ApplyFullBright()
                    end
                end)
            end
        end)
    end

    WatchProperty("Ambient")
    WatchProperty("Brightness")
    WatchProperty("ClockTime")
    WatchProperty("FogEnd")
    WatchProperty("GlobalShadows")

    self.Conns.ChildAdded = L.ChildAdded:Connect(function()
        if S.FullBrightEnabled then
            task.defer(function()
                self:CaptureGameState()
                self:ApplyFullBright()
            end)
        end
    end)
end

function FullBright:Cleanup()
    for _, c in pairs(self.Conns) do
        if c then
            pcall(function()
                c:Disconnect()
            end)
        end
    end

    self.Conns = {}
end

function FullBright:Remove()
    self:Cleanup()

    local L = Services.Lighting

    if self.GameLighting.Ambient then
        L.Ambient = self.GameLighting.Ambient
    end

    if self.GameLighting.Brightness then
        L.Brightness = self.GameLighting.Brightness
    end

    if self.GameLighting.ClockTime then
        L.ClockTime = self.GameLighting.ClockTime
    end

    if self.GameLighting.FogEnd then
        L.FogEnd = self.GameLighting.FogEnd
    end

    if self.GameLighting.GlobalShadows ~= nil then
        L.GlobalShadows = self.GameLighting.GlobalShadows
    end

    for fx, data in pairs(self.EffectData) do
        if fx and fx.Parent then

            if fx:IsA("Atmosphere") then
                for k, v in pairs(data) do
                    pcall(function()
                        fx[k] = v
                    end)
                end

            elseif fx:IsA("ColorCorrectionEffect") then
                for k, v in pairs(data) do
                    pcall(function()
                        fx[k] = v
                    end)
                end

            elseif fx:IsA("BloomEffect") then
                for k, v in pairs(data) do
                    pcall(function()
                        fx[k] = v
                    end)
                end
            end
        end
    end
end

local NoTex = {
    Selected = {
        TEXTURES = false,
        MATERIALS = false,
        PARTICLES = false,
        GUI = false,
        LIGHTS = false,
    },

    OrigT=setmetatable({},{__mode="k"}),
    OrigM=setmetatable({},{__mode="k"}),
    OrigGui=setmetatable({},{__mode="k"}),
    OrigFx=setmetatable({},{__mode="k"}),
    OrigLgt=setmetatable({},{__mode="k"}),

    Conns={},
}
local VisualItems = {
    {Key="TEXTURES",  Label="Textures"},
    {Key="MATERIALS", Label="Materials"},
    {Key="PARTICLES", Label="Particles"},
    {Key="GUI",       Label="GUI"},
    {Key="LIGHTS",    Label="Lights"},
}

function NoTex:ApplyObj(obj)
    local useTextures  = self.Selected.TEXTURES
    local useMaterials = self.Selected.MATERIALS
    local useParticles = self.Selected.PARTICLES
    local useGui       = self.Selected.GUI
    local useLights    = self.Selected.LIGHTS

    local p = obj.Parent
    while p and p ~= workspace do
        if p:FindFirstChildOfClass("Humanoid") then
            return
        end
        p = p.Parent
    end

    -- TEXTURES

    if useTextures then

        if obj:IsA("Texture") or obj:IsA("Decal") then
            if self.OrigT[obj] == nil then
                self.OrigT[obj] = obj.Transparency
            end

            obj.Transparency = 1
            return
        end

        if obj:IsA("MeshPart") and obj.TextureID ~= "" then
            if self.OrigT[obj] == nil then
                self.OrigT[obj] = obj.TextureID
            end

            obj.TextureID = ""
            return
        end
    end

    -- MATERIALS

    if useMaterials and obj:IsA("BasePart") then
        if self.OrigM[obj] == nil then
            self.OrigM[obj] = obj.Material
        end

        obj.Material = Enum.Material.SmoothPlastic
        return
    end

    -- GUI

    if useGui and (
            obj:IsA("BillboardGui")
            or obj:IsA("SurfaceGui")
            or obj:IsA("ViewportFrame")
        ) then

        if self.OrigGui[obj] == nil then
            self.OrigGui[obj] = obj.Enabled
        end

        obj.Enabled = false
        return
    end

    -- PARTICLES

    if useParticles and (
        obj:IsA("ParticleEmitter")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
    ) then

        if self.OrigFx[obj] == nil then
            self.OrigFx[obj] = obj.Enabled
        end

        obj.Enabled = false
        return
    end

    -- LIGHTS

    if useLights and (
        obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight")
    ) then

        if self.OrigLgt[obj] == nil then
            self.OrigLgt[obj] = obj.Enabled
        end

        obj.Enabled = false
        return
    end
end
function NoTex:RestoreAll()

    for obj, value in pairs(self.OrigT) do
        if obj then

            if obj:IsA("Texture") or obj:IsA("Decal") then
                if obj.Parent then
                    obj.Transparency = value
                end

            elseif obj:IsA("MeshPart") then
                if obj.Parent then
                    obj.TextureID = value
                end
            end
        end
    end

    for obj, value in pairs(self.OrigM) do
        if obj and obj.Parent then
            obj.Material = value
        end
    end

    for obj, value in pairs(self.OrigGui) do
        if obj and obj.Parent then
            obj.Enabled = value
        end
    end

    for obj, value in pairs(self.OrigFx) do
        if obj and obj.Parent then
            obj.Enabled = value
        end
    end

    for obj, value in pairs(self.OrigLgt) do
        if obj and obj.Parent then
            obj.Enabled = value
        end
    end

    self.OrigT   = setmetatable({}, {__mode="k"})
    self.OrigM   = setmetatable({}, {__mode="k"})
    self.OrigGui = setmetatable({}, {__mode="k"})
    self.OrigFx  = setmetatable({}, {__mode="k"})
    self.OrigLgt = setmetatable({}, {__mode="k"})
end
function NoTex:Cleanup()
    for _, conn in pairs(self.Conns) do
        if conn then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end

    self.Conns = {}
end
function NoTex:Refresh()

    self:Cleanup()
    self:RestoreAll()

    local enabled = false

    for _, state in pairs(self.Selected) do
        if state then
            enabled = true
            break
        end
    end

    if not enabled then
        return
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        self:ApplyObj(obj)
    end

    self.Conns.added = workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            self:ApplyObj(obj)
        end)
    end)

    self.Conns.removing = workspace.DescendantRemoving:Connect(function(obj)

        self.OrigT[obj] = nil
        self.OrigM[obj] = nil
        self.OrigGui[obj] = nil
        self.OrigFx[obj] = nil
        self.OrigLgt[obj] = nil

    end)
end

local Tools = {
    Data  = setmetatable({},{__mode="k"}),
    Conns = setmetatable({},{__mode="k"}),
}
function Tools:ShowNotif(player, toolName, action)
    if not S.ToolNotifyEnabled then return end
    local dn
    if S.NameDisplayMode=="DisplayName" then dn="["..(player.DisplayName or player.Name).."]"
    elseif S.NameDisplayMode=="Both" then dn="["..(player.DisplayName or player.Name).."] "..player.Name
    else dn=player.Name end
    Notify("Tool", dn.." "..(action=="equip" and "equipped" or "unequipped").." "..toolName, 3)
    if action == "equip" then
        local matched, word = Trigger:Check(toolName)
        if matched then Trigger:Alert(player.Name, toolName, word) end
    end
end
function Tools:Track(player)
    if player == LocalPlayer or self.Conns[player] then return end
    self.Data[player]={}
    local conns={}
    self.Conns[player]=conns
    local function Setup(cm)
        if not cm then return end
        if conns.childAdd then conns.childAdd:Disconnect() end
        if conns.childRem then conns.childRem:Disconnect() end
        self.Data[player]={}
        for _, c in ipairs(cm:GetChildren()) do
            if c:IsA("Tool") then self.Data[player][c.Name]=true end
        end
        conns.childAdd = cm.ChildAdded:Connect(function(c)
            if not c:IsA("Tool") or not S.ToolNotifyEnabled then return end
            task.defer(function()
                if self.Data[player] and not self.Data[player][c.Name] then
                    self.Data[player][c.Name]=true
                    self:ShowNotif(player, c.Name, "equip")
                end
            end)
        end)
        conns.childRem = cm.ChildRemoved:Connect(function(c)
            if not c:IsA("Tool") or not S.ToolNotifyEnabled then return end
            task.defer(function()
                if self.Data[player] and self.Data[player][c.Name] then
                    self.Data[player][c.Name]=nil
                    self:ShowNotif(player, c.Name, "unequip")
                end
            end)
        end)
    end
    if player.Character then Setup(player.Character) end
    conns.charAdd = player.CharacterAdded:Connect(function(nc)
        self.Data[player]={}
        task.defer(function() task.wait(0.3) Setup(nc) end)
    end)
end
function Tools:Untrack(player)
    local c = self.Conns[player]
    if c then for _, conn in pairs(c) do conn:Disconnect() end self.Conns[player]=nil end
    self.Data[player]=nil
end

local NPCTracker = {Conns={}}
function NPCTracker:IsValidNPC(model)
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    if Services.Players:GetPlayerFromCharacter(model) then return false end
    if ESP.Tracked[model] then
        local data = ESP.Tracked[model]
        if data and not data.IsNPC then return false end
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    return true
end
function NPCTracker:TryTrack(npcChar)
    if not self:IsValidNPC(npcChar) then return end
    if not S.EspNPCEnabled and not S.TargetNPCs and S.NPCHighlightMode=="OFF" then return end
    ESP:Track(npcChar, nil)
end
function NPCTracker:Cleanup()
    for k, c in pairs(self.Conns) do
        if c then pcall(function() c:Disconnect() end) end
        self.Conns[k] = nil
    end
end
function NPCTracker:Init()
    self:Cleanup()
    task.defer(function()
        local c = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") then
                local m = obj.Parent
                if m and self:IsValidNPC(m) then
                    c=c+1 if c%10==0 then task.wait() end
                    self:TryTrack(m)
                end
            end
        end
    end)
    self.Conns.added = workspace.DescendantAdded:Connect(function(obj)
        if not obj:IsA("Humanoid") then return end
        if not S.EspNPCEnabled and not S.TargetNPCs and S.NPCHighlightMode=="OFF" then return end
        local m = obj.Parent
        if not m or not m:IsA("Model") then return end
        task.defer(function()
            task.wait(0.1+math.random()*0.05)
            if self:IsValidNPC(m) then self:TryTrack(m) end
        end)
    end)
end
function NPCTracker:Rescan()
    task.defer(function()
        for chr, data in pairs(ESP.Tracked) do
            if data.IsNPC and not self:IsValidNPC(chr) then ESP:Untrack(chr)
            elseif data.IsNPC and Services.Players:GetPlayerFromCharacter(chr) then ESP:Untrack(chr) end
        end
        local c = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") then
                local m = obj.Parent
                if m and self:IsValidNPC(m) then
                    c=c+1 if c%10==0 then task.wait() end
                    self:TryTrack(m)
                end
            end
        end
    end)
end
function NPCTracker:Destroy() self:Cleanup() end

local Fling = {}
function Fling:SkidFling(TP)
    local Character = LocalPlayer.Character
    local Humanoid2 = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart  = Humanoid2 and Humanoid2.RootPart
    local TC        = TP.Character
    if not TC or not Character or not Humanoid2 or not RootPart then return end
    local TH    = TC:FindFirstChildOfClass("Humanoid")
    local TR    = TH and TH.RootPart
    local THead = TC:FindFirstChild("Head")
    if RootPart.Velocity.Magnitude < 50 then R.OldPos = RootPart.CFrame end
    if TH and TH.Sit then return Notify("Fling", TP.Name.." sitting", 2) end
    if THead then Camera.CameraSubject=THead
    elseif TR then Camera.CameraSubject=TR end
    local function FP(BP, Pos, Ang)
        if not RootPart or not Character.Parent then return end
        RootPart.CFrame = CFrame.new(BP.Position)*Pos*Ang
        RootPart.Velocity = Vector3.new(9e7,-9e8,9e7)
        RootPart.RotVelocity = Vector3.new(9e8,9e8,9e8)
    end
    local function SFB(BP)
        local ts=tick() local ang=0
        repeat
            if RootPart and Character.Parent and BP.Parent then
                ang=ang+120
                FP(BP, CFrame.new(0,1.5,0), CFrame.Angles(math.rad(ang),0,0)) task.wait()
                FP(BP, CFrame.new(0,-0.5,0), CFrame.Angles(math.rad(ang),0,0)) task.wait()
            end
        until ts+1.5<tick() or not R.FlingActive or not BP.Parent or not RootPart
    end
    workspace.FallenPartsDestroyHeight = -math.huge
    local BV = Instance.new("BodyVelocity")
    BV.Parent=RootPart BV.Velocity=Vector3.zero BV.MaxForce=Vector3.new(9e9,9e9,9e9)
    Humanoid2:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if TR then SFB(TR) elseif THead then SFB(THead) end
    BV:Destroy()
    Humanoid2:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Camera.CameraSubject=Humanoid2 Camera.CameraType=Enum.CameraType.Custom
    if R.OldPos and RootPart then
        local returnTs=tick()
        repeat
            RootPart.CFrame=R.OldPos RootPart.Velocity=Vector3.zero
            RootPart.RotVelocity=Vector3.zero Humanoid2:ChangeState("GettingUp")
            task.wait() Camera.CameraSubject=Humanoid2
        until (RootPart.Position-R.OldPos.p).Magnitude<20 or tick()-returnTs>1
        workspace.FallenPartsDestroyHeight=R.FPDH
    end
    task.delay(0.1,function()
        if Humanoid2 then Camera.CameraSubject=Humanoid2 Camera.CameraType=Enum.CameraType.Custom end
    end)
end
function Fling:Start()
    if R.FlingActive then return end
    local c=0 for _ in pairs(R.FlingTargets) do c=c+1 end
    if c==0 then Notify("Fling","No targets!",2) return end
    R.FlingActive=true
    Notify("Fling","Flinging "..c.." target(s)",2)
    task.spawn(function()
        while R.FlingActive do
            for name, player in pairs(R.FlingTargets) do
                if not R.FlingActive then break end
                if player and player.Parent then self:SkidFling(player) task.wait(0.1)
                else R.FlingTargets[name]=nil end
            end
            task.wait(0.5)
        end
    end)
end
function Fling:Stop()
    if not R.FlingActive then return end
    R.FlingActive=false Notify("Fling","Stopped",2)
end

local WaterBlock = {
    Enabled     = false,
    WalkOnWater = false,
    SwimUnder   = false,
    Platform    = nil,
    MainConn    = nil,
    ScanConn    = nil,
    WaterParts  = {},
    LastWaterY  = nil,
    DebugMode   = false,
    Jumping     = false,
    JumpVel     = 0,
}

local function WB_FindWaterParts()
    local parts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Water then
            table.insert(parts, obj)
        end
    end
    WaterBlock.WaterParts = parts
    return #parts
end

local function WB_RaycastWater(pos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, WaterBlock.Platform}
    params.IgnoreWater = false
    local rayOrigin = pos + Vector3.new(0, 200, 0)
    local rayDir   = Vector3.new(0, -500, 0)
    local result   = workspace:Raycast(rayOrigin, rayDir, params)
    if result then
        if result.Material == Enum.Material.Water then
            return true, result.Position.Y
        end
        if result.Instance == workspace.Terrain then
            local params2 = RaycastParams.new()
            params2.FilterType = Enum.RaycastFilterType.Exclude
            params2.FilterDescendantsInstances = {LocalPlayer.Character, WaterBlock.Platform}
            params2.IgnoreWater = false
            local rayOrigin2 = result.Position + Vector3.new(0, 0.5, 0)
            local rayDir2 = Vector3.new(0, 100, 0)
            local result2 = workspace:Raycast(rayOrigin2, rayDir2, params2)
            if result2 and result2.Material == Enum.Material.Water then
                return true, result2.Position.Y
            end
        end
    end
    return false, nil
end

local function WB_CheckTerrainBox(pos)
    local terrain = workspace.Terrain
    if not terrain then return false end
    local ok, isWater = pcall(function()
        local cellPos = Vector3.new(
            math.floor(pos.X / 4),
            math.floor(pos.Y / 4),
            math.floor(pos.Z / 4)
        )
        local region = Region3.new(
            Vector3.new(cellPos.X*4, cellPos.Y*4, cellPos.Z*4),
            Vector3.new((cellPos.X+1)*4, (cellPos.Y+1)*4, (cellPos.Z+1)*4)
        )
        local materials, _ = terrain:ReadVoxels(region, 4)
        if materials and materials.Size.X > 0 then
            return materials[1][1][1] == Enum.Material.Water
        end
        return false
    end)
    return ok and isWater
end

local function WB_CheckSwimState(hum)
    if not hum then return false end
    return hum:GetState() == Enum.HumanoidStateType.Swimming
end

local function WB_DetectWater(hrp, hum)
    if not hrp then return false, nil end
    local pos = hrp.Position
    local swimming   = WB_CheckSwimState(hum)
    local rayHit, raySurfY = WB_RaycastWater(pos)
    local voxelHit   = WB_CheckTerrainBox(pos)

    local basePartHit, basePartY = false, nil
    for _, part in ipairs(WaterBlock.WaterParts) do
        if not part or not part.Parent then continue end
        local pPos = part.Position
        local hX = part.Size.X / 2
        local hY = part.Size.Y / 2
        local hZ = part.Size.Z / 2
        if pos.X >= pPos.X - hX and pos.X <= pPos.X + hX then
            if pos.Z >= pPos.Z - hZ and pos.Z <= pPos.Z + hZ then
                if pos.Y >= pPos.Y - hY - 10 and pos.Y <= pPos.Y + hY + 10 then
                    basePartHit = true
                    basePartY = pPos.Y + hY
                    break
                end
            end
        end
    end

    local detected = swimming or rayHit or voxelHit or basePartHit
    local surfY = raySurfY or basePartY or WaterBlock.LastWaterY
    if detected and surfY then
        WaterBlock.LastWaterY = surfY
    end
    return detected, surfY
end

local function WB_EnsurePlatform()
    if WaterBlock.Platform and WaterBlock.Platform.Parent then
        return WaterBlock.Platform
    end
    local p = Instance.new("Part")
    p.Name          = "DivaWaterPlat"
    p.Size          = Vector3.new(12, 1, 12)
    p.Anchored      = true
    p.CanCollide    = true
    p.CanTouch      = false
    p.CanQuery      = false
    p.Transparency  = WaterBlock.DebugMode and 0.3 or 1
    p.CastShadow    = false
    p.Material      = Enum.Material.SmoothPlastic
    p.Color         = Color3.fromRGB(0, 255, 0)
    p.TopSurface    = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent        = workspace
    WaterBlock.Platform = p
    return p
end

local function WB_DestroyPlatform()
    if WaterBlock.Platform and WaterBlock.Platform.Parent then
        WaterBlock.Platform:Destroy()
    end
    WaterBlock.Platform = nil
end

local function WB_BlockSwim(hum, block)
    if not hum or not hum.Parent then return end
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, not block)
    end)
end

local function WB_Update()
    if not WaterBlock.Enabled then return end
    local c = LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    if S.FlyEnabled or S.CarFlyEnabled then
        WB_DestroyPlatform()
        return
    end
    local inWater, surfY = WB_DetectWater(hrp, hum)
    if not inWater then
        WB_DestroyPlatform()
        WB_BlockSwim(hum, false)
        WaterBlock.Jumping = false
        return
    end
    WB_BlockSwim(hum, true)
    if hum:GetState() == Enum.HumanoidStateType.Swimming then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    local pos = hrp.Position
    if WaterBlock.WalkOnWater then
        local targetSurfY = surfY
        if not targetSurfY then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {c, WaterBlock.Platform}
            params.IgnoreWater = false
            local result = workspace:Raycast(pos, Vector3.new(0, 50, 0), params)
            if result and result.Material == Enum.Material.Water then
                targetSurfY = result.Position.Y
            else
                targetSurfY = pos.Y + 2
            end
        end
        local humHip   = hum.HipHeight or 2
        local hrpHalfY = hrp.Size.Y / 2
        local platTopY = targetSurfY - 0.3
        local platY    = platTopY - 0.5
        local plat = WB_EnsurePlatform()
        local desiredTransp = WaterBlock.DebugMode and 0.3 or 1
        if plat.Transparency ~= desiredTransp then
            plat.Transparency = desiredTransp
        end
        plat.CFrame = CFrame.new(pos.X, platY, pos.Z)
        local desiredCharY = platTopY + humHip + hrpHalfY
        if pos.Y < desiredCharY - 2 then
            hrp.CFrame = CFrame.new(pos.X, desiredCharY, pos.Z) * hrp.CFrame.Rotation
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y > 5 then
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end
    elseif WaterBlock.SwimUnder then
        WB_DestroyPlatform()
        local vel = hrp.AssemblyLinearVelocity
        if hum.Jump and not WaterBlock.Jumping then
            WaterBlock.Jumping = true
            local jumpPower = hum.JumpPower
            if hum.UseJumpPower == false then
                jumpPower = math.sqrt(2 * workspace.Gravity * (hum.JumpHeight or 7.2))
            end
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, jumpPower, vel.Z)
        end
        if vel.Y <= 0 then
            WaterBlock.Jumping = false
        end
        local gravity = workspace.Gravity
        local dt = 1/60
        if vel.Y > -50 then
            hrp.AssemblyLinearVelocity = Vector3.new(
                vel.X,
                vel.Y - gravity * dt,
                vel.Z
            )
        end
    else
        WB_DestroyPlatform()
    end
end

local function SetWaterBlock(on)
    WaterBlock.Enabled = on
    S.WaterBlockEnabled = on
    if WaterBlock.MainConn then WaterBlock.MainConn:Disconnect() WaterBlock.MainConn=nil end
    if WaterBlock.ScanConn then WaterBlock.ScanConn:Disconnect() WaterBlock.ScanConn=nil end
    if not on then
        WB_DestroyPlatform()
        WaterBlock.LastWaterY = nil
        WaterBlock.Jumping = false
        local c = LocalPlayer.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then WB_BlockSwim(hum, false) end
        end
        WaterBlock.WalkOnWater = false
        WaterBlock.SwimUnder   = false
        return
    end
    WB_FindWaterParts()
    WaterBlock.ScanConn = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Water then
            table.insert(WaterBlock.WaterParts, obj)
        end
    end)
    WaterBlock.MainConn = Services.RunService.RenderStepped:Connect(function()
        if not WaterBlock.Enabled then return end
        pcall(WB_Update)
    end)
end

-- UIRefs нужен до всех функций SetXxx которые его используют
local UIRefs = {
    Toggles  = {},
    Sliders  = {},
    Dropdowns = {},
    ColorPickers = {},
    AntiManager = nil,
}

local SyncUI = function(key, value) end

local SetFly, SetCarFly, SetNoClip, SetShiftLock, SetForceApply
local SetScaffold, SetTriggerbot, ApplyZoomLimits, SetForceSpeed
local SetAntiSlip

local _RawSetFly, _RawSetCarFly

_RawSetFly = function(on)
    S.FlyEnabled = on
    SyncUI("FlyEnabled", on)
    if R.FlyPos then pcall(function() R.FlyPos:Destroy() end) R.FlyPos = nil end
    if R.FlyGyro then pcall(function() R.FlyGyro:Destroy() end) R.FlyGyro = nil end
    if R.FlyBV then pcall(function() R.FlyBV:Destroy() end) R.FlyBV = nil end
    if not on then
        char = LocalPlayer.Character
        if char then
            local curHum = char:FindFirstChild("Humanoid")
            if curHum then curHum.PlatformStand = false end
        end
        return
    end
    if S.CarFlyEnabled then _RawSetCarFly(false) end
    char = LocalPlayer.Character
    root = char and char:FindFirstChild("HumanoidRootPart")
    local curHum = char and char:FindFirstChild("Humanoid")
    if not root or not curHum then return end
    local flyMethod = S.ForceSpeedEnabled and S.ForceSpeedMethod or 0
    if flyMethod == 2 then
        -- CFrame метод: движение через CFrame напрямую
    elseif flyMethod == 3 then
        R.FlyBV = Instance.new("BodyVelocity")
        R.FlyBV.Name = "_FlyBV"
        R.FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        R.FlyBV.Velocity = Vector3.zero
        R.FlyBV.P = 10000
        R.FlyBV.Parent = root
        R.FlyGyro = Instance.new("BodyGyro")
        R.FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        R.FlyGyro.P = 10000
        R.FlyGyro.D = 1000
        R.FlyGyro.Parent = root
    elseif flyMethod == 4 then
        R.FlyBV = Instance.new("BodyVelocity")
        R.FlyBV.Name = "_FlyBV"
        R.FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        R.FlyBV.Velocity = Vector3.zero
        R.FlyBV.P = 10000
        R.FlyBV.Parent = root
        R.FlyGyro = Instance.new("BodyGyro")
        R.FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        R.FlyGyro.P = 10000
        R.FlyGyro.D = 1000
        R.FlyGyro.Parent = root
    else
        R.FlyPos = Instance.new("BodyPosition")
        R.FlyPos.Position = root.Position
        R.FlyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        R.FlyPos.P = 10000
        R.FlyPos.D = 1000
        R.FlyPos.Parent = root
        R.FlyGyro = Instance.new("BodyGyro")
        R.FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        R.FlyGyro.P = 10000
        R.FlyGyro.D = 1000
        R.FlyGyro.Parent = root
    end
    curHum.PlatformStand = true
end

_RawSetCarFly = function(on)
    S.CarFlyEnabled = on
    if R.CarFlyConn then R.CarFlyConn:Disconnect() R.CarFlyConn=nil end
    if R.CarFlyBV then R.CarFlyBV:Destroy() R.CarFlyBV=nil end
    if R.CarFlyBG then R.CarFlyBG:Destroy() R.CarFlyBG=nil end
    if not on then return end
    if S.FlyEnabled then _RawSetFly(false) end
    local c = LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
    bv.Velocity=Vector3.zero bv.Parent=hrp
    R.CarFlyBV=bv
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
    bg.D=5000 bg.P=100000 bg.CFrame=Camera.CFrame bg.Parent=hrp
    R.CarFlyBG=bg
    R.CarFlyConn = Services.RunService.RenderStepped:Connect(function()
        if not S.CarFlyEnabled or not hrp or not hrp.Parent then _RawSetCarFly(false) return end
        bg.CFrame=Camera.CFrame
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camCF = Camera.CFrame
                local speed = S.CarFlySpeed
                local dir   = camCF:VectorToObjectSpace(moveDir*speed)
                local worldDir = camCF:VectorToWorldSpace(Vector3.new(dir.X,0,dir.Z).Unit*speed)
                bv.Velocity = worldDir
            else bv.Velocity=Vector3.zero end
        else bv.Velocity=Vector3.zero end
    end)
end

SetFly = function(on)
    if on and WaterBlock.Enabled then
        Notify("Anti-Fly", "Fly blocked: Water Block is active", 3)
        return
    end
    _RawSetFly(on)
end

-- ИСПРАВЛЕНО: одно определение SetCarFly без дублирования
SetCarFly = function(on)
    if on and S.ForceSpeedEnabled then
        Notify("Anti-Fly", "Car Fly blocked: ForceSpeed is active", 3)
        return
    end
    if on and WaterBlock.Enabled then
        Notify("Anti-Fly", "Car Fly blocked: Water Block is active", 3)
        return
    end
    _RawSetCarFly(on)
end

SetAntiSlip = function(on)
    S.AntiSlipEnabled = on
    if R.AntiSlipConn then R.AntiSlipConn:Disconnect() R.AntiSlipConn=nil end
    if not on then return end
    R.AntiSlipConn = Services.RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if hum.Health <= 0 then return end
        if hum.Sit then return end
        if S.FlyEnabled or S.CarFlyEnabled then return end
        local moveDir = hum.MoveDirection
        local vel = hrp.AssemblyLinearVelocity
        if S.AntiSlipMode == "StopOnly" then
            if moveDir.Magnitude < 0.05 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
            end
        elseif S.AntiSlipMode == "Full" then
            if moveDir.Magnitude < 0.05 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
            else
                local target = moveDir.Unit * hum.WalkSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(target.X, vel.Y, target.Z)
            end
        end
    end)
end

local function SetLocked(newTarget)
    local old = R.LockedTarget
    if old == newTarget then return end
    R.LockedTarget = newTarget
    if old and ESP.Tracked[old] then
        task.defer(function()
            ESP:UpdateDraw(old,ESP.Tracked[old],false)
            ESP:UpdateHL(old,ESP.Tracked[old],false)
        end)
    end
    if newTarget and ESP.Tracked[newTarget] then
        task.defer(function()
            ESP:UpdateDraw(newTarget,ESP.Tracked[newTarget],true)
            ESP:UpdateHL(newTarget,ESP.Tracked[newTarget],true)
        end)
    end
end

local function SetAimbot(on)
    S.Enabled = on
    FOVCircle.Visible = S.Enabled or S.TargetNPCs
    if not on then
        SetLocked(nil)
        R.MobileAiming = false
        Services.UserInputService.MouseDeltaSensitivity = 1
    end
end

local function SetTargetNPCs(on)
    S.TargetNPCs = on
    FOVCircle.Visible = S.Enabled or S.TargetNPCs
    if not on then
        SetLocked(nil)
        if not S.Enabled then
            R.MobileAiming = false
            Services.UserInputService.MouseDeltaSensitivity = 1
        end
    end
    if on then NPCTracker:Rescan() end
end

local function SetEsp(on)
    S.EspEnabled = on
    if on then S.ShowRobloxNames=false SetDefaultNamesVisible(false)
    else
        S.ShowRobloxNames=true SetDefaultNamesVisible(true)
        for chr, data in pairs(ESP.Tracked) do
            if not data.IsNPC then ESP:Hide(chr) end
        end
    end
end

local function SetEspNPC(on)
    S.EspNPCEnabled = on
    if on then NPCTracker:Rescan() end
    for chr, data in pairs(ESP.Tracked) do
        if data.IsNPC then
            if on then
                ESP:UpdateDraw(chr, data, chr == R.LockedTarget)
                ESP:UpdateHL(chr, data, chr == R.LockedTarget)
            else
                ESP:RemoveDraw(chr) ESP:CreateDraw(chr)
                if data.Highlight then data.Highlight.Enabled = false end
            end
        end
    end
end

local function SetToolNotify(on)
    S.ToolNotifyEnabled = on
    if on then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= LocalPlayer and not Tools.Conns[p] then Tools:Track(p) end
        end
    end
end

local function SetXray(on)
    S.XrayEnabled = on
    if on then Xray:Apply() else Xray:Remove() end
end

local function SetXrayPlayers(on)
    S.XrayPlayers = on
    if S.XrayEnabled then Xray:Remove() Xray:Apply() end
end

local function SetFullBright(on)
    S.FullBrightEnabled = on
    if on then FullBright:Apply() else FullBright:Remove() end
end

local OriginalCollisions = {}

SetNoClip = function(on)
    S.NoClipEnabled = on
    SyncUI("NoClipEnabled", on)
    if on then
        for _, part in ipairs(R.CharParts) do
            if part and part.Parent and part:IsA("BasePart") then
                if OriginalCollisions[part] == nil then
                    OriginalCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for _, part in ipairs(R.CharParts) do
            if part and part.Parent and part:IsA("BasePart") then
                if OriginalCollisions[part] ~= nil then
                    part.CanCollide = OriginalCollisions[part]
                end
            end
        end
    end
end

SetForceApply = function(on)
    S.ForceApplyEnabled = on
    if R.ForceApplyConn then R.ForceApplyConn:Disconnect() R.ForceApplyConn=nil end
    if not on then return end
    R.ForceApplyConn = Services.RunService.Heartbeat:Connect(function()
        if not S.ForceApplyEnabled then return end
        pcall(function()
            local c = LocalPlayer.Character
            if c then
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.WalkSpeed ~= S.WalkSpeed then hum.WalkSpeed = S.WalkSpeed end
                    if hum.JumpPower ~= S.JumpPower then hum.JumpPower = S.JumpPower end
                    if hum.UseJumpPower == false then hum.UseJumpPower = true end
                end
            end
            if Camera.FieldOfView ~= S.CameraFOV then Camera.FieldOfView = S.CameraFOV end
        end)
    end)
end

ApplyZoomLimits = function()
    pcall(function()
        LocalPlayer.CameraMinZoomDistance = S.ZoomMin
        LocalPlayer.CameraMaxZoomDistance = S.ZoomMax
    end)
end

local function CleanupForceSpeed()
    if R.ForceBV then R.ForceBV:Destroy() R.ForceBV=nil end
end

local function ApplyForceSpeed()
    local c = LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if S.FlyEnabled or S.CarFlyEnabled then return end
    if hum.Sit then return end
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude < 0.1 then
        if R.ForceBV and R.ForceBV.Parent then R.ForceBV.Velocity = Vector3.zero end
        return
    end
    local targetVel = moveDir.Unit * S.ForceSpeedValue
    local m = S.ForceSpeedMethod
    if m == 1 or m == 4 then
        local currentY = hrp.Velocity.Y
        hrp.Velocity = Vector3.new(targetVel.X, currentY, targetVel.Z)
    end
    if m == 2 or m == 4 then
        local delta = moveDir.Unit * (S.ForceSpeedValue / 60)
        hrp.CFrame = hrp.CFrame + Vector3.new(delta.X, 0, delta.Z)
    end
    if m == 3 or m == 4 then
        if not R.ForceBV or not R.ForceBV.Parent then
            R.ForceBV = Instance.new("BodyVelocity")
            R.ForceBV.Name = "_ForceSpeed"
            R.ForceBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
            R.ForceBV.P = 10000
            R.ForceBV.Parent = hrp
        end
        R.ForceBV.Velocity = Vector3.new(targetVel.X, 0, targetVel.Z)
    else
        if R.ForceBV and R.ForceBV.Parent and m ~= 4 then R.ForceBV.Velocity = Vector3.zero end
    end
end

SetForceSpeed = function(on)
    S.ForceSpeedEnabled = on
    if R.ForceSpeedConn then R.ForceSpeedConn:Disconnect() R.ForceSpeedConn = nil end
    CleanupForceSpeed()
    if S.FlyEnabled then
        _RawSetFly(true)
    end
    if not on then return end
    R.ForceSpeedConn = Services.RunService.Heartbeat:Connect(function()
        if not S.ForceSpeedEnabled then return end
        pcall(ApplyForceSpeed)
    end)
end

local SHIFT_MAX_LENGTH = 900000
local SHIFT_ENABLED_OFFSET = CFrame.new(1.7, 0, 0)
local SHIFT_DISABLED_OFFSET = CFrame.new(-1.7, 0, 0)
local SHIFT_ICONS = {
    OFF = "rbxasset://textures/ui/mouseLock_off@2x.png",
    ON  = "rbxasset://textures/ui/mouseLock_on@2x.png",
}

local function GetShiftCamCFrame(rootPart, cam)
    return CFrame.new(rootPart.Position, Vector3.new(
        cam.CFrame.LookVector.X * SHIFT_MAX_LENGTH,
        rootPart.Position.Y,
        cam.CFrame.LookVector.Z * SHIFT_MAX_LENGTH
    ))
end

local function UpdateMobileShiftIcon(state)
    if R.MobileShiftBtn and R.MobileShiftBtn.Parent then
        R.MobileShiftBtn.Image = SHIFT_ICONS[state]
    end
end

local function EnableShiftLockLoop()
    local c = LocalPlayer.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    hum.AutoRotate = false
    UpdateMobileShiftIcon("ON")
    hrp.CFrame = GetShiftCamCFrame(hrp, Camera)
    Camera.CFrame = Camera.CFrame * SHIFT_ENABLED_OFFSET
end

local function ToggleShiftLockState()
    if LocalPlayer.DevEnableMouseLock == false then
        pcall(function() LocalPlayer.DevEnableMouseLock = true end)
        Notify("Shift Lock","Force unlocked",2)
    end
    if not R.ShiftLockActive then
        R.ShiftLockActive = Services.RunService.RenderStepped:Connect(EnableShiftLockLoop)
    end
end

local function CreateMobileShiftButton()
    if R.MobileShiftGui then
        pcall(function() R.MobileShiftGui:Destroy() end)
        R.MobileShiftGui=nil R.MobileShiftBtn=nil
    end
    local gui = Instance.new("ScreenGui")
    gui.Name=GenStr(10) gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true gui.DisplayOrder=9
    gui.Parent=Services.CoreGui
    R.MobileShiftGui=gui
    local btn = Instance.new("ImageButton")
    btn.Name="MobileShiftLock"
    btn.Size=UDim2.new(0,55,0,55)
    btn.Position=UDim2.new(1,-75,0.4,-27)
    btn.BackgroundTransparency=1
    btn.Image=SHIFT_ICONS.OFF
    btn.BorderSizePixel=0
    btn.AutoButtonColor=false
    btn.Parent=gui
    R.MobileShiftBtn=btn
    local touching,moved=false,false
    local startTP,startBP=nil,nil
    local changeListener, endListener
    btn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            touching=true moved=false startTP=input.Position startBP=btn.Position
        end
    end)
    changeListener = function(input)
        if touching and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
            local delta=input.Position-startTP
            if delta.Magnitude>15 then
                moved=true
                if btn and btn.Parent then
                    btn.Position=UDim2.new(startBP.X.Scale,startBP.X.Offset+delta.X,startBP.Y.Scale,startBP.Y.Offset+delta.Y)
                end
            end
        end
    end
    endListener = function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            if touching then touching=false if not moved then ToggleShiftLockState() end end
        end
    end
    AddInputListener("Changed", changeListener)
    AddInputListener("Ended", endListener)
    R.MobileShiftListeners = {Changed=changeListener, Ended=endListener}
end

local function RemoveMobileShiftButton()
    if R.MobileShiftListeners then
        if R.MobileShiftListeners.Changed then RemoveInputListener("Changed", R.MobileShiftListeners.Changed) end
        if R.MobileShiftListeners.Ended then RemoveInputListener("Ended", R.MobileShiftListeners.Ended) end
        R.MobileShiftListeners = nil
    end
    if R.MobileShiftGui then
        pcall(function() R.MobileShiftGui:Destroy() end)
        R.MobileShiftGui=nil R.MobileShiftBtn=nil
    end
    if R.MobileShiftCASBound then
        pcall(function() Services.ContextActionService:UnbindAction("DivaShiftLock") end)
        R.MobileShiftCASBound = false
    end
end

SetShiftLock = function(on)
    S.ShiftLockEnabled = on
    R.ShiftLockEnabledByUser = on
    if not on then
        RemoveMobileShiftButton()
        if R.ShiftPCConn then R.ShiftPCConn:Disconnect() R.ShiftPCConn=nil end
        return
    end
    if LocalPlayer.DevEnableMouseLock == false then
        local ok = pcall(function() LocalPlayer.DevEnableMouseLock = true end)
        if ok then Notify("Shift Lock","! Was unlocked!",4)
        else Notify("Shift Lock","! Failed to unlock",4) end
    else Notify("Shift Lock","! Already unlocked",2) end
    if isMobile then
        CreateMobileShiftButton()
        pcall(function()
            Services.ContextActionService:BindAction("DivaShiftLock", function(_, state)
                if state == Enum.UserInputState.Begin then ToggleShiftLockState() end
            end, false, "On")
            Services.ContextActionService:SetPosition("DivaShiftLock", UDim2.new(0.8,0,0.8,0))
            R.MobileShiftCASBound = true
        end)
        Notify("Shift Lock","Tap icon to toggle",3)
    else
        if R.ShiftPCConn then R.ShiftPCConn:Disconnect() end
        R.ShiftPCConn = Services.UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if not S.ShiftLockEnabled then return end
            if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift then
                ToggleShiftLockState()
            end
        end)
        Notify("Shift Lock","Press Shift to toggle",3)
    end
end

SetScaffold = function(on)
    S.ScaffoldEnabled = on
    if R.ScaffoldConn then R.ScaffoldConn:Disconnect() R.ScaffoldConn=nil end
    if R.ScaffoldPart and R.ScaffoldPart.Parent then pcall(function() R.ScaffoldPart:Destroy() end) end
    R.ScaffoldPart = nil
    if not on then return end
    local part = Instance.new("Part")
    part.Name = "DivaScaffold"
    part.Size = Vector3.new(S.ScaffoldX, S.ScaffoldY, S.ScaffoldZ)
    part.Anchored = true
    part.CanCollide = true
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(100, 180, 255)
    part.Transparency = 0.5
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = workspace
    R.ScaffoldPart = part
    R.ScaffoldConn = Services.RunService.RenderStepped:Connect(function()
        if not S.ScaffoldEnabled then return end
        if not R.ScaffoldPart or not R.ScaffoldPart.Parent then R.ScaffoldPart=nil return end
        local c = LocalPlayer.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local desiredSize = Vector3.new(S.ScaffoldX, S.ScaffoldY, S.ScaffoldZ)
        if R.ScaffoldPart.Size ~= desiredSize then R.ScaffoldPart.Size = desiredSize end
        local hipHeight = hum.HipHeight or 2
        local rootHeight = hrp.Size.Y * 0.5
        local yOffset = -(hipHeight + rootHeight + S.ScaffoldY * 0.5)
        R.ScaffoldPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + yOffset, hrp.Position.Z)
    end)
end

local function FireTriggerKey()
    local kt = S.TriggerbotKey
    pcall(function()
        if kt == "MouseButton1" then
            Services.VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait()
            Services.VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        elseif kt == "MouseButton2" then
            Services.VirtualInputManager:SendMouseButtonEvent(0,0,1,true,game,0)
            task.wait()
            Services.VirtualInputManager:SendMouseButtonEvent(0,0,1,false,game,0)
        else
            local keyCode = Enum.KeyCode[kt]
            if keyCode then
                Services.VirtualInputManager:SendKeyEvent(true,keyCode,false,game)
                task.wait()
                Services.VirtualInputManager:SendKeyEvent(false,keyCode,false,game)
            end
        end
    end)
end

SetTriggerbot = function(on)
    S.TriggerbotEnabled = on
    if not on then return end
    if R.TriggerbotRunning then return end
    R.TriggerbotRunning = true
    task.spawn(function()
        while S.TriggerbotEnabled do
            if R.LockedTarget then
                local hum = R.LockedTarget:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then FireTriggerKey() end
            end
            task.wait(math.max(S.TriggerbotDelay, 0.05))
        end
        R.TriggerbotRunning = false
    end)
end

local function GetSlotFile(slot) return R.SaveDir.."/d_"..slot..".json" end
local SaveLoad = {}
local SyncUIFromSettings

function SaveLoad:EnsureDir()
    pcall(function() if not isfolder(R.SaveDir) then makefolder(R.SaveDir) end end)
end
function SaveLoad:GetData()
    local d = {}
    for k, v in pairs(S) do
        if type(v) ~= "userdata" and type(v) ~= "function" and type(v) ~= "table" then d[k] = v end
    end
    d.TriggerWords = S.TriggerWords
    d.AntiStates = {}
    for k, v in pairs(AS) do d.AntiStates[k]=v end
    d.AntiThingAdded = {}
    for _, entry in ipairs(AntiThingAdded) do table.insert(d.AntiThingAdded, entry.Key) end
    return d
end
function SaveLoad:Save()
    if not writefile then Notify("Save","File API not available",3) return end
    self:EnsureDir()
    local ok, err = pcall(function()
        writefile(GetSlotFile(R.CurSlot), Services.HttpService:JSONEncode(self:GetData()))
    end)
    if ok then Notify("Save","Slot "..R.CurSlot.." saved!",2)
    else Notify("Save","Failed: "..tostring(err),3) end
end
function SaveLoad:Load()
    if not readfile then return end
    local fn = GetSlotFile(R.CurSlot)
    pcall(function()
        if not isfile(fn) then Notify("Save","Slot empty",2) return end
        local d = Services.HttpService:JSONDecode(readfile(fn))
        for k, v in pairs(d) do if S[k] ~= nil then S[k]=v end end
        if d.AntiStates then for k, v in pairs(d.AntiStates) do if AS[k] ~= nil then AS[k]=v end end end
        if d.AntiThingAdded then
            AntiThingAdded = {}
            for _, key in ipairs(d.AntiThingAdded) do
                for _, entry in ipairs(AntiStateList) do
                    if entry.Key==key then table.insert(AntiThingAdded, entry) break end
                end
            end
        end
        task.defer(function()
            task.wait(0.15)
            if SyncUIFromSettings then SyncUIFromSettings() end
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed=S.WalkSpeed humanoid.JumpPower=S.JumpPower
            end
            Camera.FieldOfView=S.CameraFOV
            FOVCircle.Radius=S.FOV FOVCircle.Color=S.TargetColor
            ApplyZoomLimits() ApplyAntiStates()
        end)
        Notify("Save","Slot "..R.CurSlot.." loaded!",3)
    end)
end
function SaveLoad:Delete()
    if not delfile then Notify("Save","File API not available",3) return end
    pcall(function()
        local fn = GetSlotFile(R.CurSlot)
        if isfile(fn) then delfile(fn) Notify("Save","Slot "..R.CurSlot.." deleted!",2)
        else Notify("Save","Slot "..R.CurSlot.." empty",2) end
    end)
end
function SaveLoad:StartAutoLoop()
    task.spawn(function()
        while R.SaveEnabled do
            task.wait(R.SaveInterval)
            if R.SaveEnabled then self:Save() end
        end
    end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local function TrackCharacter(chr, player)
    if not chr or chr == LocalPlayer.Character then return end
    task.spawn(function()
        if player and player ~= LocalPlayer then
            local hrp = chr:WaitForChild("HumanoidRootPart",10)
            local hum = chr:WaitForChild("Humanoid",10)
            if hrp and hum then ESP:Track(chr,player) end
        elseif not player and chr:FindFirstChildOfClass("Humanoid") then
            ESP:Track(chr,nil)
        end
    end)
end

local function TrackPlayer(p)
    if p == LocalPlayer then return end
    Tools:Track(p)
    p.CharacterAdded:Connect(function(c)
        TrackCharacter(c,p)
        task.defer(function() task.wait(0.5) UpdateCharCache(LocalPlayer.Character) end)
    end)
    p.CharacterRemoving:Connect(function(c) ESP:Untrack(c) end)
    if p.Character then TrackCharacter(p.Character,p) end
end

task.spawn(function()
    task.wait(1)
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer then TrackPlayer(p) end
    end
end)

Services.Players.PlayerAdded:Connect(TrackPlayer)
Services.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(chr)
        task.wait(0.5)
        local hum = chr:FindFirstChildOfClass("Humanoid")
        if hum and not S.ShowRobloxNames then ProtectHumanoidName(hum) end
    end)
end)
Services.Players.PlayerRemoving:Connect(function(p) Tools:Untrack(p) end)
NPCTracker:Init()

LocalPlayer.CharacterAdded:Connect(function(nc)
    char=nc root=nc:WaitForChild("HumanoidRootPart",5)
    humanoid=nc:WaitForChild("Humanoid",5)
    task.wait(0.5)
    UpdateCharCache(nc)
    ApplyAntiStates()
    if S.FlyEnabled then SetFly(true) end
    if S.CarFlyEnabled then task.wait(0.3) SetCarFly(true) end
    if S.XrayEnabled then SetXray(true) end
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed=S.WalkSpeed humanoid.JumpPower=S.JumpPower
    end
    Camera.FieldOfView=S.CameraFOV
    ApplyZoomLimits()
    if S.ShiftLockEnabled and R.ShiftLockActive then
        R.ShiftLockActive:Disconnect() R.ShiftLockActive=nil
        UpdateMobileShiftIcon("OFF")
    end
    if S.ScaffoldEnabled then
        task.wait(0.3) SetScaffold(false) SetScaffold(true)
    end
    if WaterBlock.Enabled then
        task.wait(0.5)
        WB_FindWaterParts()
        local hum = nc:FindFirstChildOfClass("Humanoid")
        if hum then
            if WaterBlock.WalkOnWater or WaterBlock.SwimUnder then
                WB_BlockSwim(hum, true)
            end
        end
    end
    if R.FlingInvis then
        task.wait(0.2)
        for _, part in ipairs(nc:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency=1
            elseif part:IsA("Decal") or part:IsA("Texture") then part.Transparency=1 end
        end
    end
end)

Services.UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then SetFly(not S.FlyEnabled) end
    if input.KeyCode == Enum.KeyCode.N then SetNoClip(not S.NoClipEnabled) end
end)

local Main = {}
function Main:Init()
    Scheduler:Register("noclip", function()
        if S.NoClipEnabled then
            for _, part in ipairs(R.CharParts) do
                if part and part.Parent and part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    Scheduler:Register("fly", function()
        if not S.FlyEnabled then return end
        char = LocalPlayer.Character
        root = char and char:FindFirstChild("HumanoidRootPart")
        local curHum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not root.Parent or not curHum or curHum.Health <= 0 then return end
        local speed = S.FlySpeed
        local cf = Camera.CFrame
        local moveDir = curHum.MoveDirection
        local direction
        if moveDir.Magnitude > 0 then
            local dir = cf.Rotation:VectorToObjectSpace(moveDir * speed)
            direction = cf.Rotation:VectorToWorldSpace(Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude)
        else
            direction = Vector3.zero
        end
        local flyMethod = S.ForceSpeedEnabled and S.ForceSpeedMethod or 0
        if flyMethod == 2 then
            if direction.Magnitude > 0 then
                root.CFrame = root.CFrame + direction * (1/60)
            end
            root.CFrame = CFrame.new(root.Position) * cf.Rotation
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        elseif flyMethod == 3 then
            if R.FlyBV and R.FlyBV.Parent then
                R.FlyBV.Velocity = direction
            end
            if R.FlyGyro and R.FlyGyro.Parent then
                R.FlyGyro.CFrame = cf
            end
        elseif flyMethod == 4 then
            root.Velocity = direction
            root.CFrame = CFrame.new(root.Position) * cf.Rotation
            if R.FlyBV and R.FlyBV.Parent then
                R.FlyBV.Velocity = direction
            end
            if R.FlyGyro and R.FlyGyro.Parent then
                R.FlyGyro.CFrame = cf
            end
        else
            if R.FlyPos and R.FlyPos.Parent then
                R.FlyPos.Position = R.FlyPos.Position + direction
            end
            if R.FlyGyro and R.FlyGyro.Parent then
                R.FlyGyro.CFrame = cf
            end
        end
        curHum.PlatformStand = true
    end)
    Scheduler:Register("flinginvis", function()
        if R.FlingInvis then
            local lc = LocalPlayer.Character
            if lc then
                for _, p in ipairs(lc:GetDescendants()) do
                    if p:IsA("BasePart") and p.Transparency ~= 1 then p.Transparency=1
                    elseif (p:IsA("Decal") or p:IsA("Texture")) and p.Transparency ~= 1 then p.Transparency=1 end
                end
            end
        end
    end)
    Scheduler:Register("esp", function(dt) ESP:Update(dt) end)
end

function Main:Update(dt) UpdateFPS(dt) Scheduler:Update(dt) end

function Main:GetClosest()
    local best, bestDist = nil, S.FOV
    local center = isMobile
        and Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5)
        or  Services.UserInputService:GetMouseLocation()
    if S.Enabled then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= LocalPlayer and (not S.TeamCheckHL or not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                local c = p.Character
                if c then
                    local part = c:FindFirstChild(S.TargetPart)
                    local hum  = c:FindFirstChildOfClass("Humanoid")
                    if part and hum and hum.Health > 0 then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)

                    if on then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude

                        if d < bestDist and (S.ThroughWalls or IsVisible(part)) then
                            bestDist = d
                            best = c
                        end
                    end
                end
                end
            end
        end
    end
    if S.TargetNPCs then
        for chr, data in pairs(ESP.Tracked) do
            if data.IsNPC then
                local part = chr:FindFirstChild(S.TargetPart)
                local hum  = data.Humanoid
                if part and hum and hum.Health > 0 then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local d = (Vector2.new(pos.X,pos.Y)-center).Magnitude
                        if d<bestDist and (S.ThroughWalls or IsVisible(part)) then bestDist=d best=chr end
                    end
                end
            end
        end
    end
    return best
end

function Main:AimUpdate()
    local Camera = workspace.CurrentCamera
    if not S.Enabled and not S.TargetNPCs then
        if R.LockedTarget then SetLocked(nil) end
        if Services.UserInputService.MouseDeltaSensitivity ~= 1 then
            Services.UserInputService.MouseDeltaSensitivity=1
        end
        R.MobileAiming=false return
    end
    local isAiming = false
    if isMobile then isAiming = R.MobileAiming == true
    else pcall(function() isAiming=Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end) end
    if not isAiming then
        if R.LockedTarget then SetLocked(nil) end
        if Services.UserInputService.MouseDeltaSensitivity ~= 1 then
            Services.UserInputService.MouseDeltaSensitivity=1
        end
        if FOVCircle.Visible then
            local center = isMobile
                and Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5)
                or  Services.UserInputService:GetMouseLocation()
            FOVCircle.Position=center
        end
        return
    end
    if R.LockedTarget then
        local hum  = R.LockedTarget:FindFirstChildOfClass("Humanoid")
        local part = R.LockedTarget:FindFirstChild(S.TargetPart)
        if not R.LockedTarget.Parent or not hum or hum.Health <= 0
            or (not S.ThroughWalls and part and not IsVisible(part)) then SetLocked(nil) end
    end
    if not R.LockedTarget then SetLocked(self:GetClosest()) end
    if R.LockedTarget then
        Services.UserInputService.MouseDeltaSensitivity=0
        local part = R.LockedTarget:FindFirstChild(S.TargetPart)
        if part then
            local camCF     = Camera.CFrame
            local offset    = camCF.RightVector*S.OffsetX + camCF.UpVector*S.OffsetY
            local targetPos = part.Position+offset
            local targetDir = (targetPos-camCF.Position).Unit
            local curDir    = camCF.LookVector
            local angle     = math.acos(math.clamp(curDir:Dot(targetDir),-1,1))
            if angle > 0.001*(1-S.Sensitivity*0.9) then
                Camera.CFrame = camCF:Lerp(CFrame.new(camCF.Position,targetPos), S.Sensitivity)
            else Camera.CFrame = CFrame.new(camCF.Position,targetPos) end
        end
    else Services.UserInputService.MouseDeltaSensitivity=1 end
    if FOVCircle.Visible then
        local center = isMobile
            and Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5)
            or  Services.UserInputService:GetMouseLocation()
        FOVCircle.Position=center
    end
end

function Main:Destroy()
    Services.UserInputService.MouseDeltaSensitivity=1
    if R.AntiSlipConn then R.AntiSlipConn:Disconnect() R.AntiSlipConn=nil end
    SetWaterBlock(false)
    ESP:Destroy() NPCTracker:Destroy()
    FullBright:Remove() Xray:Remove() NoTex:RestoreAll() NoTex:Cleanup()
    SetForceSpeed(false) SetShiftLock(false)
    if R.FlyBV then pcall(function() R.FlyBV:Destroy() end) R.FlyBV = nil end
    SetForceApply(false) SetScaffold(false) SetTriggerbot(false)
    DrawPool:Clear()
    pcall(function() FOVCircle:Remove() end)
    if R.RenderName then
        pcall(function() Services.RunService:UnbindFromRenderStep(R.RenderName) end)
    end
    if R.MobileAimGui then
        pcall(function() R.MobileAimGui:Destroy() end)
        R.MobileAimGui=nil
    end
    if R.MobileAimListeners then
        if R.MobileAimListeners.Changed then RemoveInputListener("Changed", R.MobileAimListeners.Changed) end
        if R.MobileAimListeners.Ended then RemoveInputListener("Ended", R.MobileAimListeners.Ended) end
        if R.MobileAimListeners.TouchEnded then RemoveInputListener("TouchEnded", R.MobileAimListeners.TouchEnded) end
        R.MobileAimListeners=nil
    end
    if GlobalInputConns.Changed then pcall(function() GlobalInputConns.Changed:Disconnect() end) end
    if GlobalInputConns.Ended then pcall(function() GlobalInputConns.Ended:Disconnect() end) end
    if GlobalInputConns.TouchEnded then pcall(function() GlobalInputConns.TouchEnded:Disconnect() end) end
    pcall(function() GlobalHLFolder:Destroy() end)
end

local Window = DivaUI:CreateWindow({
    Name  = "DIVA HACKS",
    Theme = "Midnight",
    Size  = "Normal",
})
Window:CreateCustomizePanel()

SyncUI = function(key, value)
    if not UIRefs or not UIRefs.Toggles then return end
    local toggle = UIRefs.Toggles[key]
    if toggle and toggle.Set then
        pcall(function()
            toggle:Set(value, true)
        end)
    end
end

local function RegToggle(key, obj)   UIRefs.Toggles[key] = obj end
local function RegSlider(key, obj)   UIRefs.Sliders[key] = obj end
local function RegDropdown(key, obj) UIRefs.Dropdowns[key] = obj end
local function RegColor(key, obj)    UIRefs.ColorPickers[key] = obj end

local function ForceToggleVisual(toggleObj, name, state, theme)
    if not toggleObj or not toggleObj.Instance then return end
    local btn = toggleObj.Instance
    if not btn or not btn.Parent then return end
    local bg = state and theme.ButtonOn or theme.ButtonOff
    btn.BackgroundColor3 = bg
    local lum = bg.R*0.299 + bg.G*0.587 + bg.B*0.114
    btn.TextColor3 = lum > 0.62 and Color3.fromRGB(20,20,24) or Color3.fromRGB(245,245,245)
    btn.Text = name..": "..(state and "ON" or "OFF")
end

local function CreateFixedToggle(tab, name, settingKey, callback)
    local currentState = S[settingKey] or false
    local toggle = tab:CreateToggle({
        Name = name, Default = currentState,
        Callback = function(v)
            currentState = v S[settingKey] = v
            if callback then callback(v) end
            ForceToggleVisual(toggle, name, v, Window.CurTheme())
        end
    })
    task.defer(function()
        task.wait(0.05)
        ForceToggleVisual(toggle, name, currentState, Window.CurTheme())
    end)
    local origSet = toggle.Set
    toggle.Set = function(self, value, silent)
        local newState = value and true or false
        currentState = newState S[settingKey] = newState
        if origSet then pcall(function() origSet(self, newState, true) end) end
        ForceToggleVisual(self, name, newState, Window.CurTheme())
        if not silent and callback then task.spawn(function() pcall(callback, newState) end) end
    end
    RegToggle(settingKey, toggle)
    return toggle
end

local function CreateFixedSlider(tab, name, settingKey, mn, mx, fmt, callback)
    local currentValue = S[settingKey] or mn
    local slider = tab:CreateSlider({
        Name=name, Min=mn, Max=mx, Default=currentValue, Format=fmt,
        Callback=function(v)
            currentValue=v S[settingKey]=v
            if callback then callback(v) end
        end
    })
    RegSlider(settingKey, slider)
    return slider
end

local function CreateFixedDropdown(tab, name, settingKey, options, callback)
    local currentValue = S[settingKey] or options[1]
    local dropdown = tab:CreateDropdown({
        Name=name, Options=options, Default=currentValue,
        Callback=function(v)
            S[settingKey]=v
            if callback then callback(v) end
        end
    })
    RegDropdown(settingKey, dropdown)
    return dropdown
end

local function CreateFixedColorPicker(tab, name, settingKey, callback)
    local currentValue = S[settingKey]
    local picker = tab:CreateColorPicker({
        Name=name, Default=currentValue,
        Callback=function(c)
            S[settingKey]=c
            if callback then callback(c) end
        end
    })
    RegColor(settingKey, picker)
    return picker
end

SyncUIFromSettings = function()
    for key, obj in pairs(UIRefs.Toggles) do
        if S[key] ~= nil and obj and obj.Set then pcall(function() obj:Set(S[key], true) end) end
    end
    for key, obj in pairs(UIRefs.Sliders) do
        if S[key] ~= nil and obj and obj.Set then pcall(function() obj:Set(S[key], true) end) end
    end
    for key, obj in pairs(UIRefs.Dropdowns) do
        if S[key] ~= nil and obj and obj.Set then pcall(function() obj:Set(S[key], true) end) end
    end
    for key, obj in pairs(UIRefs.ColorPickers) do
        if S[key] ~= nil and obj and obj.Set then pcall(function() obj:Set(S[key], true) end) end
    end
    if UIRefs.AntiManager and UIRefs.AntiManager.Refresh then
        UIRefs.AntiManager.Added = {}
        for _, entry in ipairs(AntiThingAdded) do table.insert(UIRefs.AntiManager.Added, entry) end
        UIRefs.AntiManager:Refresh()
    end
    task.spawn(function()
        FOVCircle.Visible=S.Enabled or S.TargetNPCs
        FOVCircle.Radius=S.FOV FOVCircle.Color=S.TargetColor
        ApplyFOVStyle()
        if S.EspEnabled then SetEsp(true) else SetEsp(false) end
        if S.EspNPCEnabled then SetEspNPC(S.EspNPCEnabled) end
        if S.XrayEnabled then SetXray(true) else SetXray(false) end
        if S.FullBrightEnabled then SetFullBright(true) else SetFullBright(false) end
        if S.FlyEnabled and not R.FlyPos then SetFly(true) end
        if not S.FlyEnabled and R.FlyPos then SetFly(false) end
        if S.CarFlyEnabled and not R.CarFlyBV then SetCarFly(true) end
        if not S.CarFlyEnabled and R.CarFlyBV then SetCarFly(false) end
        if S.ForceApplyEnabled and not R.ForceApplyConn then SetForceApply(true) end
        if not S.ForceApplyEnabled and R.ForceApplyConn then SetForceApply(false) end
        if S.ForceSpeedEnabled and not R.ForceSpeedConn then SetForceSpeed(true) end
        if not S.ForceSpeedEnabled and R.ForceSpeedConn then SetForceSpeed(false) end
        if S.ShiftLockEnabled then SetShiftLock(true) end
        if S.ScaffoldEnabled and not R.ScaffoldPart then SetScaffold(true) end
        if not S.ScaffoldEnabled and R.ScaffoldPart then SetScaffold(false) end
        if S.TriggerbotEnabled and not R.TriggerbotRunning then SetTriggerbot(true) end
        if S.ToolNotifyEnabled then SetToolNotify(true) end
        local c = LocalPlayer.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed=S.WalkSpeed hum.JumpPower=S.JumpPower end
        end
        Camera.FieldOfView=S.CameraFOV
        ApplyZoomLimits() ApplyAntiStates()
    end)
end

local custApi = Window.CustomizePanel
if custApi then
    custApi.AddSection("ESP TARGET COLOR")
    custApi.AddSwatchRow(HighlightColors,
        function(i) S.TargetColor=HighlightColors[i].Color FOVCircle.Color=S.TargetColor end,
        function() for i, hc in ipairs(HighlightColors) do if hc.Color==S.TargetColor then return i end end return 1 end
    )
    custApi.AddSection("ESP HEALTH COLOR")
    local healthColors = {
        {Color=Color3.fromRGB(0,255,0)},{Color=Color3.fromRGB(100,255,100)},
        {Color=Color3.fromRGB(255,255,0)},{Color=Color3.fromRGB(255,165,0)},
        {Color=Color3.fromRGB(255,80,80)},{Color=Color3.fromRGB(255,255,255)},
        {Color=Color3.fromRGB(0,200,255)},{Color=Color3.fromRGB(180,0,255)},
    }
    custApi.AddSwatchRow(healthColors,
        function(i) S.EspHealthColor=healthColors[i].Color end,
        function() for i, hc in ipairs(healthColors) do if hc.Color==S.EspHealthColor then return i end end return 1 end
    )
    custApi.AddSection("ESP SETTINGS")
    custApi.AddSlider("Max Dist",100,10000,
        function() return S.EspMaxDistance end,
        function(v) S.EspMaxDistance=v end,
        "%d", math.floor)
    custApi.AddSlider("HL Fill",0,1,
        function() return S.EspFillTransparency end,
        function(v) S.EspFillTransparency=v end,
        "%.2f", function(v) return math.floor(v*100)/100 end)
    custApi.AddTextInput("NPC Alias",
        function() return S.EspNPCAlias end,
        function(v) S.EspNPCAlias=(v~="" and v or "NPC") end, "NPC")
    custApi.AddSection("FOV CIRCLE")
    custApi.AddCycle(
        function() return "Style: "..FOVStyles[FOVStyleIdx] end,
        function() FOVStyleIdx=FOVStyleIdx%#FOVStyles+1 ApplyFOVStyle() end
    )
end

local AimTab = Window:CreateTab("Aiming")
CreateFixedToggle(AimTab, "Aim Player", "Enabled", function(v) SetAimbot(v) end)
CreateFixedToggle(AimTab, "Aim NPC", "TargetNPCs", function(v) SetTargetNPCs(v) end)
CreateFixedDropdown(AimTab, "Target Part", "TargetPart", {"Head","HumanoidRootPart","LowerTorso"})
CreateFixedToggle(AimTab, "Through Walls", "ThroughWalls")
CreateFixedSlider(AimTab, "Smoothness", "Sensitivity", 0.01, 1, "%.2f")
CreateFixedSlider(AimTab, "Aim FOV", "FOV", 10, 500, "%d", function(v) FOVCircle.Radius=v end)
CreateFixedSlider(AimTab, "Offset X", "OffsetX", -5, 5, "%.1f")
CreateFixedSlider(AimTab, "Offset Y", "OffsetY", -5, 5, "%.1f")
AimTab:CreateDivider()
AimTab:CreateSection("Triggerbot")
AimTab:CreateLabel({Text="Fires automatically when aimed", Wrapped=true})
CreateFixedToggle(AimTab, "Triggerbot", "TriggerbotEnabled", function(v) SetTriggerbot(v) end)
CreateFixedDropdown(AimTab, "Trigger Key", "TriggerbotKey", TriggerbotKeys)
CreateFixedSlider(AimTab, "Trigger Delay (s)", "TriggerbotDelay", 0.05, 1, "%.2f")

local PlayerESPTab = Window:CreateTab("Player ESP")
CreateFixedToggle(PlayerESPTab, "ESP Player", "EspEnabled", function(v) SetEsp(v) end)
CreateFixedDropdown(PlayerESPTab, "Highlight", "HighlightMode", {"OFF","HIGHLIGHT","WO_CHAMS","CHAMS"}, function(v)
    for chr, data in pairs(ESP.Tracked) do
        if not data.IsNPC then ESP:UpdateHL(chr,data,chr==R.LockedTarget) end
    end
end)
CreateFixedColorPicker(PlayerESPTab, "Highlight Color", "HighlightColor", function(c)
    for chr, data in pairs(ESP.Tracked) do ESP:UpdateHL(chr,data,chr==R.LockedTarget) end
end)
CreateFixedDropdown(PlayerESPTab, "Names", "NameDisplayMode", {"DisplayName","Username","Both"})
CreateFixedToggle(PlayerESPTab, "Tool Notify", "ToolNotifyEnabled", function(v) SetToolNotify(v) end)
CreateFixedToggle(PlayerESPTab, "Team Color", "UseTeamColor", function(v)
    for chr, data in pairs(ESP.Tracked) do
        if not data.IsNPC then ESP:UpdateHL(chr,data,chr==R.LockedTarget) end
    end
end)
CreateFixedToggle(PlayerESPTab, "Hide Teammates", "TeamCheckHL", function(v)
    for chr, data in pairs(ESP.Tracked) do
        if not data.IsNPC then ESP:UpdateHL(chr,data,chr==R.LockedTarget) end
    end
end)
PlayerESPTab:CreateDivider()
PlayerESPTab:CreateSection("Trigger Words")
CreateFixedToggle(PlayerESPTab, "Trigger Words", "TriggerWordsEnabled")
CreateFixedToggle(PlayerESPTab, "Fuzzy Match", "TriggerFuzzy")
CreateFixedDropdown(PlayerESPTab, "Alert Mode", "TriggerDisplayMode", {"Hint","Message","Notification"})
PlayerESPTab:CreateTextBox({
    Name="Add Trigger Word", Placeholder="Type and press Enter...",
    Callback=function(text, enter)
        if enter and text and text ~= "" then
            table.insert(S.TriggerWords, text) Notify("Trigger","Added: "..text,2)
        end
    end
})
PlayerESPTab:CreateButton({Name="Clear Trigger Words", Callback=function()
    S.TriggerWords={} Notify("Trigger","All cleared",2)
end})

local NPCESPTab = Window:CreateTab("NPC ESP")
CreateFixedToggle(NPCESPTab, "ESP NPC", "EspNPCEnabled", function(v) SetEspNPC(v) end)
CreateFixedDropdown(NPCESPTab, "NPC Highlight", "NPCHighlightMode", {"OFF","HIGHLIGHT","WO_CHAMS","CHAMS"}, function(v)
    if v ~= "OFF" then NPCTracker:Rescan() end
    for chr, data in pairs(ESP.Tracked) do
        if data.IsNPC then ESP:UpdateHL(chr,data,chr==R.LockedTarget) end
    end
end)
NPCESPTab:CreateColorPicker({
    Name="NPC Color", Default=S.HighlightColor,
    Callback=function(c)
        S.HighlightColor=c
        for chr, data in pairs(ESP.Tracked) do
            if data.IsNPC then ESP:UpdateHL(chr,data,chr==R.LockedTarget) end
        end
    end
})

local WorldTab = Window:CreateTab("World")
CreateFixedToggle(WorldTab, "XRay Vision", "XrayEnabled", function(v) SetXray(v) end)
CreateFixedToggle(WorldTab, "Xray Players", "XrayPlayers", function(v) SetXrayPlayers(v) end)
CreateFixedToggle(WorldTab, "Full Bright", "FullBrightEnabled", function(v) SetFullBright(v) end)
WorldTab:CreateSection("Visual Remover")
WorldTab:CreateAntiThingManager({
    Items = VisualItems,
    States = NoTex.Selected,

    OnAdd = function(key)
        NoTex.Selected[key] = true
        NoTex:Refresh()
    end,

    OnRemove = function(key)
        NoTex.Selected[key] = false
        NoTex:Refresh()
    end,

    OnToggle = function(key, val)
        NoTex.Selected[key] = val
        NoTex:Refresh()
    end,
})
WorldTab:CreateDivider()
WorldTab:CreateSection("Force Speed")
WorldTab:CreateLabel({Text="! Bypasses WalkSpeed blocking. Works with fly, experimentally!", Wrapped=true})
CreateFixedSlider(WorldTab, "Force Speed Value", "ForceSpeedValue", 5, 200, "%d")
CreateFixedDropdown(WorldTab, "Force Method", "ForceSpeedMethodName", ForceSpeedMethodNames, function(v)
    for i, n in ipairs(ForceSpeedMethodNames) do
        if n == v then S.ForceSpeedMethod = i break end
    end
    if S.ForceSpeedEnabled then
        SetForceSpeed(false)
        SetForceSpeed(true)
    end
    if S.FlyEnabled then
        _RawSetFly(true)
    end
end)
CreateFixedToggle(WorldTab, "Force Speed", "ForceSpeedEnabled", function(v) SetForceSpeed(v) end)
WorldTab:CreateDivider()
WorldTab:CreateSection("Shift Lock Unlocker")
WorldTab:CreateActionButton({
    Name="Unlock Shift Lock",
    Cooldown=1.5,
    NotifyTitle="Shift Lock",

    Callback=function()

        if LocalPlayer.DevEnableMouseLock == true then
            Notify("Shift Lock", "Already enabled", 3)
            return true
        end

        local ok = pcall(function()
            LocalPlayer.DevEnableMouseLock = true
        end)

        if ok then
            Notify("Shift Lock", "Unlocked successfully", 4)
            return true
        else
            Notify("Shift Lock", "Failed to unlock", 4)
            return false
        end
    end
})
WorldTab:CreateDivider()
WorldTab:CreateSection("Camera Zoom")
CreateFixedSlider(WorldTab, "Zoom Min", "ZoomMin", 0, 50, "%.1f", function(v) ApplyZoomLimits() end)
CreateFixedSlider(WorldTab, "Zoom Max", "ZoomMax", 10, 1000, "%d", function(v) ApplyZoomLimits() end)
WorldTab:CreateButton({Name="Apply Zoom", Callback=function()
    ApplyZoomLimits() Notify("Zoom","Applied: "..S.ZoomMin.." "..S.ZoomMax,2)
end})

local FlyTab = Window:CreateTab("Flying")
FlyTab:CreateLabel({Text="Fly and Car Fly are blocked when Water Block is active", Wrapped=true})
CreateFixedToggle(FlyTab, "Fly (F)", "FlyEnabled", function(v) SetFly(v) end)
CreateFixedSlider(FlyTab, "Fly Speed", "FlySpeed", 1, 100, "%.1f")
CreateFixedToggle(FlyTab, "Car Fly", "CarFlyEnabled", function(v) SetCarFly(v) end)
CreateFixedSlider(FlyTab, "Car Fly Speed", "CarFlySpeed", 10, 500, "%d")

local WaterTab = Window:CreateTab("Water")
WaterTab:CreateSection("Water Block System")
WaterTab:CreateLabel({
    Text = "Walk on water surface or move freely underwater. Fly is auto-blocked.",
    Wrapped = true
})

local WalkOnWaterToggle = CreateFixedToggle(WaterTab, "Walk On Water", "WalkOnWater", function(v)
    WaterBlock.WalkOnWater = v
    if v then
        WaterBlock.SwimUnder = false
        S.SwimUnder = false
        if UIRefs.Toggles["SwimUnder"] then
            pcall(function() UIRefs.Toggles["SwimUnder"]:Set(false, true) end)
        end
        SetWaterBlock(true)
    else
        if not WaterBlock.SwimUnder then
            SetWaterBlock(false)
        end
    end
end)

local SwimUnderToggle = CreateFixedToggle(WaterTab, "Walk Underwater", "SwimUnder", function(v)
    WaterBlock.SwimUnder = v
    if v then
        WaterBlock.WalkOnWater = false
        S.WalkOnWater = false
        WB_DestroyPlatform()
        if UIRefs.Toggles["WalkOnWater"] then
            pcall(function() UIRefs.Toggles["WalkOnWater"]:Set(false, true) end)
        end
        SetWaterBlock(true)
    else
        if not WaterBlock.WalkOnWater then
            SetWaterBlock(false)
        end
    end
end)

WaterTab:CreateDivider()
WaterTab:CreateButton({
    Name = "Diagnose Water",
    Callback = function()
        local partCount = WB_FindWaterParts()
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hrp then Notify("Water", "No character!", 3) return end
        local rayHit, raySurfY = WB_RaycastWater(hrp.Position)
        local voxelHit = WB_CheckTerrainBox(hrp.Position)
        local swimming = WB_CheckSwimState(hum)
        local state = hum and tostring(hum:GetState()) or "no hum"
        local msg = string.format(
            "Parts: %d | Ray: %s | Vox: %s | Swim: %s | Y: %s\nState: %s",
            partCount, tostring(rayHit), tostring(voxelHit), tostring(swimming),
            raySurfY and tostring(math.floor(raySurfY)) or "nil", state
        )
        Notify("Water Debug", msg, 8)
    end
})
WaterTab:CreateButton({
    Name = "Toggle Debug Platform",
    Callback = function()
        WaterBlock.DebugMode = not WaterBlock.DebugMode
        if WaterBlock.Platform and WaterBlock.Platform.Parent then
            WaterBlock.Platform.Transparency = WaterBlock.DebugMode and 0.3 or 1
        end
        Notify("Water", "Debug visible: " .. tostring(WaterBlock.DebugMode), 2)
    end
})
WaterTab:CreateButton({
    Name = "Rescan Water Parts",
    Callback = function()
        local count = WB_FindWaterParts()
        Notify("Water", "Found " .. count .. " BasePart water(s)", 3)
    end
})
WaterTab:CreateButton({
    Name = "Reset Water System",
    Callback = function()
        SetWaterBlock(false)
        WaterBlock.WalkOnWater = false WaterBlock.SwimUnder = false
        S.WalkOnWater = false S.SwimUnder = false
        WB_DestroyPlatform()
        local c = LocalPlayer.Character
        if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum then WB_BlockSwim(hum, false) end end
        if UIRefs.Toggles["WalkOnWater"] then pcall(function() UIRefs.Toggles["WalkOnWater"]:Set(false, true) end) end
        if UIRefs.Toggles["SwimUnder"] then pcall(function() UIRefs.Toggles["SwimUnder"]:Set(false, true) end) end
        Notify("Water", "Water system reset", 2)
    end
})

local CharTab = Window:CreateTab("Character")
CharTab:CreateSection("ANTI-THING")
local AntiManager = CharTab:CreateAntiThingManager({
    Items = AntiStateList, States = AS,
    OnAdd = function(key)
        for _, entry in ipairs(AntiStateList) do
            if entry.Key==key then table.insert(AntiThingAdded, entry) break end
        end
        ApplyAntiStates()
    end,
    OnRemove = function(key)
        for i = #AntiThingAdded, 1, -1 do
            if AntiThingAdded[i].Key==key then table.remove(AntiThingAdded, i) break end
        end
        ApplyAntiStates()
    end,
    OnToggle = function(key, val) ApplyAntiStates() end,
})
UIRefs.AntiManager = AntiManager

CharTab:CreateDivider()
CharTab:CreateSection("MOVEMENT")
CreateFixedToggle(CharTab, "NoClip (N)", "NoClipEnabled", function(v) SetNoClip(v) end)
CreateFixedToggle(CharTab, "Anti Slip", "AntiSlipEnabled", function(v) SetAntiSlip(v) end)
CreateFixedDropdown(CharTab, "Anti Slip Mode", "AntiSlipMode", AntiSlipModes)
CreateFixedSlider(CharTab, "Walk Speed", "WalkSpeed", 5, 500, "%.1f", function(v)
    if humanoid and humanoid.Parent then humanoid.WalkSpeed=v end
end)
CreateFixedSlider(CharTab, "Jump Power", "JumpPower", 0, 500, "%d", function(v)
    if humanoid and humanoid.Parent then humanoid.JumpPower=v end
end)
CreateFixedSlider(CharTab, "Camera FOV", "CameraFOV", 1, 120, "%d", function(v) Camera.FieldOfView=v end)

CharTab:CreateDivider()
CharTab:CreateSection("SCAFFOLD")
CharTab:CreateLabel({Text="Platform underfoot", Wrapped=true})
CreateFixedToggle(CharTab, "Scaffold", "ScaffoldEnabled", function(v) SetScaffold(v) end)
CreateFixedSlider(CharTab, "Size X", "ScaffoldX", 1, 10, "%.1f")
CreateFixedSlider(CharTab, "Size Y", "ScaffoldY", 0.5, 10, "%.1f")
CreateFixedSlider(CharTab, "Size Z", "ScaffoldZ", 1, 10, "%.1f")

CharTab:CreateDivider()
local forceToggle

forceToggle = CreateFixedToggle(
    CharTab,
    "Force Apply Stats",
    "ForceApplyEnabled",
    function(v)
        SetForceApply(v)

        if v then
            Notify("Force Apply",
                "Stat locked to your values",
                2)
        end
    end
)

CharTab:CreateButton({
    Name = "Reset Values From Game",
    Callback = function()
        if S.ForceApplyEnabled then
            Notify("Blocked", "Выключи Force Apply чтобы сбросить!", 3)
            return
        end
        local c = LocalPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then
            S.WalkSpeed = hum.WalkSpeed
            S.JumpPower = hum.JumpPower
            S.CameraFOV = workspace.CurrentCamera.FieldOfView
            if UIRefs.Sliders["WalkSpeed"] then UIRefs.Sliders["WalkSpeed"]:Set(S.WalkSpeed, true) end
            if UIRefs.Sliders["JumpPower"] then UIRefs.Sliders["JumpPower"]:Set(S.JumpPower, true) end
            if UIRefs.Sliders["CameraFOV"] then UIRefs.Sliders["CameraFOV"]:Set(S.CameraFOV, true) end
            Notify("Reset", "Синхронизировано с игрой", 2)
        end
    end
})

local FlingTab = Window:CreateTab("Fling")
local FlingStatusLbl = FlingTab:CreateLabel({Text="0 target(s) selected"})
local FlingList
local function UpdateFlingStatus()
    local c=0 for _ in pairs(R.FlingTargets) do c=c+1 end
    if R.FlingActive then FlingStatusLbl:Set("Flinging "..c.." target(s)...")
    else FlingStatusLbl:Set(c.." target(s) selected") end
end
FlingTab:CreateButton({Name="START", Callback=function()
    if FlingList then R.FlingTargets=FlingList:GetSelected() end
    Fling:Start() UpdateFlingStatus()
end})
FlingTab:CreateButton({Name="STOP", Callback=function() Fling:Stop() UpdateFlingStatus() end})
CreateFixedToggle(FlingTab, "Invis", "FlingInvis", function(v) R.FlingInvis=v end)
FlingTab:CreateDivider()
FlingTab:CreateButton({Name="Select All", Callback=function() if FlingList then FlingList:SelectAll() end end})
FlingTab:CreateButton({Name="Deselect All", Callback=function() if FlingList then FlingList:DeselectAll() end end})
FlingList = FlingTab:CreatePlayerList({
    OnChange=function(selected) R.FlingTargets=selected UpdateFlingStatus() end
})

local SaveTab = Window:CreateTab("Save")
local SlotLbl = SaveTab:CreateLabel({Text="Slot 1 [Empty]", Primary=true})
local function UpdateSlotLabel()
    local has=false
    pcall(function() has=isfile and isfile(GetSlotFile(R.CurSlot)) end)
    SlotLbl:Set("Slot "..R.CurSlot.." ["..(has and "Saved" or "Empty").."]")
end
SaveTab:CreateButton({Name="< Previous Slot", Callback=function()
    R.CurSlot=R.CurSlot-1 if R.CurSlot<1 then R.CurSlot=5 end UpdateSlotLabel()
end})
SaveTab:CreateButton({Name="> Next Slot", Callback=function()
    R.CurSlot=R.CurSlot+1 if R.CurSlot>5 then R.CurSlot=1 end UpdateSlotLabel()
end})
SaveTab:CreateDivider()
SaveTab:CreateButton({Name="Save Current Slot", Callback=function() SaveLoad:Save() UpdateSlotLabel() end})
SaveTab:CreateButton({Name="Load Current Slot", Callback=function() SaveLoad:Load() UpdateSlotLabel() end})
SaveTab:CreateButton({Name="Delete Current Slot", Callback=function() SaveLoad:Delete() UpdateSlotLabel() end})
SaveTab:CreateDivider()
CreateFixedToggle(SaveTab, "Auto Save", "AutoSaveEnabled", function(v)
    R.SaveEnabled=v if v then SaveLoad:StartAutoLoop() end
end)
SaveTab:CreateDropdown({
    Name="Auto Save Interval", Options={"1 min","5 min","1 hour"}, Default="1 min",
    Callback=function(v)
        for i, item in ipairs(SaveIntervals) do
            if item.Name==v then R.SaveIntIdx=i R.SaveInterval=item.Time break end
        end
    end
})
UpdateSlotLabel()

if isMobile then
    task.wait(0.3)
    local aimGui = Instance.new("ScreenGui")
    aimGui.Name=GenStr(10) aimGui.ResetOnSpawn=false
    aimGui.IgnoreGuiInset=true aimGui.DisplayOrder=9
    aimGui.Parent=Services.CoreGui
    R.MobileAimGui=aimGui

    local aimBtn = Instance.new("TextButton")
    aimBtn.Name="MobileAimBtn"
    aimBtn.Size=UDim2.new(0,65,0,65)
    aimBtn.Position=UDim2.new(1,-85,0.65,-32)
    aimBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
    aimBtn.BackgroundTransparency=0.25
    aimBtn.Text="" aimBtn.TextColor3=Color3.new(1,1,1)
    aimBtn.TextSize=32 aimBtn.Font=Enum.Font.GothamBold
    aimBtn.BorderSizePixel=0 aimBtn.AutoButtonColor=false
    aimBtn.Parent=aimGui
    Instance.new("UICorner",aimBtn).CornerRadius=UDim.new(1,0)

    local aimStroke=Instance.new("UIStroke")
    aimStroke.Color=Color3.fromRGB(255,255,255)
    aimStroke.Thickness=2 aimStroke.Transparency=0.4 aimStroke.Parent=aimBtn

    local function setAimingState(state)
        R.MobileAiming=state
        if state then
            aimBtn.BackgroundColor3=Color3.fromRGB(180,60,60)
            aimBtn.BackgroundTransparency=0.1
            aimStroke.Color=Color3.fromRGB(255,80,80) aimStroke.Transparency=0
        else
            aimBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
            aimBtn.BackgroundTransparency=0.25
            aimStroke.Color=Color3.fromRGB(255,255,255) aimStroke.Transparency=0.4
            SetLocked(nil)
        end
    end

    local aimTouching,aimMoved=false,false
    local aimStartTP,aimStartBP=nil,nil

    aimBtn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            aimTouching=true aimMoved=false
            aimStartTP=input.Position aimStartBP=aimBtn.Position
            setAimingState(true)
        end
    end)

    local aimChangeListener = function(input)
        if aimTouching and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
            local delta=input.Position-aimStartTP
            if delta.Magnitude>30 then
                if not aimMoved then aimMoved=true setAimingState(false) end
                if aimBtn and aimBtn.Parent then
                    aimBtn.Position=UDim2.new(aimStartBP.X.Scale,aimStartBP.X.Offset+delta.X,aimStartBP.Y.Scale,aimStartBP.Y.Offset+delta.Y)
                end
            end
        end
    end
    local aimEndListener = function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            if aimTouching then aimTouching=false setAimingState(false) end
        end
    end
    local aimTouchEndListener = function()
        if aimTouching then aimTouching=false setAimingState(false) end
    end

    AddInputListener("Changed", aimChangeListener)
    AddInputListener("Ended", aimEndListener)
    AddInputListener("TouchEnded", aimTouchEndListener)

    R.MobileAimListeners = {
        Changed=aimChangeListener, Ended=aimEndListener, TouchEnded=aimTouchEndListener,
    }
end

Main:Init()
local renderName = GenStr(12)
R.RenderName = renderName

shared[DIVA_MARKER] = function()
    pcall(function() Main:Destroy() end)
    pcall(function() Window:Destroy() end)
    pcall(function() DivaUI:Destroy() end)
    shared[DIVA_MARKER]=nil
end

Services.RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value+1, function(dt)
    Main:Update(dt)
    Main:AimUpdate()
end)
