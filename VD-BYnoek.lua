-- Violence District - NOEK Premium v12.1 FINAL CLEAN
-- Добавлен ColorPicker для FOV аимбота, исправлены все функции, убран мусор
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local safe_call = function(f, ...) local ok, err = pcall(f, ...) if not ok then warn(err) end end

-- Состояние всех опций
local State = {
    brightness = 2, worldTime = 14,
    bloomEnabled = false, bloom = 0,
    contrastEnabled = false, contrast = 0.5,
    skyboxEnabled = false,
    localGlowEnabled = false, localGlowColor = Color3.fromRGB(255,255,0),
    worldColorEnabled = false, worldColor = Color3.fromRGB(255,255,255),
    playerAuraEnabled = false, playerAuraColor = Color3.fromRGB(0,255,0),
    maniacAuraEnabled = false, maniacAuraColor = Color3.fromRGB(255,0,0),
    vaultAuraEnabled = false, vaultAuraColor = Color3.fromRGB(255,255,0),
    fovEnabled = false, fov = 70,
    stretchResEnabled = false, stretchRes = 0.9,
    walkSpeedActive = false, walkSpeedValue = 30, walkSpeedBind = nil, walkSpeedHolding = false, walkSpeedMode = "Hold",
    moonwalkActive = false, moonwalkBind = nil, moonwalkHolding = false, moonwalkMode = "Toggle", moonwalkBodyVelocity = nil,
    spinbotActive = false, spinbotSpeed = 180, spinbotBind = nil, spinbotHolding = false, spinbotMode = "Toggle",
    aimbotEnabled = false, aimbotBind = nil, aimbotHolding = false, aimbotMode = "Hold", aimbotFOV = 100, aimbotPart = "Head",
    aimbotFOVColor = Color3.fromRGB(128, 0, 128),
    menuScale = 1.0, menuBg = Color3.fromRGB(18,18,22)
}
local loops = {fov = nil, walkSpeed = nil, moonwalk = nil, spinbot = nil, stretchRes = nil}
local effects = {bloom = nil, cc = nil, skybox = nil}
local walkSpeedConnections = {}

-- Aimbot FOV Circle
local aimbotCircle = Drawing.new("Circle")
aimbotCircle.Radius = State.aimbotFOV
aimbotCircle.Color = State.aimbotFOVColor
aimbotCircle.Thickness = 2
aimbotCircle.Transparency = 0.6
aimbotCircle.Visible = false
aimbotCircle.Filled = false

-- ==================== GUI ====================
local mainGui = Instance.new("ScreenGui", CoreGui)
mainGui.Name = "VD_Main"; mainGui.ResetOnSpawn = false; mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local main = Instance.new("Frame", mainGui)
main.BackgroundColor3 = State.menuBg; main.BorderSizePixel = 0; main.Visible = false; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,35); topBar.BackgroundColor3 = Color3.fromRGB(12,12,16); topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)
local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.65,0,1,0); titleLabel.Position = UDim2.new(0.02,0,0,0)
titleLabel.BackgroundTransparency = 1; titleLabel.Text = "VIOLENCE DISTRICT"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255); titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextSize = 16; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
local subLabel = Instance.new("TextLabel", topBar)
subLabel.Size = UDim2.new(0.3,0,1,0); subLabel.Position = UDim2.new(0.68,0,0,0)
subLabel.BackgroundTransparency = 1; subLabel.Text = "by NOEK"; subLabel.TextColor3 = Color3.fromRGB(255,140,0)
subLabel.Font = Enum.Font.GothamBlack; subLabel.TextSize = 12; subLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Вкладки
local tabButtons = Instance.new("Frame", main)
tabButtons.Size = UDim2.new(0,100,1,-45); tabButtons.Position = UDim2.new(0,5,0,40); tabButtons.BackgroundTransparency = 1
Instance.new("UIListLayout", tabButtons).Padding = UDim.new(0,3)
local tabs, pages = {}, {}

local function resizeMain(page)
    local layout = page:FindFirstChildOfClass("UIListLayout")
    if layout then
        local h = math.min(600, 45 + layout.AbsoluteContentSize.Y + 20)
        main.Size = UDim2.new(0, 420 * State.menuScale, 0, h * State.menuScale)
        main.Position = UDim2.new(0.5, -210 * State.menuScale, 0.5, -h/2 * State.menuScale)
    end
end

local function createTab(name, icon)
    local btn = Instance.new("TextButton", tabButtons)
    btn.Size = UDim2.new(1,-4,0,30); btn.Text = " "..icon.." "..name
    btn.BackgroundColor3 = Color3.fromRGB(28,28,34); btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(190,190,190); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local page = Instance.new("ScrollingFrame", main)
    page.Size = UDim2.new(1,-120,1,-55); page.Position = UDim2.new(0,110,0,45)
    page.BackgroundTransparency = 1; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    page.CanvasSize = UDim2.new(0,0,0,0); page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,4); layout.SortOrder = Enum.SortOrder.LayoutOrder
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do t.BackgroundColor3 = Color3.fromRGB(28,28,34); t.BackgroundTransparency = 0.2 end
        btn.BackgroundColor3 = Color3.fromRGB(55,55,100); btn.BackgroundTransparency = 0
        for _, p in ipairs(pages) do p.Visible = false end
        page.Visible = true
        wait(0.05)
        page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
        resizeMain(page)
    end)
    table.insert(tabs, btn); table.insert(pages, page)
    return page
end

local lightingPage = createTab("Lighting", "💡")
local visualPage = createTab("Visual", "🎨")
local ragePage = createTab("Rage", "💢")
local miscPage = createTab("Misc", "⚙️")
tabs[1].BackgroundColor3 = Color3.fromRGB(55,55,100); tabs[1].BackgroundTransparency = 0
pages[1].Visible = true; wait(0.1); resizeMain(pages[1])

-- ==================== UI КОМПОНЕНТЫ ====================
local function addSection(parent, title)
    local s = Instance.new("Frame", parent)
    s.Size = UDim2.new(1,-8,0,22); s.BackgroundColor3 = Color3.fromRGB(28,28,34); s.BackgroundTransparency = 0.4
    Instance.new("UICorner", s).CornerRadius = UDim.new(0,5)
    local l = Instance.new("TextLabel", s)
    l.Size = UDim2.new(1,-10,1,0); l.Position = UDim2.new(0,10,0,0); l.BackgroundTransparency = 1
    l.Text = title; l.TextColor3 = Color3.fromRGB(190,190,190); l.Font = Enum.Font.GothamBold; l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left
    return s
end

local function createSlider(parent, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-10,0,30); frame.BackgroundColor3 = Color3.fromRGB(32,32,38); frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,5)
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1,-16,0,8); bg.Position = UDim2.new(0,8,0,11); bg.BackgroundColor3 = Color3.fromRGB(55,55,60)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,4)
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(100,100,255); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
    local knob = Instance.new("TextButton", bg)
    knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new((default-min)/(max-min),-7,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,7)
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0,40,0,14); valLabel.Position = UDim2.new(0,8,0,2); valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default); valLabel.TextColor3 = Color3.fromRGB(255,255,255); valLabel.Font = Enum.Font.Gotham; valLabel.TextSize = 10
    local current = default; local dragging = false
    local function update(input)
        local percent = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        current = math.floor((min + (max-min)*percent)*100+0.5)/100
        fill.Size = UDim2.new(percent,0,1,0); knob.Position = UDim2.new(percent,-7,0.5,-7); valLabel.Text = tostring(current)
        if callback then callback(current) end
    end
    knob.MouseButton1Down:Connect(function() dragging = true end)
    bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end end)
    UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    return frame
end

local function createToggle(parent, text, default, onToggle)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-10,0,28); btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.BackgroundColor3 = default and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = text .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)
        if onToggle then onToggle(enabled) end
    end)
    return btn
end

local function createColorPicker(parent, defaultColor, onColorChange)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-10,0,100); frame.BackgroundColor3 = Color3.fromRGB(32,32,38); frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    local preview = Instance.new("Frame", frame)
    preview.Size = UDim2.new(0,24,0,24); preview.Position = UDim2.new(1,-30,0,5)
    preview.BackgroundColor3 = defaultColor; preview.BorderSizePixel = 1; preview.BorderColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0,4)
    local r, g, b = math.floor(defaultColor.R*255), math.floor(defaultColor.G*255), math.floor(defaultColor.B*255)
    local function updatePreview() preview.BackgroundColor3 = Color3.fromRGB(r,g,b) end
    local function makeCh(ch, y, val, clr)
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0,10,0,16); lbl.Position = UDim2.new(0,5,0,y); lbl.BackgroundTransparency = 1; lbl.Text = ch; lbl.TextColor3 = clr; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
        local bg = Instance.new("Frame", frame)
        bg.Size = UDim2.new(1,-65,0,7); bg.Position = UDim2.new(0,20,0,y+3); bg.BackgroundColor3 = Color3.fromRGB(55,55,60)
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0,4)
        local fill = Instance.new("Frame", bg)
        fill.Size = UDim2.new(val/255,0,1,0); fill.BackgroundColor3 = clr; fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
        local knob = Instance.new("TextButton", bg)
        knob.Size = UDim2.new(0,13,0,13); knob.Position = UDim2.new(val/255,-6,0.5,-6); knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.Text = ""
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,6)
        local valLbl = Instance.new("TextLabel", frame)
        valLbl.Size = UDim2.new(0,30,0,16); valLbl.Position = UDim2.new(1,-35,0,y); valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(val); valLbl.TextColor3 = Color3.fromRGB(255,255,255); valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 10; valLbl.TextXAlignment = Enum.TextXAlignment.Right
        local dragging = false
        local function upd(input)
            local percent = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(percent*255)
            if ch == "R" then r = newVal elseif ch == "G" then g = newVal else b = newVal end
            fill.Size = UDim2.new(percent,0,1,0); knob.Position = UDim2.new(percent,-6,0.5,-6); valLbl.Text = tostring(newVal)
            updatePreview()
            if onColorChange then onColorChange(Color3.fromRGB(r,g,b)) end
        end
        knob.MouseButton1Down:Connect(function() dragging = true end)
        bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; upd(input) end end)
        UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then upd(input) end end)
        UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    end
    makeCh("R", 35, r, Color3.fromRGB(255,80,80)); makeCh("G", 60, g, Color3.fromRGB(80,255,80)); makeCh("B", 85, b, Color3.fromRGB(80,80,255))
    return frame
end

local function createBindButton(parent, text, onBind)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-10,0,25); btn.Text = text; btn.BackgroundColor3 = Color3.fromRGB(32,32,38)
    btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Press a key..."
        local con; con = UIS.InputBegan:Connect(function(input, gp)
            if not gp and (input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton4 or input.UserInputType == Enum.UserInputType.MouseButton5) then
                con:Disconnect(); btn.Text = text .. ": " .. tostring(input.KeyCode)
                if onBind then onBind(input) end
            end
        end)
    end)
    return btn
end

local function createModeButton(parent, modeVar, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-10,0,22); btn.Text = "Mode: " .. modeVar
    btn.BackgroundColor3 = Color3.fromRGB(32,32,38); btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    btn.MouseButton1Click:Connect(function()
        if modeVar == "Hold" then modeVar = "Toggle" else modeVar = "Hold" end
        btn.Text = "Mode: " .. modeVar
        if callback then callback(modeVar) end
    end)
    return btn
end

-- ==================== LIGHTING PAGE ====================
addSection(lightingPage, "Brightness")
createSlider(lightingPage, 0, 10, State.brightness, function(v) State.brightness = v; safe_call(function() Lighting.Brightness = v end) end)
addSection(lightingPage, "World Time")
createSlider(lightingPage, 1, 24, State.worldTime, function(v) State.worldTime = v; safe_call(function() Lighting.ClockTime = v end) end)
addSection(lightingPage, "Bloom")
local bloomToggle = createToggle(lightingPage, "Bloom", State.bloomEnabled, function(on)
    State.bloomEnabled = on
    if on then
        if not effects.bloom then effects.bloom = Instance.new("BloomEffect"); safe_call(function() effects.bloom.Parent = Lighting end) end
        safe_call(function() effects.bloom.Intensity = State.bloom end)
    else
        if effects.bloom then safe_call(function() effects.bloom:Destroy(); effects.bloom = nil end) end
    end
end)
createSlider(lightingPage, 0, 2, State.bloom, function(v) State.bloom = v; if State.bloomEnabled and effects.bloom then safe_call(function() effects.bloom.Intensity = v end) end end)
addSection(lightingPage, "Contrast")
local contrastToggle = createToggle(lightingPage, "Contrast", State.contrastEnabled, function(on)
    State.contrastEnabled = on
    if on then
        if not effects.cc then effects.cc = Instance.new("ColorCorrectionEffect"); safe_call(function() effects.cc.Parent = Lighting end) end
        safe_call(function() effects.cc.Contrast = State.contrast end)
    else
        if effects.cc then safe_call(function() effects.cc:Destroy(); effects.cc = nil end) end
    end
end)
createSlider(lightingPage, 0, 2, State.contrast, function(v) State.contrast = v; if State.contrastEnabled and effects.cc then safe_call(function() effects.cc.Contrast = v end) end end)
addSection(lightingPage, "Skybox (Blue)")
createToggle(lightingPage, "Skybox", State.skyboxEnabled, function(on)
    State.skyboxEnabled = on
    if on then applySkybox() else removeSkybox() end
end)
addSection(lightingPage, "Local Glow")
createToggle(lightingPage, "Local Glow", State.localGlowEnabled, function(on)
    State.localGlowEnabled = on
    if on then applyLocalGlow() else removeLocalGlow() end
end)
createColorPicker(lightingPage, State.localGlowColor, function(c) State.localGlowColor = c; if State.localGlowEnabled then applyLocalGlow() end end)
addSection(lightingPage, "World Color")
createToggle(lightingPage, "World Color", State.worldColorEnabled, function(on)
    State.worldColorEnabled = on
    if on then setWorldColor(State.worldColor) else resetWorldColor() end
end)
createColorPicker(lightingPage, State.worldColor, function(c) State.worldColor = c; if State.worldColorEnabled then setWorldColor(c) end end)

-- ==================== VISUAL PAGE ====================
addSection(visualPage, "Player Aura")
createToggle(visualPage, "Player Aura", State.playerAuraEnabled, function(on)
    State.playerAuraEnabled = on
    if on then applyPlayerAuras() else removePlayerAuras() end
end)
createColorPicker(visualPage, State.playerAuraColor, function(c) State.playerAuraColor = c; if State.playerAuraEnabled then applyPlayerAuras() end end)
addSection(visualPage, "Maniac Aura")
createToggle(visualPage, "Maniac Aura", State.maniacAuraEnabled, function(on)
    State.maniacAuraEnabled = on
    if on then applyManiacAura() else removeManiacAura() end
end)
createColorPicker(visualPage, State.maniacAuraColor, function(c) State.maniacAuraColor = c; if State.maniacAuraEnabled then applyManiacAura() end end)
addSection(visualPage, "Vault Aura")
createToggle(visualPage, "Vault Aura", State.vaultAuraEnabled, function(on)
    State.vaultAuraEnabled = on
    if on then applyVaultAuras() else removeVaultAuras() end
end)
createColorPicker(visualPage, State.vaultAuraColor, function(c) State.vaultAuraColor = c; if State.vaultAuraEnabled then applyVaultAuras() end end)
addSection(visualPage, "FOV")
createToggle(visualPage, "FOV", State.fovEnabled, function(on)
    State.fovEnabled = on
    if on then
        safe_call(function() Camera.FieldOfView = State.fov end)
        loops.fov = RunService.RenderStepped:Connect(function() safe_call(function() Camera.FieldOfView = State.fov end) end)
    else
        safe_call(function() Camera.FieldOfView = 70 end)
        if loops.fov then safe_call(function() loops.fov:Disconnect(); loops.fov = nil end) end
    end
end)
createSlider(visualPage, 30, 120, State.fov, function(v) State.fov = v; if State.fovEnabled then safe_call(function() Camera.FieldOfView = v end) end end)
addSection(visualPage, "Stretch Res")
createToggle(visualPage, "Stretch Res", State.stretchResEnabled, function(on)
    State.stretchResEnabled = on
    if on then
        if not loops.stretchRes then
            loops.stretchRes = RunService.RenderStepped:Connect(function() safe_call(function() Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, State.stretchRes, 0, 0, 0, 1) end) end)
        end
    else
        if loops.stretchRes then safe_call(function() loops.stretchRes:Disconnect(); loops.stretchRes = nil end) end
    end
end)
createSlider(visualPage, 0.8, 1.0, State.stretchRes, function(v) State.stretchRes = v end)

-- ==================== RAGE PAGE ====================
addSection(ragePage, "Walk Speed")
local walkSpeedToggle = createToggle(ragePage, "Walk Speed", State.walkSpeedActive, function(on)
    State.walkSpeedActive = on
    if on then startWalkSpeedLoop() else stopWalkSpeedLoop() end
end)
createSlider(ragePage, 1, 200, State.walkSpeedValue, function(v) State.walkSpeedValue = v end)
createBindButton(ragePage, "Walk Speed Bind: None", function(input) State.walkSpeedBind = input end)
createModeButton(ragePage, State.walkSpeedMode, function(m) State.walkSpeedMode = m end)

addSection(ragePage, "Moonwalk")
local moonwalkToggle = createToggle(ragePage, "Moonwalk", State.moonwalkActive, function(on) State.moonwalkActive = on; if on then startMoonwalkLoop() else stopMoonwalkLoop() end end)
createBindButton(ragePage, "Moonwalk Bind: None", function(input) State.moonwalkBind = input end)
createModeButton(ragePage, State.moonwalkMode, function(m) State.moonwalkMode = m end)

addSection(ragePage, "Spinbot")
local spinbotToggle = createToggle(ragePage, "Spinbot", State.spinbotActive, function(on) State.spinbotActive = on; if on then startSpinbotLoop() else stopSpinbotLoop() end end)
createSlider(ragePage, 50, 720, State.spinbotSpeed, function(v) State.spinbotSpeed = v end)
createBindButton(ragePage, "Spinbot Bind: None", function(input) State.spinbotBind = input end)
createModeButton(ragePage, State.spinbotMode, function(m) State.spinbotMode = m end)

addSection(ragePage, "Aimbot")
local aimbotToggle = createToggle(ragePage, "Aimbot", State.aimbotEnabled, function(on)
    State.aimbotEnabled = on
    aimbotCircle.Visible = on
end)
createSlider(ragePage, 30, 200, State.aimbotFOV, function(v) State.aimbotFOV = v; aimbotCircle.Radius = v end)
createBindButton(ragePage, "Aimbot Bind: None", function(input) State.aimbotBind = input end)
createModeButton(ragePage, State.aimbotMode, function(m) State.aimbotMode = m end)
local aimPartBtn = Instance.new("TextButton", ragePage)
aimPartBtn.Size = UDim2.new(1,-10,0,28); aimPartBtn.Text = "Aim Part: Head"
aimPartBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); aimPartBtn.TextColor3 = Color3.fromRGB(255,255,255)
aimPartBtn.Font = Enum.Font.GothamBold; aimPartBtn.TextSize = 11
Instance.new("UICorner", aimPartBtn).CornerRadius = UDim.new(0,5)
aimPartBtn.MouseButton1Click:Connect(function()
    if State.aimbotPart == "Head" then State.aimbotPart = "Body"; aimPartBtn.Text = "Aim Part: Body"
    else State.aimbotPart = "Head"; aimPartBtn.Text = "Aim Part: Head" end
end)
createColorPicker(ragePage, State.aimbotFOVColor, function(c) State.aimbotFOVColor = c; aimbotCircle.Color = c end)

-- ==================== MISC PAGE ====================
addSection(miscPage, "Menu Scale")
createSlider(miscPage, 0.7, 1.5, State.menuScale, function(v) State.menuScale = v; resizeMain(currentPage or pages[1]) end)
addSection(miscPage, "Menu Background")
createColorPicker(miscPage, State.menuBg, function(c) State.menuBg = c; main.BackgroundColor3 = c end)

-- ==================== LOGIC ====================
function applySkybox()
    if effects.skybox then safe_call(function() effects.skybox:Destroy() end) end
    effects.skybox = Instance.new("Sky", Lighting)
    local c = Color3.fromRGB(100,150,255)
    effects.skybox.SkyboxBk = c; effects.skybox.SkyboxDn = c; effects.skybox.SkyboxFt = c
    effects.skybox.SkyboxLf = c; effects.skybox.SkyboxRt = c; effects.skybox.SkyboxUp = c
    effects.skybox.SunTextureId = ""; effects.skybox.MoonTextureId = ""; effects.skybox.SunAngularSize = 0
end
function removeSkybox() if effects.skybox then safe_call(function() effects.skybox:Destroy(); effects.skybox = nil end) end end

function applyLocalGlow()
    if not LocalPlayer.Character then return end
    local color = State.localGlowColor
    local hl = LocalPlayer.Character:FindFirstChild("LocalGlow") or Instance.new("Highlight")
    hl.Name = "LocalGlow"; hl.Parent = LocalPlayer.Character; hl.FillColor = color; hl.FillTransparency = 0.5; hl.OutlineTransparency = 1
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local light = root:FindFirstChild("LocalGlowLight") or Instance.new("PointLight")
        light.Name = "LocalGlowLight"; light.Parent = root; light.Color = color; light.Brightness = 1.5; light.Range = 8; light.Enabled = true
    end
end
function removeLocalGlow()
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("LocalGlow"); if h then safe_call(function() h:Destroy() end) end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then local light = root:FindFirstChild("LocalGlowLight"); if light then safe_call(function() light:Destroy() end) end end
    end
end

function applyPlayerAuras()
    local color = State.playerAuraColor
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            safe_call(function()
                if player.Character then
                    if State.maniacAuraEnabled and IsManiac(player) then
                        local h = player.Character:FindFirstChild("PlayerAura"); if h then h:Destroy() end; return
                    end
                    local hl = player.Character:FindFirstChild("PlayerAura") or Instance.new("Highlight")
                    hl.Name = "PlayerAura"; hl.Parent = player.Character; hl.FillColor = color; hl.FillTransparency = 0.6
                    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.OutlineTransparency = 0.5; hl.OutlineThickness = 2
                end
            end)
        end
    end
end
function removePlayerAuras()
    for _, p in ipairs(Players:GetPlayers()) do
        safe_call(function() if p.Character then local h = p.Character:FindFirstChild("PlayerAura"); if h then h:Destroy() end end end)
    end
end

function applyManiacAura()
    local color = State.maniacAuraColor
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            safe_call(function()
                if player.Character and IsManiac(player) then
                    local hl = player.Character:FindFirstChild("ManiacAura") or Instance.new("Highlight")
                    hl.Name = "ManiacAura"; hl.Parent = player.Character; hl.FillColor = color; hl.FillTransparency = 0.5
                    hl.OutlineColor = color; hl.OutlineTransparency = 0.3
                end
            end)
        end
    end
end
function removeManiacAura()
    for _, p in ipairs(Players:GetPlayers()) do
        safe_call(function() if p.Character then local h = p.Character:FindFirstChild("ManiacAura"); if h then h:Destroy() end end end)
    end
end

function IsManiac(player)
    if not player.Character then return false end
    if player:GetAttribute("IsManiac") or player:GetAttribute("Role") == "Maniac" or player:GetAttribute("Team") == "Maniac" then return true end
    local char = player.Character
    if char:FindFirstChild("Maniac") or char:FindFirstChild("Killer") or char:FindFirstChild("Murderer") then return true end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed > 24 then return true end
    if player.Team and player.Team.Name and (string.find(string.lower(player.Team.Name), "maniac") or string.find(string.lower(player.Team.Name), "killer")) then return true end
    if string.find(string.lower(player.Name), "maniac") or string.find(string.lower(player.DisplayName), "maniac") then return true end
    return false
end

-- Исправленная Vault Aura: ищет pallet/pallets/window/vault/vaults + дочерние объекты
function applyVaultAuras()
    if not State.vaultAuraEnabled then return end
    local color = State.vaultAuraColor
    removeVaultAuras()
    local keywords = {"pallet", "window", "vault"} -- базовые ключи
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local parentName = obj.Parent and obj.Parent.Name:lower() or ""
        -- проверяем, содержит ли имя объекта или его родителя одно из ключевых слов (учитываем множественное число)
        local found = false
        for _, kw in ipairs(keywords) do
            if name:find(kw) or parentName:find(kw) then
                found = true
                break
            end
        end
        if found then
            if obj:IsA("Model") and obj.PrimaryPart then
                local hl = Instance.new("Highlight", obj)
                hl.Name = "VaultAura"; hl.FillColor = color; hl.FillTransparency = 0.8
                hl.OutlineColor = color; hl.OutlineTransparency = 0.5; hl.OutlineThickness = 1
            elseif obj:IsA("BasePart") and not obj:IsA("Terrain") and (not LocalPlayer.Character or not obj:IsDescendantOf(LocalPlayer.Character)) then
                local hl = Instance.new("Highlight", obj)
                hl.Name = "VaultAura"; hl.FillColor = color; hl.FillTransparency = 0.8
                hl.OutlineColor = color; hl.OutlineTransparency = 0.5; hl.OutlineThickness = 1
            end
        end
    end
end
function removeVaultAuras()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "VaultAura" then obj:Destroy() end
    end
end

function setWorldColor(color)
    safe_call(function()
        Lighting.Ambient = color; Lighting.OutdoorAmbient = color; Lighting.ColorShift_Top = color; Lighting.ColorShift_Bottom = color; Lighting.FogColor = color; Lighting.FogEnd = 5000
    end)
end
function resetWorldColor()
    safe_call(function()
        Lighting.Ambient = Color3.fromRGB(0,0,0); Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
        Lighting.ColorShift_Top = Color3.fromRGB(0,0,0); Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
        Lighting.FogColor = Color3.fromRGB(191,191,191); Lighting.FogEnd = 100000
    end)
end

-- Walk Speed
local function startWalkSpeedLoop()
    if loops.walkSpeed then loops.walkSpeed:Disconnect() end
    loops.walkSpeed = RunService.Heartbeat:Connect(function()
        if State.walkSpeedHolding or State.walkSpeedActive then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then hum.WalkSpeed = State.walkSpeedValue end
            end
        end
    end)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            local conn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if State.walkSpeedHolding or State.walkSpeedActive then hum.WalkSpeed = State.walkSpeedValue end
            end)
            table.insert(walkSpeedConnections, conn)
        end
    end
end
local function stopWalkSpeedLoop()
    if loops.walkSpeed then loops.walkSpeed:Disconnect(); loops.walkSpeed = nil end
    for _, conn in ipairs(walkSpeedConnections) do conn:Disconnect() end
    walkSpeedConnections = {}
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

-- Moonwalk
local function startMoonwalkLoop()
    if loops.moonwalk then loops.moonwalk:Disconnect() end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = root:FindFirstChild("MoonwalkBodyVelocity")
    if bv then bv:Destroy() end
    bv = Instance.new("BodyVelocity")
    bv.Name = "MoonwalkBodyVelocity"
    bv.MaxForce = Vector3.new(1e4, 0, 1e4)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    State.moonwalkBodyVelocity = bv
    if char:FindFirstChild("Humanoid") then char.Humanoid.AutoRotate = false end

    loops.moonwalk = RunService.Heartbeat:Connect(function()
        if State.moonwalkHolding or State.moonwalkActive then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char:FindFirstChild("HumanoidRootPart")
                local bv = State.moonwalkBodyVelocity
                if bv and bv.Parent == root then
                    local moveDir = -root.CFrame.LookVector
                    bv.Velocity = moveDir * 50
                end
            end
        end
    end)
end
local function stopMoonwalkLoop()
    if loops.moonwalk then loops.moonwalk:Disconnect(); loops.moonwalk = nil end
    local bv = State.moonwalkBodyVelocity
    if bv then bv:Destroy(); State.moonwalkBodyVelocity = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.AutoRotate = true
    end
end

-- Spinbot
local function startSpinbotLoop()
    if loops.spinbot then loops.spinbot:Disconnect() end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = false end
    end
    loops.spinbot = RunService.Heartbeat:Connect(function()
        if State.spinbotHolding or State.spinbotActive then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(State.spinbotSpeed / 60), 0)
            end
        end
    end)
end
local function stopSpinbotLoop()
    if loops.spinbot then loops.spinbot:Disconnect(); loops.spinbot = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.AutoRotate = true
    end
end

-- Aimbot (Hold) – цвет FOV регулируется
local function getAimTarget()
    local closest = nil
    local minDist = math.huge
    local center = Camera.ViewportSize / 2
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetChar = player.Character
            local targetPart
            if State.aimbotPart == "Head" then
                local head = targetChar:FindFirstChild("Head")
                if head then
                    targetPart = head.Position
                else
                    local root = targetChar:FindFirstChild("HumanoidRootPart")
                    if root then targetPart = root.Position + Vector3.new(0, 1.5, 0) end
                end
            else
                local root = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
                if root then targetPart = root.Position end
            end
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= State.aimbotFOV then
                        if dist < minDist then
                            minDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Input handling
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
        UIS.MouseBehavior = main.Visible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    end

    if State.walkSpeedBind and input.UserInputType == State.walkSpeedBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.walkSpeedBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        if State.walkSpeedMode == "Toggle" then
            State.walkSpeedActive = not State.walkSpeedActive
            walkSpeedToggle.Text = "Walk Speed: " .. (State.walkSpeedActive and "ON" or "OFF")
            walkSpeedToggle.BackgroundColor3 = State.walkSpeedActive and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)
            if State.walkSpeedActive then startWalkSpeedLoop() else stopWalkSpeedLoop() end
        else
            if not State.walkSpeedHolding then State.walkSpeedHolding = true; startWalkSpeedLoop() end
        end
    end

    if State.moonwalkBind and input.UserInputType == State.moonwalkBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.moonwalkBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        if State.moonwalkMode == "Toggle" then
            State.moonwalkActive = not State.moonwalkActive
            moonwalkToggle.Text = "Moonwalk: " .. (State.moonwalkActive and "ON" or "OFF")
            moonwalkToggle.BackgroundColor3 = State.moonwalkActive and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)
            if State.moonwalkActive then startMoonwalkLoop() else stopMoonwalkLoop() end
        else
            if not State.moonwalkHolding then State.moonwalkHolding = true; startMoonwalkLoop() end
        end
    end

    if State.spinbotBind and input.UserInputType == State.spinbotBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.spinbotBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        if State.spinbotMode == "Toggle" then
            State.spinbotActive = not State.spinbotActive
            spinbotToggle.Text = "Spinbot: " .. (State.spinbotActive and "ON" or "OFF")
            spinbotToggle.BackgroundColor3 = State.spinbotActive and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)
            if State.spinbotActive then startSpinbotLoop() else stopSpinbotLoop() end
        else
            if not State.spinbotHolding then State.spinbotHolding = true; startSpinbotLoop() end
        end
    end

    if State.aimbotBind and input.UserInputType == State.aimbotBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.aimbotBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        if State.aimbotMode == "Toggle" then
            State.aimbotActive = not State.aimbotActive
            aimbotToggle.Text = "Aimbot: " .. (State.aimbotActive and "ON" or "OFF")
            aimbotToggle.BackgroundColor3 = State.aimbotActive and Color3.fromRGB(0,180,0) or Color3.fromRGB(40,40,40)
        else
            State.aimbotHolding = true
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if State.walkSpeedBind and State.walkSpeedMode == "Hold" and input.UserInputType == State.walkSpeedBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.walkSpeedBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        State.walkSpeedHolding = false; stopWalkSpeedLoop()
    end
    if State.moonwalkBind and State.moonwalkMode == "Hold" and input.UserInputType == State.moonwalkBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.moonwalkBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        State.moonwalkHolding = false; stopMoonwalkLoop()
    end
    if State.spinbotBind and State.spinbotMode == "Hold" and input.UserInputType == State.spinbotBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.spinbotBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        State.spinbotHolding = false; stopSpinbotLoop()
    end
    if State.aimbotBind and State.aimbotMode == "Hold" and input.UserInputType == State.aimbotBind.UserInputType and (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.aimbotBind.KeyCode or input.UserInputType ~= Enum.UserInputType.Keyboard) then
        State.aimbotHolding = false
    end
end)

-- RenderStepped (Aimbot)
RunService.RenderStepped:Connect(function()
    if State.aimbotEnabled then
        aimbotCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        aimbotCircle.Visible = true
        if State.aimbotHolding or State.aimbotActive then
            local targetPos = getAimTarget()
            if targetPos then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end
    else
        aimbotCircle.Visible = false
    end
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if State.walkSpeedHolding or State.walkSpeedActive then wait(0.3); startWalkSpeedLoop() end
    if State.moonwalkHolding or State.moonwalkActive then wait(0.3); startMoonwalkLoop() end
    if State.spinbotHolding or State.spinbotActive then wait(0.3); startSpinbotLoop() end
    if State.localGlowEnabled then wait(0.3); applyLocalGlow() end
    if State.stretchResEnabled then
        if loops.stretchRes then loops.stretchRes:Disconnect() end
        loops.stretchRes = RunService.RenderStepped:Connect(function() Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, State.stretchRes, 0, 0, 0, 1) end)
    end
end)

-- Periodic updates
task.spawn(function()
    while wait(3) do
        if State.playerAuraEnabled then applyPlayerAuras() end
        if State.maniacAuraEnabled then applyManiacAura() end
        if State.vaultAuraEnabled then applyVaultAuras() end
        if State.localGlowEnabled then applyLocalGlow() end
    end
end)

-- Init
safe_call(function() settings().Rendering.QualityLevel = 5; settings().Rendering.EnableFRM = true end)