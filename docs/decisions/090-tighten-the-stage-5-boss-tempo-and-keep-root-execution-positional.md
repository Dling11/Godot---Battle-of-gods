# Decision 090: Tighten the Stage 5 Boss Tempo and Keep Root Execution Positional

- Status: Accepted
- Date: 2026-08-14

## Context

Owner playtesting found the isolated boss too slow while chasing and swinging. It also exposed a weak branch in the signature root execution: dash-avoiding capture or breaking the restraint could make the eventual eruption harmless even when King remained directly on its locked ground point.

## Decision

The boss proof moves at 58 pixels per second with 480 acceleration and a 9 fps walk cycle. Its lunge uses 0.62-second warning, 0.12-second contact, and 0.66-second recovery; its overhead slap uses 0.60/0.12/0.54 seconds. Damage, reach, alternating melee order, jump timing, and root warning duration remain unchanged.

The root warning still locks to the world and uses the same 34-pixel core. Capture and five-input restraint remain separate from execution safety: avoiding capture or breaking free permits movement, but the delayed 300 physical-damage eruption hits any player still inside that locked core. Leaving the marked ground before impact remains the miss condition. Decision 089's automatic escaped-execution miss clause is superseded by this positional check.

## Alternatives Considered

- Increasing melee damage instead of tempo would not correct the sluggish feel.
- Removing melee warnings entirely would make the large authored swings unreadable.
- Treating successful restraint escape as automatic eruption immunity would preserve the observed stand-still exploit.
- Expanding damage to the complete decorative execution column would make its real danger larger than the prison/ground core communicates.

## Consequences

The boss closes space and completes ordinary swings more aggressively while retaining visible warnings. Root counterplay becomes two-stage: avoid or break the restraint, then leave the locked ground core. The 300 hit remains provisional physical damage and can be balanced against future armor without becoming true damage.
