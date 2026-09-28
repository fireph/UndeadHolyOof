local _, addon = ...

-- One representative ID per Holy spell. Localized names also match other ranks.
-- Keep this explicit: spellcast events do not include a spell-school mask.
addon.holySpellIDs = {
    PALADIN = {
        635,    -- Holy Light
        19750,  -- Flash of Light
        633,    -- Lay on Hands
        20473,  -- Holy Shock
        879,    -- Exorcism
        2812,   -- Holy Wrath
        24275,  -- Hammer of Wrath
        26573,  -- Consecration
        20271,  -- Judgement
        21084,  -- Seal of Righteousness
        20164,  -- Seal of Justice
        20165,  -- Seal of Light
        20166,  -- Seal of Wisdom
        20375,  -- Seal of Command
        21082,  -- Seal of the Crusader
        20154,  -- Seal of Righteousness (alternate ID)
        465,    -- Devotion Aura
        7294,   -- Retribution Aura
        19746,  -- Concentration Aura
        19876,  -- Shadow Resistance Aura
        19888,  -- Frost Resistance Aura
        19891,  -- Fire Resistance Aura
        19740,  -- Blessing of Might
        19742,  -- Blessing of Wisdom
        20217,  -- Blessing of Kings
        20911,  -- Blessing of Sanctuary
        1038,   -- Blessing of Salvation
        1022,   -- Blessing of Protection
        1044,   -- Blessing of Freedom
        6940,   -- Blessing of Sacrifice
        25782,  -- Greater Blessing of Might
        25894,  -- Greater Blessing of Wisdom
        25898,  -- Greater Blessing of Kings
        25899,  -- Greater Blessing of Sanctuary
        25895,  -- Greater Blessing of Salvation
        25780,  -- Righteous Fury
        498,    -- Divine Protection
        642,    -- Divine Shield
        20925,  -- Holy Shield
        853,    -- Hammer of Justice
        20066,  -- Repentance
        2878,   -- Turn Undead
        1152,   -- Purify
        4987,   -- Cleanse
        7328,   -- Redemption
        5502,   -- Sense Undead
        19752,  -- Divine Intervention
        20216,  -- Divine Favor
    },
    PRIEST = {
        585,    -- Smite
        14914,  -- Holy Fire
        15237,  -- Holy Nova
        2050,   -- Lesser Heal
        2054,   -- Heal
        2060,   -- Greater Heal
        2061,   -- Flash Heal
        139,    -- Renew
        596,    -- Prayer of Healing
        17,     -- Power Word: Shield
        1243,   -- Power Word: Fortitude
        21562,  -- Prayer of Fortitude
        14752,  -- Divine Spirit
        27681,  -- Prayer of Spirit
        588,    -- Inner Fire
        1706,   -- Levitate
        2006,   -- Resurrection
        528,    -- Cure Disease
        552,    -- Abolish Disease
        527,    -- Dispel Magic
        9484,   -- Shackle Undead
        6346,   -- Fear Ward
        19236,  -- Desperate Prayer
        724,    -- Lightwell
        10060,  -- Power Infusion
    },
}
