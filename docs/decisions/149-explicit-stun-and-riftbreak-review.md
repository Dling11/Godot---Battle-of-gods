# 149 - Explicit stun and targeted Riftbreak review

Status: control distinction accepted and implemented; targeted Riftbreak is an authorized Lab comparison awaiting owner review. 2026-09-14.

## Context

The owner noticed every skill looked like a stun after the head-marker addition. The marker observed the enemy STAGGER state, which actually also represents ordinary interruption. King likewise classified long interruptions as a stun by duration. The owner explicitly chose **only designated heavy attacks and stun skills can stun**, rejecting damage-threshold inference. They also authorized moving on to a targeted Riftbreak animation/gameplay comparison using the approved King identity.

## Decision

Keep flinch, knockback and true stun separately authored. Preserve the existing flinch field and controller interruption path, add explicit zero-default stun metadata, and track stun duration independently inside shared control authority. Stars/body poses require both explicit stun and controller acceptance. Damage, critical hits, ImpactWeight, character level and duration do not select stun. Existing resistance, boss immunity, super armor and committed enemy attacks continue to apply.

Riftbreak's grounded impact is designated stun-capable; Worldsplitter designates only its final heavy contact. Other King skills keep brief flinch and their original knockback. Future skills/heavy attacks must opt in explicitly. Hog crash daze and Examiner guard break remain authored encounter stuns.

Riftbreak's new targeted concept is a reversible Lab toggle: 180px targeting, 30px stun center, 68px outer flinch/push at 65% core damage, .18/.07/.13s phases and sixteen generated VFX drawings. Terrain stops the confirmed point. The original skill, visual resources and prior loadout restore on toggle-off; saves and campaign appearance remain unchanged. The existing King identity/body frames and impact sound are reused for the comparison. Bespoke skill-body frames, later-stage radius upgrades and final campaign promotion require subsequent review.

## Alternatives

- Damage/max-HP thresholds: explicitly rejected by the owner.
- Inferring stun from long flinch or the STAGGER enum: produced false status feedback.
- Removing interruption entirely: would discard useful flinch and existing enemy counterplay.
- Promoting targeted Riftbreak directly into the campaign: would bypass the requested visual/playable review.

## Consequences and validation

DamageInfo/AbilityDefinition/hitbox callers remain backward-compatible through zero-default metadata. Stun may begin during a flinch and expire before it; kind-change signals update presentation without restarting the gameplay interruption. Focused checks cover this distinction, huge critical hits without stun, accepted/ignored hits, target resistance, final-contact-only metadata, core/rim collision, targeting/cancellation/walls, early control return, fixed residual origin and exact restoration. Existing four-skill, mastery and collection regressions pass. Passing tests does not establish final artistic or balance approval.
