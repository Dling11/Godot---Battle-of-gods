# Decision 030: Keep Combat Impact Feedback Presentation-Only and Time-Scale-Free

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The early sword and Sweeping Cut need stronger confirmation when they connect. Full hit stop can feel satisfying, but changing the global simulation clock would alter dodge windows, enemy telegraphs, timers, and future networking assumptions.

## Alternatives Considered

1. Leave combat without impact confirmation.
2. Freeze the entire game briefly after every hit.
3. Put damage-number spawning directly inside health or hitbox authority.

## Decision

Use a level-owned `CombatFeedbackPresenter` that observes accepted hits and damage. It creates short-lived world-space numbers and pixel bursts and applies a sub-0.12-second camera-offset nudge. It does not alter global time scale or authoritative combat state.

## Consequences

- Hits are easier to read while dashes, projectile markers, and attack recovery remain temporally consistent.
- Misses and invulnerability blocks produce no false damage feedback.
- Future hit sounds, accessibility options, and stronger boss-specific presentation can subscribe at this boundary without modifying health, hitboxes, or enemy controllers.
