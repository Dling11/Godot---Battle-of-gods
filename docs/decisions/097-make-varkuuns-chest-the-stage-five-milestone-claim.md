# Decision 097: Make Varkuun's Chest the Stage Five Milestone Claim

- **Status:** Accepted; Sanctuary destination superseded by Decision 129
- **Date:** 2026-08-15

## Context

Stage V is the first major-boss milestone. Varkuun already has a complete production encounter, but defeat previously committed progression and opened the return portal without the core-gear seal or repeatable catalyst promised by Decisions 067 and 069. Reusing Stage III's Rootbound Reliquary would also flatten the distinction between a mini-boss and a major boss.

## Alternatives Considered

1. Grant the Stage V rewards automatically when Varkuun dies.
2. Reuse the Rootbound Reliquary with a different loot table.
3. Spawn a distinct major-boss chest at Varkuun's death position and commit completion only after its explicit claim.

## Decision

Choose option 3. Varkuun's Chest is a third `StageRewardChest` presentation tier with unique closed/open art, a restrained oxblood/plum and aged-gold boss palette, green lord-core accent, and dedicated prompt. Its 74x66 runtime canvas remains consistent with the 72x64 mini-boss Reliquary while reading one tier higher. It spawns under the Y-sorted actor owner at Varkuun's actual death location.

The first claim grants two `Varkuun Core` boss catalysts plus the permanent `forest_core_gear_seal` key item and `forest_core_gear_crafting` discovery. Replays grant one Varkuun Core and never repeat the seal. `LootService` and the Stage V `LootTableDefinition` remain the only reward authorities. The Sanctuary portal and Stage V safe-point save occur only after a successful chest claim.

The entrance becomes a six-line Varkuun/King conversation with per-line portrait switching. A visible mouse-operated Skip closes the cinematic through the same completion handoff, without changing boss authority.

Varkuun's death opens a separate three-line final exchange before reward presentation. Closing or skipping that quote allows his authored collapse/hold/fade to finish for 2.2 seconds; only then does the chest appear. Root-prison audio observes explicit lock and execution signals so the 300-damage eruption receives both a low earth rumble and heavy impact.

## Consequences

- Stage V now fulfills its milestone reward contract while crafting transactions remain honestly unimplemented.
- The major-boss payout is visually and mechanically distinct from Stage III's mini-boss reliquary.
- Full-map pursuit cannot strand the reward at a fixed arena marker.
- Defeating Varkuun without opening the chest remains an uncommitted expedition and cannot grant the permanent seal.
