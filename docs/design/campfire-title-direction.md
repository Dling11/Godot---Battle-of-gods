# Campfire title direction

2026-10-03 update: owner accepts all A/B/C and requests random homepage selection on relaunch; rejects King walking. Production title trio is delivered. Earlier B walking preview below is historical. Loading redesign remains future.

## Current production

Three still 960x540 illustrations occupy the right side; real menu/labels sit in the quiet left space. A is the breach, B has seated King by the fire, C is a planted sword-ready clash. No title walking sprite, actor controller or structural frame redraw. Fixed decorative pixels fade subtly. TitleBackground makes one random pick, excluding the previous valid index. A tiny ConfigFile stores only the cosmetic last choice at the current profile basename + _title_art.cfg, ensuring different art after quitting/relaunching while keeping review/test history isolated. No new service or per-frame random work.

Source/prompts: art_source/generated/ui/title_trio_2026_10_03/. Runtime assets: assets/ui/title/trio/. Native 72/restarted headless 66 assertions plus menu/Continue and 27 native loading checks pass. Captures/logs: art_source/review/ui/title_trio_2026_10_03/. Production no longer depends on prototype disk-loaded images. F5 starts this actual title.

## Earlier direction and prototype

## Purpose

The former title is clean but feels like a menu panel. Freezing its emblem fixes source drift at the cost of the motion the owner wanted. Show the actual game identity: compact King, familiar small wooden enemies, a warm refuge surrounded by quiet darkness. No named gods/bosses, ending clues or biome-locking loading screen. The generated board is a composition reference, not gameplay or finished animation.

## Native prototype

The fixed background contains only shelter/hearth/ground. Eight independently generated flame drawings share one normalization scale and a registered base; their tongues genuinely change shape. Actual approved King idle/walk frames provide breathing, turns and small pacing steps; he is standing beside the fire, not a newly animated seated illustration. Two existing Rootlings walk, pause and withdraw with actual pose cycles and displacement. They are AnimatedSprite2D decoration only, with no enemy AI, physics, drops or encounter authority. Clean menu at left reuses actual TitleScreen controls and an isolated profile.

Sources: art_source/generated/ui/campfire_title_2026_10_03/; exact built-in imagegen prompts and original board/background/flames retained. Builder outputs960x540 backdrop and640x80 flame atlas (eight80x80 cells). Prototype images load from disk because source/review directories are not export assets. Do not ship these disk-loading tool paths as production.

## Review

Run powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_campfire_title_preview.ps1. Native screenshot/GIF evidence: art_source/review/ui/campfire_title_2026_10_03/. user://campfire_title_review.json protects normal storage even if title/New Journey/real travel is used.80 captures assert fixed backdrop, all8 flame frames,19 King poses,8 first-watcher poses and actual watcher travel. Native preview scale differs from world scale intentionally; final illustration density/contrast needs review. GIF is an8-second motion clip, not a proof that every independent loop closes together at its boundary. Existing GPU shutdown warnings persist.

## Earlier prototype plan (superseded for the homepage)

1. Review the native composition rather than treating static board text/characters as final assets. Improve King expression/resting action and watcher readability/occlusion with coherent original poses; retain approved identity.
2. Promote layered assets to exportable runtime folders and replace only TitleBackground/layout presentation. Preserve real Continue/save validation, New Journey confirmation, Settings, focus and Quit; test relevant controls at960x540 and resized windows. Avoid applying walking-body silhouette freezes.
3. Rebuild a consistently animated generic loading composition after the title review. Use a compact vignette/character action, real loader progress, no fixed forest setting/spoilers and no forced animation wait. The frozen seal is not the rebuilt motion requested by the owner.

Recommendations are presentation only: campfire flame/embers, expressive King rest/turn, short wary Rootling patrol/peek, slow fixed-scene lighting and quiet ambience. Do not expand this into new campaign mobs or mechanics without a separate task.
