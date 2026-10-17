# Weapon mastery, base crafting and combat expansion

## Installed follow-up232

The owner now approves creation after Cyclone review. Veyr/northern court, a real-action Axe proof, permanent Cyclone and one proof-opened Nema pattern are installed for review. This supersedes the old deferred mentor/earning statements below. No combat-XP curve is selected. Detailed current rules: weapon-court-and-first-proof.md; other family lessons, item evolution and broad combat expansion remain proposals.

Updated2026-10-18. The first Axe proof/mentor/forging loop is installed under232; the remaining broader progression, evolution and combat ideas below remain proposals. Preserve the accepted B HUD and settled actor artwork.

## Earlier follow-up228

The owner requests first Axe skill before mentor/earning implementation and wants a distinctive mechanic rather than another ordinary XP bar. War Cyclone is playable as a session-only F9/Combat Lab review; it grants no permanent learning. See axe-war-cyclone.md. A discovery/practice/weapon-proof loop is a new recommendation to discuss after skill review; no earning formula or NPC identity is selected.

## Owner direction

- Weapon crafting belongs at the Sanctuary/base. Upgrading weapons should also form part of the preparation loop there.
- Weapon active skills come from weapon mastery. Owner clarifies these are unique actions requiring their own combo/animation frames; the first Axe action is now implemented; other family techniques remain deferred. The current HUD direction supports up to8 King powers and6 equipped-weapon techniques, showing only unlocked active skills.
- Weapon upgrades should eventually have visible milestones: new weapon designs, matching equipment/HUD icons and clear upgrade presentation. Mastery5 is the owner's example milestone, not a balanced final threshold.
- Preserve the full combat vocabulary: physical, magic and pure damage; criticals; defense; HP-based damage; abnormal statuses including poison, blind and slow; stun, knockback; misses and evasion. Recording an idea does not make it implemented.
- A new Sanctuary weapons mentor is an idea to explore. The owner has not selected the NPC name, artwork or exact XP-earning model.

## Verified baseline

`DamageInfo` already carries physical/magic/pure type, critical metadata and independent stun/stagger/knockback. `HealthComponent` resolves physical through armor, magic through magic resistance, then ward; pure bypasses these reductions. Guard, temporary shield, invulnerability and encounter-specific control rules remain authoritative (Decision178). Critical presentation and existing crowd-control tiers are installed.

The current skill loadout has ten compatible data slots; Decision225 now provides compact native HUD and themed current-data tooltips. Separate weapon-technique progression and family mastery are not implemented. The14-slot concepts are a future capacity illustration, not14 granted skills.

Nema already presents deterministic recipes and `CraftingService` owns the ingredient/gold/output/save transaction. Its inspected public `try_craft` path does not yet express the newly requested Sanctuary-location permission. Enforce that rule at the crafting authority when implemented, with a valid base/station context; a hidden button alone is insufficient. Preserve current inventory/profile IDs, starting equipment and earned skills during migration.

## Three kinds of progression

| Track | Represents | Owns |
| --- | --- | --- |
| King level | General character growth | Existing XP/level and King progression |
| Weapon-family mastery | King learning a fighting discipline | Learned weapon techniques, family choices and trials |
| Forged weapon tier | The particular item King carries | Item stats, traits and reviewed weapon/icon appearance |

Learning Axe mastery carries over to another axe. Switching family shows that family's progression; it does not erase previous learning. Forging a better axe does not reset its owner's mastery. Ordinary basic combos remain usable immediately; mastery adds techniques rather than making a newly crafted family unusable.

Recommendation: stages award materials and blueprint discoveries, then the player forges/evolves equipment at base. The accepted location restriction does not itself authorize deleting starting equipment, changing existing rewards or migrating every recipe now. Nema remains the current crafting authority/service; station/NPC presentation can expand without duplicating transactions.

## Earlier earning model: combat, clears and proofs (unselected)

The following records the earlier XP suggestion only. The owner's latest direction is distinctive learning after Axe skill1, not an ordinary secondary XP bar; these values and attribution rules are not selected for implementation.

| Source | Purpose | Proposed rule |
| --- | --- | --- |
| Genuine enemy defeats | Steady progress while using a weapon | Enemy-value XP attributed to the family that contributed eligible weapon damage |
| Stage completion | Reward finishing the expedition | A bounded clear bonus distributed among meaningfully used families |
| Mentor trials | Demonstrate understanding at important ranks | Short authored challenges unlock milestone lessons/evolution eligibility |
| Campaign milestones | Pace access to materials and advanced challenges | Open recipes/trial availability; do not replace weapon practice with automatic mastery |

This is a recommendation, not an accepted XP formula. Start with a simple deterministic prototype and tune values against equal-time Sword/Greatsword/Twinsteel/Axe/Reaper play. Do not introduce daily chores or mandatory rare XP drops.

Credit comes from an enemy's bounded reward budget, not raw hit count. Rapid Twinsteel hits, a slow Greatsword hit, a critical and poison ticks must not multiply one enemy's XP pool. Attribute released attacks/statuses to their originating family at commitment/application, so switching just before a kill cannot transfer all credit. Cap attributed damage at genuine remaining HP; do not reward overkill, invulnerable contacts or test dummies. Author any future support/control credit explicitly instead of awarding XP for every status tick. The first solo implementation can use weapon-damage contribution; more elaborate support credit is deferred.

A King power contributes only under an authored eligibility rule, such as a weapon-derived strike credited to the equipped family at cast. A purely independent divine spell must not silently train an unused weapon. Clear bonuses use the expedition's contribution record, not only the weapon held while opening the chest. Existing one-versus-two weapon policy remains undecided.

Proposed death behavior: earned mastery XP follows character XP's persistence expectations, while unbanked materials retain the existing expedition rules. Validate this with real saves before accepting it. Persist stable family IDs and milestone/claim IDs, never scene/resource paths. No live save migration is performed in this planning pass.

## A prospective mentor

Working proposal: **Veyr, the Godscarred** — a battle-worn mortal weapons master. Name, title, backstory and appearance are unapproved.

Visual direction: lean mature silhouette, ash-dark hair with one pale streak, a scar across one brow, charcoal half-cloak, one battered iron pauldron and wrapped weapon hand. Restrained cold-steel accents distinguish him from King's red scarf. A small training circle and a readable five-family weapon stand explain his service. Match current Sanctuary scale, palette, lighting, depth and complete-body anatomy; review a concept before generating animation or placing a station. No house/environment redesign is implied.

Potential services: view each family's mastery tree, explain the next milestone, select learned weapon techniques and enter short practice trials. The first implemented lesson uses action proofs, without weapon XP; further earning rules remain open. Do not make the NPC a gold vendor for unlimited mastery.

Suggested future division: Eira retains King powers and their loadout; the new mentor handles weapon-family lessons/trials; Nema forges/evolves items; Orren retains his existing workshop/preparation role. This is a proposed division, not permission to remove current NPC functionality or grant the mentor unapproved divine lore.

## Weapon-technique examples

These are brainstorm names/actions, not unlocks, damage values or completed animations:

| Family | Example | Identity and limits |
| --- | --- | --- |
| Axe | War Cyclone | Up to five seconds of blade-led spinning; slower movement, dodge cancellation, authored contact cadence and per-target control limits |
| Greatsword | Falling Titan | Two-hand windback, powerful leap and large landing cleave/shockwave; high commitment and strong payoff with clear landing feedback |
| Twinsteel | Phantom Cross | Fast alternating focused strikes and a short reposition; bounded on-hit effects, not automatic invulnerability |
| Sword | Oathbreaker Counter | A readable timed defensive response leading into a precise counter; any promotion of the current Lab-only pure counter needs explicit review |
| Reaper | Reaping Brand | Mark/arrange a group, then exploit the returning weapon or wounded target; develop existing hook/reap identity instead of making a second generic spin |

For the owner's five-second Axe example, duration and attack cadence are distinct: attack speed may increase bounded contact cadence while the authored channel stays five seconds. Do not automatically shorten the channel because ordinary combo phases speed up. No five-second uninterruptible input lock or free invulnerability is implied. Repeated hits need balanced damage/status coefficients and must not stun-lock bosses or spawn one expensive effect/audio voice per target per tick.

Heavy spectacle does not automatically mean pure damage. Greatsword can deliver very high physical damage through an authored coefficient and commitment; critical chance, status application, knockback and stun remain separately defined.

## Mastery milestones and visible evolution

Recommendation for the owner's Mastery5 example: achieving the rank opens a mentor proof; completing it enables an explicit base evolution recipe. Materials and gold fund the item upgrade, mastery supplies eligibility, and the resulting variant receives a new readable weapon design/icon and reviewed effects. The player sees requirements/results before spending. Exact rank, quest, costs, automatic-versus-crafted evolution and branching remain open.

Do not automatically transform every owned weapon or confuse family rank with an item's upgrade level. Prefer a reviewed family-compatible steel variant and reuse approved grip/motion contracts where appropriate; do not redraw King's head/body for every item upgrade. A radically different silhouette may still need grip, directional, collision/reach and action checks. Preserve matching physical/Bag/HUD silhouettes and avoid relying on a recolor alone for a major evolution.

Add one rank-up cue and a clear next-milestone tooltip to the selected C2 display. Progress/rank must bind real family authority. Stage trial generation temporarily, keep only approved runtime assets and compact metadata, and never restore `art_source/generated` or an iteration archive.

## Combat vocabulary and proposed rules

| Concept | Meaning and design direction | Current status |
| --- | --- | --- |
| Physical damage | Resolves through physical armor then applicable ward | Implemented baseline |
| Magic damage | Resolves through separate magic resistance then applicable ward | Implemented baseline |
| Pure damage | Bypasses those reductions, while existing guard/shield/invulnerability rules remain | Implemented baseline; no universal starter pure skill |
| Critical | A separately authored chance/multiplier and stronger hit feedback, not a fourth damage type | Implemented baseline |
| HP-based damage | A scaling formula, independent of physical/magic/pure type | New general framework proposed |
| Poison / bleed / burn | Timed damage with authored type, duration, bounded stacks and clear refresh rules | Generic status framework/content proposed |
| Blind | Recommended initial behavior disrupts ordinary enemy aim updates/attacks last-known position; committed warnings stay honest | Proposed |
| Miss / evasion | Distinct accuracy failure or successful avoidance, with clear feedback; ordinary air swings are not random failed hit rolls | Broader probabilistic model proposed; existing dash i-frames remain |
| Stun / stagger / knockback | Independent authored control, scaled/rejected by current target tiers and encounter rules | Implemented baseline |
| Slow / root / fracture / weakness | Different movement, armor or offense changes with bounded duration/stack rules | Expanded generic statuses proposed |

HP scaling must explicitly name the subject and basis: target current HP (opening pressure), target maximum HP (tank pressure), target missing HP (finisher), or caster maximum HP (an authored tank-build option). Do not label all of these simply `%HP`. Bosses need specific coefficients and absolute/relative caps; no generic percentage poison deletes a boss in a few ticks. Distinguish `% weapon power` from `% target HP` and show per-hit versus full-sequence totals in skill tooltips.

For statuses, define source, duration, stack cap, refresh/replacement rule, mitigation/control resistance and whether periodic damage may critically hit. Recommended first poison implementation: offensive snapshot on application, existing typed damage authority for ticks, bounded stacks, no tick-triggered hitstop/stun/knockback or recursive proc/XP loops. Final poison type and numeric tuning are not chosen yet. Existing boss control immunity and enemy-specific resistance cannot be bypassed by calling a status magic/pure.

Recommendation: keep baseline aimed attacks reliable. Add visible, bounded accuracy/evasion effects only when authored; do not impose universal random misses on every King attack. Distinguish MISS, EVADE, BLOCK, IMMUNE and RESIST so the player knows whether damage failed or a control effect was rejected. A resisted stun may still deal its legal damage. Broad evasion should not make every boss warning ignorable.

## Implementation sequence and checks

1. Build the selected compact C2 HUD and themed hover cards using real current data; preserve saved skills, accepted actor art and input authority. Empty technique/mastery rows cannot show invented progression.
2. Add family mastery and one family's first two real techniques as a small playable prototype. Keep permanent unlocks separate from equipped slots; plan migration from current ten-slot data.
3. Expand base-only crafting permissions and deterministic family recipes/upgrades through the existing transaction/save authority. Verify denial outside base and exact rollback on failure.
4. Introduce one bounded status (poison is a candidate), its feedback/tooltip and real-enemy tests before extending the full catalog. Test crit/type/shield/control interactions and large-group cadence.
5. Review the proposed mentor concept and milestone earning rules, then add a short trial and first visual evolution. Tune mastery earning across slow/fast/cleave families and fresh/existing profiles.

Acceptance includes no dummy/overkill XP multiplication, correct source attribution on released hits/ticks, no duplicated clear/milestone rewards, compatible saves, crafting location/transaction checks, boss percent-damage/control limits, honest hover values, readable native UI and crowded-fight frame-time measurements. These are future checks, not tests run by this design document.

## Inspiration and open choices

Official references: [Grim Dawn combat guide](https://www.grimdawn.com/guide/gameplay/combat/) distinguishes defense, criticals, current-life damage and status/control rules; [Guild Wars2 mastery introduction](https://www.guildwars2.com/en/news/reimagining-progression-the-mastery-system/) describes progression that unlocks abilities and interactions. The proposed hybrid family/trial/crafting model above is our design recommendation, not a copy of either game's exact progression.

Open: XP curve and persistence policy, trial gates, mentor identity/art/services, item evolution threshold/costs, first two family techniques, probability-based evasion rules and status/HP-scaling values. Owner directions above remain durable while those details are refined. No commit/push, save mutation, new NPC or runtime balance change is part of this pass.
