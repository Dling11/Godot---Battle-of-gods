# Decision 112: Make left click manual selection authority

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

Right-click ground movement could remain active while a left-click sword attack played, producing a sliding attack. Left click also swung through enemies without selecting them, while assisted combat decided attack readiness from actor-centre distance and could hover at range without reliably contacting differently sized hurtboxes.

## Decision

- A world left click immediately disables optional auto-combat, cancels active ground movement, and suspends assisted pursuit.
- A single left click that intersects an enemy hurtbox or physical underfoot circle selects and highlights that enemy without moving or attacking.
- A double left click on an enemy selects it and enables navigation-aware repeated basic attacks.
- A left click outside enemy selection geometry remains a directional manual air swing.
- Right click retains its contextual behavior: ground movement on empty terrain and immediate engage/pursuit on an enemy.
- Assisted approach uses the player's six-pixel footprint plus the selected enemy's data-owned movement footprint and an eight-pixel combat gap. Damage remains owned by the real melee hitbox; the visible aura remains presentation only.

## Consequences

- Manual left-click intent always stops automated locomotion before an attack starts.
- Small enemies and large bosses use one size-aware approach rule instead of a hard-coded 38-pixel stop distance.
- Selection accepts either body hurtbox or the readable foot-circle area without conflating selection, movement collision, and damage authority.
- Regression coverage must prove selection-only single click, double-click engagement, movement cancellation, footprint approach, and a real landed damage event.
