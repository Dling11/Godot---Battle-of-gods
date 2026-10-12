# Decision 079: Make Skill 2 a Self-Centered Riftbreak

## Status

Accepted for gameplay proof on 2026-08-11.

## Context

The first Skill 2 proposal was a targeted jump. Owner review reserved jumping and lifting for Skill 3 or Skill 4. A grounded travelling-line fissure was then implemented as a temporary proof, but further review found that its target path, two contacts, and endpoint presentation overcomplicated a simple warrior kit. The desired relationship is natural sequencing—future Skill 3 places King inside a group, then Skill 2 clears around him—not a hidden technical combo system.

## Alternatives

- Keep the targeted leap and impact ring in Skill 2.
- Keep the implemented travelling fissure and endpoint eruption.
- Use one immediate circular sword slam centered beneath King.

## Decision

Skill 2 becomes **Riftbreak**. Pressing `2` immediately commits a 0.16-second grounded wind-up, one 0.10-second 84-pixel-radius contact centered at King's feet for 150% sword power, and 0.22 seconds of recovery. King remains vulnerable. Each accepted target receives knockback away from the circle center through shared combat authority. Cooldown is 6.5 seconds.

Riftbreak works independently when King is surrounded. A future targeted jump Skill 3 may naturally precede it, but there is no combo flag, bonus damage, alternate version, timer, or cooldown reset. The first visual remains a minimal expanding fracture ring until owner feel review approves radius and timing.

## Consequences

- Skill 2 is readable at the project's small pixel scale and requires no target marker.
- Skill 1 and Skill 2 have distinct jobs: aimed directional pressure versus immediate surrounding space control.
- Jumping and lifting remain available for Skill 3 escalation.
- `MeleeHitbox` gains reusable radial direction calculation while retaining target deduplication and damage delivery.
- The discarded line-target adapter, dynamic line/endpoint shapes, icon, test, and resources are removed rather than retained as dead runtime code.
