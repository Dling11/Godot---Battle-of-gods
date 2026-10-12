# Decision 047: Equip Weapon-Scaled Piercing Rush and Preserve Sweeping Cut

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

Opaw's grounded Sweeping Cut proved the reusable ability/cooldown/hitbox foundation, but its wide fixed-damage spacing role does not match the approved first-skill direction. Skill 1 should demonstrate forward commitment, equipped-weapon scaling, stronger Warrior presentation, and a responsive clickable HUD seam without inventing divine power or building an unused ground-target flow.

## Alternatives Considered

- Keep Sweeping Cut equipped and postpone the thrust kit.
- Delete Sweeping Cut and hard-code Piercing Rush directly in `Player`.
- Make Piercing Rush a second dash with invulnerability.
- Create separate Ashwood and Iron copies of every weapon skill.
- Extend the shared ability definition/runtime, equip Piercing Rush, and preserve Sweep as unequipped content.

## Decision

Piercing Rush occupies Opaw's active slot 1. `1`, legacy Q, left shoulder, or clicking its ready HUD slot requests the same actor command along Opaw's movement-owned facing. Ground-target activation remains unavailable until a skill requires a confirmed point.

`AbilityDefinition` declares stable identity, activation and presentation modes, hitbox shape, flat damage, equipped-weapon multiplier, knockback, active movement speed, phases, and cooldown. `AbilityComponent` snapshots resolved damage and shape on accepted cast and owns phase/cooldown timing. `Player` consumes active velocity and remains body/collision authority. Piercing Rush moves at 280 px/s for 0.18 seconds after a 0.14-second wind-up, recovers for 0.24 seconds, cools down for 3 seconds, deals 135% of the snapshotted weapon damage once per target, applies 78 pushback, and grants no invulnerability.

The detached weapon enters a thrust pose. `PiercingRushVisual` draws the longer white-gold spirit blade and streaks as presentation only; combat contacts come from the definition-owned narrow shape. The existing technique SFX is temporarily reused at a sharper pitch until timing is approved. A generated binary-alpha icon joins the established UI icon kit.

Sweeping Cut remains loadable and regression-tested with its definition, old slot, presentation code, fixed 20 damage, 90 pushback, phase timings, and cooldown. It is unequipped rather than deleted.

## Consequences

- Iron Sword naturally strengthens Piercing Rush without copied ability resources.
- Movement, collision, damage, UI, VFX, and audio retain separate authorities.
- Skill 1 can be tested through keyboard, controller, and pointer without a premature target cursor.
- Piercing Rush's mobility and damage may shorten already brief stages, so encounter pacing must be measured before adding reinforcements or changing enemy health.
- Sweeping Cut can return through a future loadout/awakening system without reconstruction.
- Consecutive Thrust, ground targeting, unique Piercing audio, Eira awakening, and slots 2-4 remain separate work.
