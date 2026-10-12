# Decision 057: Complete the Pre-Stage-IV Progression and Control Pass

- **Status:** Accepted; XP thresholds superseded by Decision 061
- **Date:** 2026-07-26

## Context

The first forest arc awarded 304 XP in Stage I, but the original cumulative curve reached Level 7 at 270 XP. Consecutive Thrust was complete but available only through F9 because Eira had no awakening action. Weapon cards attempted to equip immediately, so opening the paused character surface during an attack could freeze the player outside the idle-only swap seam and make equip appear broken. The HUD also hid dash reuse state, mouse clicks on HUD skills could leak into the globally polled basic attack, and health was too small to read during pressure.

## Alternatives Considered

1. Leave F9 as the only Skill 2 path until disk saves and a complete skill tree exist.
2. Auto-equip purchases and auto-unlock every level-eligible skill.
3. Add a bounded session-only awakening/equip/control pass before designing Stage IV.

## Decision

Choose option 3. Use cumulative XP thresholds `0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700`; Stage I's authored 304 XP now finishes near Level 3. Level 3 creates eligibility for Consecutive Thrust, and Eira's skill service presents one explicit `AWAKEN SKILL • FREE` action. `StoryState` remembers that awakening across scene replacement for the current application session.

Persistence was subsequently expanded to the safe-point disk profile by Decision 063; the sentence above records the boundary at the time of this decision.

Consecutive Thrust grants invulnerability for its full cast and is the first ability explicitly cancelable into dash. Its damage, strike windows, reach, and five-second cooldown remain unchanged. Ability data declares these exceptions; other skills remain committed unless their own definitions opt in.

Weapon purchase and selection remain separate from equip. Orren and the character detail panel expose explicit Equip actions. `WeaponInventory` commits the selected owned item immediately, while `Player` applies the combat/presentation definition at the next safe idle boundary if the menu paused during another action.

Basic attack is accepted through `Player._unhandled_input()` so native GUI controls consume pointer clicks first. The combat HUD adds a clickable dash slot with cooldown state, a top-right Options entry, a larger vitality readout, and slightly smaller skill slots. Mouse targeting/lock-on and a mobile action-wheel layout remain separate design work.

## Consequences

- Normal play can obtain and retain Skill 2 without coins or F9.
- Stage I no longer consumes most of the ten-level arc; level costs rise by 50 XP at every step.
- Consecutive Thrust is intentionally defensive and mobile through invulnerability plus dash cancel, so human balance testing is required before changing its damage or cooldown.
- Equip no longer fails silently when a paused menu freezes a committed player action.
- Clicking dash or a skill button cannot also trigger the world basic attack.
- Disk persistence is still unimplemented; closing the application still resets XP, coins, weapons, skill awakening, and story memory.
