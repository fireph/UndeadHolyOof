local _, addon = ...

-- One representative ID per Holy spell. Localized names also match other ranks.
-- Keep this explicit: spellcast events do not include a spell-school mask.
-- Audited against Wowhead Forever on 2026-09-28; see docs/spell-audit.md.
addon.holySpellIDs = {
    PALADIN = {
        635,    -- Holy Light
        19750,  -- Flash of Light
        633,    -- Lay on Hands
        20473,  -- Holy Shock
        1311606, -- Holy Shock (Forever talent)
        678,    -- Holy Strike
        1319259, -- Crusader Strike (Holy variant; match this ID only)
        1310911, -- Light's Vigil
        458856, -- Divine Light
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
        1311649, -- Seal of Fury
        407798, -- Seal of Martyrdom
        20154,  -- Seal of Righteousness (alternate ID)
        465,    -- Devotion Aura
        7294,   -- Retribution Aura
        19746,  -- Concentration Aura
        20218,  -- Sanctity Aura
        19876,  -- Shadow Resistance Aura
        19888,  -- Frost Resistance Aura
        19891,  -- Fire Resistance Aura
        19740,  -- Blessing of Might
        19742,  -- Blessing of Wisdom
        20217,  -- Blessing of Kings
        19977,  -- Blessing of Light
        1038,   -- Blessing of Salvation
        1022,   -- Blessing of Protection
        1044,   -- Blessing of Freedom
        6940,   -- Blessing of Sacrifice
        25782,  -- Greater Blessing of Might
        25894,  -- Greater Blessing of Wisdom
        25898,  -- Greater Blessing of Kings
        25890,  -- Greater Blessing of Light
        25895,  -- Greater Blessing of Salvation
        25780,  -- Righteous Fury
        498,    -- Divine Protection
        642,    -- Divine Shield
        20925,  -- Holy Shield
        412019, -- Sacred Shield
        440658, -- Shield of Righteousness
        407632, -- Hammer of the Righteous
        1219206, -- Hand of Reckoning (active spell, not passive 407774)
        462853, -- Hand of Sacrifice
        407788, -- Avenging Wrath
        407804, -- Divine Sacrifice
        1310897, -- Voice of Truth
        1311015, -- Templar's Bulwark
        853,    -- Hammer of Justice
        20066,  -- Repentance
        1152,   -- Purify
        4987,   -- Cleanse
        7328,   -- Redemption
        5502,   -- Sense Undead
        19752,  -- Divine Intervention
        20216,  -- Divine Favor
        13819,  -- Summon Warhorse
        23214,  -- Summon Charger
        1296534, -- Summon Forsaken Charger
        461607, -- Divine Steed
    },
    PRIEST = {
        585,    -- Smite
        14914,  -- Holy Fire
        15237,  -- Holy Nova
        2050,   -- Lesser Heal
        2054,   -- Heal
        2060,   -- Greater Heal
        2061,   -- Flash Heal
        401937, -- Binding Heal
        402174, -- Penance (cast, not individual bolts)
        401859, -- Prayer of Mending
        401946, -- Circle of Healing
        139,    -- Renew
        596,    -- Prayer of Healing
        17,     -- Power Word: Shield
        1243,   -- Power Word: Fortitude
        21562,  -- Prayer of Fortitude
        27683,  -- Prayer of Shadow Protection (school is Holy)
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
        724,    -- Lightwell
        10060,  -- Power Infusion
        402004, -- Pain Suppression
        425207, -- Power Word: Barrier
        425284, -- Spirit of the Redeemer
    },
}

-- Other Crusader Strike IDs are Physical; never classify them by shared name.
addon.exactOnlySpellIDs = { [1319259] = true }
