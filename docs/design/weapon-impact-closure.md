# Weapon impact closure and Greatsword retirement

2026-10-07. The owner accepts the installed Greatsword animation, authorizes hit-audio polish and real-enemy comparison, and requests removal of the V1 comparison weapon. Scythe design must be shown and chosen before animation or equipment implementation.

## Play

Restart F5 → F9 → F7 → **Weapons**. Choose **Royal Greatsword**, **Iron Beard Axe**, **Twinsteel**, or **King's Sword**. F9 grants a session-only test kit and suppresses campaign autosaving. Tab opens the Bag; Escape closes it. Hold world left click to repeat the normal combo. The existing Lab enemy selector, Spawn 1/4/8 and AI toggle support moving-enemy comparisons.

The direct `tools/launch_king_greatsword_v2_training.ps1` shortcut opens actual Combat Lab with the approved Greatsword and three paused Rootlings. Its compatibility shortcut `launch_king_greatsword_review.ps1` reaches the same training instead of retired V1 review code. Enable enemy AI to fight rather than inspect stationary targets.

## Accepted Greatsword

There is one selectable Royal Greatsword. The former V2 item keeps ID `weapon_king_royal_greatsword_v2` and its existing resource paths to preserve saves and presentation dependencies; the display name is **Royal Greatsword**. The four-cut front → return → spin → jump combo, 2.34s authored budget, damage, shapes, camera strength, steel and approved body/effect art remain unchanged by this closure. The Bag shows the existing data-derived damage, 29.6 base DPS and a 64px inspection.

The retired item/weapon definitions, V1 family resources and obsolete V1-only tests/capture tools are archived under `art_source/archive/greatsword_v1_retired_2026_10_07/`, with `.gdignore` and hashes. Shared canonical steel, proud idle, locomotion, plant effects and the offline source helper remain because approved V2 uses them. They are dependencies, not an independently playable V1.

## Save compatibility

WeaponInventory translates only the retired ID `weapon_king_royal_greatsword` to the existing V2 ID during both version 1 and 2 ownership/equipped validation and restoration. Owning both old/new items collapses to one. New snapshots contain the live ID. An unowned equipped weapon and arbitrary unknown version-2 IDs remain invalid. The retired item cannot be acquired/purchased again; removing it does not grant a fresh campaign free equipment. No new save version or direct profile-file mutation is introduced.

## Hit audio

Normal Greatsword enemy contacts reuse the retained CC0 qubodup meat-impact variations at 0.74 pitch / -4dB. The fourth cut selects a new static recording: 65% meat + 20% wood + 30% stone, trimmed/faded and peak-normalized to approximately -4dBFS, then played at 0.9 pitch / -4dB. There is no metallic sample or runtime DSP. The existing ground-contact sound remains separate; the body impact occurs only on an accepted enemy hit. Each cleave plays one shared body cue regardless of targets; misses stay silent.

Optional `WeaponDefinition.combo_hit_audio` selects by authoritative combo step, with missing/null entries falling back to `hit_audio`, then the existing legacy sound when no profile exists. CombatFeedbackPresenter owns playback and retains its one-cue-per-swing guard; it never changes damage, timing or hit deduplication. Sword/axe/dual profiles remain unchanged. [Attribution](../../assets/audio/ATTRIBUTION.md), audio manifest and audition.

## Real-enemy comparison

`tests/weapon_enemy_comparison.gd` exercises actual Lab/Player/Rootling/Armored Hog scenes and their normal health, hurtbox, stagger and knockback components. Controlled single-Rootling, eight-Rootling and single-Hog samples pin body locomotion and raise instance HP to avoid deaths/rewards; they verify each hit's raw/mitigated damage, resolved knockback resistance, exact phase budgets, near/far reach, per-target deduplication and one shared impact. This is controlled authority evidence, not natural encounter DPS.

Separate eight-Rootling samples keep AI/physics/separation active, use normal hitstop/feedback and run a baseline, first comparison combo and repeated combo for each weapon. King is invulnerable/stationary and enemies have high instance HP. No saves/rewards are allowed. Native OpenGL compatibility on this AMD Radeon desktop records:

| Weapon | Cuts / authored chain | Base DPS | Frontal shape / special reach | Moving first/repeat contacts | Worst combat frame |
|---|---:|---:|---|---:|---:|
| King's Sword | 3 / 1.91s | 21.9 | 36px | 16 / 16 | 15.75ms |
| Iron Beard Axe | 5 / 3.19s | 28.9 | 72px, 78px thrust, 68px radial | 38 / 38 | 16.02ms |
| Twinsteel | 5 / 2.20s | 24.1 | 72px, 80px final fan, 58px radial | 37 / 37 | 17.35ms |
| Royal Greatsword | 4 / 2.34s | 29.6 | 96px, 82px radial spin | 30 / 30 | 16.95ms |

Base DPS is unbuffed per-target arithmetic, not measured horde DPS. The same compact horde moves during each combo, so target contacts need not equal population × cuts. Greatsword's strongest authored push is 144px/s; the Hog's 0.35 multiplier resolves it to 50.4px/s. Highest physics monitor peak was 3.78ms; combat-frame p95 ranged 14.15–14.44ms. No large stall appeared in this short desktop sample. These runs follow controlled contacts in one process and are not cold-process/campaign, export, GPU or phone certification. The historical Skill 1 first-cast concern remains open.

No speculative damage/reach/cadence adjustment was made from these samples. Owner playtesting remains the basis for further role tuning.

## Proof and remaining work

Retirement/full-profile migration: 39/0. Native four-weapon damage/Bag/audio closure: 301/0, with clean teardown after transient audio finishes. Actual approved Greatsword integration: 197/0; moving/controlled real-enemy comparison: 1256/0. Axe138/0 and dual244/0 native regressions pass; profile snapshot/catalog checks also pass. Total2175 focused assertions, including2136 native-rendered assertions. All123 snapshotted approved art/pose/import files remain byte-identical after the V2 builder rerun; all143 rollback copies and18 retired files match their manifests. The new finisher PCM rebuilds to the same SHA256.

The existing Greatsword integration fixture retains 56 ObjectDB / 1-resource exit warnings; the axe fixture retains 57 ObjectDB warnings. Passing contact assertions do not resolve those separate teardown limits. Proof, exact raw results and screenshots.

Scythe is concept-only. After the revised separate silhouettes, the owner explicitly selects **A: Iron Reaper**, then prioritizes a fresh dual-sword side study. Its silhouette choice is complete; scythe frames/equipment are deferred behind that work. Concepts and prompts, current dual study.

Next: owner reviews the new dual side motion and the installed contact sounds/weapon roles; then author vertical dual attacks and validate promotion before returning to the selected scythe. Campaign acquisition/recipes, encounter balance, family-specific skills, fixture cleanup and device profiling remain distinct work.
