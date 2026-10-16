# Battle of Gods

A Godot pixel action prototype with a renewed Sanctuary, six campaign stages, five equipable weapon families, King techniques, crafting/material exchange and an isolated Combat Lab. The owner provisionally settles current weapon artwork on2026-10-16; Decisions222/223 remove superseded experiments and bulk generation sources. Earned family acquisition, later story arcs and final balance remain planned.

## Setup

1. Install **Godot 4.7.2 standard**; .NET is not required.
2. Clone/pull the current branch or extract the lightweight source ZIP.
3. Import project.godot, wait for initial import, then press **F5**. The main scene is ui/screens/title/title_screen.tscn.

Current repository: [Dling11/Godot---Battle-of-gods](https://github.com/Dling11/Godot---Battle-of-gods).

~~~bash
git clone https://github.com/Dling11/Godot---Battle-of-gods.git
~~~

This repository starts from cleaned source on2026-10-13 and excludes the original multi-gigabyte art history; shallow cloning is optional. Godot creates .godot locally. Saves live at user://battle_of_gods_profile.json with a .bak recovery copy. Cloning does not transfer player progress. Continue resumes in Sanctuary.

## Controls

| Action | Keyboard/mouse |
| --- | --- |
| Move | WASD or right-click ground |
| Basic attack | Left-click; hold world LMB to repeat |
| Dodge | Space |
| Equipped techniques | 1–9, 0; targeting confirms with LMB and cancels with RMB/Escape |
| Bag/loadout | Tab or satchel |
| NPC/door/chest/portal interaction | F |
| Pause/close | Escape |
| Return after defeat | R |
| Non-saving debug kit | F9 |
| Combat Lab after debug kit | F7 |

F5 → F9 → F7 → Weapons selects Sword, Iron Beard, Royal Greatsword, Twinsteel or Iron Reaper. Dedicated launch_king_*_training.ps1 helpers and launch_king_iron_reaper.ps1 under tools/ open real non-saving Labs. Normal campaign acquisition is separate from debug grants. Sanctuary is temporarily complete and its map remains hidden.

## Current files

- assets/: current runtime art/audio, attribution and frozen complete King baseline references.
- autoload/, data/, entities/, environment/, gameplay/, levels/, ui/: current systems and content.
- tools/: retained launchers, map/audio helpers, runtime-art checks and packaging. tools/editor contains scene backdrops required at runtime.
- tests/: maintained gameplay/data/asset regressions.
- art_source/: compact approved references, production hash/motion metadata and licensed audio originals; bulky generation sheets/builders are removed.
- docs/: active design contracts, historical decisions and maintenance evidence.
- tmp/: ignored logs/captures; exports/: ignored packages.

Current weapon paths and review instructions are in [CONTINUE_WEAPONS.md](CONTINUE_WEAPONS.md). The Greatsword saved item ID retains its historical _v2 suffix for compatibility; only one current Greatsword is selectable. Current legacy Sword/Spellward frames serve skills/reactions/Varkuun and must remain.

## Verify and package

Use your installed Godot console path:

~~~powershell
& '<Godot console executable>' --headless --editor --path . --import --quit
& '<Godot console executable>' --headless --path . --script res://tools/check_project_resources.gd
& '<Godot console executable>' --headless --path . --script res://tools/check_king_body.gd
./tools/package_playable_project.ps1
~~~

Native rendering is required for tests that await frame_post_draw or capture pixels. Captures belong in ignored tmp/review/. The ZIP is a **source project** requiring Godot; standalone executable export is not validated here. Packaging excludes Git, caches, captures, tests and generation sources, while retaining all runtime dependencies.

Deleting current files does not remove earlier Git objects. Do not restore the original repository's branches/tags into this fresh repository. See [repository migration](docs/maintenance/repository-migration.md) and [cleanup verification](docs/maintenance/repository-cleanup.md). No commit/push is performed unless requested.

Start meaningful tasks with PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md. Read only routed task-specific design/architecture/style/decision documents.

Source retention: art_source/generated is deleted and ignored. Stage future raw generations temporarily under ignored tmp/, publish approved game assets, then clear trials. Keep only small useful references/metadata/licenses. See Decision223; the finished Godot game does not depend on raw image sources.
