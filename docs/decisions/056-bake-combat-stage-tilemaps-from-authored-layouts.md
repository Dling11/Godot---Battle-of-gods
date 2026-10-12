# Decision 056: Bake Combat-Stage TileMaps from Authored Layout Resources

- **Status:** Accepted
- **Date:** 2026-07-23

## Context

Stages I-III all used the same four-tile bright atlas and a seeded runtime fill. The result was reproducible but still visually arbitrary: terrain did not explain routes or arenas, while manually placed statues had no authored ground relationship and therefore read as random decoration. The project also needed organized shared and region-specific environment resources that remain easy to revise in Godot.

## Alternatives Considered

1. Keep seeded runtime variation and add more random tile choices.
2. Paint every stage only as opaque embedded TileMap data with no reusable composition source.
3. Define exact stage layouts in resources, materialize them into `TileMapLayer`, and bake the cells into scenes for normal editor painting.

## Decision

Use `AuthoredGroundLayout` resources as the diffable whole-map composition source. A layout records map size, a glyph-to-atlas legend, and explicit rows. `authored_ground.gd` materializes a layout only when cells are absent or the layout is deliberately reassigned; `tools/bake_authored_ground.gd` writes those cells into the owning stage scene. The baked cells are runtime truth and remain directly editable with Godot's TileMap tools.

Stages I and II share an organized 4x4 bright-forest TileSet. The Rootbound Hollow owns a separate 4x4 corrupted TileSet because its palette and ritual-arena roles are region-specific. Trees may remain organically asymmetric, but statues, seals, and other landmarks must belong to visible paths, plazas, thresholds, or encounter boundaries. Generated sources stay under `art_source/`; normalized runtime assets stay under biome shared/region folders in `assets/environment/`.

## Consequences

- Runtime terrain performs no random generation or per-frame authoring work.
- Whole-stage layouts are reviewable as text and reproducible through one bake tool.
- Designers may paint local changes directly in the baked TileMap; rebaking intentionally replaces those cells from the layout resource.
- TileSet/layout pairings, cell counts, prop navigation, and key landmark identities require smoke coverage.
- Region-specific TileSets are allowed only when palette or terrain semantics materially differ, not merely to rearrange shared tiles.
