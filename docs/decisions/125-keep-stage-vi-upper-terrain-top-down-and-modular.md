# Decision 125: Keep Stage VI Upper Terrain Top-Down and Modular

- **Status:** Accepted
- **Date:** 2026-08-24
- **Supersedes:** Decision 124's distant canyon backdrop and monumental threshold presentation only

## Context

The approved Stage VI ground atlas already matches the game, but the generated
distant canyon and oval threshold changed the camera language into a side-view
landscape. Battle of Gods uses one top-down/slightly angled top-down world. The
upper edge must therefore read as reachable world terrain at another elevation,
not a horizon behind the arena.

## Decision

- Preserve the approved `elder_ascent_ground_atlas_4x4.png` TileSet and extend
  that authored ground continuously through the upper camera view.
- Remove the active canyon backdrop and oval root threshold. Keep rejected
  sources and runtime derivatives recoverable only in the ignored art archive.
- Build the upper boundary from transparent modular cliff straights, inner and
  outer corners, a ramp, rocky outcrop, boulder cluster, existing top-down
  ancient trees, and a four-frame waterfall.
- One explicit cliff collision strip owns traversability. Art alpha and visual
  overlap never decide movement.
- Waterfall animation is presentation-only and uses four stable frames at six
  frames per second. It does not own damage, travel, or progression.
- Do not add sky, horizon, distant mountains, scenic perspective, or a one-use
  painted background to a playable top-down stage.

## Consequences

- Stage VI now retains one camera perspective from the lower arena through the
  upper terrace.
- The cliff, rock, and waterfall assets can be recomposed in later maps.
- Decision 124 remains valid for establishing an environment-only Stage VI
  review before enemy production, but its backdrop/threshold art direction is
  no longer active.
- Encounters, production navigation, rewards, completion, save authority, and
  the Stage V campaign transition remain separate future work.
