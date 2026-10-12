# King responsive combat kit — proposal

**Current implementation update — Decision 147:** The owner authorized development. The responsive four-technique core and ten-slot foundation are now installed; eight techniques exist. See [current rules](../decisions/147-responsive-king-core-and-ten-slots.md). Historical timing/four-slot statements below describe the earlier design or implementation baseline. The six divine spells, future stage gates and inheritance rewards remain proposals.

Status: design proposal only, 2026-09-13. The owner requested brainstorming before implementation after trying Decision 144. No combat, art, audio or progression changes are approved by this document. Decision 144 remains runtime truth.

Scope: the new Oath preset (Crosscut Advance / Griefwake / Starfall Step / Oathstorm). The original four techniques remain collection alternatives.

Subsequent owner clarification: **ten skills equipped simultaneously on 1–0**, not four chosen from ten. Decision 145 supersedes the four-slot end-state assumed below. These four concepts are now core members of [the broader ten-skill proposal](king-ten-skill-domain-powers.md); the runtime still has four slots.

## What the current implementation explains

The configured preparation + active + recovery durations are:

| Technique | Mortal | Unbound |
|---|---:|---:|
| Crosscut | 0.81 s | 1.25 s |
| Griefwake | 1.17 s | 1.65 s |
| Starfall | 0.78 s | 1.14 s |
| Oathstorm | 1.43 s | 2.19 s |

These are calculated from current KingOathDefinition, not measured end-to-end input latency. Player suppresses ordinary movement while an ability casts. Only authored skill travel moves him; finishing the travel does not restore ordinary control. The new definitions retain dash_cancelable=false, so Dash buffers instead of interrupting the cast.

Successful Oath contacts receive Heavy (45 ms) or Devastating (65 ms) global hit pauses through the current feedback presenter. Those pauses freeze enemies too, but repeated pauses can extend perceived lock duration. Oathstorm selects Devastating for every beat, so its strongest feedback lacks a clear final accent. Griefwake's body can finish its slam/settle while the remaining eruption sequence still holds gameplay control.

The reported 2–3-second Skill 2 experience has not been reproduced or timed in this design pass. The installed timelines and control restrictions establish a plausible responsiveness problem without dismissing that observation.

## Design contract

King should engage, place pressure, evade/reposition and finish an opening. Each slot needs a distinct job.

- Separate player commitment, damage-event lifetime and cosmetic lifetime. A launched rupture may continue after King can move; its attack authority must then live independently of the player's current action. Merely unlocking movement while the old component still monopolizes action state is insufficient.
- Upgrades must not make the same button slower by appending mandatory hits. Aim for equal or shorter commitment at higher mastery.
- The player may move while selecting a ground point. Target selection itself has no cooldown cost, charge or attack lock. Confirmation commits one visible point; it does not chase a moving enemy afterward.
- Preserve contextual attack input, one action buffer, equipment authority and stage caps. Plan for ten equipped slots under Decision 145; the current four-slot runtime requires migration.
- Dash before a release point aborts unreleased damage; after release it may cut recovery without erasing the launched attack. Cast acceptance retains cooldown cost, preventing free feints or cancel-reset loops.
- Keep invulnerability specific to evasive travel. Do not compensate for every long cast with blanket armor, immunity or automatic enemy freezing. Existing Elite/Boss control resistance still applies.

All timings and tuning below are prototype targets, not tested balance.

## Proposed four-slot kit

### 1 — Crosscut Advance: close pressure

Use when closing a small gap, cutting a nearby group or keeping pressure during a short opening.

Keep two articulated opposing cuts and a modest forward step. Put useful damage on the first contact. Permit a dodge exit between cuts at the cost of the second strike; release ordinary control after approximately 0.40–0.50 s. Progression improves damage and controlled fan width instead of adding more compulsory cuts. This remains the frequent offensive technique, distinct from the defensive movement of Skill 3.

### 2 — Griefwake / Faultline: aimed ground control

Use against a ranged enemy, a grouped pack, or the location an approaching enemy is about to reach.

Choose a ground point using the existing reticle/confirm/cancel language. A selected enemy may provide the initial reticle point, but the player controls it. King strikes the ground; a readable crack reaches that point and erupts. The connecting crack is cosmetic unless a lane is explicitly included in the target preview.

The center deals meaningful damage and staggers susceptible enemies. The wider, weaker rim briefly slows normal enemies instead of throwing the entire pack away from a follow-up. Bosses receive damage and retain their control rules. Center/rim damage must be mutually exclusive or deliberately capped; no accidental overlapping damage multiplication.

Target ~0.18–0.22 s startup, release by ~0.25 s, ordinary control by ~0.40–0.50 s. Travel, a short second ground pulse and debris may continue independently for another ~0.6–0.9 s. The player can cast and immediately reposition. Committing the point creates a miss risk against a moving target, so useful reach does not become guaranteed damage.

### 3 — Breakstep: defensive mobility with an earned riposte

Use when a boss commits its attack, a melee pack surrounds King, or reaching an exposed flank matters more than dealing immediate AOE.

Replace mandatory landing explosions with a low, sharp evasive step. Movement input selects its direction; otherwise use pointer/right-stick aim with facing as fallback. No second confirmation or automatic nearest-target teleport. World collision still stops movement.

Target ~0.06 s anticipation, ~0.18–0.22 s travel and full control by ~0.30–0.35 s. Only a short middle part of travel grants invulnerability. Ordinary Space Dash remains the general escape; Breakstep earns its skill slot through the combat follow-up.

An actual eligible hostile hit avoided during that protection window primes one short-lived riposte on the next accepted basic attack: a compact, stronger return cut. No automatic attack, extra counter button or added meter. Merely pressing the button nearby does not grant the reward. Unavoidable Verdict mechanics and debug immunity never qualify. If the player uses another skill or the window expires, the opportunity ends.

Completing the step can also preserve the existing short link into Griefwake, replacing its current landing trigger. Choosing a basic riposte versus immediate ground control becomes a small decision. The move remains useful when no perfect evade occurs; its baseline value is repositioning.

### 4 — Last Oath: precise, committed finisher

Use against an exposed boss, an Elite after a missed charge, or a compact group caught by Griefwake.

Replace the repeated all-around storm with one decisive greatsword strike into a point just ahead of King. A compact inner impact receives the high damage; a broader, weaker shockwave pushes ordinary surrounding enemies away and creates room to disengage. The inner impact and outer wave are visibly different, and each enemy receives one intended damage tier.

The narrow valuable center rewards positioning. The outer wave supplies spectacle and safety through actual enemy response rather than a long invulnerability state. Missing the center loses damage; blindly using it into a boss attack remains risky.

Target ~0.25–0.30 s wind-up, a brief contact, and normal control by ~0.60–0.70 s. The ground scar and dust can settle for about a second afterward. Resolve can empower it, but an unempowered cast remains useful; do not make Resolve mandatory or add a second finisher meter.

Use a short directional camera kick and the strongest hit pause only on its decisive accepted hit. Ground-only impact gets a softer, distance-scaled thump, not a fake enemy-hit freeze. Avoid a cutscene, full-screen flash, repeated sub-explosions or long forced slow motion.

## Alternatives considered before selecting 3 and 4

| Alternative | What would make it fun | Why it is not the first recommended pairing |
|---|---|---|
| Skill 3: planted guard-counter | Read an attack, brace, then retaliate with a forceful countercut | Strong dueling option, but loses the mobility the owner explicitly values |
| Skill 3: place-and-return anchor | Dive into danger and choose when to return to an earlier position | Adds a second activation, marker lifetime and more input/teleport rules |
| Skill 4: advancing blade storm | A walking pressure field that clears mobs while King advances | Could rescue the current art, but retains repeated pulses and weaker distinction from the existing kit |
| Skill 4: oath field | Fight inside a placed field to strengthen attacks and hold territory | Adds sustained control/build depth, but overlaps aimed Griefwake control and has less immediate finishing impact |

Breakstep plus Last Oath is the recommended first prototype because mobility, timing reward, precision and crowd utility coexist without more active buttons. The other concepts remain viable future collection alternatives.

## How the kit works together

Crowd example: place Griefwake under approaching enemies, move away from their attack while it erupts, then use Last Oath's tight center on the group. Use Crosscut instead when the opening is too short for the finisher.

Boss example: Breakstep across an evadable committed strike, take the earned riposte or linked Griefwake, then spend a safe recovery opening on Last Oath. None of these attacks assumes it can stun Examiner.

Emergency example: Breakstep out without any attack follow-up. A mobility button should still rescue the player when the damage opportunity is poor.

Do not require a single fixed four-button rotation or stack new marks/debuff currencies on every technique. Existing basic hits and Resolve retain their purpose.

## Stage growth, AOE and damage

Each cleared stage should advance access to a bounded mastery budget. Define those budgets alongside current level/gear curves instead of silently adding another independent percentage multiplier. Replaying a capped stage does not farm unlimited skill strength.

| Family | Damage emphasis | AOE / range evolution | What must stay bounded |
|---|---|---|---|
| Crosscut | Reliable close-range damage | Small fan gains modest width | Two core cuts and short commitment |
| Griefwake | Medium area damage and setup | Aim reach and medium ground area grow independently | Limited pulses and short player release |
| Breakstep | Low baseline damage; compact timing reward | Travel improves modestly; riposte remains small | Evade duration and follow-up frequency |
| Last Oath | High precision-center damage | Compact core; larger but weaker crowd-clearing rim | One decisive hit, short recovery, boss readability |

Damage can advance at stage upgrades while AOE/range grows in bounded steps appropriate to each role. A range cap does not prevent later damage progression. Higher forms can sharpen a center, improve target reach or alter ground behavior without turning every skill into a whole-arena attack. Exact percentages, pixel radii and future milestone gates require the responsiveness prototype and gear measurements first.

## Animation, audio and verification direction

Approve movement/contact/recovery timing in a plain prototype before generating new sheets. Then author actual coil, planted foot, sword acceleration, contact, follow-through and a locomotion-compatible settle. Reuse the approved C identity at human scale; do not stretch poses to fill a longer timer.

Give each attack one audible accent: steel/air for Crosscut; ground crack for Griefwake; a short cloth/air movement cue and optional metallic riposte for Breakstep; steel bite, low thump and quieter debris for Last Oath. Reduce surrounding layers briefly around the decisive impact rather than raising every sound. Final sound quality needs listening in combat.

Keep active enemy warnings readable over friendly residues. Damage-boundary effects must match real shapes; dim settling particles must stop suggesting active damage. Coalesce feedback across a pack so eight contacts do not trigger eight camera shakes or global pauses.

Compare old/new versions against a moving target, ranged pressure, eight normal enemies, an Elite and Examiner with debug immunity/unlimited skills disabled. Measure confirm-to-contact, movement return, earliest dodge, successful buffered actions, incoming damage during commitment and total time including hit pauses. Verify cancel-before-release, dodge-after-release, walls, defeated caster cleanup and late impacts overlapping another skill. Only then lock animations, damage and upgrade values.
