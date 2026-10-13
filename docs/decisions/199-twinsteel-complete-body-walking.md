# Decision 199 — Twinsteel complete-body walking

2026-10-13. Status: superseded by [Decision 200](200-generate-complete-twinsteel-running-cels.md) for current Twinsteel running. The owner subsequently rejected reference head/body reuse; this file records the historical canonical-body candidate. Supersedes Decision 196's frozen-upper/waist-strip gait requirement for Twinsteel. The owner explicitly withdrew fixed-arm walking and requested fuller vertical feet and natural motion in every facing.

## Context

The previous baker copied the identical complete upper cel into eight walking frames. It squeezed generated vertical legs into a 14-texel strip below row 81, making feet small and disconnecting movement quality from King's approved whole-body proportions. Fixing palms alone could not create a gait.

## Decision

Use complete immutable accepted King gait cels as the anatomy source. Preserve every source pixel and full boot silhouette at density 1; translate each entire cel horizontally by its authored identity landmark to remove lateral registration drift. Do not cut limbs/head, resize individual poses, alter the frozen library or add runtime reconstruction. Author both glove coordinates per cel and small opposite blade sway; bake source-pixel glove masks. Keep the hidden rear side handle and camera-relative depth.

Replace only the current three walking resources and six walking rasters in dual_carry_v3. The existing profile/catalog already selects them. tools/build_king_twinsteel_carry.gd now only builds walking, using tools/king_twinsteel_walk.gd; walk_registration.json records source/translation/density. Attacks, ready/proud idle, other families, native 0.5 scale, collision, movement speed, 48px distance-driven stride, combat clocks and saved IDs remain unchanged.

## Alternatives

- Keeping the upper body fixed or enlarging only the cropped feet retains the rejected gait and introduces body seams.
- Generating a new unrelated torso/head risks the recurring identity/size drift. The approved complete motion library already supplies useful connected anatomy.
- Runtime detached limb animation or per-frame rescaling adds avoidable presentation work and cannot establish art quality.

## Consequences and validation

Both arms and the body now move with full-sized feet. Pose/action changes are allowed while character identity and density remain stable. Automated checks enforce complete canonical pixel provenance, connected anatomy, real glove attachment, cyclic continuity, distinct feet/upper motion, actual input/travel/walls and run-to-attack/ready transitions. Native rendering verifies four-direction playback and preserved proud idle/retrieval. Nine walking assets change; all other 637 protected assets remain unchanged. Technical verification does not establish owner approval; Iron Reaper remains deferred pending that review. No commit/push is authorized for this change.
