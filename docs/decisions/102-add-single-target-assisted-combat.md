# Decision 102: Add Single-Target Assisted Combat

- **Status:** Accepted and implemented; feel tuning pending
- **Date:** 2026-08-15

## Context

New-player testing found that continuous WASD, facing, repeated left-click attacks, dodge, and four skills created unnecessary control load. Removing direct movement or turning every nearby enemy into an implicit target would reduce player authority and become ambiguous in Stage 4 crowds. Treating stronger hitstop as attack interruption would also let rapid attacks disable enemies indefinitely.

## Alternatives Considered

1. Retain manual-only combat and simplify only the HUD.
2. Automatically attack whichever enemy is nearest without an explicit selection.
3. Add one explicit assisted-combat target while retaining direct controls and keeping hitstop separate from stagger.

## Decision

Choose option 3. Clicking an enemy hurtbox selects exactly one target and replaces any prior target. King faces it, follows a navigation path while outside signature-sword reach, and repeats normal attacks only from legal idle boundaries. Held WASD supplies higher-priority movement intent; dash, skills, restraints, targeting previews, defeat, and existing action recovery retain their authority. Right-click clears the selected target.

The HUD presents the target's name and health and adds a dedicated `ATTACK / AUTO` control. With a current target, that control enables or resumes assistance; without one, it acquires the nearest living enemy within 260 pixels, or performs one manual attack when no candidate exists. A world-space gold marker makes the one authoritative target unambiguous.

Basic attacks receive damage-scaled presentation hitstop from 0.024 to 0.034 seconds. This does not enter an enemy stagger state or cancel its action. `DamageInfo.stagger_seconds` and the existing Light/Elite/Boss control tiers remain the only interruption path, so Armored Hog charge and boss actions cannot be permanently canceled by auto-attacks.

## Consequences

- Keyboard and controller movement remain fully usable; assistance is additive and may be ignored.
- Small enemies use a forgiving eight-pixel click radius, with nearest-to-click resolution in crowds.
- Selection state is session-local combat authority and is never saved.
- Target UI and marker observe `PlayerCombatTargetingComponent`; neither owns damage, navigation motion, or attack timing.
- Manual feel testing must verify pursuit around every authored obstacle and the 260-pixel Attack-button assist radius at 960x540.
