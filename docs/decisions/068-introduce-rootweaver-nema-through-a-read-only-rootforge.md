# Decision 068: Introduce Rootweaver Nema Through a Read-Only Rootforge

- **Status:** Accepted and implemented
- **Date:** 2026-07-29

## Context

Forest materials and four deterministic recipe definitions already exist, but normal play has no crafting seals, blueprint sources, output equipment, or atomic crafting authority. The Sanctuary still needs to explain what those materials are for before Stage IV production begins.

Rootweaver Nema also needs to belong beside compact Eira and Orren without duplicating their services. Her forge work requires readable hands and tools even though Opaw's active model intentionally remains armless.

## Alternatives Considered

1. Hide all recipe information until Stage V and add Nema only when crafting transactions are complete.
2. Add a functioning craft button now and let UI or the NPC remove materials directly.
3. Introduce Nema, the Living Rootforge, portrait dialogue, and a strictly read-only recipe preview now; defer all mutations to the future `CraftingService`.

## Decision

Choose option 3.

Rootweaver Nema is an adult human female grove smith with a compact oversized-head Sanctuary silhouette, auburn side braid, moss forge apron, root hammer, and gold-thread tongs. Visible arms are a deliberate action-specific NPC exception because her identity and four-frame work loop depend on readable tool handling. This does not change Opaw's compact armless presentation contract.

Nema and her colliding, Y-sorted Living Rootforge occupy the west-mid Sanctuary garden at `(342, 630)` and `(240, 610)`. Nema stands to the screen-right of the forge in a three-quarter pose facing screen-left toward her work. The Rootforge uses separate rear-rack and anvil footprints so the open front remains approachable and the central avenue remains clear.

`DialogueNpc` now supplies an optional portrait with dialogue intent. `SanctuaryFlow` remains the composition owner: completing Nema's three-line dialogue opens `RootforgeMenu`, while canceling dialogue or closing the menu restores the shared interaction prompt.

`RootforgeMenu` may observe `RecipeCatalogDefinition`, `MaterialInventory`, and `RecipeDiscovery`. It may filter and inspect the four current recipes, show `owned / required` ingredients, and explain missing blueprints, milestone seals, and output implementation. Its primary action remains disabled. It must not remove materials, discover recipes, grant equipment, or save state.

Nema's intermittent forge animation and strike sound are presentation-only and timer/signal driven. Her actor scene owns no recipe balance, loot resolution, unlock rule, or save operation.

## Consequences

- Players can understand earned materials and future recipes without losing inventory or receiving fabricated equipment.
- Stage V retains the core-gear seal, Stage VIII opens standard accessories, and Stage X retains the later relic/signature seal defined by Decision 069.
- Segment 5 must add output equipment and an atomic `CraftingService` before enabling any craft action.
- The reusable portrait signal can support future named NPC dialogue without special-case flow code.
- Nema's visible arms are scoped to her integrated work silhouette and do not reopen Opaw's approved armless model decision.
- The dedicated Rootweaver asset processor and smoke test protect exact image sizes, binary alpha, side-facing safe margins, animation names, placement, collision, modal behavior, and the no-mutation boundary.
