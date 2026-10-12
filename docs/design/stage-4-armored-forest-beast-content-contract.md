# Stage 4 Armored Hog Content Contract

## Status

Implemented and structurally verified. The approved stylized Armored Hog now joins every Stage 4 wave while the stage totals remain `6/8/10/12/14` and the live cap remains eight.

## Combat identity

- A squat reddish Forest hog carries one oversized wedge of living bark across its forehead and shoulders. Short root horns, amber eyes, large hooves, a pale rear scar, and a curled tail preserve the approved toy-like enemy language instead of realistic animal anatomy.
- A fixed `0.62 s` scrape-and-brace warning snapshots one straight 210-pixel charge lane. Moving after commitment dodges it; the hog does not retarget.
- The braced/charging front cone takes 35% damage. The exposed side and scarred rear take full damage.
- Completing or colliding during the charge produces a crash and `1.15 s` daze, creating the punish window.
- The enemy is Elite crowd-control tier and uses a 9-pixel movement footprint plus 40-pixel separation radius for Stage 4 crowds.

## Runtime art

- Approved identity: `art_source/generated/characters/enemies/stage_4_armored_hog/armored_hog_identity_approved.png`
- Locomotion: `assets/characters/enemies/stage_4_armored_hog/armored_hog_locomotion_sheet_64x48.png`
- Charge: `assets/characters/enemies/stage_4_armored_hog/armored_hog_charge_sheet_64x48.png`
- Reaction: `assets/characters/enemies/stage_4_armored_hog/armored_hog_reaction_sheet_64x48.png`
- Runtime frames: `assets/characters/enemies/stage_4_armored_hog/armored_hog_sprite_frames.tres`

Each family uses one shared scale, 64x48 cells, a common ground baseline, and four rows in `down/left/right/up` order. All authored frames are consumed by 32 named animations; none are silently discarded. The rejected realistic draft is recoverably archived under `art_source/archive/stage_4_rejected_realistic_hog_2026-08-13/` and is not runtime-loadable.

## Materials and audio

- `Armored Hog Hide`: 20% common roll, protected after six misses.
- `Living Bark Plate`: 8% secondary roll, protected after twelve misses.
- Both own distinct 24x24 icons and stable Forest material IDs. They are collectible/saveable crafting inputs; no recipe currently consumes them.
- Hoofbeats, brace scrape, and crash are original deterministic project sounds. The brace also layers a pitch-lowered CC0 boar vocal for a natural warning without copying another game's audio.

## Verification

`tests/armored_hog_smoke.gd`, `tests/stage_4_encounter_smoke.gd`, `tests/material_crafting_data_smoke.gd`, and `tests/loot_resolution_smoke.gd` protect the runtime scene, all animation families, guard angle, committed charge/daze, sound resources, encounter counts, icons, and protected drops.
