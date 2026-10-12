# Decision 050: Use authored multi-strike data and a debug-only test loadout for Consecutive Thrust

- **Status:** Accepted
- **Date:** 2026-07-18

## Context

Opaw's second Warrior skill needs repeated directional contacts, distinct final-hit feedback, weapon-grade scaling, and a way to test it before Eira's normal free-awakening flow exists. The former generated board embedded a mismatched character and was rejected.

## Alternatives

1. Duplicate a unique ability script and animation for every strike pattern.
2. Add the unfinished skill to the normal progression loadout before its awakening rules exist.
3. Extend immutable ability data with strike multipliers, use an approved-Opaw action sheet plus effect-only VFX, and swap a separate test loadout only through debug F9.

## Decision

Choose option 3. `AbilityDefinition` declares per-strike damage multipliers and a non-final knockback multiplier. `AbilityComponent` owns timed hitbox reactivation and emits strike observation signals; all hit detection and damage remain component-owned. Consecutive Thrust is slot 2 only in `opaw_debug_test_loadout.tres`, while normal progression remains Piercing Rush only until Eira's free awakening is authored.

## Consequences

- Seven contacts scale from the equipped weapon without duplicating the ability for Ashwood and Iron. The current rapid-flurry balance is 18/19/20/21/22/25/100% (225% total), with a shared 128x26 tapered forward lane, no non-final pushback, a 150 final push, refreshed 0.21 small-hit stagger, and 0.42 final stagger. Enemy control resistance is governed by Decision 051 rather than the ability itself.
- Body, weapon, VFX, HUD, audio, and hit feedback observe cast/strike signals and do not calculate damage.
- F9 exposes all currently authored Warrior skills (Piercing Rush and Consecutive Thrust) and grants current compatible Warrior weapons for comparison, but does not pretend that slots 3-4, normal awakening, or normal purchases are finished.
- Future repeated techniques can reuse the same data contract, subject to dedicated balance and visual review.
