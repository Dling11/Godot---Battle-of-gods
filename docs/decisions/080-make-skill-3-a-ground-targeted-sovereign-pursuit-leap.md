# Decision 080: Make Skill 3 a ground-targeted Sovereign Pursuit leap

Status: Accepted — 2026-08-11

## Context

Riftbreak is strongest after King reaches a group. The older enemy-locked multi-crossing proposal was more complicated than the approved fast, simple combat direction and coupled the skill to a living target.

## Alternatives

- Enemy-targeted three-cut pursuit combo.
- Targeted jump with a hidden Riftbreak bonus.
- Ground-targeted leap that is independently useful and creates positional synergy.

## Decision

Sovereign Pursuit is a 220-pixel ground-targeted leap. Confirmation commits a collision-safe traversal with invulnerability only during active travel. Landing resolves one 52-pixel, 125% weapon-damage radial contact with outward knockback. Riftbreak synergy is purely positional; no combo state, bonus, timer, or reset exists.

## Consequences

The skill remains usable without an enemy target, respects authored obstacles through normal player collision, and introduces reusable ground-point targeting. Presentation uses dedicated body and effect atlases but observes component signals rather than owning movement, protection, or damage.
