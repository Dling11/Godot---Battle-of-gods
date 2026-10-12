# Decision 049: Align Piercing Rush's Central Lance and Audio with Its Presentation

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

Piercing Rush now has a dramatically oversized six-frame visual plume, but its original 44x12 hit shape, 135% multiplier, 78 pushback, and reused swing cue made the action feel much weaker than it looked. The user explicitly requested stronger damage, a larger true hit area, and sound that cannot be mistaken for the normal attack.

## Alternatives Considered

- Keep the original narrow shape and only raise damage.
- Make all of the roughly 160-pixel visual wings damaging.
- Keep the generic swing sound and adjust its pitch further.
- Enlarge the bright central lance, strengthen its weapon scaling, and add separate authoritative phase/contact audio.

## Decision

The definition-owned Piercing Rush shape is a 128x30 tapered forward lance. It remains narrower than the outer VFX wings, so the skill reaches targets clearly inside the bright central spear but does not damage enemies merely touched by cosmetic ribbons. The multiplier is 180% equipped weapon damage and pushback is 112. Ashwood resolves to 45 and Iron resolves to 57.6.

The cast still moves about 50 pixels, keeps its 0.14/0.18/0.24 phase timing and 3-second cooldown, and grants no invulnerability. `PlayerActionSfx` uses the same `AbilityComponent` phase signal to play a quiet CC0 charge during wind-up and a distinct CC0 thrust during active. `CombatFeedbackPresenter` plays a separate CC0 impact only after the ability's accepted hit signal. Normal sword and preserved Sweeping Cut sounds remain independent.

## Consequences

- The cast-facing direction is immutable from wind-up through recovery: player movement may prepare the next idle direction, but cannot rotate the live thrust's VFX, hit shape, damage, or knockback.
- Multiple accepted contacts in one physics frame retain each target's local feedback while emitting only one shared hitstop, camera nudge, and impact cue.
- Piercing Rush now supports its signature visual with reliable forward reach, meaningful weapon scaling, and a heavier sound sequence.
- The central bright spear reads the real 128x30 lane from the immutable shape; the outer 160-pixel visual plume remains presentation only for fairness and telegraph readability.
- Source licenses and original packs are recorded and archived, while only three selected named clips ship as runtime dependencies.
- Encounter clear time and crowd readability must be measured before further multipliers, range, or cooldown reductions are considered.
