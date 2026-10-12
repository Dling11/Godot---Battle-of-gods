# Decision 059: Align Cleave, Routing, and Run Vitality

- **Status:** Accepted; cleave dimensions superseded by Decision 060
- **Date:** 2026-07-26

## Context

Playtesting exposed three authority/presentation mismatches after the compact combat pass. Balanced Slash drew an approximately semicircular cleave, but its 52x36 contact lane covered only the narrow center; visible side-edge contacts could miss. Stage III navigation baked only six pixels of obstacle clearance even though Rootbound Husk has a 16-pixel movement radius, allowing a valid path to wedge the boss against the central seal. Player maximum health grew by level, but current health refilled whenever a replacement Player entered another stage. Dash also sat flush against Skill 1 and read as a fifth skill.

The requested RPG direction additionally needs a larger vitality budget, slow natural recovery, and room for later armor, lifesteal, critical hits, potions, and mana without claiming those future systems already exist.

## Alternatives Considered

1. Shrink the cleave VFX, remove the seal collision, keep stage refills, and leave current balance unchanged.
2. Add special-case extra hits, teleport stuck bosses, and copy health between individual level scripts.
3. Align authoritative footprints with what the player sees and keep cross-stage health in the narrow run-session boundary.

## Decision

Choose option 3.

Balanced Slash uses one convex forward fan with 62-pixel forward reach and 54-pixel half-width. Its side shoulders cover the visible arc near Opaw and its tip extends through the visible forward edge. `MeleeAttackComponent` and `MeleeHitbox` remain the only normal-attack contact/damage authority; presentation reads the same weapon-owned bounds. A regression target at the visual side edge must receive the same single hit as a centered target.

`ArenaNavigation` exposes its bake radius. Stage III uses 20 pixels, exceeding Rootbound Husk's 16-pixel body radius, while other stages retain their established six-pixel baseline. The central seal keeps collision and navigation ownership; tests sample the complete north/south route and reject any segment entering the Husk-expanded footprint. No teleport or per-frame unstuck behavior is added.

The action tray keeps fixed 52x48 controls but inserts a visible 20-pixel effective gap between dash and Skill 1. Dash remains mobility, not skill-slot content.

Opaw vitality becomes `140 + 12 * (level - 1) + flat equipment bonus`, reaching 248 maximum HP at Level 10. `RunSession` retains current health alongside XP/coins, so portal travel and Sanctuary returns do not refill Opaw; new journey and defeat restart still reset the run. `PlayerHealthRegenerationComponent` requests 1 HP per second after five damage-free seconds through `HealthComponent.heal()`. Timers stop at full health or defeat. Future equipment may add flat vitality/regen, but armor items, lifesteal, critical hits, potions, and mana remain unimplemented.

Enemy damage is retuned against the larger bar without changing health, timing, or encounter counts: Mireling 8, Rootling 10, Forsaken Thrall 18, Bramble Spitter 12, and Rootbound Husk 18 before its authored burst multiplier.

## Consequences

- Every visible normal-cleave edge is backed by one authoritative contact fan.
- The Husk routes around the large Stage III seal with body-sized clearance.
- Dash is visually distinct from numbered skills.
- Damage taken matters across the forest expedition instead of disappearing at each portal.
- Slow regeneration prevents permanent chip damage while remaining too weak to erase pressure during combat.
- Enemy damage and the new vitality curve require human Stage I-III time-to-defeat testing before Stage IV.
