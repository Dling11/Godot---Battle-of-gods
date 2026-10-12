# Decision 041: Activate Compact Armless Opaw With an Explicit Visual Rollback

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

The first modular Opaw model still showed hands or sleeve-shaped arms, while the desired presentation was a compact top-down fighter with no arms or hands, tiny feet, and combat motion carried by the whole body plus a detached sword. Earlier `handless`, `armless`, and `armless_small_feet` experiments established the distinction but were attack-only or incomplete. Replacing the active seven-action model also needed a project-local rollback rather than relying only on version-control history.

A user-supplied screenshot from another game demonstrated useful broad qualities: large readable heads, small grounded bodies, minimal limbs, and clear top-down silhouettes. Its individual characters, costumes, weapons, names, UI, environment, and distinctive authored designs are not project assets and must not be reproduced.

## Alternatives Considered

- Keep the previous Wayfarer model active and preserve the armless work as attack-only review material.
- Cover the visible hands while retaining sleeve/arm silhouettes.
- Replace only the attack body and allow locomotion/interaction to use a different silhouette.
- Activate one complete original compact armless action set while preserving the former model as an independently loadable runtime backup.

## Decision

Opaw's active `SpriteFrames` uses the seven sheets under `assets/characters/playable/opaw/compact_armless/`. The body has an oversized slightly boxy head, pure-black serious eyes, rust scarf, narrow green tunic, tiny boots, and no arms, sleeves, hands, elbows, or shoulder stubs. Idle, walk, attack, dash, interact, hurt, and defeat keep Decision 040's action names, direction rows, frame counts, 18x27 upright scale, and y=32 foot baseline.

Attack force comes from authored whole-body coil, lean, lunge, overshoot, tiny-foot bracing, and scarf follow-through. `PlayerWeaponVisual` keeps the Ashwood Blade separate, but its integer-pixel anchor is moved outward from the body and its normal swing spans a wider bounded phase-driven orbit. Gameplay hitboxes, damage, reach, timing authority, collision, and hurtboxes do not derive from the artwork or weapon orbit.

The complete model that was active immediately before this decision is copied to `assets/characters/playable/opaw/variants/wayfarer_original/` with all seven textures and an independent `SpriteFrames` resource. Earlier sleeve-ended and attack-only variants remain preserved, but they are not the supported rollback.

The screenshot reference informs only general compact top-down proportions and readability. Opaw's identity, palette, clothing, scarf, facial treatment, action poses, detached sword behavior, and runtime assets remain original to this project.

## Consequences

- The playable scene and character-menu preview now show one coherent armless silhouette across every required action.
- Wide attacks can gain visual momentum without inventing arms or moving gameplay authority into presentation.
- The weapon intentionally floats with a small readable gap; future weapon families need reviewed anchors and must not inherit the orbit blindly.
- The previous active model is immediately restorable through a single `SpriteFrames` resource swap and remains testable independently.
- Runtime/source storage increases because both active and rollback sets coexist.
- Human gameplay-scale review is still required; mechanical tests cannot decide whether tiny feet, scarf motion, or the weapon gap feel visually correct.
