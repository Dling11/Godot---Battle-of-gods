# Decision 043: Align Sanctuary Services With Compact Characters and Archive Superseded Content

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

After Opaw adopted a compact armless oversized-head silhouette, the tall anatomically detailed Eira and Orren sprites no longer shared the same visual language. The mushroom dwelling, merchant hall, and weapon stall were also denser than the active character style, and the earlier stall/building generation pass risked preserving cropped character fragments. Separately, rejected Opaw experiments, their builders/tests, and the superseded Awakened presentation still occupied active Godot folders despite having no runtime consumer.

## Alternatives Considered

- Keep all Sanctuary service art unchanged and treat the mismatch as intentional.
- Scale the old NPC/building rasters down without reauthoring their silhouettes.
- Replace only the NPCs while retaining the old service structures.
- Rebuild the complete skill/equipment service corner and archive confirmed-unused material outside Godot while retaining explicit supported rollbacks.

## Decision

Skillkeeper Eira and Armskeeper Orren use 48x48 cells with compact Opaw-compatible proportions and two intentional detached role props each. Eira retains a violet/gold scholar identity with book and wisp; Orren retains rust/iron armskeeper identity with hammer and wooden sword. Their gameplay collision, interaction, dialogue, and one-pixel idle-breath ownership remain unchanged.

The active side structures are `skillkeeper_lodge.tscn`, `armskeeper_workshop.tscn`, and `armskeeper_cart.tscn`. Their normalized hard-pixel rasters contain complete silhouettes; the cart contains no merchant body. Collision and idle glows remain separate scene responsibilities.

`process_sanctuary_direction_board.gd` now owns only terrain and trees. `process_sanctuary_individual_assets.gd` owns portal, fountain, both service NPCs, and all three service structures. Replaced service content, rejected handless/armless Opaw experiments and associated code, and the superseded Awakened presentation move under Godot-ignored `art_source/archive/`. The complete Wayfarer model remains under active `assets/` as the explicitly supported loadable rollback.

## Consequences

- Sanctuary's service characters and structures share one compact, readable visual language with Opaw.
- No active service raster contains a cropped or baked-in merchant body.
- Active tools cannot accidentally regenerate the retired direction-board service crops.
- Godot scans fewer unused scenes, assets, scripts, and tests while historical work remains recoverable.
- Archive content has no runtime guarantee; restoration requires a reviewed migration.
- Human gameplay-scale review of the new NPC proportions, detached props, collision, and building density remains required.
