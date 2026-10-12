# King — The Unwritten Oath

**Current implementation update — Decision 147:** The owner authorized development. The responsive four-technique core and ten-slot foundation are now installed; eight techniques exist. See [current rules](../decisions/147-responsive-king-core-and-ten-slots.md). Historical timing/four-slot statements below describe the earlier design or implementation baseline. The six divine spells, future stage gates and inheritance rewards remain proposals.

Implemented 2026-09-13 (Decision 144). Eight techniques are available in the collection; King equips four. The original Echoing Sever, Riftbreak, Sovereign Pursuit and Worldsplitter remain the initial loadout and usable alternatives.

## Play and progression

Open **Tab → Active Skills → Technique Collection**, or speak to Eira and open the collection. Select a technique, then its destination slot. Swaps are allowed in Sanctuary while idle. Equipping a technique already in another slot swaps those two slots. A technique keeps its cooldown while unequipped.

In **F7 Combat Lab**, the **King · Technique Collection** button exposes a form selector and **Equip all four Oath skills**. Preview ranks unlock the collection locally and never write campaign flags or loadout saves. Choosing Campaign progression restores the loadout that preceded the preview. F7/F9 retain their existing unlimited-cooldown helper; use a production scene or disable the helper in a test for cooldown balance.

| Family | Function | Learned | Cooldown |
|---|---|---|---|
| Crosscut Advance | A short forward step through alternating physical cuts; each contact is a forward fan | Initial | 5 s |
| Griefwake | Planted blade, then successive ground eruptions along the committed direction | Stage II clear | 8 s |
| Starfall Step | Aim a ground point, cross the gap with movement echoes, then release landing pulses | Initial | 7.5 s |
| Oathstorm | Committed two-handed turns release expanding white-steel waves around King | Stage V clear | 17 s |

Starfall uses the existing ground reticle, confirm/cancel inputs and collision-controlled Player movement. Its 0.24 s travel has invulnerability; preparation and landing/recovery do not. Walls stop travel, and every landing pulse uses the actual reachable point. Crosscut has no invulnerability. Other techniques can be interrupted; enemy armor, wards and boss stagger resistance remain authoritative.

Three successful basic swings still fill Resolve for +25% on one committed skill. Either Pursuit or Starfall landing opens the existing 1.2 s link; the next Riftbreak or Griefwake receives +15%. Another skill consumes the opportunity. Additional Starfall pulses do not refresh it. Level mastery remains +2% per level after 1, capped at +18%, and the current stage ceilings are unchanged.

## Four authored forms

| Family | Mortal | Resonant | Ascendant | Unbound |
|---|---|---|---|---|
| Crosscut | Crosscut Advance | Silver Refrain | Horizon Cleaver | Sever the Horizon |
| Rupture | Griefwake | Echoes Below | Fault of Heaven | The Earth Remembers |
| Mobility | Starfall Step | Comet Return | Astral Passage | Beyond the Firmament |
| Storm | Oathstorm | Choir of Steel | Heaven's Silence | The Unwritten Dawn |

Mortal is the initial form. Clearing Stage V evolves learned techniques to Resonant. Ascendant and Unbound are playable Lab previews and have future story hooks, `king_oath_ascendant` and `king_oath_unbound`. No current campaign encounter grants those flags. Stage XX is the intended next narrative gate, subject to that encounter's still-pending outcome/reward design; late-game placement is not locked. The production route still ends at VI.

Ranks are finite authored steps, not endless farming bonuses. Weapon-derived damage continues to use equipment power and normal critical/mitigation rules. New forms add physical follow-ups, impact pulses and reach; ordinary level mastery does not enlarge effects or shorten cooldowns.

| Tuning, Mortal / Resonant / Ascendant / Unbound | Values |
|---|---|
| Crosscut contacts | 2 / 2 / 3 / 4, 0.22 s apart |
| Crosscut radius; step | 48 / 62 / 76 / 90 px; 28 / 35 / 42 / 49 px |
| Griefwake contacts | 3 / 4 / 5 / 6, 0.16 s apart |
| Griefwake starting radius | 48 / 63 / 78 / 93 px; each successive rupture adds 4 px |
| Starfall contacts | 1 / 2 / 2 / 3, 0.18 s apart after travel |
| Starfall range; starting radius | 180 / 200 / 220 / 240 px; 56 / 69 / 82 / 95 px |
| Oathstorm contacts | 3 / 4 / 5 / 7, 0.19 s apart |
| Oathstorm final radius | 108 / 146 / 184 / 222 px |

Exact damage multipliers and timings live in `KingOathDefinition`. Every beat has one 0.1 s contact window and deduplicates each hurtbox. Crosscut follows King's blade-height origin during its step; ruptures and landing effects stay at their world contacts. Cosmetic settling does not keep damage active.

## Lore and presentation

The Unwritten Oath describes a human promise becoming a fighting discipline. It is not a declaration that King's family survives, that resurrection works, or that a god has already bestowed a power. Early flavor speaks of weight, distance, memory and perseverance; future forms suggest increasing agency without revealing the gods' manipulation.

King keeps the approved C silhouette, clothing, palette and approximately 27 px anatomy. An eight-pose, four-direction greatsword family joins the approved slam and travel poses. Complete weapons fit padded 96×64 cells. Separate 16-frame storm and rupture sequences carry the larger spectacle; the body never scales into a boss. Generated icons use four distinct 24 px silhouettes. Original layered steel, air, stone and low-impact sounds use the SFX bus; accepted-hit camera/flash/hitstop remains the existing feedback presenter's job.

Sources/prompts: `art_source/generated/characters/king/unwritten_oath_2026_09_13/`. Review stills and gameplay video: `art_source/review/characters/king/unwritten_oath_2026_09_13/`.

## Remaining balance work

The forms, swaps and existing combat integrations have focused automated and rendered coverage. Full campaign pacing, crowd damage and the eventual Stage XX equipment/seal matchup still need playtesting. Ascendant/Unbound story rewards, later gear and the final whole-game level cap are future content, not completed progression.
