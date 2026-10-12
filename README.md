# Battle of Gods

A Godot pixel action prototype with a renewed Sanctuary, six campaign stages, four weapon families, five current King techniques, crafting/material exchange and an isolated Combat Lab. Later story arcs, scythe and Stage XX campaign routing remain planned.

## Setup

1. Install **Godot 4.7.2 standard**; .NET is not required.
2. Clone/pull the current branch, or extract the lightweight project ZIP.
3. Import project.godot, wait for the initial resource import, then press **F5**. The main scene is ui/screens/title/title_screen.tscn.

Godot rebuilds .godot automatically. Saves live at user://battle_of_gods_profile.json with a .bak recovery copy; they are local to each PC. A clone does not transfer player progress. Continue resumes in Sanctuary.

The current repository is [Dling11/Godot---Battle-of-gods](https://github.com/Dling11/Godot---Battle-of-gods). Use an ordinary clone:

~~~bash
git clone https://github.com/Dling11/Godot---Battle-of-gods.git
~~~

This repository starts from the cleaned project on 2026-10-13. It does not include the old multi-gigabyte art history; `--depth 1` is optional. Godot creates its own local import cache after opening the project.

## Controls

| Action | Keyboard/mouse |
|---|---|
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

Controller movement, attack, dodge and skill-slot selection are also supported. HUD/modal clicks are consumed by UI. Debug tools suppress saves/rewards. In Lab, use Weapons or Tab Bag to equip Sword, Iron Beard, Royal Greatsword or Twinsteel. King can jump over obstacles with Skill3 when the landing is clear; skills1/5 retain their authored range across intervening obstacles.

## Current art

Royal Greatsword V2 and its heavy four-cut sequence are the accepted baseline. Twinsteel selects shared_bodies/dual_carry_v3; its remodeled carry is awaiting owner review. Iron Beard retains the five-cut chop/rise/head-push/jump/spin combo. Frozen complete King references keep palette, scale and anatomy consistent across weapons. Sanctuary is temporarily complete and its map stays hidden.

## Project structure

- assets/: retained runtime art/audio plus frozen King reference poses and attribution.
- autoload/, data/, entities/, environment/, gameplay/, levels/, ui/: current systems/content.
- tools/: current launchers, deterministic Twinsteel carry rebuild, map baking, audio helpers and resource/packaging checks. tools/editor supplies the isolated-scene backdrop required by asset scenes.
- tests/: maintained gameplay/data/asset regressions, not historical art-comparison fixtures.
- art_source/: current Twinsteel stepping source, small identity references and licensed audio originals.
- docs/: current design contracts/decisions/maintenance.
- tmp/: ignored test logs/captures; exports/: ignored distribution packages.

Old archives, discarded models, generated experiment sheets and review recordings were deleted by owner request on2026-10-13. Previously tracked versions remain recoverable in the [original repository](https://github.com/Dling11/godot-practice-first-game), which is retained separately. Ignored/untracked recordings were discarded. Do not add new recovery copies or screenshot batches to Git.

## Verify and package

Use your installed Godot console path:

~~~powershell
& '<Godot console executable>' --headless --editor --path . --import --quit
& '<Godot console executable>' --headless --path . --script res://tools/check_project_resources.gd
& '<Godot console executable>' --headless --path . --script res://tools/check_king_body.gd
./tools/package_playable_project.ps1
~~~

The ZIP is a small **source project**, not a standalone executable: Godot is required to play it. It excludes .git, .godot, captures, tests and raw generation sources. A native executable needs matching export templates; they are not installed by this cleanup.

Restart F5 → F9 → F7 → Weapons for current art. The three launch_king_*_training.ps1 helpers open non-saving real Labs and accept -GodotPath for another PC. Captures now write only to ignored tmp/review/.

Deleting files in a commit does not erase older Git objects. The owner therefore selected a fresh repository on 2026-10-13, with a new root commit containing only the cleaned project. The original repository remains unchanged and no force-push is used. See [repository migration](docs/maintenance/repository-migration.md) and [cleanup evidence](docs/maintenance/repository-cleanup.md).

Start future tasks with PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md. GAME_DESIGN.md, ARCHITECTURE.md, STYLE_GUIDE.md and the relevant decision own design/implementation rules.
