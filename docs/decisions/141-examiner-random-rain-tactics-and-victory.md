# 141 - Examiner randomized rain, tactics and victory

## Status

Implemented in the rewardless F7 proof, 2026-09-12. Owner playtesting remains necessary. Supersedes Decision 140's fixed rain layout; approved body art and charge presentation remain intact.

## Context

The owner accepted the living charge and Unbound phase, requested many randomly falling red Suns, and approved improving attack sequencing, reactions and encounter closure. A fixed safe column allowed passive avoidance; fixed move priority reduced variety.

## Decision

- Crimson Firmament retains the berserk gate and 180-point seal over 3.8 seconds. Failure produces eight waves of three meteors, spaced 0.62 seconds apart. Each meteor warns for 0.90 seconds and resolves once inside its shared 48px radius. Damage remains 100 raw before the existing Unbound multiplier.
- Each wave snapshots King's current position once and scatters two further impacts, respecting same-wave separation and a nearby opening. A live RNG varies casts; optional seed injection supports tests. Escape selection considers unresolved older warnings. No fixed sanctuary or permanent safe column exists.
- A composed tactics helper chooses only legal range/phase/cooldown actions. When alternatives exist it excludes the immediately previous action and downweights other recent actions. The actor still owns state, movement, timing and contact.
- Selected odd-numbered Axiom recoveries in phase two can trigger an advancing Reprisal against a frontal target 92-320px away. It receives a new full warning and commits its endpoint; behind positioning remains a punish opportunity.
- Breaks increment session counters and change Examiner's short remarks. A real lethal hit immediately clears trial, lane and projectile authority, then plays approved kneel/recovery poses and a skippable conversation. Completion emits once, restores King's input and withdraws Examiner.
- Dialogue reinforces the false mentor's encouragement without revealing the dead-family truth. No blessing, stat reward, permanent story flag or production Stage XX route is added.

## Alternatives

Increasing meteor counts in the old rows would preserve the solved safe column. Unrestricted random overlap risks unavoidable damage. Hidden tracking would undermine the visible warning. A larger damage multiplier alone would not improve decision-making.

## Consequences and validation

Eight waves create repeated movement decisions, with at most six unresolved warnings under normal scheduling. A local opening is a readability constraint, not a guarantee that every chosen movement route is safe. Thirty reproducible center/corner simulations compare stationary targets with 120px/s movement; actual player feel and final equipment survival still require playtesting. Outcome checks cover lethal damage, hazard cleanup, skip/completion and reset during the kneel. Presentation remains separate from future save/reward authority.
