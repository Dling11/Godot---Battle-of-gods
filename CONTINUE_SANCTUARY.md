# Continue Battle of Gods — Sanctuary handoff

Updated 2026-10-18 after Decision 234. Repo: D:\React_ONLY_2026\GODOT-BATTLE-OF-GODS. Runtime code/scenes are truth. Preserve the dirty working tree; do not commit, push, change branches or reset files unless the owner explicitly asks.

## Read first

1. PROJECT_CONTEXT.md, ROADMAP.md, KNOWN_ISSUES.md.
2. This handoff, ARCHITECTURE.md, STYLE_GUIDE.md and relevant GAME_DESIGN.md sections.
3. docs/design/weapon-court-and-first-proof.md and Decisions 232, 233, 234 in docs/decisions/.
4. ART_DIRECTION.md and art_source/reference/environment/weapon-court.json for current art/registration/prompts. CONTINUE_WEAPONS.md owns settled weapons. Read AI_NOTES.md only if compact context is insufficient.

## Latest owner request and result

The owner provisionally likes 233's relocated gate, mentor base and dummy idea. They request Veyr's missing shadow, a younger hooded/cool weapons master instead of an old man, more displayed weapons, an improved lodge/dummies and a prompt for another chat.

Decision 234 is installed for review:

- Eight fresh COMPLETE young hooded Veyr poses, dark teal/charcoal, brown gloves/boots and visible sword/axe gear. No reused head/body fragments. Same 57 source-pixel actor height, 96px cels, sole row 78, runtime scale 0.5 and y=-15: 28.5 world pixels, matching Orren.
- A separate stationary Orren-style foot shadow at y=-2/z=-2. Body radius 7 and interaction radius 48 stay unchanged.
- Same-size 232x152 pavilion with greatsword, paired swords, axe/scythe displays, teal banners, sharpening wheel and chest. Existing shallow collision and canopy reveal remain.
- New four-cel 256x64 training-post atlas. Rest → directional yield → counter-recoil → settle on accepted damage. Four reused straw flecks, one replaced 0.24s tween, no idle polling. All bases stay at sole row 54, scale 0.65/y=-14.3; target transforms/colliders never move. Corrected generic target-shadow offset.

Only three requested runtime PNGs change. The other 689 guarded assets remain exact; count stays 692. Five court/gate/NPC PNGs now total 152,139 bytes. There is one current compact prompt/provenance record, no new permanent art archive. Native owner approval of 234 is pending; passing tests do not approve appearance/feel.

## Preserve layout 233

`levels/sanctuary/town/sanctuary_layout.gd` owns coordinates/routes/bounds:

- Veyr (368,80), approach (368,116), pavilion (256,16), northwest yard.
- Sanctuary gate (864,128), approach (864,176), northeast court. This request concerns Sanctuary's gate/stage selector, NOT stage-completion portals.
- Four north terrain rows; ground 36x28 from row -4, player bounds Rect2(56,-72,1040,784), camera top -128.
- Coherent perimeter walls, stone service branches and center rest garden. Do not return to the oversized terrace/internal cross-path walls.

Other services remain: Eira directly right of her lectern, Nema crafting, Umi exchange, Orren workshop. F is required for NPC/door/gate interactions; do not reintroduce automatic walk-in. Map stays hidden. Keep accepted HUD/Bag and all five King weapon/Cyclone artwork, movement and audio.

## Play and learning authority 232

F5 → Continue/New Journey → northwest stone path → Veyr → F → Begin Axe Lesson. Use NORMAL play: F9/debug review suppresses permanent learning.

1. Loaned Axe: land normal hits on three distinct posts.
2. F1: contact three posts in one Cyclone while steering at least 36px with WASD/right-click.
3. Space + direction: leave the harmless one-second warning. Walking alone does not count.

One stable Axe proof permanently learns War Cyclone and unlocks Nema's Iron Beard recipe: 4 Weathered Fittings + 6 Root Fiber + 75 gold, at Sanctuary/Nema only. Equip via Tab → Weapons → Iron Beard Axe; F1 then works in expeditions. No free weapon/resources, no second XP bar, no invented mastery rank. Replay is idempotent; failed saves roll back proof, old saves remain compatible, exiting restores the loan/equipment/bounds/auto-combat preferences.

Ownership: autoload/weapon_training.gd and save_service.gd persist proofs; gameplay/training/axe_mastery_trial.gd owns the lesson; levels/sanctuary/town/weapon_court.gd presents NPC/menu/lodge; entities/training/presentation/weapon_training_post.gd owns hit artwork only. CraftingService owns costs/location/transaction. Other family proofs, evolved weapon visuals, wider base-only crafting migration and campaign balance remain future work.

## Verification and previews

Godot 4.7.2 standard: D:/WORK_APP/godot/Godot_v4.7.2-stable_win64_console.exe.

Current headless checks: weapon_mentor_smoke 181/0, sanctuary_hub_smoke 67/0, sanctuary_skills_flow_smoke 73/0; import and runtime_archive_boundary_smoke pass. Added coverage includes shadow, every mentor/post world height/sole, accepted-damage reaction/settle, unchanged collision and unearned-proof rejection. All 692 asset hashes pass; production profile/backup hashes remain unchanged during this task. Logs: tmp/test_logs/sanctuary_234/.

Current CPU previews: tmp/review/sanctuary_234/weapon_court.png, north_services.png and world_scale_comparison.png. They use actual scene transforms/shadow polygons, but omit native labels/shaders/audio and cannot establish owner visual approval. The scale strip order is Orren, Veyr, Eira, Nema, Umi, King.

Session constraint: owner was playing Monster Hunter and asked for no forced alt-tab. Keep checks headless/offline; do not open/focus Godot windows until explicitly lifted. Headless weapon_finalize_smoke cannot complete because it needs native audio/frame drawing; do not run it here.

## Next work

First let the owner review the installed hooded mentor/lodge/dummy reactions in normal play, preserving the corrected proportions and layout. Make only concrete requested visual corrections. Then review the first Axe proof's clarity, loan/restoration, forging/material pacing and F1 use in a real expedition. After acceptance, discuss the next family lesson and weapon-role balance; do not automatically invent XP curves, ten new skills or weapon evolution.

Keep only final runtime art, compact prompts/contracts/licenses and hashes. Raw generations remain outside the repo; staging/previews/logs are ignored tmp/. Do not recreate art_source/generated. Earlier automatic approval review blocked deletion of three ignored clone archives and some 233 staging; paths/reasons are documented in KNOWN_ISSUES.md and the 233 audit. Do not claim those are deleted or retry broad recursive cleanup. Do not touch production saves or the existing user's editor process.
