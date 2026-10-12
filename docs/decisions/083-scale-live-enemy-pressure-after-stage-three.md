# Decision 083 - Scale Live Enemy Pressure After Stage Three

## Status

Accepted for the Stage 4 implementation.

## Context

King's four active skills include substantial area coverage, but a universal four-enemy ceiling makes that coverage feel unnecessary. The early stages still need enough visual space to teach movement, attack timing, and individual enemy tells.

## Decision

- Stages 1-3 retain a maximum of four active enemies.
- Stage 4 raises the authored maximum to eight active enemies and uses waves of 6, 8, 10, 12, and 14 total enemies so later waves reinforce continuously.
- Later stages may raise their own explicit authored ceilings instead of sharing one global cap. Stage 6 is reserved for a clear horde escalation, with its exact ceiling chosen only after Stage 4 performance and readability profiling.
- Enemy health will not be inflated merely to compensate for area damage.

## Consequences

Stage 4 gives area skills a real crowd-control purpose while keeping a finite performance and readability boundary. Every later increase requires encounter-specific testing of navigation, separation, spawn cadence, threat tells, hit feedback, and frame time.
