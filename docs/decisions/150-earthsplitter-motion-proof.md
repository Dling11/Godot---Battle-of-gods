# 150 - Earthsplitter motion proof

Status: implemented as an opt-in Lab Foundation proof, September 14, 2026. Owner subsequently approved the sword animation. Decision 151 supersedes the ground stamps and endpoint marker described below; production replacement remains pending. The remainder records the original proof.

## Decision

The owner approved a quick separately summoned sword: King performs an action, the sword appears into a weighted overhead swing, and its ground contact sends an earth rupture toward the aim. Skill 2 retains its separately approved local molten crash concept. The V3 board's enlarged held blade was explicitly corrected.

Implement Skill 1 first through a reversible Lab adapter. Keep the accepted compact C body and use its eight heavy-cleave poses at the new short phase durations. A sixteen-drawing sword sheet and sixteen-drawing rupture sheet supply the separate weapon and traveling earth. Left casts mirror the sword instead of rotating it upside down; vertical casts preserve screen-up overhead motion. Ground travel retains exact aim independently.

## Ownership

The Lab adapter swaps Ability1Component's script to an EchoingSeverComponent-compatible subclass, retaining the existing Player/signal identity and session-only legacy slot ID. A new per-player definition configures a 164px target range, 17px lane half-width, contact up to 34px ahead, .20/.04/.12-second phases, .25-second released travel, 165% weapon damage, .10s flinch, 45px/s knockback and zero stun. Five-second cooldown; dash cancellation retained. No invulnerability.

Player still handles input, target confirmation, facing, constraints and equipment-derived weapon/critical data. Existing mastery amplification reaches the committed snapshot. Current attack-speed gear affects basic attacks and movement gear affects movement; this proof does not invent cast-speed scaling.

A released GroundAttack snapshots damage, origin and endpoint. Swept capsule queries find hurtboxes along the advancing front; MeleeHitbox supplies its existing damage roll, per-target deduplication and accepted-hit signal. Radius-wide terrain sweeps stop it at obstacles, including initial overlap. Normal Area monitoring is disabled to avoid a stale second hit path. Presentation consumes committed contact/front events and never decides damage.

The visual anchors its sword tip at contact, sequences ground stamps behind the advancing front and clears after debris settles. Player movement returns after .36s of unpaused simulation; existing accepted-hit pauses can add wall-clock time. A small ground-contact camera pulse uses the shared presenter. Existing cleave and ground-slam audio are reused, with restrained gain/pitch; no new downloaded sound or audition claim.

The adapter restores script, definition, signal connections and loadout; switching off or defeat clears released authority and visuals. Campaign assets, saves, old skill availability and skill upgrades remain unchanged.

## Alternatives and limits

A vertically dropped sword was rejected for Skill 1; a clean crescent projectile was rejected in favor of earth splitting. Enlarging King's held blade was also rejected. This proof demonstrates a separate summon using existing body poses, not newly generated character animation.

Foundation emits several decorative ground stamps, but each enemy receives one 165% contact per cast. Stamps are not upgraded damage pulses. Upgrade forms, stage unlocks, new Skill 2 runtime, permanent collection identity and old-skill removal remain pending under the production plan. The Lab target marker currently uses the shared endpoint circle/guide, not a new lane-shaped preview. The illustrative rubble is not destructible terrain.

## Validation

Five test scripts passed: Earthsplitter review (49 assertions), Spellward preview (232), targeted Riftbreak review (28), King greatsword mastery (385) and original Echoing Sever smoke. Coverage includes no early hit, one hit/damage budget per target, no stun, range, all cardinal requests, wall blocking, post-release movement independence, equipment speed bounds, cancellation, defeat cleanup, review restoration and saved-loadout preservation.

Rendered the actual Lab through Godot Movie Maker. Reviewed summon/contact/rupture captures in all four directions and a real three-target damage pass; corrected the left/up orientation after the first capture. Real-time video, slow review and GIF live in art_source/review/characters/king/earthsplitter_2026_09_14/.

