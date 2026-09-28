local _, addon = ...
local panel, minimapButton, volumeLabel, testButton
local volumeButtons = {}
local dragging, suppressClick = false, false

local function PositionMinimapButton()
    local angle = math.rad(UndeadHolyOofDB.minimapAngle)
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle) * (Minimap:GetWidth() / 2 + 8),
        math.sin(angle) * (Minimap:GetHeight() / 2 + 8))
end

local function UpdateMinimapDrag()
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then return end
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local x, y = cursorX / scale - centerX, cursorY / scale - centerY
    if x == 0 and y == 0 then return end
    UndeadHolyOofDB.minimapAngle = math.deg(math.atan2(y, x))
    PositionMinimapButton()
end

local function StopMinimapDrag()
    dragging = false
    minimapButton:SetScript("OnUpdate", nil)
end

function addon.RefreshSettings()
    if not panel then return end
    local selected = addon.GetVolume()
    volumeLabel:SetText(selected == 0 and "Volume: Muted" or ("Volume: " .. selected .. "%"))
    for volume, button in pairs(volumeButtons) do
        button:SetEnabled(volume ~= selected)
    end
    testButton:SetEnabled(selected > 0)
end

function addon.InitializeUI()
    if panel then return end
    panel = CreateFrame("Frame", "UndeadHolyOofSettings", UIParent, "BackdropTemplate")
    panel:SetSize(360, 175)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Undead Holy Oof")
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() panel:Hide() end)
    volumeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    volumeLabel:SetPoint("TOP", 0, -57)
    for index, volume in ipairs({ 0, 25, 50, 75, 100 }) do
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(58, 26)
        button:SetPoint("TOPLEFT", 23 + (index - 1) * 64, -82)
        button:SetText(volume .. "%")
        button:SetScript("OnClick", function() addon.SetVolume(volume) end)
        volumeButtons[volume] = button
    end
    testButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testButton:SetSize(120, 26)
    testButton:SetPoint("TOP", 0, -123)
    testButton:SetText("Test sound")
    testButton:SetScript("OnClick", function() addon.TestSound() end)
    panel:SetScript("OnShow", addon.RefreshSettings)
    table.insert(UISpecialFrames, "UndeadHolyOofSettings")
    panel:Hide()

    minimapButton = CreateFrame("Button", "UndeadHolyOofMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    local angle = UndeadHolyOofDB.minimapAngle
    if type(angle) ~= "number" or angle ~= angle or math.abs(angle) == math.huge then
        UndeadHolyOofDB.minimapAngle = 315
    end
    PositionMinimapButton()
    Minimap:HookScript("OnSizeChanged", PositionMinimapButton)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    minimapButton:RegisterForClicks("LeftButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(24, 24)
    icon:SetPoint("CENTER", minimapButton, "CENTER", 1, 0)
    icon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathScream")
    local mask = minimapButton:CreateMaskTexture()
    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)
    local border = minimapButton:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimapButton:SetScript("OnMouseDown", function() suppressClick = false end)
    minimapButton:SetScript("OnDragStart", function(self)
        dragging, suppressClick = true, true
        GameTooltip:Hide()
        UpdateMinimapDrag()
        self:SetScript("OnUpdate", UpdateMinimapDrag)
    end)
    minimapButton:SetScript("OnDragStop", function()
        UpdateMinimapDrag()
        StopMinimapDrag()
    end)
    minimapButton:SetScript("OnHide", StopMinimapDrag)
    minimapButton:SetScript("OnClick", function()
        if suppressClick or dragging then return end
        addon.ToggleSettings()
    end)
    minimapButton:SetScript("OnEnter", function(self)
        if dragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Undead Holy Oof")
        GameTooltip:AddLine("Click to change volume", 1, 1, 1)
        GameTooltip:AddLine("Drag to move around the minimap", 1, 1, 1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    addon.RefreshSettings()
end

function addon.ToggleSettings()
    addon.InitializeUI()
    panel:SetShown(not panel:IsShown())
end
