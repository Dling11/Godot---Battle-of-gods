# Decision 120: Enable Atomic Rootforge Crafting

## Status

Accepted — 2026-08-22

## Context

Stage V already grants Varkuun Cores, the permanent `forest_core_gear_seal`, and the category discovery `forest_core_gear_crafting`. Six exact equipment recipes, ownership authorities, live equipping, and profile persistence are implemented, but Nema's action remained disabled. The preview also checked only individual `RecipeDiscovery` IDs, so a legitimate Stage V clear still displayed the recipes as sealed even though the milestone category had been discovered.

## Decision

Add one reusable `CraftingService` authority. A craft is ready only when:

- the recipe is the canonical catalog resource;
- its individual recipe or category discovery is present;
- the required permanent milestone seal is owned;
- every exact ingredient quantity is available;
- its supported unique equipment output is not already owned.

The transaction reserves the equipment output, spends the full material batch once, then requests one Sanctuary safe-point save. Any acquisition, spend, or save failure restores the pre-transaction material and output-inventory snapshots. Duplicate crafting is rejected before mutation. `RootforgeMenu` presents the reason for every disabled state and invokes the service; it never mutates inventories itself.

Stage V's category discovery unlocks its six current recipes. The two Stage VIII accessory previews remain sealed. Exact authored costs are unchanged.

Inventory drag previews preserve the local grab point beneath the mouse, fixing the visible offset under the project's 2x canvas scaling without changing equipment drop authority.

## Consequences

- The implemented loop now reaches Fight → Loot → Craft → Equip → Save.
- Varkuun Core ownership alone is not sufficient when another authored ingredient is missing; the Rootforge displays every owned/required count and a clear `MISSING MATERIALS` state.
- Crafted weapons and armor use the existing `WeaponInventory` and `GearInventory` ownership paths and appear in Character & Bag immediately.
- Crafted equipment is unique; there is no repeat-craft, sell, dismantle, or refund transaction yet.
- Hunts and later-region crafting remain separate milestones.
