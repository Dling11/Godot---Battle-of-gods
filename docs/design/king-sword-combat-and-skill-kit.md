# King Sword Combat and Skill Kit

**Current sword closure (2026-10-06):** Signature sword keeps10–12 physical rolls,25 Skill Power and three-hit1.91s phases/shape/art. Bag now has a clear approved-raster icon, per-cut ranges and21.9 base DPS; normal hits use CC0 recorded body impacts. [Closure rules/audio/proof](king-weapon-closure.md). Other weapon families own separate shapes and chains; Royal Greatsword is frozen at the owner's request.

**Current terrain/aim correction (2026-10-03,Decision177):** Slot1/5 keep full authored reach through scenery; Slot3 flies over any intervening obstacle to clear, real-foot/nav/bounds-valid ground. Silver/slate/violet circles and hardware pointers replace gold/blue targeting and use actor feet/render-frame aim. This supersedes earlier terrain-aware/clipped or LOS-stopped descriptions below. Current rule/validation: king-targeting-and-terrain.md.

## Current status

Decision 143 installs owner-selected compact greatsword **C**. This documents the default four-technique loadout; [Decision 144’s collection extension](king-unwritten-oath.md) adds four alternatives and evolving forms. Earlier tap/hold proposals are archived under `art_source/archive/retired_docs_2026-09-12/`; they do not describe active controls.

## Identity and art

King is a simple progressing MMORPG adventurer: black tousled hair, short brick-red scarf, navy tunic, dark trousers, brown belt/gloves/boots and a broad silver two-handed blade with dark fuller. No crown, ornate armor or mantle. Anatomy stays approximately 27px tall, independent of weapon extent; the 96x64 cells have y48 feet with Body centered at (0,-16). All four directions use the same reference. Left mirrors the complete right pose; the northward attack correction keeps contact above the actor. Source matte removal/packing never draws replacement anatomy.

The current `assets/characters/playable/king/greatsword/` set supplies four-step alternating gait, two-frame idle/reactions and eight-frame basic/skill families. The September 13 review replaces front/back gait against the same reference, gives the basic finisher its own waist-height sweep, and holds the correct back-facing defeat rather than turning toward the camera. Some recovery/defeat frames deliberately hold the same drawing. Movement equipment changes stride cadence; reaction/dash playback resets that multiplier. Basic phase durations drive body frames and white raster contact trails; those trails are clipped to the authoritative fan. Menu preview and dialogue portrait use C. Complete `simple_reboot/` frames remain supported visual rollback.

## Basic chain

| Cut | Windup / contact / recovery | Basic damage | Knockback |
|---|---|---|---|
| Opening | .19 / .12 / .30 s | 100% | 100% |
| Return | .15 / .12 / .27 s | 115% | 115% |
| Finishing sweep (internal heavy_cleave) | .26 / .14 / .36 s | 165% | 200% |

King's signature sword and Varkuun Edge use a36px-forward,44px-wide convex fan; new families own their separate contact data. Direction commits on acceptance. Equipment attack speed divides all phases (existing +50% cap). Base weapon roll stays10–12, or16–20 for Varkuun Edge; basic rolls remain separate from Skill Power. Each swing deduplicates per target. The next cut can be buffered using the existing single latest-intent buffer and starts after full recovery. Continuation remains available0.9s after recovery; dash, skills, interruption and weapon changes reset it. Signature-sword basics continue to permit movement. No hold-charge action or extra queue is installed.

## Active skills

| Slot | Technique | Current mechanical identity |
|---|---|---|
| 1 | Echoing Sever | Confirm a 130px directional wedge; 110% primary and 75% delayed echo; .16/.46/.18s phases, 5s cooldown. |
| 2 | Riftbreak | Immediate self-area cast; 84px radius, 150% weapon power, .16/.10/.22s phases, 6.5s cooldown. |
| 3 | Sovereign Pursuit | Confirm a ground point within 220px; collision-safe .28s travel, invulnerable only during travel; 52px landing, 125% power; .14s windup/.24s recovery, 8.5s cooldown. |
| 4 | Worldsplitter | Confirm within 260px; giant sword forms, falls and drives into one fixed point; 58px first hit at 220%, then 104px final hit at 300% after .4s; .48/.8/.35s phases, 20s cooldown. |

Body anticipation, planted impact, hop and command poses use C's generated frames. Generated white/cyan contact accents accompany the existing skill fields, Pursuit sheath and world-locked craters. Original cut/return/cleave, leather step and Resolve cues join the working four-skill audio. Target confirmation/cancellation, player interruption, armor, criticals and hitstop continue through the existing components.

Riftbreak now owns one seven-frame steel/debris impact followed by its eighth-frame residue, with explicit source ground anchors mapped to (96,96). Contact captures the actual hitbox world position; its floor sprite has no extra 16px offset, and the generic contact observer no longer duplicates its crater. The sequence survives gameplay recovery and fades in place. Pursuit's world-space landing offset is zero, aligning its damage, crater and shockwave with King's actual foot/target origin; its jump mechanics and numbers above are retained.

## Passive and skill link

**Resolve:** one stack per basic swing that lands an accepted hit, at most three. Three stacks multiply the next committed skill by 1.25. Retention is eight seconds after the last landed swing. Air swings and skills do not charge it. Rejected casts preserve it; accepted casts consume it even if subsequently interrupted. Defeat clears it. Three overhead pips and HUD text show progress; a chime announces readiness. The HUD explicitly distinguishes building stacks from the ready bonus, offers an explanation on hover, and appends the landing-link cue without replacing Resolve status.

**Pursuit -> Riftbreak:** actual landing opens 1.2 seconds to commit Riftbreak for a 1.15 multiplier. Any intervening skill consumes the opportunity. The existing buffer supports pressing 3 then 2; no extra input or cooldown reset exists. A short blue line and HUD cue announce the link.

**Level mastery:** weapon-derived skill damage gains 2% per level after L1, capped at +18% at L10. Resolve/link multiply it. Areas, travel distance and cooldowns do not inflate with level. Shared ability/weapon resources are never mutated by a cast.

## Stage progression

Current campaign ceiling: 3 initially; clearing Stages I/II/III/IV/V unlocks 4/5/6/7/10. New XP stops at the unlocked ceiling; coins/loot continue. Existing earned levels/save XP are preserved. F9 remains a non-saving Level-10 development preset. These caps cover the implemented six-stage campaign; later content and the final 100-stage game's cap are undecided.

## Open work

[Action-kit brainstorm](king-action-kit-brainstorm.md) proposes Crosscut Advance, Faultline, the preserved Pursuit jump and Last Oath, plus a timed-counter alternative. These are proposals, not installed skills.

Owner full-campaign testing must judge the new cut timing, shorter honest reach, Resolve/link values, stage caps and audio mix against starter and crafted gear. Ultimate, Reality Breaking, charged-hold basics and further skills remain future proposals. Production Stage XX Examiner integration is separate from this player overhaul.

## Collection extension — September 13 / Decision 144

The four techniques above remain the default loadout. [The Unwritten Oath](king-unwritten-oath.md) adds four alternative families and four finite forms, with Sanctuary slot assignment and non-persistent Lab previews. Either Pursuit or Starfall can now open the link into Riftbreak or Griefwake. C identity, the physical basic chain, capped level mastery and current stage ceilings remain unchanged. The active player SpriteFrames resource is now `king_oath_sprite_frames.tres`, which includes every approved greatsword action plus the new eight-pose spin; the menu retains the same existing idle art.

## September 14 control clarification and Riftbreak review

Decision 149 explicitly separates flinch, knockback and stun. Only designated heavy/stun contacts carry stun; damage and critical hits do not infer it. Campaign Riftbreak carries 0.52s stun and Worldsplitter only its final contact carries 0.65s, before target resistance. Other King skills now use short flinches. The opt-in F7 targeted Riftbreak comparison uses a 30px stun core, 68px outer push and 0.38s cast. Its generated sixteen-drawing aftermath outlives control recovery; campaign targeting, bespoke body frames and later stage AOE growth remain pending.
