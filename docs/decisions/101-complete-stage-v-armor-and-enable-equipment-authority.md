# Decision 101: Complete Stage V Armor and Enable Equipment Authority

- **Status:** Accepted and implemented; normal crafting transaction pending
- **Date:** 2026-08-15

## Context

The four-position armor model felt visually and functionally incomplete without Leggings. Stage V item definitions existed, but non-weapon ownership, equipping, live stat aggregation, sorting, drag-to-equip, and persistence did not. Adding unsupported critical or magic-resistance labels would create fake stats because combat has no critical-hit or damage-type authority yet.

## Alternatives Considered

1. Keep four armor positions and treat Boots as the whole lower-body piece.
2. Add Leggings as presentation only and leave armor effects dormant.
3. Finalize five armor positions and implement a small reusable stat/equipment authority now.

## Decision

Choose option 3. The stable loadout is one Weapon Essence; Head, Plate, Gloves, Leggings, and Boots; Bracer, Amulet, Ring, and Talisman. Stage V adds Mirebound Leggings and becomes a six-output set including Varkuun Edge.

The reusable live stat vocabulary is maximum health, armor, Ward, normal-attack speed, health regeneration, and grounded movement speed. Ward is capped all-damage reduction applied after armor. No critical resistance, magic resistance, lifesteal, or proc is displayed until its gameplay authority exists.

`GearInventory` owns non-weapon acquisition, per-character slot choices, snapshot validation, and restoration. `Player` aggregates equipped effects into existing health, vitality, regeneration, attack, and movement components. Inventory items can be selected or dragged to a matching slot and sorted by slot, name, rarity, or quantity.

F9 remains non-saving. It grants the authored Stage V equipment, recipes, seal, and maximum materials so the UI reports test readiness instead of a missing-seal blocker. Normal Rootforge crafting remains disabled until one atomic transaction can validate, consume, grant, and save safely.

## Consequences

- King moves at 110 px/s and uses a 0.46-second base normal-attack cycle; Stage V Boots raise movement to 126.5 px/s and Gloves shorten the cycle by 12% to approximately its prior feel.
- The five armor pieces total +32 maximum health, +16 armor, +4% Ward, +12% normal-attack speed, and +15% grounded movement speed.
- Stage V's six recipes cost five Varkuun Cores in total, requiring first clear plus three replay catalyst claims under the current reward cadence.
- Existing profiles remain compatible because the new gear snapshot extension may be absent and restores as empty.
- Decision 101 supersedes Decision 099's four-armor count and Decision 100's five-output boundary; their historical rationale remains preserved.
