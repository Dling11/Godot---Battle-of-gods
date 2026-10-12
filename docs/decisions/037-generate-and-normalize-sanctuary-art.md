# Decision 037: Generate and Normalize a Dedicated Sanctuary Art Kit

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The first functional Sanctuary proved the title-to-hub-to-expedition loop, but its code-drawn houses, fountain, altar, NPC, reused Stage 1 grass, and scattered prototype trees did not meet the approved luminous dark-fantasy quality bar. Replacing the entire hub with one painted background would improve the screenshot while breaking traversability, interaction, collision, Y-sorting, reusable props, and future editing.

## Alternatives Considered

- Keep the functional prototype art and postpone visual identity.
- Use one flattened Sanctuary illustration as the playable map.
- Import the generated direction board directly as runtime art.
- Preserve the generated direction board as source and reproducibly normalize selected assets into separate runtime sprites, scenes, and tiles.

## Decision

The approved generated Sanctuary direction board is preserved under Godot-ignored `art_source/` as source material. `tools/process_sanctuary_direction_board.gd` owns reviewed crop rectangles for terrain, buildings, stall, trees, and Eira, plus crop-color-matched border background removal, binary-alpha normalization, exact runtime canvases, four-frame accent animation, and the dedicated 64x64 Sanctuary ground atlas. Character, building, stall, and tree crops must preserve dark outlines, interiors, limbs, and connectors.

The portal, fountain, and Armskeeper Orren use individually generated sources because the combined board crop coupled unrelated landmarks and clipped Orren's silhouette. `tools/process_sanctuary_individual_assets.gd` deterministically removes the keyed background, keeps the intended connected silhouette, hardens alpha, reduces the palette, fits exact runtime canvases, and builds Orren's accent frames. Generated originals and cleaned intermediates remain under `art_source/`; scenes load only normalized runtime assets.

Runtime presentation remains decomposed: the fountain is an independent static prop in the courtyard, while `ExpeditionAltar` owns a separate north portal with a broad open staircase, guardian footprints, rear backstop, and doorway-only trigger. The visible gap and both radius-six walk-around routes are verified rather than implied by a combined raster. Skillkeeper Eira and Armskeeper Orren reuse one `DialogueNpc` contract and compose `NpcIdleBreath`, which steps only their visual node on a timer. Buildings and the weapon stall own footprint collision and bounded light idle effects, and Sanctuary trees own footprint collision plus presentation-only sway. `SanctuaryGround` paints a compact authored route network from Sanctuary-only grass and cardinal pavement transitions; combat-stage grass is no longer reused.

The first code-drawn Sanctuary kit and its obsolete generator were removed after the replacement passed runtime, interaction, and asset validation. They must not be recreated or receive new runtime references. Shop prices, purchasing, equipment, and coin sinks remain deferred; Orren is an honest interactive preview, not a fake completed shop.

## Consequences

- The hub now matches the approved generated visual language while remaining editable and mechanically correct.
- Source art, runtime crops, collision, interaction, and idle presentation can evolve independently.
- Rebuilding the kit is deterministic as long as the direction board, three standalone 1254x1254 sources, and documented processing contracts remain unchanged.
- Crop cleanup is asset-specific; a convenient global dark-key pass is forbidden when it would erase legitimate sprite structure.
- New Sanctuary props should extend the dedicated kit rather than reusing combat-stage tiles or flattening interaction into background art.
- The generated source and exact crop choices require review if the board or standalone source images are replaced.
