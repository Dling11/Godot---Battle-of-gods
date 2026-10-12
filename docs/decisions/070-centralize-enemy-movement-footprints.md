# Decision 070: Centralize Enemy Movement Footprints Without Flattening Combat Shapes

- **Status:** Accepted and implemented for the five current enemy archetypes
- **Date:** 2026-08-01

## Context

Current enemies already use circular underfoot collision like a top-down MOBA, but physical collision and `NavigationAgent2D.radius` were duplicated as scene numbers. Crowd-separation detection also used one scene default. That makes a new large or unusually shaped enemy easy to configure inconsistently, especially when navigation clearance must match its real movement footprint.

Movement footprint, damageable body, and attack contact are different gameplay concepts. Making every shape circular would damage the authored Rootling lane, sword fan, projectiles, and boss telegraphs.

## Alternatives Considered

1. Keep manually synchronized scene values.
2. Replace movement, hurtboxes, and attacks with one universal circle.
3. Store movement and separation radii in `EnemyDefinition`, apply them through one reusable runtime system, and keep hurtboxes/attacks independent.

## Decision

Choose option 3.

`EnemyDefinition` owns `movement_footprint_radius` and `crowd_separation_radius`. `EnemyFootprintSystem.configure()` duplicates and resizes each instance's circular movement shape, synchronizes `NavigationAgent2D.radius`, and configures an optional `EnemySeparationComponent`. Scene defaults remain readable editor fallbacks but are not runtime authority.

The current bands are small 6-pixel Rootling/Mireling, medium 7-pixel Thrall/Bramble Spitter, and large 16-pixel Rootbound Husk. These are archetype values, not a promise that every future enemy must use one of exactly three numbers.

Hurtboxes remain authored from the damageable silhouette. Attack shapes remain ability-specific rectangles, fans, capsules, circles, or projectile contacts. A selection/debug ring may observe the movement radius later, but a permanent visible ring is not part of this decision.

## Consequences

- New enemies declare their underfoot/navigation size once in data.
- Multiple spawned instances cannot resize one another because the scene shape is duplicated before mutation.
- Navigation bake clearance still must accommodate the largest actor intended for a map.
- The medium Thrall footprint increases from 6 to 7 pixels; Opaw remains a separate 6-pixel player footprint.
- `enemy_footprint_smoke.gd` protects movement, navigation, and crowd-separation synchronization across all five current enemy archetypes.
