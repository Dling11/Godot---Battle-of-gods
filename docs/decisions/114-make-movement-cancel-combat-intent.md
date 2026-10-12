# Decision 114: Make movement cancel combat intent

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

Contextual right click still engaged enemies, native double-click recognition was inconsistent, and WASD could leave a hidden selection or pursuit active. The enemy roster also revealed distant or dormant actors and rebuilt too often for overflow text to scroll.

## Decision

- Right click always requests ground movement and clears selection, pursuit, Auto All, and the repeated-click sequence.
- WASD movement clears the same combat intent.
- One left click on enemy selection geometry selects only. A second or later click on that same actor within 520 milliseconds and 14 pixels enables approach-and-repeat basic attacks.
- Empty-world left click remains a directional basic attack and stops click movement.
- Roster rows use the same left-click/double-click contract. They reveal only visible enemies within 300 pixels, then remember those actors until death/despawn.
- Overflowing enemy names use a clipped, padded marquee that stays still when the text fits.

## Consequences

- Movement is unambiguous manual authority and cannot leave combat automation running behind it.
- A distant or dormant boss is not spoiled by the combat HUD before discovery.
- The roster refreshes only when its actor, health, or selection signature changes, so marquee animation is stable and avoids needless UI churn.
