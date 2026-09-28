-- Run from the repository root with Lua 5.1: lua tests/addon_test.lua
local frame, sounds, messages = {}, {}, {}
local race, class = "Scourge", "PRIEST"
local secret = {}
local names = { [585] = "Localized Smite", [591] = "Localized Smite" }
local registered = {}
local activeHandles = {}
C_Sound = { IsPlaying = function(handle) return activeHandles[handle] end }
function StopSound(handle) activeHandles[handle] = nil end
local soundDirectory = "Interface\\AddOns\\UndeadHolyOof\\sounds\\"
local expectedWeights = {
    ["pain.mp3"] = 1,
    ["ack.mp3"] = 11,
    ["bone-crack.mp3"] = 11,
    ["bonk.mp3"] = 11,
    ["error.mp3"] = 11,
    ["gunshot.mp3"] = 11,
    ["lego-breaking.mp3"] = 11,
    ["minecraft-hit.mp3"] = 11,
    ["minecraft-oof.mp3"] = 11,
    ["roblox-oof.mp3"] = 11,
}

function CreateFrame() return frame end
function frame:RegisterEvent(event) registered[event] = true end
function frame:RegisterUnitEvent(event, unit) registered[event] = unit end
function frame:UnregisterEvent(event) registered[event] = nil end
function frame:SetScript(_, callback) self.callback = callback end
function UnitRace(unit) assert(unit == "player"); return "Localized race", race end
function UnitClass(unit) assert(unit == "player"); return "Localized class", class end
function issecretvalue(value) return value == secret end
function PlaySoundFile(path, channel)
    assert(path:sub(1, #soundDirectory) == soundDirectory)
    assert(expectedWeights[path:match("([^\\]+)$")])
    assert(channel == "Master")
    sounds[#sounds + 1] = path
    activeHandles[#sounds] = true
    return true, #sounds
end
local output = print
function print(message) messages[#messages + 1] = message end
C_Spell = { GetSpellInfo = function(id)
    if names[id] then return { name = names[id] } end
end }
SlashCmdList = {}
local addon = {}
assert(loadfile("HolySpells.lua"))("UndeadHolyOof", addon)
assert(loadfile("UndeadHolyOof.lua"))("UndeadHolyOof", addon)

local function fire(event, ...) frame.callback(frame, event, ...) end
local function cast(unit, guid, id) fire("UNIT_SPELLCAST_SUCCEEDED", unit, guid, id) end
local function count(expected) assert(#sounds == expected, "Unexpected sound count: " .. #sounds) end

assert(registered.UNIT_SPELLCAST_SUCCEEDED == "player")
fire("ADDON_LOADED", "SomeOtherAddon")
assert(UndeadHolyOofDB == nil)
fire("ADDON_LOADED", "UndeadHolyOof")
assert(UndeadHolyOofDB.enabled)
assert(addon.GetVolume() == 100)
cast("player", "cast-1", 585); count(1)
cast("player", "cast-1", 585); count(1) -- duplicate
cast("target", "cast-other", 585); count(1)
cast("party1", "cast-party", 585); count(1)
cast("player", "cast-2", 591); count(2) -- another rank, localized name
cast("player", "cast-shadow", 589); count(2) -- Shadow Word: Pain
cast("player", "cast-unknown", 999999); count(2)
fire("UNIT_SPELLCAST_START", "player", "cancelled", 585)
fire("UNIT_SPELLCAST_INTERRUPTED", "player", "cancelled", 585); count(2)
race = "Human"
cast("player", "cast-human", 585); count(2)
race, class = "Scourge", "MAGE"
cast("player", "cast-mage", 585); count(2)
class = "PALADIN"
cast("player", "cast-paladin", 635); count(3)
cast("player", "cast-blessing", 19740); count(4)
cast("player", "cast-physical", 6603); count(4)
cast("player", "cast-wrong-class", 585); count(4)
cast(secret, "cast-secret-unit", 635)
cast("player", secret, 635)
cast("player", "cast-secret-id", secret)
race = secret
cast("player", "cast-secret-race", 635)
race, class = "Scourge", secret
cast("player", "cast-secret-class", 635); count(4)
class = "PALADIN"
SlashCmdList.UNDEADHOLYOOF(" off ")
cast("player", "cast-disabled", 635); count(4)
SlashCmdList.UNDEADHOLYOOF("test"); count(5)
SlashCmdList.UNDEADHOLYOOF("ON")
cast("player", "cast-enabled", 635); count(6)
for i = 1, 256 do cast("player", "many-" .. i, 635) end
count(262)
cast("player", "many-256", 635); count(262)

-- Exhaust the initial distribution and every possible previous-sound transition.
local originalRandom = math.random
local function reload()
    assert(loadfile("UndeadHolyOof.lua"))("UndeadHolyOof", addon)
    fire("ADDON_LOADED", "UndeadHolyOof")
end
local function forceRoll(roll, total)
    math.random = function(low, high)
        assert(low == 1 and high == total)
        return roll
    end
end
local function latest() return sounds[#sounds]:sub(#soundDirectory + 1) end
local frequencies, seedRolls = {}, {}
for roll = 1, 100 do
    reload()
    forceRoll(roll, 100)
    cast("player", "initial", 635)
    local filename = latest()
    frequencies[filename] = (frequencies[filename] or 0) + 1
    seedRolls[filename] = roll
end
for filename, weight in pairs(expectedWeights) do
    assert(frequencies[filename] == weight, "Wrong initial weight for " .. filename)
    local file = assert(io.open("sounds/" .. filename, "rb"))
    assert(file:seek("end") > 0)
    file:close()
end
local transitions = {}
for previous, seed in pairs(seedRolls) do
    local total = previous == "pain.mp3" and 9 or 792
    frequencies = {}
    for roll = 1, total do
        reload()
        forceRoll(seed, 100)
        cast("player", "seed", 635)
        assert(latest() == previous)
        forceRoll(roll, total)
        -- Manual tests and automatic casts share the no-repeat history.
        if roll % 2 == 0 then
            SlashCmdList.UNDEADHOLYOOF("test")
        else
            cast("player", "next", 635)
        end
        local filename = latest()
        assert(filename ~= previous, "Consecutive repeat: " .. filename)
        frequencies[filename] = (frequencies[filename] or 0) + 1
    end
    transitions[previous] = {}
    for filename in pairs(expectedWeights) do
        local expected = 0
        if filename ~= previous then
            expected = previous == "pain.mp3" and 1 or (filename == "pain.mp3" and 8 or 98)
        end
        assert((frequencies[filename] or 0) == expected)
        transitions[previous][filename] = (frequencies[filename] or 0) / total
    end
end
-- Starting at 1%/11%, a transition preserves those exact marginal probabilities.
-- This checks the full distribution rather than a potentially flaky simulation.
for filename, weight in pairs(expectedWeights) do
    local probability = 0
    for previous, previousWeight in pairs(expectedWeights) do
        probability = probability + previousWeight / 100 * transitions[previous][filename]
    end
    assert(math.abs(probability - weight / 100) < 1e-12, "Biased probability: " .. filename)
end
math.random = originalRandom
local soundCount = #sounds

-- Reload preserves the saved disabled preference.
UndeadHolyOofDB.enabled = false
assert(loadfile("UndeadHolyOof.lua"))("UndeadHolyOof", addon)
fire("ADDON_LOADED", "UndeadHolyOof")
assert(UndeadHolyOofDB.enabled == false)
cast("player", "after-reload", 635); count(soundCount)

UndeadHolyOofDB.enabled = true
for _, volume in ipairs({ 25, 50, 75, 100 }) do
    addon.SetVolume(volume)
    assert(addon.GetVolume() == volume)
    local before = #sounds
    cast("player", "volume-" .. volume, 635)
    count(before + 1)
    local prefix = soundDirectory .. (volume == 100 and "" or (volume .. "\\"))
    assert(sounds[#sounds]:sub(1, #prefix) == prefix)
    local previousFilename = sounds[#sounds]:match("([^\\]+)$")
    addon.SetVolume(volume == 100 and 25 or 100)
    assert(not activeHandles[#sounds], "Volume change must stop the old clip")
    SlashCmdList.UNDEADHOLYOOF("test")
    assert(sounds[#sounds]:match("([^\\]+)$") ~= previousFilename)
end
addon.SetVolume(0)
assert(not activeHandles[#sounds])
soundCount = #sounds
cast("player", "muted-cast", 635)
SlashCmdList.UNDEADHOLYOOF("test")
count(soundCount)
assert(addon.GetVolume() == 0)
reload()
assert(addon.GetVolume() == 0, "Mute must persist")
addon.SetVolume(50)
reload()
assert(addon.GetVolume() == 50, "Volume must persist")
addon.SetVolume(42)
assert(addon.GetVolume() == 50, "Invalid choice must be ignored")
UndeadHolyOofDB.volume = "invalid"
reload()
assert(addon.GetVolume() == 100, "Invalid saved volume must default to 100")
output("PASS: exact 1%/11% marginal probabilities, all no-repeat transitions, volume, mute, persistence, assets, filtering, controls")
