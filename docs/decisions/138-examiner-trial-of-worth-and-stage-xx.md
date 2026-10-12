# Decision 138: Examiner Trial of Worth and Stage XX False Mentor

## Status

Combat seal/sanctuary/phase rules below are superseded by Decision 139. The Stage XX false-mentor story and advancing-combo direction remain current.

Owner-authorized and implemented in the rewardless F7 proof, 2026-09-12. Production Stage XX scenario integration and final gear balance remain pending. Supersedes the Stage VII optional encounter and Stage XX direct One Above placement in Decisions 131/133, and the freely available cover/260 damage lesson in Decision 135. Decision 137's corrected body identity is owner-approved.

## Context and alternatives

Owner playtesting found that walking backward escaped the stationary melee sequence and that 3.8 seconds to enter any of four wards made the signature jump trivial. Increasing damage alone would preserve that strategy. Removing all counterplay would make failure unexplained. The chosen design asks players to engage under pressure and earn safety, while keeping ordinary attacks readable and committed.

## Decision

- Opening thrust advances physically by up to 38px during its active frames. After its gap, a target behind the committed direction earns recovery; a target beyond 92px triggers Reprisal; a nearby target receives a sweep or, on alternating close exchanges in phase two, Held Judgment.
- Reprisal snapshots its lane for a 0.48s warning, travels up to 260px in 0.26s with collision, and exposes 0.78s recovery. Held Judgment raises the existing overhead anticipation in 0.38s, holds it, and strikes at 1.05s. Contact remains controller-owned.
- First Trial of Worth starts at 70% HP after short dialogue; a second begins on an accepted combat hit at/below 35% HP after phase two. King is unlocked during the trial and Examiner is damageable.
- Deal 240 accepted, armor-mitigated damage to Examiner within 7 seconds. A numeric damage/time meter reports progress. Alternating horizontal/vertical 210x26 capsule lanes snapshot King's position, warn for 0.85s, and deal 46 raw damage. The first warning arrives after 1s, then every 1.5s. Trial completion cancels outstanding cuts.
- Success activates exactly one of the four authored 54px sanctuary zones: the nearest to King when the seal breaks. The choice never moves afterward. Failure activates none. Both paths show preparation, complete launch, 2.8s escape countdown, and physical landing.
- Exposed Verdict deals 800 raw damage through temporary action invulnerability, retaining armor/ward mitigation. Earned sanctuary blocks it completely. Explicit lab immunity remains separate and absolute. This is finite damage, not forced death or a gear-stage check.
- Prototype ordinary damage: thrust 60, sweep 72, charge/Reprisal 82, slam/Held Judgment 110, Refutation 40, Axiom 90. Movement is 90px/s (phase two adds the existing 12%); charge cooldown is 3.8s. HP remains 1800. These are F7 tuning values; unimplemented late equipment cannot yet establish final survival thresholds.

## Story direction

Examiner is the required Stage XX scenario boss and an apparent severe teacher: a false mentor who helps sustain the gods' manipulation. They promise that Stage 100 can save/reunite King with his family. The family is actually dead. Preserved souls, resurrection, replicas, any gifted power, and the final ending are open, not confirmed facts. The One Above's direct encounter is unscheduled. Stage VII content needs a separate plan.

The F7 phase lines are: `You seek the hundredth gate. You are not ready.` / `Break my seal. Earn your sanctuary.` They teach the mechanic without revealing the lie. No power reward or production story outcome is implemented by these lines.

## Ownership and consequences

`ExaminerTrial` owns accepted-damage progress, timed cuts, timeout, and cleanup. Examiner owns body state, phase checks, branching and physical movement; Court owns active ward geometry, shader flags and Verdict resolution. Director owns camera/dialogue/music and releases King before the trial. Art/HUD/audio observe these owners.

Approved raster body and effect assets are reused. New states reference real charge/guard/overhead frames; no procedural replacement body is introduced. Lab announcements sit below the boss panel. `DamageInfo.ignores_invulnerability` defaults false, and `HealthComponent.is_damage_immune` separates lab immunity from dodge/ability signals.

Focused checks cover real accepted damage, conditional follow-ups, commitment, physical advancement, sanctuary boundaries, timeout/reset cleanup, ordinary mitigation, Verdict action-i-frame bypass and lab immunity. GPU captures exercise both trial outcomes with scripted fixtures; they are not an autonomous playthrough or final balance validation.

## Verification evidence

`tests/examiner_worth_smoke.gd` reproduces straight retreat at 120px/s with real hitboxes: 82 accepted damage, versus zero for a sidestep at the Reprisal warning. It also checks the actual 35% repeat trigger, distinct held anticipation, damage-meter accounting, one-ward bounds, 400 accepted damage from 800 raw at 100 armor through dodge, and reset cleanup. The seven related Examiner/lab/evade/armor/archive checks pass; the older armor fixture emits exit cleanup warnings. The GPU capture and validation record are under `art_source/review/characters/disciples/examiner/worth_2026_09_12/`.
