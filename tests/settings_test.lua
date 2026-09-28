-- Lightweight UI behavior test; the actual layout still requires an in-game check.
local frames = {}
local methods = {}
local function newWidget(name)
    local widget = setmetatable({ scripts = {}, shown = true, enabled = true }, { __index = methods })
    frames[#frames + 1] = widget
    if name then _G[name] = widget end
    return widget
end
for _, method in ipairs({ "SetSize", "SetPoint", "SetFrameStrata", "SetClampedToScreen",
    "SetMovable", "EnableMouse", "RegisterForDrag", "SetBackdrop", "StartMoving",
    "StopMovingOrSizing", "SetFrameLevel", "RegisterForClicks", "SetHighlightTexture" }) do
    methods[method] = function() end
end
function methods:SetScript(event, callback) self.scripts[event] = callback end
function methods:HookScript(event, callback) self.scripts[event] = callback end
function methods:SetSize(width, height) self.width, self.height = width, height end
function methods:SetPoint(...) self.point = { ... } end
function methods:ClearAllPoints() self.point = nil end
function methods:GetWidth() return self.width or 160 end
function methods:GetHeight() return self.height or 160 end
function methods:GetCenter() return 400, 300 end
function methods:GetEffectiveScale() return 2 end
function methods:SetText(text) self.text = text end
function methods:SetEnabled(enabled) self.enabled = enabled end
function methods:SetTexture(texture) self.texture = texture end
function methods:CreateTexture() return newWidget() end
function methods:CreateMaskTexture() return newWidget() end
function methods:SetAllPoints(target) self.allPoints = target end
function methods:AddMaskTexture(mask) self.mask = mask end
function methods:CreateFontString() return newWidget() end
function methods:GetFrameLevel() return 1 end
function methods:IsShown() return self.shown end
function methods:Hide() self.shown = false end
function methods:SetShown(shown)
    self.shown = shown
    if shown and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function CreateFrame(_, name) return newWidget(name) end
UIParent, Minimap, UISpecialFrames = newWidget(), newWidget(), {}
UndeadHolyOofDB = {}
GameTooltip = { Hide = function() end }
local cursorX, cursorY = 1200, 600
function GetCursorPosition() return cursorX, cursorY end
local volume, previews = 100, 0
local addon = {}
function addon.GetVolume() return volume end
function addon.SetVolume(value) volume = value; addon.RefreshSettings() end
function addon.TestSound() previews = previews + 1 end
assert(loadfile("Settings.lua"))("UndeadHolyOof", addon)
addon.InitializeUI()
local panel, icon = UndeadHolyOofSettings, UndeadHolyOofMinimapButton
assert(panel and icon and not panel:IsShown())
assert(UISpecialFrames[1] == "UndeadHolyOofSettings")
local frameCount = #frames
addon.InitializeUI()
assert(#frames == frameCount, "UI must be created once")
icon.scripts.OnClick(icon)
assert(panel:IsShown())
local choices, testButton, foundIcon = {}, nil, false
for _, widget in ipairs(frames) do
    assert(not widget.text or not widget.text:find("Saved automatically", 1, true))
    local percent = widget.text and widget.text:match("^(%d+)%%$")
    if percent then choices[tonumber(percent)] = widget end
    if widget.text == "Test sound" then testButton = widget end
    if widget.texture == "Interface\\Icons\\Spell_Shadow_DeathScream" then
        foundIcon = true
        assert(widget.width == 24 and widget.height == 24)
        assert(widget.point[2] == icon and widget.point[4] == 1 and widget.point[5] == 0)
        assert(widget.mask and widget.mask.allPoints == widget)
        assert(widget.mask.texture == "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    end
end
assert(foundIcon)
for _, value in ipairs({ 0, 25, 50, 75, 100 }) do
    assert(choices[value])
    choices[value].scripts.OnClick()
    assert(volume == value)
    for candidate, button in pairs(choices) do
        assert(button.enabled == (candidate ~= value))
    end
    assert(testButton.enabled == (value > 0))
end
testButton.scripts.OnClick()
assert(previews == 1)
icon.scripts.OnClick(icon)
assert(not panel:IsShown())

local function near(actual, expected) assert(math.abs(actual - expected) < 1e-9) end
local function checkAnchor(x, y)
    assert(icon.point[1] == "CENTER" and icon.point[2] == Minimap and icon.point[3] == "CENTER")
    near(icon.point[4], x)
    near(icon.point[5], y)
end
near(UndeadHolyOofDB.minimapAngle, 315)
checkAnchor(88 / math.sqrt(2), -88 / math.sqrt(2))
icon.scripts.OnMouseDown(icon)
icon.scripts.OnDragStart(icon)
assert(icon.scripts.OnUpdate)
checkAnchor(88, 0) -- cursor coordinates are divided by effective UI scale
cursorX, cursorY = 800, 200
icon.scripts.OnUpdate(icon)
checkAnchor(0, -88)
icon.scripts.OnDragStop(icon)
assert(icon.scripts.OnUpdate == nil)
near(UndeadHolyOofDB.minimapAngle, -90)
icon.scripts.OnClick(icon) -- releasing a drag must not open the settings
assert(not panel:IsShown())
icon.scripts.OnMouseDown(icon)
icon.scripts.OnClick(icon)
assert(panel:IsShown())
Minimap:SetSize(200, 100)
Minimap.scripts.OnSizeChanged()
checkAnchor(0, -58)
-- Recreate the UI with the saved position to simulate the next login.
assert(loadfile("Settings.lua"))("UndeadHolyOof", addon)
addon.InitializeUI()
icon = UndeadHolyOofMinimapButton
checkAnchor(0, -58)
-- Match ForeverDubbed's cursor angle on non-square minimaps too.
cursorX, cursorY = 1000, 800
icon.scripts.OnDragStart(icon)
near(UndeadHolyOofDB.minimapAngle, 45)
checkAnchor(108 / math.sqrt(2), 58 / math.sqrt(2))
icon.scripts.OnHide(icon)
assert(icon.scripts.OnUpdate == nil)
print("PASS: footer removed, drag geometry, scaling, resize, saved position, click suppression, volume UI")
