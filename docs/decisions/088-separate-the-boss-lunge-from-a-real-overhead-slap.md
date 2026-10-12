# Decision 088: Separate the Boss Lunge from a Real Overhead Slap

- Status: Accepted
- Date: 2026-08-14

## Context

The first Stage 5 boss melee was described as a sweep, but its approved frames show a direct forward root-arm extension. In motion the whole boss appeared to lean forward, so the label implied an arc and impact language the art did not contain. The owner also requested a clearly readable slap in addition to that attack.

## Decision

Keep the existing authored motion as a quick physical root-arm lunge and name its runtime states accordingly. Add a separate heavy overhead root-hand slap with eight chronological frames in every cardinal direction, its own hitbox and timing, 42 provisional damage, deliberate recovery, and a smaller camera kick than the jump landing. Alternate lunge and slap deterministically so both remain visible in a short feel-test. Keep the jump as a separate special action.

## Alternatives Considered

- Calling the existing attack a sweep and changing only its damage would preserve the readability mismatch.
- Replacing the existing sheet would discard usable authored frames and erase a distinct quick-melee role.
- Treating the forward motion as a root summon would contradict the body animation and duplicate Rootbound Husk's weaker presentation problem.

## Consequences

The boss now has three visually and mechanically distinct actions in the proof: quick lunge, heavy overhead slap, and target-locked jump. The visual observer exposes 56 directional animation ranges, while controller-owned states and hitboxes remain authoritative. Damage, cadence, audio, encounter integration, and final boss balance remain provisional.
