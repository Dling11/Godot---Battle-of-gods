# Decision 066: Use Protected Enemy Drops and Tiered Clear Chests

- **Status:** Superseded in part by Decision 067
- **Date:** 2026-07-29

## Context

When every ordinary enemy supplied its common material, the Forest economy produced a large predictable shower of loot and did not support purposeful replays. Contact-only collection also asked the player to backtrack across an arena after combat. The same ordinary chest art at the end of the Rootbound Husk fight did not communicate that Stage III ended with a mini-boss.

The game still needs deterministic progression. A player must not lose a required boss material or finish a complete stage with an empty clear reward because of random rolls.

## Alternatives Considered

1. Keep every enemy material guaranteed and balance only by raising recipe costs.
2. Use unrestricted low drop rates and require the player to touch every world pickup.
3. Use readable percentage rolls with short bad-luck protection for ordinary enemies, guaranteed signature materials for bosses, magnetic pickup presentation, and authored stage-clear chest tiers.

## Decision

Choose option 3.

Ordinary current-enemy common materials use profile-owned percentage rolls with persisted bad-luck protection. `LootService` and persisted `LootState` remain the only resolution/protection authorities. Decision 067 supersedes the original exact percentages and protection caps.

The Rootbound Husk guarantees both Husk Heartwood and Rootbound Core. Every authored chest table remains guaranteed non-empty. Stage III uses the visually distinct Rootbound Reliquary tier. Chest tier changes presentation, interaction copy, footprint size, and arrival emphasis, never the stage loot table itself. Decision 067 removes clear chests from Stages I-II and reserves authored chests for milestone encounters.

An already-resolved world pickup performs a short hop and idle hover, then magnetically travels to its injected player recipient after a 0.5-second readability window. Contact collection remains a fallback. Pickups grant only through `LootService`.

Reward chests spawn under the stage's Y-sorted actor owner with a small solid ground footprint, a larger non-blocked interaction range, and a presentation-only rune/spark reveal. Successful claim disables the footprint before the chest fades and the portal opens.

## Consequences

- Ordinary encounters can produce no material or one/two stacks, creating controlled replay value without blind infinite droughts.
- Boss and clear progression cannot be invalidated by luck.
- Loot remains visible long enough to read but no longer requires arena cleanup walking.
- Mini-boss clears have a reusable chest-rarity seam without duplicating reward authority.
- Future elite, boss, and regional chest tiers may add art/presentation variants, but their actual contents must remain data-defined by `LootTableDefinition`.
- Exact percentages and protection caps remain balance-tunable profile data; changing them does not require enemy-controller or pickup code changes. Current values are recorded by Decision 067.
