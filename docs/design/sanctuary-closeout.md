# Sanctuary closeout

## Current refinement 234

Owner provisionally likes 233's layout/dummy idea. Younger hooded Veyr with grounded shadow, same-size outfitted lodge and responsive straw posts are installed for visual review. Preserve 233 coordinates/world scale and 232 learning/forging. Resume through CONTINUE_SANCTUARY.md and Decision 234; older artwork descriptions below are historical where superseded.

## Current correction233

Veyr now uses Orren's0.5 world scale at a furnished northwest pavilion/yard. The gate moves northeast; coherent perimeter walls/paths and a small rest garden replace232's placement. Four additional north rows reduce the oversized terrace. The first Axe proof remains installed for review. Nema gains one proof-opened base-only Axe pattern. The Sanctuary Veil Gate/route picker are refreshed; other service/house/character artwork is retained. See weapon-court-and-first-proof.md and Decision232. The older closeout below is historical where superseded.

2026-10-02. **Temporarily complete for the current development pass.** Decision 165 replaces the optional-only town boundary. Resume other game work unless a concrete Sanctuary regression is reported.

## Playable baseline

F5 -> Continue loads the renewed Sanctuary directly, with normal recovery/save behavior and no study header, comparison switch, test teleports or fixture rewards. A new game and expedition return use the same Sanctuary scene.

- Orren keeps his accepted workshop, planted blade-inspection poses and dialogue. Workshop entry, inspection and exit require F. Walking near the door only displays the prompt. Current room/furniture scale is retained.
- Eira stands directly right of the lectern at384,410; the approach is384,446. F/dialogue opens Training directly. Free manual level gates: Earth2, Molten3/6/9, Pursuit5/8, Vow7/10, World8/10. Loadout arranges ten slots; ordinary inventory cannot train remotely.
- Nema keeps canonical seal/material/gold crafting, output/stat previews, atomic costs and unique ownership. Readiness is owned by CraftingService; open-menu gold changes refresh it.
- Umi retains canonical sale/reconstruction service, material metadata, encounter memory and transaction rules. No new exchange economy is introduced.
- All four NPCs retain their original dialogue/body/interaction authority, current portraits, role markers, names, work poses and proximity greetings.
- Current overhead houses, planted trees, intentional wall runs, courier footfalls/yield/rest/dialogue, foliage motion and occasional birds remain. Other house interiors are deferred.
- Map/minimap/directory are temporarily withdrawn at the owner's request during further layout iteration. TownMap.PRESENTATION_ENABLED=false stops polling and blocks M/toggle/destination entry; the noticeboard stays a prop without map prompt or F consumption. The map modules/art remain for later restoration. NPC service beacons and F dialogues are unaffected.
- Shared HP loss trail/critical label, exact XP/cap copy and searchable Character & Bag remain. Tab or the bag button opens inventory; Esc closes menus. The town uses the compact action frame and generated modal theme. Expeditions retain their existing battle frame.

## Ownership

levels/sanctuary/sanctuary.tscn keeps the same service and Player nodes. SanctuaryFlow mounts exactly one levels/sanctuary/town/sanctuary_town.gd after wiring services, then writes its normal checkpoint. It never suppresses saves merely to present the town.

levels/sanctuary/town/ owns ground, buildings, map, ambient life, interface and workshop composition. The former review directory is retired. NPC scenes load authored renewal/sprite_frames.tres; entities/npcs/presentation/service_work_animation.gd handles dialogue/greeting holds and planted work resumption. Old breathing/work timers, old resource snapshots and compare restoration are removed. WorkshopVisit still snapshots camera/bounds/navigation state because returning from an actual room requires it; that is current transition behavior.

Inventory, training, crafting, exchange, XP, stage gates and SaveService remain authoritative. Presentation does not grant items, spend gold, unlock ranks or alter saves.

## Test mode

F10 -> SANCTUARY TEST · NO SAVES reuses the current town, enables visit/overview controls and suppresses saving for the rest of the process. It cannot restore the old town.

Existing launcher:

`powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -InterfaceDemo`

Starts at Nema with temporary materials/gold and XP/damage/heal/cap controls. -TrainingDemo starts at Eira with temporary Level10. Both suppress saving before loading the hub. Close/restart normal play to resume saving. Normal F5 never receives these fixtures.

## Archive and recovery

Decision223 permanently removed raw generation archives and old builder snapshots. Do not recreate art_source/archive or art_source/generated. Current installed assets and compact metadata are authoritative; historical implementations can be recovered from Git into an isolated checkout. Current review evidence belongs in ignored tmp, not a permanent archive.

## Validation and deferred work

tests/sanctuary_hub_smoke.gd covers real normal scene composition, absence of legacy instances, exact save/reload, no fixture gold or debug UI, all four physical F/service routes, current frames/portraits, free approaches, minimap/theme, F-only workshop entry and debug reuse/save suppression. tests/runtime_archive_boundary_smoke.gd checks retired runtime paths and archive directories remain absent. Retained Eira, workshop and HP/bag tests now exercise the same town rather than mounting a second overlay.

207 rendered checks pass (normal town67, workshop60, HP/bag66, demo14); Eira73 headless and archive/crafting/menu/progression/Umi/editor regressions pass. Final import and diff checks pass. Details are recorded in CHANGELOG.md. Native closeout captures live under art_source/review/environment/sanctuary_closeout_2026_10_02/. Existing GPU teardown warnings remain. Representative-phone profiling, indoor audio, further interiors and whole-kit balance are deferred; temporary completion does not claim those are finished.

Next game work: expedition objective/reward feedback, then a complete fight -> loot -> craft -> equip -> train loop. Do not restart Sanctuary redesign or regenerate accepted King/workshop art without new owner direction.
