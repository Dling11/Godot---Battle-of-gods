# Decision 100: Lock the Stage V Core Set Before Enabling Crafting

> Superseded in set size and equipment-authority boundary by Decision 101; retained as the original art/data lock record.

- **Status:** Accepted; data and read-only preview implemented, transactions pending
- **Date:** 2026-08-15

## Context

Stage V now grants a permanent core-gear seal and Varkuun Cores, but crafting cannot safely begin until its outputs, costs, stat budgets, visual identities, and slot mappings are stable. Enabling material spending first would create save and balance migration work around provisional items.

## Alternatives Considered

1. Enable crafting immediately with placeholder icons and change outputs later.
2. Add every armor and accessory tier at once.
3. Lock one five-item Stage V core set as immutable data and read-only Rootforge content, then implement atomic crafting and non-weapon equipment authority separately.

## Decision

Choose option 3. Stage V provides Varkuun Edge, Old Bark Helm, Heartwood Plate, Rootfiber Gloves, and Mirehide Boots. Their stats and exact recipes are owned by `docs/design/stage-5-core-equipment-set.md`.

Varkuun Edge reuses King's integrated sword art, contact shape, timing, and knockback while raising normal damage from 10-12 to 11-13 and skill power from 25 to 28. The armor set uses only maximum health, armor, and regeneration fields already supported by player components. No attack speed, critical chance, lifesteal, mana, resistance, or conditional proc is claimed.

The recipe catalog exposes all five Stage V recipes plus the two future Stage VIII accessory previews. Nema shows output icons and stats but cannot craft. F9 may grant maximum materials and Varkuun Edge for non-saving tests; it does not grant the four armor pieces before their ownership/equip authority exists.

## Consequences

- Icon, item, recipe, and stat identities are stable before material spending is introduced.
- Four total Varkuun Cores make the full set attainable after first clear plus two replays.
- The next implementation step has a narrow boundary: atomic crafting, general equipment ownership, four armor equip positions, stat aggregation, and save migration.
- Existing accessory previews remain sealed for Stage VIII.
- Normal play still cannot craft or equip non-weapon gear, and documentation must continue saying so.
