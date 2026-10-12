# Decision 096: Give Cooldown-Blocked Player Actions One Shared Denied Cue

## Status

Accepted — 2026-08-15

## Context

Dash and skill cooldowns were visually clear, but repeated input was silent. The owner requested the compact disabled-action response used by games such as Dota: a short cue on each deliberate attempt that communicates “understood, but not ready” without queuing the action.

Keyboard/controller requests already passed through `Player`, while disabled HUD countdown buttons prevented mouse and future touch attempts from reaching that same boundary.

## Decision

Emit one presentation-only `Player.action_denied(action)` signal when Dash or an equipped skill is requested with positive cooldown remaining. Preserve the existing false return and never place that request in the short action buffer. `PlayerActionSfx` observes the signal and plays Joth's real CC0 `Menu Error.mp3` selection through the SFX bus.

Keep cooldown controls visually grey with their live countdown but actionable, allowing mouse/touch to request and hear the same denial. Keep sealed and unavailable controls disabled. Root-prison Dash struggles continue to take priority over cooldown denial.

## Consequences

- Every supported input method receives consistent cooldown feedback.
- Individual abilities need no rejection audio or special input code.
- Cooldown timing, buffering, targeting, damage, and restraint authority remain unchanged.
