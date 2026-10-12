# Decision 109: Use Generated Raster Art for Skills and Cursors

- **Status:** Partially superseded by Decision 110; painted skill icons rejected, cursor experiment still pending owner review
- **Date:** 2026-08-16

## Context

The owner explicitly rejected repeated hand-authored SVG/vector substitutions for the skill and cursor polish request. Those assets read like generic engine UI and did not meet the requested authored-art quality. The small four-arrow movement destination from Decision 108 is accepted and remains unchanged.

## Decision

- King Skills 1-4 use separately generated transparent raster illustrations: Echoing Sever's double cleave, Riftbreak's planted sword rupture, Sovereign Pursuit's royal diving impact, and Worldsplitter's colossal spirit-sword fracture.
- The normal, interactive, and combat-target cursor states use separately generated transparent raster sprites: pointing royal gauntlet, open royal gauntlet, and cyan-edged royal sword.
- Full-resolution generated originals live under `art_source/generated/ui/king_combat_ui/`. `tools/prepare_generated_combat_ui.gd` reproducibly trims and downsizes them into 64-pixel skill PNGs and 32-pixel cursor PNGs.
- Runtime ability resources and `CursorService` reference the generated PNGs, not the rejected hand-authored SVG pass.
- The accepted four-arrow ground destination remains a small procedural/vector indicator because the owner explicitly said that movement art would do.

## Consequences

- Skill and cursor presentation now has painted material, lighting, and texture rather than flat vector geometry.
- Each generated source is independently replaceable without changing cooldowns, targeting, damage, or input authority.
- Runtime files remain compact while full-resolution sources preserve future rebake and refinement options.
- Generated UI needs live scale review because intricate detail can collapse when reduced to HUD or cursor size.

## Supersession Note

Owner review rejected the realistic painted material direction. Decision 110 replaces the four 64-pixel skill derivatives with a B+C hybrid, native 24x24 hard-pixel family. This decision remains historical context for why generated source art and a reproducible processor are required; its cursor experiment remains installed but is not approved by Decision 110.
