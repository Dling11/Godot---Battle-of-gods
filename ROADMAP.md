# Roadmap

Updated 2026-10-13.

## Completed

- Title → renewed Sanctuary → six campaign stages, defeat return and persistent progression/materials/gear.
- Nema crafting, Umi exchange, Eira training/loadout, F-required workshop entry, compact portrait HUD and centered paper-doll Bag; Sanctuary temporarily closed out, map hidden.
- Authored stage biomes, life/obstacles, threat-sensitive stage gates, reward chests, quiet loading and randomized campfire home backgrounds.
- Enemy pressure/control mechanics, Rotcaller campaign placement and Stage VI Crag Bear route; separate Examiner Lab trial.
- Four normal weapon families; accepted Greatsword V2 heavy combo, current axe cardinal cuts and Twinsteel V2 attacks/proud idle.
- Frozen complete King anatomy references; distinct current Twinsteel steady-carry variant.

- Repository cleanup complete: about 6.50 GB of obsolete source/derived content removed; current source about 54 MiB, packaged playable project44.4 MiB. All646 protected assets unchanged, all 134 active smoke scripts pass assertions, all 868 resources load. Fixture teardown warnings remain separately tracked (Decision 197).

## Current work

Owner motion review of current Twinsteel carry. Cleanup is finished; preserve current approved art and use the compact sources/handoffs.

## Next

1. Owner reviews current Twinsteel motion in the actual Lab.
2. Implement selected Iron Reaper only after design/motion approval.
3. Finalize campaign weapon acquisition/crafting and compare roles against single enemies/hordes.
4. Measure crowded combat, cold loading and target-device performance before optimization.
5. Extend stages/biomes and earned divine/domain mechanics using canonical stage/reward authority.

## Deferred

Sanctuary/map/house redesign; unsupported accessory visuals; Stage XX campaign integration; multiplayer/networking; future story twist/rewards and unimplemented skill tiers. Keep GAME_DESIGN.md/STORY_BIBLE.md proposals explicit.

## Maintenance

Keep .godot, tmp captures, exports and retired archives out of Git. Current source/runtime assets are authoritative. The owner selected Dling11/Godot---Battle-of-gods for a fresh root history baseline (Decision 198); ordinary clones exclude the old art history. Historical trials remain recoverable in the separate original repository/local metadata backup. Do not push legacy branches to the new repository; no force-push is authorized/performed here.
