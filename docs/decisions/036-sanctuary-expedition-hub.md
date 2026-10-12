# Decision 036: Use Sanctuary as the Expedition Hub

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

A permanent linear Start-to-Stage-1 flow would become repetitive as regions, levels, bosses, and character power expand. The game also needs a safe location for NPCs, lore, skill setup, shops, and later destination choice without placing those systems inside combat stages.

## Alternatives Considered

- Continue launching the next required combat stage directly.
- Build a large MMO town and all shops before validating hub interaction.
- Begin with a compact Sanctuary and one extensible expedition altar.

## Decision

New journeys enter the compact Sanctuary of the Remembered Veil. The hub is organized around an animated angel portal and fountain, an inhabited mushroom dwelling, a merchant hall and weapon stall, Skillkeeper Eira, and Armskeeper Orren. The player approaches the portal through either side of the fountain and physically enters its doorway threshold before route selection is offered. The portal currently opens Stage 1 and presents future routes as sealed rather than pretending their unlock rules exist. Decision 037 records the dedicated generated-art pipeline that replaced the first functional visual prototype.

Destination availability will eventually combine authored story flags, boss victories, discoveries, key items, and level requirements. Level alone will not grant every route. `SanctuaryFlow` composes interactions and UI; NPCs and the angel portal emit intent and do not own scene transitions or HUD presentation.

Stage 2 returns to Sanctuary after completion. The title resets the run before entering Sanctuary, while choosing an expedition preserves that active run.

## Consequences

- The project now has a safe social/exploration loop before combat.
- Shops, skill services, quests, and additional NPCs can be added without changing stage ownership.
- The first portal menu intentionally has one playable route and two non-functional previews.
- A future profile/story-state authority must evaluate unlock requirements outside the menu.
