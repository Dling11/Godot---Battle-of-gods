# Decision 051: Use data-driven crowd-control tiers for enemy resistance

- **Status:** Accepted
- **Date:** 2026-07-19

## Context

Opaw's rapid Consecutive Thrust should interrupt low-tier enemies so the flurry has a clear tactical payoff. The same rule must not allow a future boss to be permanently displaced or prevented from acting. Adding Boss checks to each skill would spread enemy-resistance policy through player combat code and make future control effects inconsistent.

## Alternatives

1. Give every ability a hard-coded list of enemy types it can push or interrupt.
2. Make all enemies react identically, including future bosses.
3. Store a Light/Elite/Boss control tier on immutable enemy data, have reusable observing components resolve knockback and stagger from that tier, and let each enemy controller own its own interrupted state.

## Decision

Choose option 3. `EnemyDefinition.CrowdControlTier` declares Light, Elite, or Boss. Light receives full control; Elite receives 35% movement knockback and 45% stagger duration; Boss resolves both to zero. `DamageInfo` carries optional stagger duration. `KnockbackComponent` and `StaggerComponent` observe accepted health damage and apply the data-driven multiplier. Enemy controllers, not the components, own their `STAGGER` state and deactivate their own hitbox on entry.

## Consequences

- Consecutive Thrust may refresh 0.21-second stagger on each small lance and apply 0.42 seconds on its final lance without knowing which enemy it hit.
- The current Thrall, Mireling, and Bramble Spitter explicitly use Light; future elite/boss data changes resistance without duplicating actor code or abilities.
- Bosses still receive ordinary damage and confirmed-hit presentation, but not player displacement or attack interruption.
- Future poise, immunity phases, break gauges, and special boss exceptions require a separate decision rather than overloading this simple initial tier system.
