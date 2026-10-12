# Decision 065: Use One Character and Bag Surface

- **Status:** Accepted and implemented
- **Date:** 2026-07-29

## Context

The former Gear page used large weapon cards, a narrow five-slot list, and a separate armory column. It could equip the current swords but did not provide the MMORPG-like paper doll, compact inventory scan, or material visibility needed before loot and crafting become playable.

Materials and weapons already have separate saved authorities. Combining their presentation must not combine their ownership rules or make crafting materials consume ordinary equipment capacity.

## Alternatives Considered

1. Keep the existing armory and add a separate material-list modal.
2. Build one generic mutable item dictionary owned by the UI.
3. Build one Character & Bag presentation that observes the existing authorities, with a shared compact slot grammar and distinct capacity rules.

## Decision

Choose option 3.

`CharacterMenu` now presents:

- seven paper-doll positions around the canonical live Opaw/weapon preview;
- one compact 24-slot bag grid with All, Equipment, Materials, Consumables, and Key filters;
- real owned weapons from `WeaponInventory`;
- real nonzero material stacks from `MaterialInventory`;
- one shared detail panel that permits explicit weapon equip requests and read-only material inspection.

Only ordinary equipment counts toward the 24-slot bag display. Materials remain in a capacity-free material pouch even when the All filter presents them in the shared grid. Empty, consumable, key-item, and future equipment positions are honest presentation states, not fabricated items. Every current Forest material now uses its approved flattened 24x24 icon; the family glyph remains a defensive fallback only for future definitions whose art is not yet produced.

The UI never mutates ownership dictionaries, resolves drops, crafts items, or writes save files. Weapon equip still routes through `Player`; material quantity changes still route through `MaterialInventory`.

## Consequences

- The UI is ready to show Segment 3 chest rewards without inventing a second inventory model.
- Weapon purchase/equip behavior and save reconstruction remain unchanged.
- The material pouch can scale independently from ordinary bag capacity.
- Decision 099's later compact pass makes F9 raise every authored material to the non-saving maximum for repeated crafting simulation; ordinary play still earns real materials through Segment 3.
- Sanctuary stash transfer, overflow handling, discard confirmation, consumable/key-item authorities, and armor stats remain later work.
- The seven-slot paper doll is forward-compatible presentation; only the weapon slot currently has an equippable runtime item.
