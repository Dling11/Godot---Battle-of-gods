# Repository cleanup

Updated2026-10-16. [Decision223](../decisions/223-keep-only-compact-art-support.md) supersedes222's raw-generation retention after the owner clarifies: keep important files, not a large source collection. Current changes remain uncommitted.

## Current source policy

**art_source/generated is deleted from disk**, without the Recycle Bin. This follow-up removes305 bulk generation files plus18 dependent image-builder/helper files and sidecars:118,843,676 bytes (113.3MiB). No replacement archive was created. The finished sprites, frames/resources, sounds and gameplay under assets/ remain intact; runtime folders have no dependency on the deleted source tree.

Keep only about1.6MiB of useful support under art_source/: compact approved King identity images, production-assets.json accepted hashes, axe-motion.json and reaper-grounding.json (about32KiB combined numeric data), licensed audio originals and attribution. Frozen complete body references remain under assets/characters/playable/king/body_library/baseline. Current accepted game assets are authoritative; exact old raw-image rebaking is intentionally unavailable.

Future generation uses temporary ignored tmp/ staging. Publish approved runtime assets, validate them, then clear trials. .gitignore excludes art_source/generated; AGENTS.md/project/style/art docs carry this policy, and runtime_archive_boundary_smoke rejects recreating the directory. This prevents permanent generation collections from accumulating in normal commits. Accepted hash updates require an explicit approved change.

## What remains verified

All653 protected installed resources/assets match their accepted hashes; all527 original retained runtime raster/audio payloads remain unchanged. Ten immutable complete body atlases verify. Canonical Sword/axe/Greatsword/Twinsteel/Reaper paths, stable saved IDs/migration, combat clocks/reach/damage, grips, motion, audio and current NPC/stage/UI assets are unchanged.

Source-dependent tests now verify installed PNG/resource hashes, clip/frame boundaries, complete painted strokes, genuine grip/rig ownership and current combat. Compact axe69-actor data retains weapon basis/head/body/cel checks; compact Reaper records retain160 native ground-circle probes. Large source-provenance/clean-body-sheet/rebaking checks are intentionally retired, not presented as still available.

Godot4.7.2 stable ed1daf0bf: all918 retained code/scenes/resources load. All16 affected production-art/native-gameplay tests pass after explicit reruns, covering all five weapons, movement/attacks/idle, held input, equipment/roles, save migration, exact accepted body/weapon art, ground-circle alignment and archive boundaries. Three of these fixtures emit existing ObjectDB teardown warnings despite passing assertions. [Focused results](minimal-art-tests-2026-10-16.json) and [current removal/size summary](minimal-art-summary-2026-10-16.json) record this follow-up.

One new generic frame assertion initially rejected Greatsword's legitimate rigid ready/entry blade; it now checks the explicit existing ready keys separately from baked attack keys. Held-input failed when competing native test windows cancelled focus; its isolated unchanged rerun passes46 checks. These are not gameplay or art changes. Original primary profile, .bak and title-selection config remain byte-identical to their pre-test values.

## Source footprint and earlier cleanup

Current project source is about56MiB, down from169MiB before this follow-up and326MiB before the first cleanup. These figures exclude .git, .godot, tmp, exports and local tool environments; exact current counts are in the minimal-art summary. The earlier222 pass deleted822 obsolete files/156.8MiB and passed147 active scripts/923 resource loads; those figures and builder checks in cleanup-summary-2026-10-16.json and cleanup-tests-2026-10-16.json are historical to that earlier state.

The previous playable source ZIP remains valid: runtime payloads are unchanged, and source artwork/builders/tests were already excluded. Its2097 entries/47.5MiB imported without old cache and passed731 runtime loads plus21 native title/five-weapon equip/attack checks. A standalone executable export remains unvalidated. Target-device/cold/very-large-horde performance and earned acquisition/balance remain separate work.

The user's open Godot editor/game were left running. Ignored cache is retained while they are open. An earlier automatic approval review rejected deletion of temporary production backup/fresh verification folders ("blocked by policy"); those ignored folders remain outside source metrics, Git and the playable package. No source archive or generated folder remains under art_source/.

Deleting current files does not erase committed Git objects. No history rewrite, commit or push was performed. Do not reintroduce the old multi-gigabyte history into the fresh repository. The2026-10-13 reports remain historical evidence.

## Current maintenance

- tools/check_project_resources.gd: load every retained code/scene/resource after import.
- tools/check_king_body.gd: verify immutable complete body references.
- tests/king_production_art_contract.gd: common installed-art hash/frame/stroke checks.
- Maintained native weapon/gameplay tests and real non-saving launchers in CONTINUE_WEAPONS.md.
- Licensed-audio tools, map baker, explicit checked deletion helper, closed-engine cache pruner and source ZIP packager remain.

Do not restore deleted image builders or raw-generation directories as dependencies. Gameplay authority remains in combat/services; presentation and verification retain their existing ownership.
