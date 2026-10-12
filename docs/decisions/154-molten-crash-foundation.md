# 154 - Molten Crash Foundation

Date: 2026-09-26. Status: implemented in opt-in Lab; owner feel review pending.

## Context and decision

The owner authorized Skill 2 after confirming the saved local molten lift/crash concept. Preserve King's approved art and Skill 1 while building a distinct close-area control skill. Remote targeting was rejected for this concept; the earlier Riftbreak target experiment remains a reversible comparison, not the new skill's authority.

Molten Crash lifts a separate heated summoned sword, then crashes at King's current foot position. One instantaneous 72px local circle deals 200% weapon damage, 65 radial knockback, .10s flinch and .55s explicit stun. Target resistance, including Boss stun immunity, remains authoritative. Target foot distance and a terrain ray prevent damage outside the circle or through walls. There is no residual damage, added invulnerability, implied burning status or new lore grant.

Windup .18s, contact phase .04s, recovery .14s return control in .36s before accepted-hit pauses. Cooldown is 8s outside the Lab unlimited-skills helper. Existing equipment, mastery and eligible combo modifiers flow through the preserved Ability2Component bindings. Two sixteen-drawing generated VFX atlases continue at the contact point for .95s after release. King keeps the existing coordinated Riftbreak body frames; no character redesign. Sword and ground effects sit behind his body for readability.

## Ownership and alternatives

The component subclasses Riftbreak to preserve Player's typed binding, but uses a single contact query through the existing hitbox/health/stagger pipeline instead of a persistent damage area. Presentation has no damage authority. The Lab adapter preserves signals, original script/definition and slots, disconnecting only superseded VFX/audio. Molten and targeted Riftbreak cannot be active together. Review exit and defeat remove residuals; windup cancellation prevents contact entirely. No permanent catalog or save migration occurs.

Extending the lock to match the full effect was rejected because spectacle should not prevent movement. Repeated stun from cooling lava was rejected to preserve explicit control rules. Foundation therefore proves the core first; future Developed radius/damage growth and an Awakened damage-only aftershock remain planned with shared budgets and no longer cast or stun.

## Evidence and limits

Molten 40 assertions, targeted Riftbreak 28, Spellward 232, mastery 385 and Earthsplitter Fan 136 pass (821 total). Tests disable the unlimited-skills helper when checking real cooldown and move paused test enemies out of spawning before checking controller-approved stun stars. Boss response is tested through the real shared StaggerComponent configured with the Rootbound Husk definition.

Rendered review covers four facings and live crowd stun. Generated sources and exact prompts are in `art_source/generated/vfx/king/molten_crash_2026_09_26/`; runtime video is in `art_source/review/characters/king/molten_crash_2026_09_26/`. No mobile FPS claim, final boss/gear balance, campaign promotion, upgrade unlocks or cleanup is implied.
