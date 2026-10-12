# Decision 128: Separate Impact Feedback from Accumulating Stagger Breakout

- **Status:** Accepted
- **Date:** 2026-08-24

## Context

Accepted-hit presentation was already independent from enemy state: damage, white flash, sparks, numbers, audio, camera response, and bounded hitstop did not inherently stun an actor. Gameplay stagger, however, only multiplied an authored duration by a three-tier target profile. Any non-Boss enemy could repeatedly re-enter `STAGGER`, and Crag Bear was incorrectly configured as fully Light. The Hog protected its committed charge with a controller exception, but no reusable policy prevented strong ordinary enemies from being denied every action. Enemy attacks also carried knockback/stagger in `DamageInfo` while Player did not consume those fields.

The rebuilt Bramble Spitter introduced a separate presentation regression: its approved new body frames were rasterized near Hog/Bear dimensions. Permanent node scale would hide rather than correct that source-level mismatch.

## Alternatives

1. Reduce or remove normal-hit stagger globally.
2. Make Bear and Hog fully immune, lengthen global hitstop, and special-case player cancellation in each enemy.
3. Extend the existing data/component seam with target-owned response strength, accumulating interruption limits, temporary breakout, and Player composition; correct Spitter pixels in its processor.

## Decision

Choose Alternative 3.

- `DamageInfo.stagger_seconds` remains the sole request for gameplay interruption. `CombatFeedbackPresenter` remains presentation-only.
- `EnemyDefinition` adds a `HEAVY` control response at 20% knockback and 30% stagger duration, plus optional `stagger_interrupt_limit`, chain window, and resistance duration. Control response does not declare encounter rank.
- Light Thrall/Mireling/Rootling/Spitter profiles keep a zero limit and therefore remain freely interruptible. Armored Hog breaks the third consecutive stagger within 0.9 seconds into 0.8 seconds of resistance. Crag Bear remains a normal recurring mob but uses Heavy response and breaks the fourth into 1.05 seconds of resistance. Boss response remains fully immune.
- The threshold hit ends current stagger and starts resistance. Hits during resistance still apply health damage and every accepted-hit presentation effect; only gameplay stagger is rejected. After the window, the chain resets.
- Skill 1 and Skill 3 use their existing authored stagger values through the same resolver. Skill 3's 0.78-second base remains stronger than Skill 1 after Elite/Heavy scaling without lengthening global pause.
- Player composes the shared knockback/stagger observers. Player alone cancels vulnerable normal attacks/casts, clears buffered action, integrates knockback into movement, and gates input for recovery. Existing invulnerability prevents accepted damage; `AbilityDefinition.grants_super_armor` may preserve a cast while damage and presentation still resolve.
- Hog charge knockback/recovery and Bear basic/slam control values move into their immutable definitions instead of remaining controller literals.
- Bramble Spitter's approved identity and action poses remain unchanged. Its processor rasterizes locomotion around the original normal-mob silhouette and bounds attack extensions separately; the runtime node stays at native scale outside temporary spawn animation.

## Consequences

- Strong mobs can visibly absorb pressure and regain one actionable window without making player hits feel ignored.
- Future enemies tune response and breakout in data rather than duplicating counters or immunity branches in controllers.
- Super armor is now available as an explicit ability rule, but no current King skill is silently granted it by this decision.
- Exact thresholds and recovery comfort still require owner feel-testing in Stage VI; structural tests cannot judge frustration, perceived weight, or camera/audio mix.
