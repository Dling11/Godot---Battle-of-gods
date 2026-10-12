# Decision 115: Return to Sanctuary on expedition defeat

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

Pressing the defeat action reloaded the current stage after `RunSession.reset_run()`. This erased earned XP/coins, returned a level-six or level-seven King to level one, and encouraged consequence-free immediate retries. Stage V also reused Sanctuary's music before Varkuun awakened.

## Decision

- Defeat ends the active expedition and returns King to Sanctuary after the player confirms with R/gamepad north.
- Uncommitted expedition loot is rolled back, but `RunSession` progression is not reset.
- Sanctuary remains the full-health recovery and safe-save boundary.
- Stage V's dead-forest approach is silent until Varkuun's dedicated battle theme begins.
- Future healing potions, temporary buffs, and a rare revive belong to a later utility-item system; defeat does not invent those resources early.
- Sanctuary and stage-exit portals use separate generated four-frame hard-pixel gates. Stage exits add a moving guide arrow, travel sound, King fade/pull-in, and a portal-backed loading veil.

## Consequences

- Defeat costs the expedition attempt and unclaimed loot without corrupting long-term level/coin progression.
- Returning home reinforces careful movement and preparation while leaving room for future consumable recovery choices.
- Portal travel has readable world, audio, actor, and loading feedback without moving scene authority into the HUD.
