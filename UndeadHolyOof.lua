local addonName, addon = ...
local soundDirectory = "Interface\\AddOns\\" .. addonName .. "\\sounds\\"
local soundChoices = {
    { filename = "pain.mp3", weight = 1 },
    { filename = "ack.mp3", weight = 11 },
    { filename = "bone-crack.mp3", weight = 11 },
    { filename = "bonk.mp3", weight = 11 },
    { filename = "error.mp3", weight = 11 },
    { filename = "gunshot.mp3", weight = 11 },
    { filename = "lego-breaking.mp3", weight = 11 },
    { filename = "minecraft-hit.mp3", weight = 11 },
    { filename = "minecraft-oof.mp3", weight = 11 },
    { filename = "roblox-oof.mp3", weight = 11 },
}
local lastSound
local holyIDs, holyNames = {}, {}
local recentCasts, castOrder, nextCast = {}, {}, 1
local frame = CreateFrame("Frame")
local validVolumes = { [0] = true, [25] = true, [50] = true, [75] = true, [100] = true }
local soundHandles = {}

function addon.GetVolume()
    return UndeadHolyOofDB.volume
end

function addon.SetVolume(volume)
    if not validVolumes[volume] then return end
    UndeadHolyOofDB.volume = volume
    -- Apply changes immediately to any clips still playing.
    for _, handle in ipairs(soundHandles) do StopSound(handle) end
    soundHandles = {}
    if addon.RefreshSettings then addon.RefreshSettings() end
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function SpellName(spellID)
    local info = C_Spell.GetSpellInfo(spellID)
    if IsSecret(info) or not info or IsSecret(info.name) then return end
    return info.name
end

local function BuildSpellLookup()
    for class, ids in pairs(addon.holySpellIDs) do
        holyIDs[class] = holyIDs[class] or {}
        holyNames[class] = holyNames[class] or {}
        for _, spellID in ipairs(ids) do
            holyIDs[class][spellID] = true
            local name = SpellName(spellID)
            if name and not addon.exactOnlySpellIDs[spellID] then
                holyNames[class][name] = true
            end
        end
    end
end

local function PlayOof()
    local volume = addon.GetVolume()
    if volume == 0 then return true end
    -- Preserve the 1% pain / 11% common marginal distribution without repeats.
    -- After pain: nine equal common choices. After a common sound: pain gets
    -- 8/792 = 1/99, and each of the other eight common sounds gets 98/792.
    -- Thus P(next pain) = P(previous common) / 99 = 0.99 / 99 = 0.01.
    local pain = soundChoices[1]
    local total = not lastSound and 100 or (lastSound == pain and 9 or 792)
    local roll = math.random(1, total)
    local selected
    for _, sound in ipairs(soundChoices) do
        if sound ~= lastSound then
            local weight = sound.weight
            if lastSound == pain then
                weight = 1
            elseif lastSound then
                weight = sound == pain and 8 or 98
            end
            roll = roll - weight
            if roll <= 0 then
                selected = sound
                break
            end
        end
    end
    local subdirectory = volume == 100 and "" or (volume .. "\\")
    local path = soundDirectory .. subdirectory .. selected.filename
    local played, handle = PlaySoundFile(path, "Master")
    if played and handle then
        -- Discard completed handles before tracking this clip.
        local active = {}
        for _, previous in ipairs(soundHandles) do
            if C_Sound.IsPlaying(previous) then active[#active + 1] = previous end
        end
        active[#active + 1] = handle
        soundHandles = active
    end
    if played then lastSound = selected end
    return played, path
end

function addon.TestSound()
    local played, path = PlayOof()
    if not played then print("Undead Holy Oof: cannot play " .. path) end
end

local function OnCast(unit, castGUID, spellID)
    if not UndeadHolyOofDB or not UndeadHolyOofDB.enabled then return end
    -- Restricted combat information cannot be inspected or used as table keys.
    if IsSecret(unit) or IsSecret(castGUID) or IsSecret(spellID) then return end
    if unit ~= "player" or type(spellID) ~= "number" then return end
    local _, race = UnitRace("player")
    local _, class = UnitClass("player")
    if IsSecret(race) or IsSecret(class) then return end
    if race ~= "Scourge" or not holyIDs[class] then return end

    if not holyIDs[class][spellID] then
        local name = SpellName(spellID)
        if not name or not holyNames[class][name] then return end
    end

    -- Ignore duplicate success notifications for the same cast.
    -- Bound the cache so it cannot grow throughout a long session.
    if castGUID and castGUID ~= "" then
        if recentCasts[castGUID] then return end
        local old = castOrder[nextCast]
        if old then recentCasts[old] = nil end
        recentCasts[castGUID] = true
        castOrder[nextCast] = castGUID
        nextCast = nextCast % 128 + 1
    end
    PlayOof()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName ~= addonName then return end
        if type(UndeadHolyOofDB) ~= "table" then UndeadHolyOofDB = {} end
        if UndeadHolyOofDB.enabled == nil then UndeadHolyOofDB.enabled = true end
        if not validVolumes[UndeadHolyOofDB.volume] then UndeadHolyOofDB.volume = 100 end
        BuildSpellLookup()
        frame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        addon.InitializeUI()
        frame:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "SPELLS_CHANGED" then
        BuildSpellLookup()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnCast(...)
    end
end)

SLASH_UNDEADHOLYOOF1 = "/uhoof"
SlashCmdList.UNDEADHOLYOOF = function(message)
    local command = message:match("^%s*(.-)%s*$"):lower()
    if command == "test" then
        addon.TestSound()
    elseif command == "" or command == "options" then
        addon.ToggleSettings()
    elseif command == "on" or command == "off" then
        UndeadHolyOofDB.enabled = command == "on"
        print("Undead Holy Oof: " .. command)
    else
        print("Undead Holy Oof: /uhoof options, /uhoof test, /uhoof on, /uhoof off")
    end
end
