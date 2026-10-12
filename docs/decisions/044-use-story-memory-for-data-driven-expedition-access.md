# Decision 044: Use Story Memory for Data-Driven Expedition Access

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

The Sanctuary menu previously hard-coded one playable route and two disabled labels. The desired story now includes an isekai origin, mortal lives exploited by gods, future bosses across extreme power bands, and a switchable roster beginning with Warrior before Mage and Archer foundations. Route access must eventually combine story, bosses, discoveries, key items, and level without making UI labels or player scenes authoritative.

Disk-save, inventory, class switching, and profile rules are not approved enough to implement together safely.

## Alternatives Considered

- Keep future routes as permanently hard-coded disabled buttons.
- Unlock every destination from player level alone.
- Put route flags, key items, and boss checks directly in the expedition menu.
- Build the complete disk profile, inventory, class roster, and story system in one pass.
- Introduce immutable route requirements plus a narrow in-memory story authority and versioned snapshot boundary.

## Decision

Each destination uses an immutable `ExpeditionDefinition` with stable identity, display metadata, destination scene, and an `ExpeditionRequirement`. Requirements may combine minimum level, story flags, boss victories, discoveries, and narrative key items.

`StoryState` is the cross-scene authority for those four narrative memory categories. It provides a versioned dictionary snapshot for a future save service but performs no disk I/O. `RunSession` continues to own only current-run XP and coins; `ProgressionDefinition` resolves level. The expedition menu observes both authorities, creates route buttons from data, explains missing requirements, and delegates valid scene changes to `SceneTransition`.

Entering Sanctuary records `awakened_in_sanctuary`. Clearing the current Stage 2 records `forgotten_grove_completed` and discovery of the remembered thorn shrine. A new journey resets both run and story memory. Future route definitions may express requirements now, but they remain unavailable until their destination scenes actually exist.

The narrative direction is preserved in `STORY_BIBLE.md`. Playable character identity remains distinct from class data; implementing the roster and class switching requires a later decision.

## Consequences

- Future destinations can change requirements without rewriting menu code.
- UI cannot invent progression, boss victories, discoveries, or key-item ownership.
- Missing requirements are player-visible and testable.
- Story state survives scene replacement for the application session but is lost when the application closes.
- The snapshot version is an integration boundary, not a claim that disk saving exists.
- Key-item memory does not create a general inventory or equipment system.
- The destination formerly called Ashen Pilgrimage is now the implemented Rootbound Hollow but remains sealed in normal progression until its requirements are authored; The Drowned Bells remains an honest unbuilt preview.
- Switchable characters, class selection, shops, skills 2-4, and high-tier bosses remain planned rather than partially activated.
