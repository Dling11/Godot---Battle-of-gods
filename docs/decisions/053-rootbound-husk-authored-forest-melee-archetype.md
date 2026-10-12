# Decision 053: Rootbound Husk as an Authored Forest Melee Archetype

- **Date:** 2026-07-19
- **Status:** Accepted, revised 2026-07-23

## Context

The forest roster needs a third family, but a recolored Forsaken Thrall would add no new readable decision or future boss foundation. The player approved the larger Rootbound Husk: an evil bark-and-vine humanoid with roots, moss glow, and thorns that uses a distinct attack language. Later review correctly identified its tall antlered silhouette as too boss-like for the first small Stage 1 mob; Decision 054 assigns that beginner role to Rootling instead.

## Alternatives Considered

- Reuse the Forsaken Thrall controller and only replace its sprite.
- Introduce a more complex charging Thornback Ram before the base forest roster is established.
- Build a separate rooted melee archetype with one ground-root lane attack.

## Decision

Rootbound Husk is a dedicated enemy scene/controller, not a Thrall variant. It chases with a deliberate root-heavy walk, then anchors in place to telegraph a short forward crack before a `Root Spear` erupts along the ground. The player avoids it by stepping or dashing sideways; it uses no projectile and does not track the player after its wind-up begins.

Its initial Light-tier tuning target is 70 health, 48 px/s movement, 9 contact damage, a 0.62-second root/ground-crack wind-up, 0.14-second active spear, 1.05-second recovery, 0.75-second materialization, 13 XP, and 2 coins. The attack's own tapered forward lane—not effect pixels—owns damage. A complete direction-row animation package supplies walking, six attack poses, hurt/wither/defeat, and a separate four-cell ground-eruption VFX board.

## Consequences

## Revision 2026-07-19

Rootbound Husk is implemented as Stage 3's first solo Boss-tier mini-boss, not a Stage 2 Light enemy. It now has 280 health, 12 damage, Boss crowd-control resistance, a 112x20 snapshotted Root Spear, a three-lane Root Fan, and a point-blank Root Burst. Its danger comes from readable positioning tests and enough survival time to express multiple patterns rather than extra live enemies.

- A later Stage 3 introduction gains a larger lateral-dodge role while the readable Stage 1 beginner space remains owned by Rootling and Stage 2 escalates only established forest roles.
- The Rootbound Elder can later evolve the same Root Spear language into multi-lane and arena-root boss mechanics without invalidating the base mob.
- The enemy requires independent art, collision, controller, audio, health UI binding, navigation, and regression coverage before it enters a wave.

## Revision 2026-07-22

Rootbound Husk presentation uses a fixed-scale `AnimatedSprite2D` body with named `SpriteFrames` for idle, walk, root-attack wind-up, root-attack active, root-attack recovery, hurt, and defeat. Its separate root telegraph/eruption nodes also use `AnimatedSprite2D` and render on the ground layer beneath actors. The Godot asset processor recovers connected actor pixels that cross generated cell boundaries, rejects disconnected debris, and applies one standing-reference scale unchanged across each direction row, preserving one foot baseline and using wider root-attack cells rather than shrinking extended poses. Animation remains a presentation observer; the controller's snapshotted hitboxes continue to own attack timing and damage.

## Revision 2026-07-23

Rootbound Husk's implemented attack language is now a profiled quick Root Spear plus a slower Root Fan. The fan warns all three snapshotted lanes, erupts its center first, and delays its two sides by 0.11 seconds; below half health, timings tighten modestly and fans occur more often. A target within 34 pixels selects a 0.48-second telegraphed circular Root Burst, removing the former overlap safe zone without adding a blocking body collision. The focused mini-boss tune raises health from 160 to 280 and damage from 10 to 12 while retaining Boss control resistance and the four-enemy cap. Authoritative hitboxes remain controller-owned; signals own VFX, camera response, and layered root audio.

Generated character work now follows `docs/design/character-animation-pixel-contract.md`. Husk uses `72x64` walk cells, `64x64` reaction cells, `96x64` root-attack cells, `128x64` ground-VFX cells, fixed per-direction actor scale, a stable foot baseline, binary alpha, and containment/component validation. The wider walk cell preserves complete planted strides without shrinking.

At this now-superseded original-body revision, the gliding side cycle was replaced with planted/lifted poses and the four-frame tree-like eruption was replaced with six ground-owned stages from crack through collapse. Root sprites remained unrotated and centered on the ground-plane lane location, the health bar moved above the crown, and the controller directly preloaded its profile script to avoid editor global-class cache failures. The later stump-guardian revision retains those VFX and editor-robustness corrections while replacing the body animation package.

The independently generated v2 side rows were rejected because the right row changed antlers, torso mass, arms, and stride relative to left. Foot-level review then rejected the generated v3 side motion as a complete gait because its passing feet remained effectively planted. A temporary processor repair lifted opposite feet by two pixels and mirrored the side row after normalization; the stump-guardian revision below supersedes that repair with reviewed contact/passing source poses.

## Revision 2026-07-23 - Stump-Guardian Redesign

Further gameplay review rejected the original long-antler body rather than continuing to patch its generated feet. The active Rootbound Husk is now a broad stump guardian with a compact branch crown, plated shoulders, moss-draped core, separated heavy root legs, and explicit foreground/background limb layering. All retired long-antler and pre-final body packages were permanently deleted after final approval so they cannot be mistaken for active content.

The active side cycle is contact A, passing A, opposite contact B, and passing B. Legs exchange horizontal front/back ownership and arms counter-swing; vertical-only foot movement is not accepted as locomotion. Because a single multi-frame generation repeatedly preserved the same stance, the v4 walk source is reproducibly assembled from individually reviewed poses with one shared source scale per direction row. Left is derived from the approved right cycle, and the runtime processor again mirrors left into right after normalization and byte-verifies the result.

The active `SpriteFrames` retains only approved final-model animation groups. `hurt_*` uses matching root-command body frames, while every directional `dead_*` keeps the four manually reviewed collapse frames from the runtime reaction sheet and speed-fits them to the controller's 0.6-second cleanup window. The root-command body remains an assembled v4 six-stage ready/brace/gather/ground-command/hold/recover flow in all four directions, named `root_attack_wind_up_*`, `root_attack_active_*`, and `root_attack_recovery_*`. Raw boundary-crossing poses are recovered as connected actors and normalized into an exact 6x4 source before runtime processing. No obsolete `cast_*` animation or retired Husk body package remains active.
