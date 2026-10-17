# Axe technique 1 — War Cyclone

Normal learning232: visit Veyr north of the Sanctuary Veil Gate, complete his Axe proof, forge Iron Beard Axe with Nema and equip it. F1 then works in expeditions and survives Continue. The review route below stays non-saving; F9 grants are not permanent.

Updated2026-10-18. Owner accepts the connected-motion presentation for now and asks to finalize it and remove archives. Decision231 closes visual iteration; Decision230 remains gameplay/audio authority. Decision232 now installs Veyr's first proof lesson and permanent unlock; see weapon-court-and-first-proof.md.

Final resources live under assets/vfx/abilities/weapons/axe_war_cyclone/. Preserve motion.png, outer.png, ground.png and icon.png. The sole compact prompt/source/registration/audio audit is art_source/reference/abilities/axe-war-cyclone.json; retired previews are not alternate runtime routes.

## Try it

F5 → F9 → F7 → Weapons → TRY WAR CYCLONE → F1 or its medallion. Steer with WASD or right-click. Repeating F1 plays a quiet acknowledgement and keeps the current spin running for its original duration. Space deliberately dodges out; interaction/defeat/restraint keep their normal cancellation authority. Disable King Invincible in Lab to test actual guard hits. Review access suppresses autosaves.

Selecting a different available skill replaces an unconfirmed targeting preview. Thus1→2 switches skills and1→F1 clears aim and starts Cyclone; the first uncommitted skill spends no cooldown. Repeating the same targeted key still does not confirm it.

## Current gameplay

| Rule | Value |
| --- | --- |
| Startup / ACTIVE / finishing recovery |0.03s /5s /0.24s |
| Steering |90% normal speed; normal acceleration, stopping, navigation and walls |
| Damage category |Physical continuous area damage |
| Total before modifiers |600% equipped weapon skill power per target |
| Starter Axe power25 |150 total /30 damage per second over5s |
| Pulse cadence |10 normal /15 at+50% haste; same150 total |
| Radius |96px, up from84px to match the wider sweep |
| Outgoing control |12 radial knockback; no stagger/stun |
| Guard during ACTIVE |50% less incoming Physical, Magic and Pure; stun/stagger immunity |
| Cooldown |16s from commitment; repeating F1 does not restart it |

DPS describes damage per second, not a new damage type. The owner's1,000 example means1,000 total/200 DPS over five seconds. We retain the starter150 budget rather than imposing1,000 as a balance change. Haste distributes the same budget over more frequent pulses and speeds rotation; it does not accidentally multiply total damage. A target must stay in range for the whole total. Late entry, movement away or dodge cancellation loses missed pulses. Crits, buffs, armor and resistance change actual HP loss. No bleeding, magic damage or projectile reflection is granted by blue artwork.

Health's ACTIVE-only keyed modifier composes after typed defenses/ward and before absorbers/shields, halves all three types and clears incoming stun/stagger fields. Remove it on every exit/free. Normal root/knockback remain; startup/recovery are vulnerable. Guarded hits keep damage numbers without repeated global hurt hitstop. Guard/card values come from current tuning.

## Body, blade and effects

ACTIVE draws one16-key256px-cell motion atlas: charcoal/crimson/leather body-action and its silver cut are painted together, with shared premultiplied whole-cel blends. Half scale and position(0,-21) map pivot(128,170) to the physical foot origin. The character is never rotated flat and there is no independently drifting inner spinner.

Original blue outer pixels use one320px template, a fixed source/output ellipse and behind/front masks matching the accepted preview. Body/inner revolution remains0.32s; the outer circle runs1.6times faster, taking0.20s per baseline revolution. Haste still speeds both, with the existing body-clock0.12s floor. Faster outer rotation never creates extra contact queries. C contact retains its0.44scale,0.76alpha, lower world anchor and eight-key0.64s loop. Sixteen pooled points and sixteen faint tails follow independent rim/tangent/gravity/fade clocks; only ACTIVE updates them. Existing bounded outgoing/guard impacts remain.

Startup uses ordinary accepted Axe poses0–3; recovery uses13–15 over the existing0.24s. Complete actor and paired-motion presenters are mutually exclusive; finish/cancel restores the regular weapon. The old generated spin/recovery sheets, old cut atlas, imports, definition fields and old animation branch are retired.

Final four PNGs total254,113 bytes. The production guard remains690 files: three final rasters replace three retired sheets while687 previous assets, including ordinary weapons/icon/audio, stay byte-identical. Source trials and preview GIFs are removed after validation; final runtime assets plus the one compact provenance record remain authoritative.

## Sound and skill facts

Dedicated recorded start, quiet0.40s spin loop and metal/air settle derive from retained CC0 Swishes/Impact sources. One looping voice, one activation/finish voice and one contact voice stay bounded. A repeated F1 gives a soft cue throttled180ms, without resetting loop/cooldown/damage. Haste adjusts loop pitch. Phase fades/cancel/free stop sound; no runtime DSP. Attribution: assets/audio/ATTRIBUTION.md; builder: tools/build_war_cyclone_audio.gd.

Shared skill cards keep their normal title/body/status support and add colored facts: Physical ivory, Magic blue, Pure violet, always labeled. Damage/total, damage per second when meaningful, duration/cooldown, protection and immunity occupy separate lines. F1 shows150 total,30 DPS,5s and50% guard for the starter. Numerical facts derive from current definitions/equipment; only real statuses are described. The layout takes inspiration from [Whirling Axe's channel damage facts](https://wiki.guildwars2.com/wiki/Whirling_Axe) and [official warrior weapon/burst/stance roles](https://www.guildwars2.com/en/the-game/professions/warrior/), not copied artwork or balance.

## Future upgrades

Weapon crafting/evolution belongs at Sanctuary; family mastery earns and improves weapon techniques under226/228. King level, item tier and family mastery are different progressions. Neither another XP bar nor an earning/mentor identity has been chosen.

Future F1 variants can change the total coefficient, radius, duration/cadence, defense, icon, complete actor/effect assets and sound. The new definition owns those values and cards read them directly. Evolved axe visuals need matching full skill frames at the same body size; do not silently reuse old steel or recolor damage types. Review tradeoffs explicitly: longer protection/range must be budgeted alongside damage, and any haste-to-total scaling must be an intentional trait. Crafting recipes, mastery ranks, earning, mentor trials and evolved-item content are still planned.

## Verification

Current headless Cyclone422/0 checks four entry directions, all16 paired phases, painted gutters and forward silver-centroid movement through the loop. It also checks single visible body, startup/natural settle/dodge, same150 total across10/15 pulses, full-duration repeated F1, mouse steering, aim replacement, range/walls, guard/typed damage and cleanup. Headless HUD242/0, action controls and runtime/archive boundary pass. No native window opens under the active Monster Hunter restriction.

The owner accepts the preview for now; visual iteration is closed. Native gameplay/phone/cold/horde performance has not been newly profiled. Earlier native410/0 and261/0 HUD results are historical evidence, not reruns of this closeout. Current detailed closeout/protection counts belong to art_source/reference/abilities/axe-war-cyclone.json. Learning/mentor/evolution and campaign balance remain planned.
