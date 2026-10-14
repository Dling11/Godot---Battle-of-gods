# Roadmap

Updated 2026-10-14.

## Completed

- Title → renewed Sanctuary → six campaign stages, defeat return and persistent progression/materials/gear.
- Nema crafting, Umi exchange, Eira training/loadout, F-required workshop entry, compact portrait HUD and centered paper-doll Bag; Sanctuary temporarily closed out, map hidden.
- Authored stage biomes, life/obstacles, threat-sensitive stage gates, reward chests, quiet loading and randomized campfire home backgrounds.
- Enemy pressure/control mechanics, Rotcaller campaign placement and Stage VI Crag Bear route; separate Examiner Lab trial.
- Five normal equipment families, including playable oversized Iron Reaper and its Hook and Reap specialty; accepted previous family art remains protected.
- Frozen complete King anatomy references; fresh COMPLETE Twinsteel running generation with two held swords (Decision 200).
- Fresh complete Twinsteel attacks in all directions, fixed-size held blades and new white-slash frames; owner-accepted2026-10-14 (Decision201).

- Repository cleanup complete: about 6.50 GB of obsolete source/derived content removed; current source about 54 MiB, packaged playable project44.4 MiB. All646 protected assets unchanged, all 134 active smoke scripts pass assertions, all 868 resources load. Fixture teardown warnings remain separately tracked (Decision 197).

## Current work

Iron Reaper running, complete action appearance, momentum and Decision208 centering/full-stroke correction are owner-accepted. Decision209 adds quicker2.59s cadence,24 new generated white frames and dedicated recorded scythe swing/contact sounds. Complete actor geometry/pose/run/idle/steel stay exact; only96 missing-glove color pixels change in the focused follow-up. Faster cadence raises base DPS to21.2 without changing per-hit rules or reach. The owner accepts the quicker pass and recorded audio. A quiet flight-spin layer and two bottom-facing glove-color corrections are the focused follow-up; see CONTINUE_WEAPONS.md. Debug availability does not establish earned acquisition or final balance.

## Next

1. Review the playable Iron Reaper and preserve accepted weapon art.
2. Define and implement earned weapon recipes/acquisition with Nema and stage rewards.
3. Refine weapon roles using the real-enemy comparison; only retune with explicit gameplay intent.
4. Profile cold loading, larger fights and target-device performance before optimization.
5. Extend stages/biomes and divine/domain mechanics using canonical stage/reward authority.

## Deferred

Sanctuary/map/house redesign; unsupported accessory visuals; Stage XX campaign integration; multiplayer/networking; future story twist/rewards and unimplemented skill tiers. Keep GAME_DESIGN.md/STORY_BIBLE.md proposals explicit.

## Maintenance

Keep .godot, tmp captures, exports and retired archives out of Git. Current source/runtime assets are authoritative. The owner selected Dling11/Godot---Battle-of-gods for a fresh root history baseline (Decision 198); ordinary clones exclude the old art history. Historical trials remain recoverable in the separate original repository/local metadata backup. Do not push legacy branches to the new repository; no force-push is authorized/performed here.
