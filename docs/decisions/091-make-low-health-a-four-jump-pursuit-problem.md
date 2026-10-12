# Decision 091: Scale Repeatable Jump Pursuits with Boss Health

## Status

Accepted — 2026-08-14

## Context

The isolated Stage 5 boss already had a readable target-locked jump, but repeating the same timing and target could be solved with one memorized dodge rhythm. The owner wants low-health jumping faster, more complicated, and threatening without becoming an untelegraphed homing hit.

## Alternatives

- Repeat the ordinary jump three or four times without cooldown.
- Continuously move the landing marker with King until contact.
- Add a separate phase-two body/VFX package before encounter approval.
- Reuse the approved jump art while changing target selection, timing, and escalation.

## Decision

`Stage5Boss` selects a deterministic chain count from current health whenever a jump becomes legal. Exact 80-100% health uses one ordinary jump. Below 80% alternates two then three jumps. Exact 30% or lower cycles three, four, then five rapid jumps. Crossing 30% queues the first low-health chain at the next legal chase boundary; later chains are repeatable rather than one-use.

Every jump commits its own marker before takeoff. Intermediate jumps use King's current position, movement lead, perpendicular cutoff, and—when a fifth jump exists—an opposite-side cutoff. The final jump always returns to a current-position lock. Mid-health finishers use a 1.10x footprint/1.08x impact and 120% ordinary jump damage. Low-health finishers use 1.22x/1.18x and 150% damage.

Only the final recovery arms prison. Prison recovery starts a tier-specific 4.6/3.8/2.6-second jump reuse cooldown, while low health requires one intervening melee and higher tiers require two. Low health retains faster root warning/tracking.

Continuous post-marker homing is rejected. A shown warning is authoritative and fixed, so every landing remains dodgeable even when the next jump uses a different prediction rule.

## Consequences

- The player can learn the escalating count cycle while still changing escape direction and timing.
- Controller authority remains separate from visual pulse, impact scaling, and camera shake.
- Existing jump and impact art stays active; no generated frames are discarded or replaced.
- Exact thresholds, cooldowns, timings, multipliers, and target offsets remain provisional feel-test values.
- Decision 092 subsequently implements the separate reusable top-screen boss health presentation.
