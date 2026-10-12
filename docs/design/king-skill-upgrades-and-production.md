# King Skills 1-2: upgrade and production plan

**Current campaign correction (Decision 164, 2026-10-02):** Eira now trains Earthsplitter Fan at Level2 and Molten Advanced/Awakened/Mature at3/6/9 with compatible saved ranks. Existing per-form gameplay/art/cooldowns remain. Earth Cascade stays a Lab alternative. Earlier Lab-only/future-gate statements below are historical. See sanctuary-npc-usability.md and ../decisions/164-eira-reachable-curriculum.md.

**Current runtime (Decision 157, 2026-09-26):** Earthsplitter Foundation and blue Molten Crash Foundation are production Skills 1/2. Fan/Cascade and Advanced/Awakened/Mature remain F7 session-only form comparisons. Stage unlocks, persistence for later forms and owner balance review remain open. The older execution checklist below records the prototype; campaign replacement and archive cleanup are now complete.

**Molten Crash upgrades (Decision 155, 2026-09-26):** Skill 2 now has four selectable Lab forms: 72px blue stone-and-light Foundation, 80px molten Advanced, 84px Awakened with one delayed 86px damage-only heat pulse, and 86px Mature with a stronger center and gentler damage rim. One .36s local sword cast, 8s cooldown and initial authored stun remain. The pulse resolves at the original impact while King can move. F7 -> KING REVIEW -> SKILL 2 and FORM compares them. Campaign unlock/persistence and owner feel review remain pending.

**Skill 1 accepted direction (2026-09-26):** Earthsplitter Fan now releases three simultaneous lanes at center and +/-20 degrees, followed .22s later by one stronger, longer center wave. One sword smash and .36s base commitment remain. Initial lanes reach 196px (19px radius), deal 100% weapon damage once per enemy across the fan, and use light push/flinch. The follow-up reaches 228px (21px radius), deals 140% once more, and has heavier impact/55 knockback. Maximum unmitigated noncritical weapon budget is 240% per target; side targets usually receive only the fan. No stun. Foundation and Cascade remain separate Lab comparisons. Campaign promotion, upgrade gates, phone testing and the requested later cleanup remain pending.

Status: Skill 1 Foundation, Advanced Fan and the preserved Cascade candidate are implemented in the Lab. Skill 2 Foundation, Advanced, Awakened and Mature are implemented there as selectable forms (Decision 155). Skill 1 later forms and campaign gates for both skills remain planned; these are prototype targets, not final campaign balance. The separate-summon correction in [the concept note](king-spirit-sword-concepts.md) overrides the older images. Existing hit pauses add wall-clock time. Equipment attack-speed bonuses affect basic attacks, not skill phase speed; no new cast-speed stat is introduced.

The September 14 owner-approved sword is the durable summoned-weapon reference (Decision 151). Foundation now has fixed 164px directional aiming and sequential ground eruptions with embedded white-blue energy; its decorative endpoint burst is not the planned upgraded damaging explosion; stage-based unlocks described below are still planned; Advanced can currently be selected manually in the Lab. Within each future form, cursor distance should not alter reach; authored stage/form data sets its bounded range.

## Locked direction and responsiveness

King acts while a distinct large sword appears. Earthsplitter swings into the ground and sends a fast rupture toward the aim. Molten Crash briefly lifts its summoned sword before a local impact around King. Preserve the approved compact character and molten palette.

Target a 0.32-0.42 second player commitment at baseline equipment speed, with first contact around 0.18-0.24 seconds. These are starting targets for the motion proof. Target selection time is separate. Higher forms must not extend the commitment. Respect existing equipment/cast-speed authority; do not independently accelerate damage and animation clocks. Summoned weapon, rupture and debris can finish after movement returns. No new invulnerability is assumed.

Use short anticipation, accelerating travel, a crisp contact beat and a short body recovery. Author enough distinct poses and smear/impact drawings to cover these beats without slowing playback to show every drawing.

## Proposed upgrade forms

These are upgrade ranks within each skill, not new equipped slots. Skill 2 remains the stronger close-area control tier; Skill 1 owns aimed lane pressure. Ten-slot progression remains intact.

| Form | Earthsplitter | Molten Crash |
| --- | --- | --- |
| Foundation | One short advancing fracture and one damage opportunity per enemy. Clear, narrow aimed lane. | Implemented Lab: blue stone/white-cyan light, 72px radius, 200% weapon, .55s initial stun, .36s cast and 8s cooldown. |
| Advanced Fan (implemented Lab) | Three simultaneous lanes from one contact, center and +/-20 degrees. 196px initial center reach, 19px lane radius, 100% weapon damage once across the fan; then a 228px/21px center finisher for 140% more. Cascade remains a possible later/third upgrade, with rank and fan combination undecided. | Implemented Lab: the approved orange molten appearance, 80px radius and 230% weapon on the initial crash. |
| Awakened | The last rupture section detonates. Reserve part of the cast's damage budget for that endpoint; accurate placement earns it. | Implemented Lab: 84px crash for 192% weapon, then one world-fixed 86px outward heat wave for 48% after .34s. Only the first contact stuns. |
| Mature | Stronger endpoint and modest lane-width growth; a capped visual crescendo. Preserve the recognizable swing and earth-tearing silhouette. | Implemented Lab: separate central basalt uplift at contact, 86px initial radius, 216% weapon within 48px, 72% of that initial value at the rim; then one 86px damage-only outward heat wave for 54%. Initial stun still reaches the rim. |

Current Earthsplitter Lab budgets: Foundation 165%, Fan 100% once across its three lanes plus 140% center follow-up, and Cascade 225% weapon damage split across successive waves (1.364x Foundation). This supersedes the earlier illustrative 1.15x Developed target. Cascade releases at 0/.16/.32s after contact, each wave traveling .25s, with the same .36s player cast and 5s cooldown. Molten's four Lab budgets are 200%/230%/240%/270% at the center before mitigation; the last two split 80/20 between crash and pulse, and Mature has gentler outer initial damage. Apply existing equipment, mastery and eligible combo modifiers to the cast budget. No four-step campaign unlock ladder is implemented.

For Awakened Earthsplitter, initially test 70% of the budget in the advancing rupture and 30% at the endpoint. Molten's implemented Awakened and Mature forms use 80% on the crash and 20% on one aftershock. Each pulse deduplicates targets once; a target can receive an initial hit and one later hit if still inside the area. Mature lowers only its outer initial damage, retaining initial stun there.

Start with maximum growth limits of 1.4x Earthsplitter length, 1.25x lane width and 1.2x Molten radius relative to each Foundation form. A 1.2x radius already gives 1.44x area. Actual base dimensions must be tested against the arena and enemy sizes.

## Stage and level progression

Verified runtime: King mastery adds 2% skill weapon damage per level after 1, capped at 18%; king_path starts the level ceiling at 3, unlocking 4/5/6/7/10 after the first five stage clears. These existing rules remain authoritative.

Plan each new stage-clear upgrade as a bounded damage/range/area step within its unlocked form. Larger behavior changes require an authored progression milestone, not repeated farming. First-region content should teach Foundation and Advanced; later region/boss rewards can unlock Awakened and Mature. Exact stage numbers beyond implemented content remain unset, rather than inventing Stage 10/20 progression that does not exist yet. Do not change the eventual whole-game level cap here.

Repeated stage clears cannot repeatedly award the same upgrade. After the final form, equipment and future skill choices remain relevant without infinitely increasing hit counts or screen coverage. Extra Earthsplitter rupture sections are not charges. Sovereign Pursuit is the deliberate proposed exception: its separate [range-and-charge progression](sovereign-pursuit-charge-progression.md) grows from one to three individually aimed uses. This is documented design, not implemented cooldown authority or an approved campaign unlock.

## Trails, particles and sound

Earthsplitter: a brief curved white smear follows the summoned blade only during its fast swing. At contact, a compact white flash and stone chips launch a jagged fracture. Light lives inside the split; broken floor plates and the advancing dust front define the trail. No clean flying crescent, dotted lightning line or stationary magic-geyser chain.

Molten Crash: a short upward ember draw precedes the descending sword. Contact creates white-hot orange cracks, low outward debris and brief sparks. The residual cools toward dark red and charcoal. The aftershock is a quick readable pulse, not continuous bright fire hiding enemies.

Keep large particles away from King's face and enemy tells. Ground scars stay at their contact location; debris follows short arcs and settles. Particle density increases less than damage does. Preserve the established pixel density, outlines, palette and camera perspective.

Audio recipe: quiet manifestation cue -> fast sword/air movement -> contact crack plus restrained low impact -> short stone scatter (Skill 1) or subdued heat tail (Skill 2). Avoid a separate loud boom on every upgraded rupture section. Give the endpoint one accent; cap simultaneous sounds and shake so crowd hits cannot multiply loudness or camera motion. Reuse existing accepted-hit feedback authority; physical ground contact and confirmed enemy hit remain separate events.

## External resource shortlist

Official creator pages checked September 14, 2026. These are candidates and references, not installed assets or auditioned final sounds.

| Resource | Intended use | Published terms / status |
| --- | --- | --- |
| [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds) | Audition short impact/foley layers for contact and debris. | 130 files; CC0. |
| [Kenney RPG Audio](https://kenney.nl/assets/rpg-audio) | Audition weapon movement and supporting foley. | 50 files; CC0. |
| [Pimen Earth Spell Effect 01](https://pimen.itch.io/earth-spell-effect-01) | Reference rock formation, break-up and impact timing; potential supporting art after style review. | Name-your-price; personal/commercial modification allowed; sprite resale/redistribution prohibited; credit appreciated. |
| [Pimen Fire Spell Effect 02](https://pimen.itch.io/fire-spell-effect-02) | Reference explosion shape changes and cooling aftermath; potential supporting art after style review. | Two explosion animations; same stated use/modification and redistribution terms. |
| [GDQuest: Juicing up your game attacks](https://www.gdquest.com/library/juicy_attack/) | Study short anticipation, swing-only smear, easing and layered feedback. | Technique reference; no code/assets copied in this plan. |

Use references to improve timing and shapes while retaining King's identity and our approved sword/ground-effect language. Do not mistake a pack's frame count for final animation quality. If a pack is adopted, preserve its actual included license and source attribution; do not publish its raw sprites as a redistributed asset pack. No purchases or downloads in this planning pass.

## Execution order and acceptance

1. Skill 1 baseline motion proof: separate spawn, weighted fast swing, blade-to-ground contact, moving rupture and early control return. Show real-speed playback plus slow review.
2. Test against walls, multiple targets, four facing directions and equipment speed extremes. Damage must coincide with visible contact; weapons cannot clip their frame edges. No stun on Skill 1.
3. Skill 2 Foundation through Mature are built in the Lab and checked for local contact, target resistance, radius, delayed pulse, early movement and defeat cancellation. Next, owner feel-review the form comparison and decide campaign unlock gates.
4. Compare Foundation and upgraded forms side by side at equal equipment. Test per-target damage budgets, stage unlock persistence, bounded size, repeated input and busy-scene audio/readability.
5. The reviewed Foundations replaced the old campaign alternatives under Decision 157. Later forms remain Lab-only until their stage gates and persistence are implemented.
