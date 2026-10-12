# Decision 098: Separate Normal-Hit Power and Use Armor for Boss Durability

## Status

Accepted — 2026-08-15

## Context

King could defeat early enemies and Varkuun too efficiently by repeatedly using a 25-damage, 96-pixel-wide inherited normal slash. Lowering `WeaponDefinition.damage` directly would also weaken every weapon-scaled skill. Varkuun's 30-percent jump tier was aggressive once engaged, but its repeat selection still required a completed melee attack, allowing permanent long-range kiting to suppress the boss's signature pursuit. Stage II also retained the Stage I four-enemy ceiling after the owner approved a controlled increase to five or six simultaneous threats.

## Alternatives

- Raise Varkuun's health and all early-enemy health without changing the underlying attack and kiting problems.
- Trigger the final boss phase at 50 percent, creating a new threshold that disagrees with the existing 80/30 HUD, audio, and cadence.
- Lower weapon power globally, unintentionally reducing all four King skills and weakening weapon progression.
- Implement flat damage subtraction as armor, which would make low-damage attacks collapse toward zero.

## Decision

- Preserve Varkuun's true Phase III threshold at 30 percent. While in that tier and at least 190 pixels from King for 0.55 seconds, a ready jump cooldown may bypass the prior-melee gate. Existing full-map target clamping, committed markers, 3/4/5 cadence, prison handoff, and cooldown still apply.
- Add reusable diminishing-return armor to `HealthComponent`: accepted damage is `raw * 100 / (100 + armor)`. `EnemyDefinition` owns enemy armor tuning, every enemy controller applies it, and zero armor preserves existing behavior. `DamageInfo` retains raw and accepted amounts for honest feedback.
- Give Varkuun 30 armor, reducing incoming damage by about 23 percent without adding invulnerability or changing control resistance.
- Separate a weapon's normal-hit roll from its skill-power value. King's own signature sword retains 25 skill power but rolls 10-12 normal damage.
- Give King a distinct integrated-weapon definition/catalog and dedicated 48-pixel-forward, 56-pixel-wide sword form. Keep Opaw's Ashwood/Iron catalog, fixed 25/32 damage, and Balanced Slash identity separate.
- Raise only Stage II's active-enemy ceiling from four to six. Stage I and Stage III retain four; Stage IV retains eight.

## Consequences

- Kiting remains valid movement skill but no longer disables Varkuun's final-phase pursuit loop.
- Armor is now a real combat authority usable by future player equipment, but armor items and player stat aggregation are still unimplemented.
- Basic attacks support early combat without overpowering skills or making weapon upgrades meaningless.
- Damage feedback receives post-armor accepted damage while retaining the raw amount for later UI or analytics.
- Stage II can present a small horde, while its seven-enemy finale still uses the reinforcement queue instead of opening with all seven.
