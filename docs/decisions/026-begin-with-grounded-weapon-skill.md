# Decision 026 - Begin With a Grounded Weapon Skill

- **Date:** 2026-07-13
- **Status:** Accepted for the combat prototype

## Context

The prototype needs to validate a reusable ability framework and compact skill HUD. Giving the weak early-stage character divine power immediately would undermine progression tone and make later supernatural unlocks feel less meaningful.

## Alternatives Considered

- Start with an area-damage divine shockwave.
- Delay the entire ability framework until narrative progression exists.
- Add a second normal attack without treating it as a reusable skill.

## Decision

The first Q skill is `Sweeping Cut`, a mundane sword technique with a wider frontal arc, 20 prototype damage, visible spacing pushback, vulnerable cast timing, and a short prototype cooldown. It uses the same reusable ability data/runtime contracts intended for later weapon, divine, and demonic skills.

Divine and demonic abilities remain unavailable at the beginning and should be introduced through approved story or progression milestones.

## Consequences

- The early player remains intentionally inexperienced and grounded.
- The first skill adds crowd management without replacing the 25-damage normal sword attack.
- Ability authority, cooldown UI, multi-target hit delivery, and pushback can be validated before supernatural content is designed.
- Current values and arc presentation remain feel-test tuning, not final balance or art.
