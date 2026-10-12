# Decision 130: Saturate Earned Loot but Keep Paid Creation Strict

## Status

Accepted — 2026-08-24

## Context

Material ownership has a technical maximum. Strict overflow rejection is correct for purchases and reconstruction, because spending resources for an output that cannot be stored would be unfair. Applying the same rejection to earned loot caused world pickups to remain permanently uncollectable and milestone chests to stay closed, blocking progression when any guaranteed reward stack was already full.

## Alternatives Considered

1. Leave full-stack pickups in the world until the player spends materials.
2. Raise or remove the technical maximum.
3. Saturate earned loot at the maximum while retaining strict capacity checks for paid material creation.

## Decision

Choose option 3. `MaterialInventory.add_material*` remains strict and rejects overflow. New `collect_material*` operations validate the complete request, add only the available amount, clamp ownership at `MAX_MATERIAL_QUANTITY`, and report accepted and overflow quantities.

Only `LootService` uses saturating collection. Enemy pickups count a valid capped collection as consumed and leave the world. Stage chests still record claims, permanent unlocks, saves, and onward progression even when some or all material quantities are discarded at the cap. Loot presentation reports the actual addition and clearly marks `MAX / STACK FULL`.

Umi and future paid material-creation services use strict capacity checks and must reject a full output stack before consuming fuel, gold, memory charges, or other costs.

## Consequences

- Full inventories cannot litter stages with uncollectable pickups.
- Material caps cannot block boss-chest progression or portals.
- Players receive honest feedback when some or all earned quantity is discarded.
- Paid creation never silently wastes its costs.
- The technical cap and save validation remain unchanged.
