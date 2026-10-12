# Decision 031: Drive Positional Combat SFX from Authoritative Events

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

Combat needs stronger feel, but sounds must not drift from active attack frames or become responsible for applying damage. Current encounters use only a few simultaneous actors, so actor-local players are simpler than premature pooling.

## Alternatives Considered

1. Trigger gameplay from animation/audio callbacks.
2. Put every combat sound in the global music service.
3. Build a large pooled audio framework before measuring real voice counts.

## Decision

Create Music, SFX, and reserved UI buses. Actor-local `Node2D` presenters observe existing phase/state signals for action cues. Accepted hit sounds observe hit confirmation, and projectile impacts own their local cue. Audio remains presentation-only, with no combat authority.

## Consequences

- Swing and enemy attack cues stay aligned with authoritative active states.
- Positional sounds follow actors and impacts correctly.
- The current low enemy count does not require a global voice pool; profile and add one only if later hordes produce voice or allocation pressure.
- Headless tests verify configuration while intentionally skipping device playback.
