# 145 — King ten equipped skills direction

Date: 2026-09-13. Status: accepted product direction; not implemented.

## Context

The owner explicitly clarified that King should equip ten skills simultaneously, using 1–9 and 0. Minus/plus may also be considered. The previous assumption of four equipped skills chosen from a larger collection no longer describes the desired final control budget.

## Decision

Plan for ten configurable, simultaneously equipped skills, separate from basic attack and Space Dash. Keep the collection extensible beyond ten learned choices. Grant abilities gradually; empty future slots do not imply free unlocks. Optional extra keys are not a commitment to twelve slots.

Broaden King beyond swordsmanship into earned domain powers, ranged spells, defensive tools and readable status interactions. The owner proposed major-boss/god rewards as a possible source. Exact skill names, reward locations, gods, statuses and balance remain proposals in [the ten-skill design](../design/king-ten-skill-domain-powers.md).

Maintain the earlier request to propose stronger concepts before implementation. This decision does not approve the current working names or authorize treating the proposed status framework as already present.

## Alternatives

Four equipped slots from an eight-to-ten-skill collection was explicitly rejected by the clarification. Immediately adding twelve actions goes beyond the confirmed ten. Making every new action a sword AOE would fail the requested broader power identity.

## Consequences

This supersedes the four-equipped-slot end-state in Decisions 143–144 and the earlier responsive-kit proposal. Their implemented four-slot behavior remains runtime truth until migrated. Input, HUD, controller access, save validation/migration and collection logic need coordinated work. Old saves must retain their selected skills without granting unearned powers.

Examiner remains the required Stage XX false mentor; Stage X does not become a true-god encounter merely because it may reward a domain skill. The current campaign ends at VI, and production milestone rewards beyond it remain unimplemented.
