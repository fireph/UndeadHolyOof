# Forever spell audit — 2026-09-28

Scope: Holy-school class casts for the current Undead paladin or priest, including
class mount summons. This does not make NPC spells, item effects, passive talents,
or spells restricted to another race into eligible casts. Database presence does
not prove that an ability is currently obtainable in the beta.

## Sources and completeness

- [All Holy spells](https://www.wowhead.com/forever/spells/school:1): 1,241 entries;
  the unpartitioned page embeds only 1,000.
- Retrieved the complete disjoint lists for [levels 0–30](https://www.wowhead.com/forever/spells/school:1/max-level:30)
  (796) and [levels 31+](https://www.wowhead.com/forever/spells/school:1/min-level:31)
  (445). Verified 1,241 unique IDs and the Holy school mask on retained entries.
- Cross-checked [paladin abilities](https://www.wowhead.com/forever/spells/abilities/paladin)
  (254), [paladin talents](https://www.wowhead.com/forever/spells/talents/paladin)
  (49), [priest abilities](https://www.wowhead.com/forever/spells/abilities/priest)
  (318), and [priest talents](https://www.wowhead.com/forever/spells/talents/priest)
  (54). These four lists are not truncated.
- Reviewed individual records for new spell families, racial restrictions, and
  questionable active/passive entries. `HolySpells.lua` retains 100 representative
  IDs covering 98 names. Localized spell names cover other ranks, except for the
  ID-only Holy Crusader Strike variant.

## Corrections

Added paladin healing, blessings, seals, defensive abilities, attacks, talents,
and mounts missing from the original Classic-based list. Added priest Binding
Heal, Penance, Prayer of Mending, Circle of Healing, Prayer of Shadow Protection,
Pain Suppression, Power Word: Barrier, and Spirit of the Redeemer.

- Removed [Turn Undead](https://www.wowhead.com/forever/spell=2878): Nature school.
- Removed Blessing of Sanctuary (20911) and Greater Blessing of Sanctuary (25899):
  absent from the Forever catalogs; their Forever detail URLs returned 404.
- Removed Desperate Prayer: the Forever records restrict it to dwarves. Other
  race-only spells (Chastise, Divine Grace, Elune's Grace, Confounding Flash,
  Contingency Plan) cannot be cast by the addon’s Undead characters.
- Excluded [Holy Precision](https://www.wowhead.com/forever/spell=1309957): passive.
- Excluded Holy entries named Divine Storm (407784), Righteous Judgement (440677),
  Judgement of Fury (20183 and related ranks), and Judgement of Martyrdom (407803):
  triggered heal/damage effects rather than separately cast Holy abilities.
- Use active Hand of Reckoning (1219206), not its passive record (407774).
- [Prayer of Shadow Protection](https://www.wowhead.com/forever/spell=27683) is Holy
  despite its name. [Inner Focus](https://www.wowhead.com/forever/spell=14751) is
  Physical despite being a priest cooldown.
- Holy Crusader Strike (1319259) is matched by ID only; Physical Crusader Strike
  must not qualify through a shared localized name.

The addon still relies on the client's successful player-cast events. The audit
verifies database coverage, not in-game event delivery or beta learnability.
