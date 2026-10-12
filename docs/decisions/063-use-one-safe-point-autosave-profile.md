# Decision 063: Use One Safe-Point Autosave Profile

- **Status:** Accepted and implemented
- **Date:** 2026-07-29

## Context

The Forest loot/crafting loop requires progress to survive application restarts before repeatable materials are introduced. The existing state authorities already expose versioned snapshots, but the game still lacked disk storage, recovery, a Continue route, and an explicit checkpoint policy.

Saving arbitrary scene trees or mid-combat state would couple persistence to temporary enemies, active attacks, timers, and scene structure. Writing after every reward or health change would also create unnecessary file churn and unclear defeat behavior.

## Alternatives Considered

1. Save the complete active stage at any moment, including combat actors and attacks.
2. Use several manual profile slots immediately.
3. Use one local autosave profile whose durable state resumes at Sanctuary and is written only at authored safe milestones.

## Decision

Choose option 3 for the first playable region.

`SaveService` stores one versioned JSON profile at `user://battle_of_gods_profile.json`. Every write goes to a validated temporary file first. A previously valid primary rotates to `.bak`, and a corrupt primary is recovered from that backup and repaired. All nested snapshot versions validate before live state changes.

The profile contains `RunSession`, `StoryState`, and `WeaponInventory` data plus extension seams for material inventory, recipe discovery, stage claims, and regional progress. Decision 064 later activated the material and recipe sections through dedicated versioned authorities while preserving empty legacy sections; stage claims and regional progress remain reserved. Settings remain separate.

Autosaves occur:

- after entering Sanctuary;
- after a Sanctuary weapon purchase or equip;
- after an authored skill awakening;
- after an authored stage clear, once its story/discovery/boss records are committed.

Every current checkpoint resumes in Sanctuary. Combat frames, ordinary damage/healing, individual enemy rewards, and incomplete stage state are not written. Returning to Sanctuary intentionally becomes a safe checkpoint. Headless tests suppress production-path writes unless they explicitly configure an isolated `user://` test path.

The F9 testing preset suppresses autosave for the rest of that debug session. Loading a real profile or beginning a new journey clears the suppression, so temporary level-10 currency, equipment, and route unlocks cannot overwrite legitimate progress.

The title screen exposes Continue only when the primary or backup is valid. A valid profile receives initial focus. Starting a new journey while a profile exists requires confirmation before the autosave is replaced.

## Consequences

- XP, coins, current HP, story memory, awakened Skill 2, weapon ownership, equipped weapon, and the later Decision-064 material/recipe state survive application restart.
- Corrupt or interrupted writes retain a recoverable previous checkpoint.
- Continue never reconstructs unstable mid-combat state.
- One autosave slot keeps the first implementation understandable; multiple profiles and manual saves remain deferred product choices.
- Version 1 has no older disk format to migrate. Any future schema bump must add explicit migration coverage before release.
