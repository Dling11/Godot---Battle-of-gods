# Decision 105: Use Contextual Right Click and Restore Skill Keys

- **Status:** Accepted; left-click attack and right-click preview cancellation refined by Decision 106
- **Date:** 2026-08-16

## Context

Putting Basic Attack on `1` made ordinary combat feel like keyboard spam and displaced the memorable Skill `1`-`4` layout. Separate left-click selection, double-click engagement, and ground movement also created more mouse states than this compact action game needs.

## Decision

Right click is the contextual world command: clicking traversable ground clears combat and pathfinds there; clicking an enemy selects it and immediately begins navigation-aware repeated basic attacks. The four equipped skills return to keys `1`-`4`. Basic Attack has no number key; the unnumbered HUD Attack control and controller right trigger remain manual fallbacks.

Targeted skill previews remain modal. Left click or controller confirmation commits them, `Esc` is their only cancellation input, and right click is consumed without moving or cancelling until the player exits the preview. This avoids one click being interpreted as both a world command and a skill command.

## Consequences

- Common movement and engagement use one context-sensitive mouse button without requiring double-click timing.
- Skill memory returns to the conventional `1`-`4` order and Basic Attack no longer encourages number-key spam.
- A player who wants to abandon a targeted skill must press `Esc` before issuing a right-click world command.
- Decisions 103-104 remain authoritative for stagger, HUD placement, markers, auras, and navigation-facing, but their left-click/double-click and `1` Attack mappings are superseded.
