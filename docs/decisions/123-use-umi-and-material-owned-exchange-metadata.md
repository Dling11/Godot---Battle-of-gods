# Decision 123: Use Umi and material-owned exchange metadata

- **Status:** Accepted and implemented
- **Date:** 2026-08-22

## Context

Surplus regional materials need a gold outlet and a costly reconstruction path without teaching one NPC script every future material. The service also needs to respect encounter history so low-tier farming cannot immediately manufacture boss rewards. Sanctuary space favors a narrow side-facing workstation rather than another large front-facing building.

## Decision

Umi, an adult blue witch unrelated to the Forest naming family, operates the compact Echo Crucible on Sanctuary's east side. Her 760x420 surface has Sell and Reconstruct tabs. Sell values, meld values, reconstruction costs, source enemy, defeat requirement, catalyst rule, and protection flags belong to `MaterialDefinition`; Umi reads the canonical catalog dynamically.

Common/Uncommon/Rare defaults are 1/5/18 sell gold and 1/10/35 meld value. Common materials are fuel/sale resources rather than reconstruction targets. Uncommon/Rare targets require 100/400 meld, 75/200 gold, and 10/20 source defeats. Boss materials cannot be sold or used as fuel. Boss reconstruction costs 1500 meld, 1000 gold, four same-region Rare catalysts, the material's source-defeat requirement, and one charge earned per ten victories over that boss.

`EnemyMemory` persists stable enemy defeat IDs and spent boss-memory charges. `MaterialExchangeService` validates and atomically snapshots, spends, grants, saves, or rolls back exchange transactions. Stage V recipes additionally spend 150/200/250/300/400/500 gold by Gloves/Boots/Helm/Leggings/Plate/Edge, for 1800 gold across the set.

## Alternatives rejected

- Hardcode each material and price in Umi's menu. This makes every content addition an NPC-code change.
- Allow ordinary materials alone to create boss materials. This collapses boss replay value.
- Make all boss materials permanently unreconstructable. This removes the intended long-tail victory reward.
- Add another full-width Sanctuary facade. This consumes space and repeats the front-facing service composition.

## Consequences

- A valid new material appears automatically after it is added to `material_catalog.tres` with complete exchange metadata.
- Content authors must assign a stable `EnemyDefinition.enemy_id` and matching material `source_enemy_id`.
- Umi's side-facing art, Echo Crucible, menus, defeat memory, and exchange transactions are production runtime content.
- Umi's native-density face-forward dialogue portrait is separate from her side-facing world sheet. Her environment asset is a narrow asymmetrical lateral workbench: Umi stands to its right facing the reachable right-hand bowl; it must never become a symmetrical altar, front-facing facade, or oversized shrine.
- Stage VIII is the intended future service unlock. Until Stage VIII has canonical completion authority, Umi remains available in Sanctuary for production testing rather than depending on a fake or permanently false gate.
- Exact balance remains tunable through resource metadata without changing transaction or UI code.
