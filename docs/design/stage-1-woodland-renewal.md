# Stage I woodland renewal — review pass

2026-10-02. Implemented in the normal Forgotten Grove scene; owner accepted the current visual direction on2026-10-03; precise combat feel/economy and phone profiling remain open. This is the Stage I pilot requested before extending the direction to II–VI. See Decision 167.

Current audio update (Decision171,2026-10-03): normal I–IV now use the attributed Dark Forest Theme recording, distinct from Sanctuary. Stage I art remains the accepted baseline. See [current campaign and next work](stage-5-renewal-and-combat-polish.md).

## Direction

Match the accepted Sanctuary's restrained olive meadow, grey mossy stone, defined pixel outlines and overhead view. Replace the old repeating 64px path tiles with a 32px grid: 60x36 / 2160 baked cells over the same 1920x1152 stage. One winding approach has side trails toward woodland pockets and ends at a compact old shrine apron. Dirt uses sixteen corner masks with irregular grass edges; the stone apron uses the approved connected edge tiles. Ground is still editable TileMap data with an explicit AuthoredGroundLayout, not a flattened background or runtime random fill.

Eight newly generated prop families are normalized to native gameplay scale: oak93x112, fir71x128, waystone38x50, boulder42x30, fallen log53x36, collapsed masonry58x36, fern32x24 and mushrooms24x20. Eighty-eight authored placements form edge woodland, small glade pockets and the paired exit markers. Collapsed masonry is local shrine debris, not a randomly broken perimeter wall. Small plants do not block movement. Tall trees keep small planted root collisions; rocks, logs and markers have separate physical footprints and matching navigation cutouts. King and the props share Y sorting.

The accepted Sanctuary wind shader shifts only the upper foliage in pixel steps. Roots and collision stay planted. A tree's canopy area fades its visual when King passes behind it and restores opacity on exit. Two occasional birds reuse the existing four-frame swallow and Timer/Tween flight. These presentation details have no combat/reward authority.

## Runtime and source ownership

- Normal Stage I: levels/test_arena/test_arena.tscn; data/environment/layouts/stage_1_forest_ground.tres.
- Runtime textures/TileSet: assets/environment/forest/grove_renewal/.
- Reusable prop scenes and presentation: environment/props/woodland/.
- Generated original, exact prompt and normalization manifest: art_source/generated/environment/forest/grove_renewal_2026_10_02/.
- Offline builder: retired generation tool (recover from Git history only). Run --art-only, import through Godot, then run the builder normally. The second pass writes generated prop scenes, layout and baked Stage I. Ground derivatives reuse assets/environment/sanctuary/refuge_review/ground_32.png; the town and shared forest source remain untouched.
- Recovery snapshots: historical Git-only archive/stage_1_pre_renewal_2026_10_02/ (.gdignore). Old shared trees/statues/terrain remain because other stages use them. Do not delete them as unused Stage I assets.

The player scale, world bounds, six authored waves, four-live-enemy ceiling, rewards, portal destination and save rules are preserved. The layout can still affect combat positioning, so owner feel testing remains necessary. The owner accepted Stage I on2026-10-03. Renew II–VI using this quality/density as reference while preserving their own established biome identities; the props are not a replacement for every stage theme.

## Ready review

Run `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_1_renewal.ps1`.

The visible no-save review starts with peaceful exploration. WASD moves King; Entrance/Glade/Old shrine visit the three important views; Overview/gameplay switches camera scale. Start normal waves runs the actual Stage I encounter. King is damage-immune only in this preview so the owner can inspect art while enemies are active. Saving is suppressed before scene entry. Normal F5/expedition entry shows the same environment with ordinary saving and combat vulnerability.

`--capture` on the GDScript launcher produces native960x540 entrance/glade/shrine images and an overview under historical Git-only review/environment/stage_1_renewal_2026_10_02/.

## Validation and remaining review

The environment/navigation smoke passed183 checks: preserved world extent, authored grid, six-wave/four-live contract, all spawn/exit approaches, sampled collision-free routes, every physical obstacle's cutout, decorative nonblocking plants, tree routing, canopy fade/restore, fixed root position and moving four-frame birds. Headless wave-structure, reinforcement and defeat-return regressions pass. The81-check rendered expedition test also passes through actual rewards, ordinary and milestone completion, Sanctuary return, Nema crafting, bag equip, Eira training and isolated save/Continue. Native GPU captures verify the new material scale and placement. Automated accelerated encounter tests establish integration, not final balance or player success. Owner accepted the current visual direction2026-10-03. Stage II is now renewed under Decision168. Precise combat feel, representative-phone performance and Stages III–VI renewal remain pending. Previously observed shared GPU shutdown texture/RID warnings persist.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
