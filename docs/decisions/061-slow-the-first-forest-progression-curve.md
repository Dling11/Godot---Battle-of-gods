# Decision 061: Slow the First-Forest Progression Curve

- **Status:** Accepted
- **Date:** 2026-07-26

## Context

The first progression rebalance prevented Stage I from jumping Opaw to Level 7, but playtesting still found the new curve too fast. Stage I's authored enemies award 304 XP and 46 coins. Under the `0/100/250/.../2700` curve, that already reached Level 3, while Orren's 18-coin Iron Sword could be purchased before even half of the stage's available currency had been earned. Neither milestone felt like a meaningful reward.

The complete implemented forest arc currently awards 872 XP and 144 coins: Stage I contributes 304/46, Stage II contributes 388/72, and Stage III contributes 180/26.

## Alternatives Considered

1. Reduce every enemy's reward, coupling progression pacing to encounter-role tuning.
2. Add level caps per stage and leave the very cheap shop price unchanged.
3. Keep enemy rewards readable, stretch the authored cumulative curve, and price Iron around the complete early-forest economy.

## Decision

Choose option 3.

Opaw's cumulative Level 1-10 thresholds become `0/150/400/750/1200/1750/2400/3150/4000/4950`. The cost of each new level rises by 100 XP: 150, 250, 350, 450, 550, 650, 750, 850, then 950. Stage I's 304 XP now ends at Level 2; cumulative Stage II completion reaches 692 XP and Level 3; the complete current forest arc reaches 872 XP and Level 4.

Iron Sword costs 90 coins. Stage I's complete 46 coins cannot buy it. It becomes affordable during/after Stage II or from the 144 coins available after the complete current forest arc. Ashwood remains the free permanent fallback, purchases still never auto-equip, and enemy XP/coin rewards remain unchanged.

## Consequences

- Levels and Iron Sword ownership become earned milestones rather than immediate unlocks.
- Consecutive Thrust still requires Level 3 and Eira's free awakening, placing it after meaningful forest progress.
- The current three-stage arc uses only the first four levels, leaving room for Stage IV onward.
- Save/continue should persist totals and resolve the level from the current definition instead of storing a duplicate level value.
- Human playtesting must confirm the longer gaps do not make rewards feel absent; later loot, route discoveries, and stage-clear rewards should provide additional non-level progression beats.
