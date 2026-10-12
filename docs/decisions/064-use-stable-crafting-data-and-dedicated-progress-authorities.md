# Decision 064: Use Stable Crafting Data and Dedicated Progress Authorities

- **Status:** Accepted and implemented
- **Date:** 2026-07-29

## Context

The Forest loop needs material, drop, stage-reward, and recipe identities before enemies or chests begin granting items. If those rules live in enemy controllers, stage scripts, UI labels, or story flags, Stage 4 and later regions would duplicate balance logic and saved crafting progress would become entangled with narrative state.

The version-1 profile already reserved extension dictionaries for material inventory and recipe discovery. Existing profiles may contain those sections as empty dictionaries, so activating them must preserve compatibility.

## Alternatives Considered

1. Store material counts and recipe unlocks as `StoryState` flags and key items.
2. Hard-code current enemy drops and recipe costs in stage/controller scripts until the crafting UI exists.
3. Author stable immutable Resources now, with dedicated mutable material and recipe-discovery authorities connected through the reserved save extensions.

## Decision

Choose option 3.

The project uses:

- `MaterialDefinition` plus exact `MaterialStackDefinition` and a global validated material catalog;
- `MaterialDropEntryDefinition` and `DropProfileDefinition` for ecology-linked enemy reward plans;
- `LootTableDefinition` for guaranteed first-clear/replay stage rewards and recipe discoveries;
- `RecipeDefinition` plus a global validated recipe catalog for deterministic outputs and exact ingredient costs;
- `MaterialInventory` for mutable known-material quantities;
- `RecipeDiscovery` for mutable known-recipe IDs, separate from narrative flags.

Current Forest IDs are stable and region-prefixed. Material and recipe catalogs reject unknown or duplicate IDs, invalid quantities, duplicate ingredient costs, and malformed content. `SaveService` stores versioned snapshots from both authorities in the already-reserved profile extensions. Empty legacy version-1 extension dictionaries remain valid and restore as clean empty crafting progress.

At Segment 2 acceptance, the project did not roll or grant drops, spawn chests, craft outputs, add equipment stats, or expose material UI. ADR 065 later added read-only material inspection without changing any reward or crafting authority; the other behaviors remain owned by later segments.

## Consequences

- Stage 4 and later enemies can reference one shared data grammar instead of embedding loot math in controllers.
- Ordinary recipe progress cannot accidentally satisfy narrative route requirements.
- Material quantities and recipe discoveries survive safe-point Continue and backup recovery.
- Existing version-1 saves remain readable without a schema-version bump.
- The current four recipe outputs are blueprint contracts only; they are not obtainable or equippable until the loot and crafting segments implement their authorities and presentation.
