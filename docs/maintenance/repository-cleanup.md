# Repository cleanup — 2026-10-13

Owner-authorized deletion and final active regression verification are complete. No images were opened or regenerated. Decision 197 owns the scope.

## Deleted and preserved

Removed 26,460 obsolete source files totaling 4,902,076,595 bytes (4.90 GB): historical archive/review folders, discarded generated sheets and intermediate images, unreferenced runtime assets/sidecars, obsolete King builders/viewers/comparison fixtures, unused preview/prototype resources and nine superseded design guides. Deletion used checked absolute workspace paths and native PowerShell. No replacement archive was created. Previously tracked versions remain in history; ignored/untracked recordings and intermediates were intentionally discarded.

A follow-up fresh-clone audit found 26 obsolete temporary image/sidecar/diagnostic UID files (15,841,974 bytes) still tracked under tmp/. They predated the ignore rule; adding tmp/ to .gitignore alone did not remove them from Git. After checking maintained source/resource references, these files were removed in an additional cleanup commit. No production assets or runtime dependencies changed.

Also removed 1,937 derived files totaling 1,598,677,407 bytes (1.60 GB): stale flat imported resources and old custom recordings/logs inside .godot. Current import destinations, editor settings, UID/class caches and shader caches were preserved. This brings removed disk content to about 6.50 GB; Git history is excluded from that saving.

All 646 protected production asset SHA256s match their pre-cleanup values; none are missing. The current Twinsteel carry builder was run twice against production inputs, with all 60 carry resource/body/hand files unchanged on the repeat. Accepted Sword, axe, Greatsword V2, Twinsteel contacts/idle, NPCs, tiles, enemies, portals, UI and audio remain installed. Older folder names are retained where they hold a current dependency.

Gameplay rules, save IDs/migrations, current global classes, signals and callbacks were preserved. Proven unused core files were removed only after dependency checks. Pure anatomy assertions now use an independent test base; the current Twinsteel builder reads production poses plus its small retained gait input instead of archived profiles. Other approved weapon outputs remain authoritative; retired generation chains must not be restored by default.

## Working-tree footprint

Sizes exclude .git, .godot, temporary evidence and packages. Measurements are rounded; new maintenance records add a few KiB.

| Content | Before | After |
| --- | ---: | ---: |
| art_source | 4,664.8 MiB / 25,255 files | 1.56 MiB / 42 files |
| Runtime assets | 55.87 MiB / 2,066 files | 45.60 MiB / 1,296 files |
| Tools | 1.33 MiB / 486 files | 0.15 MiB / about 95 files |
| Tests | 0.87 MiB / 331 files | 0.72 MiB / 276 files |
| Entire current source | about 4.62 GiB | about 54 MiB |

Retained source art is limited to current Twinsteel gait input, frozen King references and licensed audio originals. Authoritative docs were consolidated; historical decisions and future lore/rules remain clearly distinguished from implementation. Test captures/intermediates use ignored tmp/review/. Archives, cleaned intermediates, cache and exports are ignored.

Machine-readable counts/hashes: cleanup-summary-2026-10-13.json and active-assets-2026-10-13.json. Ignored tmp/cleanup_2026_10_13/ holds the deletion plans and current verification logs.

## Verification

Godot 4.7.2 stable (ed1daf0bf), Compatibility renderer, native AMD OpenGL. Editor import and the universal resource check loaded all 868 retained GDScript/scenes/resources without parse/load failures. The ten frozen body atlases passed their immutable-hash check.

Native current weapon checks passed: axe 2,858, Twinsteel gait 995, Twinsteel gameplay 244, Greatsword V2 197, finalized roles/equipment 301, retirement/migration 39 and real-time dual idle 100 assertions, all with zero failures. Shared anatomy/carry checks passed 711/392 assertions. Title/Sanctuary, skill terrain/input, crafting/exchange/loot, encounter structure, stage V/VI and isolated disk/profile/milestone save checks passed. All **134 retained active smoke scripts pass their assertions**, with zero remaining script/parse/load or assertion failures. Results and completion markers are recorded in cleanup-tests-2026-10-13.json. Native UI capture tests were rerun after fixing missing output directories.

54 of 134 current fixtures emit ObjectDB/resource teardown warnings despite passing assertions (including Greatsword, Twinsteel, title and Sanctuary). Treat these as existing fixture debt, not a clean-teardown claim. This cleanup is neither owner visual approval nor crowded-combat/phone performance certification. No gameplay balance/animation redesign was performed.

Fixtures were aligned with current contracts: canonical Sword/Bag art and baked locomotion outline; cap-unlock vitality in saved state; distinct per-target visuals/shared impact audio; withdrawn map state; bounded actual arrival waits; direct accepted stun authority; explicit demo launch arguments; and completion of threaded scene loads before teardown. A Stage VI fixture previously entered Sanctuary before suppressing saving; its pre-test campaign profile and backup were restored byte for byte, and suppression now precedes scene creation. Both original profile hashes were verified after the corrected test.

## Small playable distribution

Run tools/package_playable_project.ps1 to create exports/Battle-of-Gods-project.zip. The package is about 44.4 MiB with 2,150 entries (SHA256 90d5a2a22526c346d7979a65e138bfefe24e3af5edd0272a20296d25e1dfb347). It includes actual runtime dependencies (including tools/editor backdrops referenced by scenes), excludes Git history, cache, source art, tests and recordings, and requires Godot 4.7.2 standard. Import project.godot and press F5. A freshly extracted copy successfully imported and launched the title through native rendering. All 2,150 final ZIP entries match current source bytes; runtime payloads match that tested copy (only two attribution/manifest Markdown notes changed).

This is a source project, not a standalone executable. Export templates are not installed/validated here. Local saves are excluded. Another computer can play after importing the source with a compatible Godot version; platform/device performance remains to be measured.

## GitHub and history size

The original local .git directory is about 4.3 GiB; packed historical objects account for about 3.93 GiB. Deleting working-tree files does not remove reachable blobs in earlier commits. The initial cleanup left changes uncommitted; the owner subsequently authorized ordinary delivery on 2026-10-13.

Deliver the cleanup as logical commits on main to the existing Dling11/godot-practice-first-game repository with an ordinary push. Do not create a repository/branch named hobbies: the owner clarified that this was context rather than a destination. A subsequent shallow clone (git clone --depth 1 <repository-url>) reduces a new PC's history download. To remove old history from GitHub itself, create a fresh repository from the cleaned source, or separately authorize and plan a coordinated history rewrite with backups and collaborator handling. Do not describe this cleanup as remote-history removal.

The owner subsequently created Dling11/Godot---Battle-of-gods and selected the fresh-repository option. The original cleanup commits remain in Dling11/godot-practice-first-game; they are not imported into the new root history. Current clone/setup and migration verification are recorded in [repository migration](repository-migration.md) (Decision 198).

## Retained maintenance commands

- tools/check_project_resources.gd loads all supported code/scenes/resources.
- tools/check_king_body.gd checks frozen anatomy references.
- tools/build_king_twinsteel_carry.gd rebuilds current carry without archive inputs.
- tools/prune_obsolete_content.ps1 accepts an explicit checked deletion plan.
- tools/prune_unused_godot_files.ps1 previews derived-file candidates; -Apply removes only stale imports/flat recordings with Godot closed.
- tools/package_playable_project.ps1 creates the compact source ZIP.

Keep new source files purposeful and captures ignored. Do not delete code based solely on lack of a literal call: Godot class discovery, scenes, signals and dynamically formatted paths also carry dependencies.

The fresh verification copy at exports/cleanup_fresh_project remains ignored: automatic approval review rejected deleting that temporary directory with the reason "blocked by policy". It is excluded from source metrics, Git and the distribution ZIP.
