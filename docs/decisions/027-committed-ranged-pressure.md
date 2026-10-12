# Decision 027 - Introduce Ranged Pressure Through Committed Projectiles

- **Date:** 2026-07-13
- **Status:** Accepted for the combat prototype

## Context

Stage 1 already validates direct melee pursuit and a snapshot leap. The next enemy must create positioning pressure without becoming an unavoidable early-game damage source or increasing Wave 3 beyond the approved four-enemy cap. The user also found the Forsaken Thrall too soft.

## Alternatives Considered

- Add more melee enemies without a new combat role.
- Let a ranged enemy continuously track the player during its wind-up.
- Use an instant ray attack or presentation-only projectile.
- Increase Wave 3 to five enemies.

## Decision

Introduce one 40-health Bramble Spitter in Wave 3 by replacing one Mireling. It seeks a moderate firing band, snapshots one player position beneath a 0.75-second red ground marker, fires a slow authoritative seed projectile for 8 damage toward that committed point, then has a long recovery. Projectile travel and collision use the standard damage/hurtbox contracts under the arena's dedicated projectile parent. Kiting movement and facing remain separate so it can back away while watching the player.

Increase Forsaken Thrall health from 75 to 100 without increasing its 15 damage or shortening its recovery.

## Consequences

- Early ranged pressure tests movement and perpendicular dodging without aimbot tracking.
- Projectile behavior can be reused or extended independently of the Spitter's sprite and warning presentation.
- Wave 3 remains within the current performance and readability budget.
- Thralls survive four normal sword hits instead of three, making them the durable early melee role.
- All values remain prototype tuning and require a manual feel test.
