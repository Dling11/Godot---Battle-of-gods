# 233 — Correct NPC world scale and rebuild the northern service courts

Date: 2026-10-18. Status: installed for owner review. Supersedes Decision 232's placement, extent and NPC presentation scale; its proof/unlock/forging rules remain unchanged.

## Root cause and owner direction

The owner rejects the oversized new NPC and requests relocating the Sanctuary gate, a proper weapons-mentor base, and coordinated changes to walls/layout. Veyr's 57px source body was incorrectly rendered at 1.0 while approved Orren/NPC scenes use 0.5. Matching source-cell heights without inherited runtime scale doubled his world height. Previous headless functional checks did not test this visual contract.

## Correction

- Preserve Veyr's complete source poses. Render them at 0.5, y=-15, yielding approximately 28.5px body height and the same physical foot origin as Orren. Match the 7px foot collider and 48px interaction radius. Nameplate uses the existing -62px NPC offset.
- Add a slate/stone/timber open-air weapons pavilion at (256,16), with weapon rack, sharpening wheel, shallow collision and canopy reveal. Veyr stands on the yard's right side at (368,80), approach (368,116). Practice posts use 0.65 world scale and small foot collisions.
- Move the Sanctuary gate to the northeast at (864,128), approach (864,176). The gate's fixed masonry/light, route selector and F requirement are preserved. Stage-completion portals are unchanged.
- Replace the oversized eight-row extension with four north rows: terrain y=-128..768, player y=-72..712. The practice yard is northwest, expedition court northeast, and a small planted rest area sits between them. Existing Eira/Orren/Nema/Umi positions, houses, fountain and courier remain.
- Remove the old y=224 wall barriers and terrace fragments. Frame the services along the north/west/east perimeter with consistent endpoints. Separate stone branches join both service courts to the fountain.

`sanctuary_layout.gd` owns current coordinates, routes, bounds and mentor scale. Ground, presentation, lesson authority and tests consume it. Scene defaults match it. Do not derive an actor's world size from source texture/cell dimensions alone.

## Verification and retention

`weapon_mentor_smoke.gd` now measures each of Veyr's eight painted frames in WORLD units against the actual instantiated Orren sprite, checks foot registration, both collision-free routes, new station/gate positions, F interaction and the unchanged real-contact/persistent-learning/forging loop. Existing Sanctuary/Eira checks exercise the renewed composition.

CPU composition previews show actual node transforms, props and terrain; a comparison strip places Orren/Veyr/Eira/Nema/Umi/King on a common world-foot baseline. These are not native shader/audio/feel approval. No native window is opened while the Monster Hunter restriction remains active.

Headless checks pass: mentor 167/0, Sanctuary 67/0, Eira 73/0, runtime/archive boundary and editor import. All 692 guarded asset hashes match.

One final 232x152 pavilion raster adds 44,410 bytes. All 691 prior protected assets remain unchanged. Compact source/prompt/registration/testing metadata remains at art_source/reference/environment/weapon-court.json. Keep only current ignored previews, remove temporary packing scripts/rejected layout previews, and never recreate an art archive.

Cleanup limitation: automatic approval review rejected removal of this task's ignored staging helpers and rejected 232 preview, citing “blocked by policy.” They remain under tmp/ and are not runtime assets. Current preview and validation logs are retained separately under tmp/review/sanctuary_233 and tmp/test_logs/sanctuary_233.
