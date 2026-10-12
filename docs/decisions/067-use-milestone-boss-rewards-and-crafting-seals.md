# Decision 067: Use Milestone Boss Rewards and Crafting Seals

- **Status:** Accepted; Stages I-III boundary implemented, later category cadence amended by Decision 069
- **Date:** 2026-07-29

## Context

Giving every stage a guaranteed chest and every ordinary enemy a frequent material drop made rewards feel routine instead of special. It also unlocked several unrelated recipes too early, before the Sanctuary craft service or their equipment outputs existed.

The Forest needs a readable long-term reward rhythm. Ordinary stages should make their enemy drops meaningful, mini-bosses should produce memorable material payouts, and major bosses should open new build options without turning their one-time unlock item into a repeat-farm ingredient.

## Alternatives Considered

1. Keep a guaranteed chest and recipe unlock on every stage.
2. Put all equipment categories behind the Stage X regional boss.
3. Use sparse protected enemy drops, direct banking on ordinary clears, and distinct boss milestones for material payouts and permanent crafting-category seals.

## Decision

Choose option 3.

Ordinary current-enemy common drops use 15% Mire Resin, 15% Root Fiber, 20% Forsaken Cloth, and 25% Barbed Seed rolls. A protected common drop is forced on its sixth unresolved attempt. Secondary drops use 5% Mire Membrane, 6% Young Heartwood, 8% Weathered Fittings, and 10% Thorn Sap rolls, forced on the twelfth unresolved attempt. These remain profile-owned balance values resolved only by `LootService` with counters stored by `LootState`.

Stages I and II do not spawn a clear chest. Completing their final wave commits the collected expedition materials before opening the normal portal and emitting stage completion. Death, restart, or abandon before clear still restores the expedition baseline.

Stage III remains the first mini-boss payout. The Rootbound Husk guarantees Husk Heartwood and Rootbound Core through its boss profile. Its Rootbound Reliquary adds a modest guaranteed pool of ordinary Stages I-III materials on first clear and replay; it does not unlock a recipe or crafting category.

The planned later Forest cadence is:

| Stage | Encounter reward role | First-clear progression | Repeatable value |
|---|---|---|---|
| V | Medium boss | Permanent weapon-and-armor crafting seal | Boss catalyst consumed by weapon/armor recipes |
| VIII | Mini-boss | First permanent standard-accessory crafting seal | Accessory materials plus a repeatable binding/setting catalyst |
| X | Major regional boss | Permanent relic/signature-accessory crafting seal | Unique boss catalyst consumed by relic/signature recipes |

A crafting seal is a permanent unlock recorded once and never consumed. A boss catalyst is a repeatable material and may be consumed by recipes. Their exact names, stable IDs, art, boss identities, and quantities remain open until the relevant stage content contracts are approved.

The existing recipe directions are reassigned: Rootfiber Wraps and Huskbound Guard belong to the Stage V core-gear milestone. Mireward Charm and Thornward Clasp now belong to the Stage VIII standard-accessory milestone. Stage V also requires at least one authored crafted weapon recipe before its implementation can be considered complete. Decision 069 owns the detailed Stage VI-X accessory-family and stat direction.

## Consequences

- Ordinary material drops are less frequent, so a visible pickup matters and replays retain purpose.
- Stages I-II finish promptly without presenting an ordinary chest as a major event.
- Stage III teaches the mini-boss payout language without unlocking an unfinished craft service.
- The III/V/VIII/X rhythm separates material preparation from permanent category unlocks.
- Stage VIII opens the first standard accessories, while Stage X retains a decisive relic/signature payoff instead of delaying the whole accessory system until the region is over.
- Future stage implementations must not describe planned seals, catalysts, recipes, or bosses as playable until their data, art, runtime authority, save behavior, and tests exist.
- Decision 066 remains authoritative for pickup movement, boss guarantees, chest collision, spawn presentation, and tier separation, but this decision supersedes its exact ordinary drop rates and its requirement that Stages I-II spawn clear chests.
