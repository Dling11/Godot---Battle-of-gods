# 086 - Prove the Stage 5 boss in an isolated playable arena

## Status

Accepted on 2026-08-14 as a provisional combat proof.

## Context

Review sheets alone do not let the owner judge the boss's true scale, momentum, positioning, warning readability, or interaction with King's complete kit. Integrating an unfinished boss directly into Stage 5 would prematurely couple feel iteration to an unbuilt environment, reward loop, and progression contract.

## Alternatives

- Continue approving isolated sheets without gameplay context.
- Build the complete Stage 5 encounter before testing the boss.
- Install the current art and two representative attacks in a directly accessible isolated arena.

## Decision

Use the isolated arena. The boss receives a provisional data definition, controller-owned root-arm sweep, and target-locked jump. The actor root owns travel; animation observes state only. A separate visible marker communicates the committed landing point, one radial hitbox owns contact, and the impact/crater belongs to the world so it cannot follow the actor. F8 enters the proof from Sanctuary and returns from it.

## Consequences

- The owner can now judge scale, animation flow, positioning, dodge timing, and skill interaction directly.
- Focused tests can protect animation ranges, attack phases, target locking, one-hit landing authority, and world-owned residue.
- The proof's name, values, arena, and two-action kit are intentionally provisional.
- Stage 5 content, audio, phases, dialogue, rewards, and progression remain separate work.
