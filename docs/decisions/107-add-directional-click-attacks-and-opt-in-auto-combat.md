# Decision 107: Add Directional Click Attacks and Opt-In Auto Combat

- **Status:** Accepted and implemented; owner balance/feel test pending
- **Date:** 2026-08-16

## Context

Manual left-click sword attacks retained the last movement facing even when the pointer clearly indicated another side. The live enemy roster also made threats easy to inspect but did not provide an optional low-input farming loop. The former pulsing click-move ring was visually busier than the requested simple movement feedback.

## Decision

A manual left-click attack snapshots the nearest cardinal direction from King toward the clicked world position before entering the normal attack request/buffer. It does not add mouse-facing during ordinary movement.

The enemy-roster header owns two explicit toggles. `AUTO ALL` selects and engages the next living roster target whenever the current target dies. `AUTO SKILL` also tries the first ready equipped Skill `1`-`4` at safe idle/in-range boundaries and confirms its authored directional or ground target against the current enemy. Both modes reuse normal navigation, targeting, cooldown, damage, stagger, and cast authority. Ground movement, `Esc`, or disabling Auto stops both automation modes.

The large drawn move ring was initially replaced by a custom two-frame walking-foot destination icon. Decision 108 supersedes only that presentation with the smaller owner-requested four-arrow convergence marker. Auto and Auto Skill icons retain the crisp Battle-of-Gods cyan/gold/navy action-icon language; the far-right Attack button displays its existing sword icon.

## Consequences

- Pointer-side attacks are immediately readable without turning passive pointer motion into facing authority.
- Auto combat is optional and visible, never a default or reward-bypassing system.
- Auto Skill can commit long-cooldown skills and therefore intentionally trades player optimization for convenience.
- UI/menu redesign and dead-code/asset removal remain separate audited work; no bulk deletion is authorized by this decision.
