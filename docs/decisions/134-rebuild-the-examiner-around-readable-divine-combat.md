# Decision 134: Rebuild the Examiner Around Readable Divine Combat

## Status

Accepted and implemented in the debug F7 proof — 2026-08-25. Production Stage VII balance and story integration remain pending owner feel-testing.

## Context

The first compact Examiner proof moved correctly and exposed the intended techniques, but its body often appeared to hold a pose while damage and lane presentation did the expressive work. That made successful attacks difficult to identify and weakened the intended contrast between calm observation and sudden divine violence.

## Decision

- Physical `AnimatedSprite2D` motion is the first authority for attack readability. Fresh frames replace weak thrust, sweep, charge, and slam poses rather than hiding them with VFX.
- The close sequence is Precision Thrust followed by a separately warned Divine Sweep.
- Zero Interval is superseded by Judgment Charge: one unique aiming/compression pose, an accurate red rectangular travel warning, explosive straight travel, afterimages, contact response, and a punishable recovery.
- Ground Judgment is the dedicated major radial slam. Its red ring matches the 72-pixel hitbox and damage begins only on the planted contact pose.
- A charge-zone slow is deliberately omitted until owner testing proves the accurate visual warning alone insufficient. Dodge and movement counterplay remain authoritative.
- Directional trails explain weapon movement: a narrow thrust streak, curved sweep trail, and straight charge streak. Major ground response and camera pulse are reserved for the slam/charge impact.
- A reusable `DivineThreatAura` supplies restrained white-gold ground language independently of collision. Examiner-specific motes and increased skill buildup remain presentation-only.
- Original deterministic audio cues synchronize with state/contact signals. Presentation cannot decide damage, movement, story outcome, or progression.
- Compact adaptation uses existing facts instead of a large behavior tree: distance selects charge, a completed close exchange permits the slam, and repeated accepted player hits ready Refutation sooner without interrupting actions or bypassing cooldowns.

## Consequences

- The fight can be read with most effects disabled, while enabled trails/audio/ground response reinforce rather than invent motion.
- Difficulty increases through attack variety, timing, resistance, and pressure rather than extra HP.
- Future Disciples and divine bosses may reuse the threat-aura component and signal-driven presentation boundary.
- Decision 135 now adds a debug-proven phase transition and short spoiler-safe dialogue. Production Stage VII outcomes, rewards, saves, replay rules, and final balance remain non-canonical/open.
