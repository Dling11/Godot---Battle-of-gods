# Decision 140: Living Sun charge and Crimson Firmament

## Status and context

Owner-authorized on 2026-09-12. The owner likes Unbound/Crownfall and the approved character identity, but found Borrowed Sun's four held charge frames static and its flight too easy to escape. Extend that accepted foundation, preserving the seal/stun rules and readable counterplay. Supersedes Decision 139's Sun presentation, flight, release and radii only; Stage XX integration and final gear balance remain pending.

## Decision

- Borrowed Sun now uses a generated sixteen-frame churning core at 18 fps, continuous growth, accelerating pulses, counter-rotating seals, inward particles and textured filaments. The same core animates in flight. The approved body braces around its foot origin with a small rotation, then uses its original release pose. No body texture, frame crop, scale or identity is replaced.
- Release takes 0.24 seconds; flight takes 0.72 normally or 0.62 in Unbound. The target snapshots at release, including at most 28px of movement lead (0.18 seconds of velocity), and never homes afterward. The fixed ground warning begins during the throwing stance. Impact radii become 84/116px. Damage remains 155/255.75 raw, and normal dodge/armor still apply. Accelerating flight, textured wakes and original accelerating charge pulses provide momentum without changing collision through presentation.
- Unbound retains the 35% threshold, 106px/s speed, 1.65x ordinary damage and existing three-Sun Crownfall. A persistent restrained crimson/gold flame aura and rising embers mark the phase. The aura softens while guard-broken so the punish window remains distinct.
- Add **Crimson Firmament**, available only in Unbound. A 180-point seal protects a 3.8-second charge. Breaking it cancels the attack and grants the existing 2.6-second stun; failure releases twelve crimson meteors in four waves of three. Waves are 0.95 seconds apart, each with a fixed 0.85-second warning. Meteors use 58px radii and 165 raw damage after the phase multiplier.
- The barrage uses a four-by-four arena grid and omits one full column for that cast. The clear column rotates on successive completed charges. Each wave sweeps one row from north to south; its points never follow the player. At least a 64px-wide corridor is geometrically safe for the full barrage. Only three new hazards warn at once under normal fixed physics cadence, and each impact damages once. Old impacts decay visually for 0.85 seconds.
- Firmament first becomes ready six seconds into berserk and then uses a 19-second cooldown from charge start. It commits the boss through the final impact plus recovery, instead of combining the barrage with unrelated melee. It alternates with the rest of the existing kit through ordinary cooldown selection.

## Ownership, alternatives and consequences

`ExaminerFirmament` owns wave scheduling and fixed points; all individual meteors reuse `ExaminerSun` damage/lifetime/cleanup. `ExaminerEnergyPresentation` owns only procedural composition of approved raster effects. The new sixteen-frame atlas and three original synthesized cues have reproducible tools and source provenance. Simultaneous red contacts share a camera-pulse budget and attenuated audio to avoid stacking three full-strength feedback events.

Rejected invisible attacks, homing after commitment, and filling every part of the arena. The player can interrupt the cast, find its clear column, cross a spent row, or dodge a warned impact. Exact difficulty still needs owner playtesting with a defined Stage XX loadout; debug invincibility is not evidence of survivability.

Focused checks cover berserk gating, guard success/failure, twelve committed meteors, clear-corridor geometry, normal dodge, bounded aim prediction, faster fixed flight, pause and death cleanup. A rendered review checks continuous buildup, brighter aura and readable red waves. Approved body PNGs are hash-verified unchanged.

## Follow-up

Decision 141 supersedes the fixed twelve-meteor layout and clear-column escape rule with eight randomized waves. Its tactics and victory preview extend this accepted charge/aura presentation.
