# Decision 104: Refine Numbered Click Combat and Footprint Auras

- **Status:** Accepted; numbered/click mapping superseded by Decision 105, aura/HUD direction retained
- **Date:** 2026-08-15

## Context

The first assisted-combat pass over-committed Basic Attack by acquiring or pursuing enemies the player had not deliberately engaged. Its large red underfoot target ring also confused selection with the requested always-visible actor footprint, and the bottom-right roster competed with the action tray.

## Decision

The numbered action order is `1` Attack followed by Skills `2`-`5`. Attack swings freely when no target is selected or the selected target is farther than the 260-pixel assist radius. A single enemy click selects without attacking; Godot double-click or two clicks on the same enemy within 420 milliseconds explicitly enables approach-and-repeat auto attack. Clicking open ground clears target/auto attack and begins click movement. A roster-card click remains an explicit engage action. Automated movement faces along its current navigation steering direction rather than toward a stale pointer or direct line through an obstacle.

Selection uses only a small animated chevron above the enemy. Every player and enemy scene owns a subtle presentation-only oval footprint aura sized from its movement footprint; Elite and Boss tiers receive incrementally richer broken-arc motion. These visuals do not replace physics hurtboxes, movement collision, or damage authority.

The selected-target card remains in the top-left status rail. The live enemy roster moves beneath the top-right Menu button and becomes taller, narrower, and scrollable through a slim translucent scrollbar.

## Consequences

- Manual air swings remain available and Basic Attack no longer selects a nearby enemy automatically.
- Explicit double-click/card engagement can still pursue a distant target, while manual WASD continues to override assisted movement.
- Decision 103's red target circle, nearest-target Attack acquisition, bottom-right roster placement, and `BASIC ATTACK` label are superseded.
- Footprint aura animation is presentation-only and may be visually tuned after owner playtesting without changing combat authority.
