# Decision 035: Make the Title Screen the Explicit Journey Entry

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The project previously launched directly into Stage 1. The planned Sanctuary structure needs a stable front door for new journeys, settings, future profile selection, and later hub routing without embedding those concerns in a combat level.

## Alternatives Considered

- Keep launching Stage 1 and add a temporary pause-style overlay.
- Implement the full Sanctuary and profile-save system before creating a title screen.
- Add a focused title shell now and route its Start action through existing services.

## Decision

`title_screen.tscn` is the project main scene. It owns menu focus, session-audio controls, and user intent only. Beginning a journey resets `RunSession` and delegates scene replacement to `SceneTransition`; the title does not load or instantiate gameplay itself. The configured destination is now Sanctuary.

The background is a separate layered scene with `Base`, `DistantSilhouette`, `Atmosphere`, and `Vignette` owners. Its 960x540 base image contains no logo, buttons, or navigation logic and can be replaced independently.

## Consequences

- F5 now opens a coherent game entry instead of immediately starting combat.
- Future Sanctuary, profile, continue, accessibility, and settings work has a stable navigation owner.
- Audio toggles are intentionally session-only until settings persistence is designed.
- Replacing the title background cannot change button paths, focus order, audio routing, or transition behavior.
