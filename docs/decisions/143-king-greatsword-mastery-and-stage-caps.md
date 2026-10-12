# 143 - King greatsword C, earned skill strength, and stage caps

- **Status:** Implemented for the current six-stage campaign and F7 lab; owner feel-testing remains necessary.
- **Date:** 2026-09-12

## Context

The owner chose option C from the sword comparison, authorized installation of the greatsword design and complete action/skill polish, and requested passive/combo interactions plus modest level growth without early-stage grinding power creep. Existing equipment, movement, targeting and buffered chaining must remain authoritative.

## Decision

- Keep the simple black-haired, short red-scarf, navy-tunic adventurer at approximately 27px standing height. Use padded 96x64 cells with y48 feet and the existing (0,-16) centered-sprite offset. No crown, royal armor or boss-sized anatomy.
- Three successive basic attacks use opening/return/heavy drawings and 100/115/165% of the weapon's rolled basic damage. Windup/contact/recovery seconds are .19/.12/.30, .15/.12/.27, .26/.14/.36; equipment attack speed divides all three phases, still capped at +50%. Continuation lasts .9s after recovery. Skills, interruption and weapon changes reset the chain. Basic attacks still permit movement.
- Use one data-owned 36px-forward, 44px-wide convex fan for all three cuts and both authored weapon essences. Generated white contact trails clip to that exact world-transformed polygon and exist only during ACTIVE. Animation, audio and particles never award damage.
- Resolve grants at most one stack per swing that lands an accepted hit. Three stacks empower the next committed skill by 25%; all stacks expire eight seconds after the last landed swing. Air swings and skills cannot charge it. Rejected/cooldown casts keep it; an accepted cast consumes it even if subsequently interrupted. Transient stacks do not save.
- Pursuit landing opens a 1.2s link: the next committed Riftbreak receives +15%. Any intervening skill consumes that opportunity. Keep the existing latest-intent buffer, traversal collision, targeting, cooldowns and invulnerability rules. No additional input or cooldown reset.
- Level mastery multiplies all four skills' weapon contribution by +2% per level after Level 1, capped at +18% at Level 10. Resolve and the link multiply this bonus; equipment skill power and critical rules continue to apply. No radius/cooldown inflation.
- Current campaign caps start at 3; completing Stages I/II/III/IV/V unlocks 4/5/6/7/10. XP stops at the unlocked ceiling; coins and loot continue. Preserve already-earned levels and existing save XP. F9 retains its session-only Level 10 bypass and save suppression. This is not a decision about the final 100-stage game's eventual level ceiling.
- Four skill identities remain Echoing Sever, Riftbreak, Sovereign Pursuit and Worldsplitter. New body families, raster contact accents, coordinated icons, portrait, original sword/footstep/Resolve cues accompany the existing generated skill fields and their working sounds.

## Alternatives

A royal redesign was explicitly rejected (142). Expanding King's anatomy to fit a weapon would break human/NPC scale. A new fifth skill, hold input, unlimited level growth or independent combo queue would complicate the existing controls and invalidate current combat rules. The selected approach builds on the four-slot kit and single buffer.

## Consequences

The previous complete `simple_reboot` body resource and its sheets remain a supported visual rollback; they are not active player/menu references. Source boards, correction prompts, deterministic imports and rendered review are under King-owned `art_source` folders. Stage VII onward and production Stage XX progression remain unimplemented. New combo/bonus values need full-campaign owner playtesting alongside Stage V gear; automated checks cannot establish difficulty or enjoyment.
