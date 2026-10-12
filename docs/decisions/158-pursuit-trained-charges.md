# 158 - Train Sovereign Pursuit's range and stored uses with Eira

Date: 2026-09-27. Status: implemented; combat feel and mobile performance pending.

## Context

Sovereign Pursuit had one 220px cast followed by an 8.5-second cooldown. The owner wants it to remain a targeted mobility skill, ultimately usable three times, with greater reach. The owner also wants skill upgrades and level requirements to give the Skillkeeper a meaningful role. The existing level cap reaches 5 after Stage II and opens Level 8 after Stage V.

## Alternatives

- Automatically grant charges on level-up: less interaction with Eira and no deliberate training decision.
- Unlock charges through future stage flags: third use would be unreachable in the present six-stage campaign.
- Make three automatic strikes from one input: removes the separately aimed mobility that defines Pursuit.

## Decision

Foundation has one 220px use. Eira manually trains Advanced at Level 5 for two 250px uses and Mature at Level 8 for three 280px uses. Each accepted cast spends one use. Uses refill sequentially every 8.5 seconds; a later cast does not restart the active refill. Current landing damage, radius, collision-safe movement, short commitment, travel-only invulnerability, audio and frame identity remain unchanged. Repeated Pursuits refresh the existing Skill-2 link rather than stacking it.

`SovereignPursuitComponent` owns stock and refill timing through the existing ability cooldown clock. `SovereignPursuitDefinition` owns rank capacity and range. `KingSkillLibrary` gates Eira training and saves only the rank in `RunSession`; the current stock begins full on player-scene entry. Old version-1 profiles without the optional rank field restore Foundation. `SkillBarSlot` shows stock and next-use refill. F7 previews all ranks session-only; F9 fills stock during non-saving debug play.

## Consequences

King can choose mobility routes and burst three separately aimed landings after training, with no increase to sustained recharge throughput. Level requirements use the already implemented stage cap and do not create a new skill-point or coin economy. Final combat balance, Eira/HUD feel and representative-phone performance still need owner review. Skill 4 remains Worldsplitter in production; its redesign is a separate proposal.
