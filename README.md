# Battle of Gods

A Godot pixel action prototype with a renewed Sanctuary, six campaign stages, five equipable weapon families, five current King techniques, crafting/material exchange and an isolated Combat Lab. Earned weapon-family acquisition, later story arcs and Stage XX routing remain planned.

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

Twinsteel's fresh complete five-cut attacks are installed for RIGHT/LEFT/UP/DOWN. Test F5 → F9 → F7 → Weapons → Twinsteel, then hold LMB to chain; Tab opens the Bag. Direct non-saving launch: tools/launch_king_twinsteel_training.ps1. Rebuild/source instructions are in [the current attack-source README](art_source/generated/characters/king/twinsteel_attacks_complete_2026_10_14/README.md). Running/rest and the new attacks are owner-approved.

Controller movement, attack, dodge and skill-slot selection are also supported. HUD/modal clicks are consumed by UI. Debug tools suppress saves/rewards. In Lab, use Weapons or Tab Bag to equip Sword, Iron Beard, Royal Greatsword, Twinsteel or Iron Reaper. King can jump over obstacles with Skill3 when the landing is clear; skills1/5 retain their authored range across intervening obstacles.

Iron Reaper now throws its scythe, pauses while spinning with trails/ground sparks, then recalls and catches it; attack speed scales the whole sequence. Owner-approved running stays exact. All attacks now use fresh complete bodies matching that running appearance, with fixed straight steel and fuller eight-frame white sweeps. Idle makes one small upward toss/catch, then settles. Attacks use authored sweep/return arcs, anticipation and recoil, with hand-aligned throw/catch and a stronger final-reap landing (Decision207). Decision208 centers attack stances over the ground circle and displays full white strokes inside real contact space. Decision209 adds quicker2.59s cadence,24 freshly generated white effect frames and dedicated recorded scythe swing/contact sounds while preserving all character poses and locomotion. Play: F5 → F9 test kit → F7 Combat Lab → Weapons → Iron Reaper · Scythe. WASD moves, held LMB chains cuts, Space dodges, Tab opens the Bag. Alternatively run tools/launch_king_iron_reaper.ps1 (-GodotPath on another PC) for the actual Lab with the scythe equipped and four Rootlings. Debug testing suppresses autosave/rewards. Rebuild: Godot --headless --path . --script res://tools/build_king_iron_reaper.gd, then an editor import. [Weapon rules and art](docs/design/king-iron-reaper.md). Original motion viewer remains an offline study.

## Current art

Royal Greatsword V2 and its heavy four-cut sequence are the accepted baseline. Twinsteel selects shared_bodies/dual_carry_v3; its complete running and attacks are owner-approved. Iron Beard retains the five-cut chop/rise/head-push/jump/spin combo. Frozen complete King references keep palette, scale and anatomy consistent across weapons. Sanctuary is temporarily complete and its map stays hidden.

Twinsteel now uses freshly generated complete running poses, with connected anatomy and two held swords in every facing. Test F5 → F9 → F7 → Weapons → Twinsteel, or tools/launch_king_twinsteel_training.ps1 for the isolated non-saving Lab. WASD moves; held left click attacks; Tab opens the Bag. Source sheets, prompts and the deterministic bake recipe are in art_source/generated/characters/king/twinsteel_running_complete_2026_10_13/.

## Project structure

- assets/: retained runtime art/audio plus frozen King reference poses and attribution.
- autoload/, data/, entities/, environment/, gameplay/, levels/, ui/: current systems/content.
- tools/: current launchers, deterministic Twinsteel carry rebuild, map baking, audio helpers and resource/packaging checks. tools/editor supplies the isolated-scene backdrop required by asset scenes.
- tests/: maintained gameplay/data/asset regressions, not historical art-comparison fixtures.
- art_source/: current complete Twinsteel running sources/prompts, small identity references and licensed audio originals.
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
