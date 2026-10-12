# King — ten equipped skills and earned domain powers

**Current implementation update — Decision 147:** The owner authorized development. The responsive four-technique core and ten-slot foundation are now installed; eight techniques exist. See [current rules](../decisions/147-responsive-king-core-and-ten-slots.md). Historical timing/four-slot statements below describe the earlier design or implementation baseline. The six divine spells, future stage gates and inheritance rewards remain proposals.

2026-09-13. **Accepted scope:** ten simultaneously equipped skills on 1–9 and 0. Minus and plus may be considered later. **Proposed below:** skill identities, rewards, statuses and exact progression. No new combat implementation is made by this document. Runtime remains eight collection entries and four equipped slots under Decision 144.

The owner clarified that ten means equipped, not merely learned. The collection may eventually contain more than ten choices. The earlier responsive four-skill proposal now describes four core techniques within this larger loadout, not its maximum size.

## Identity and control

King is a mortal adventurer who learns to wield powers earned through the Game. His sword remains one part of his fighting style. Domain spells can use his hand, a planted weapon, a ward or a ground gesture; they do not all become different sword slashes.

Keep basic attack and Space Dash independent of the ten skill slots. Slots are rebindable and configurable in Sanctuary; the suggested arrangement keeps frequent movement/pressure actions near WASD and longer-cooldown spells farther along the number row. Use 1–0 as ten primary keys. If expanded later, the physical key normally labeled =/+ avoids requiring Shift for an essential action; exact extra-slot assignments remain open.

Show ten readable icons in a compact grouped bar at 960×540. Unlock skills gradually; ten available slots do not imply ten abilities granted at the start. Existing four-slot saves will need a migration that retains the four choices and leaves new slots empty. Do not erase them or grant powers merely by expanding the UI.

## Subsequent divine-identity clarification

Decision 146 records the owner's clarification that Examiner is a god as well as a Disciple. A true Plant God is now a proposed Stage X candidate; the earlier guardian/beast-only preference is superseded. [Divine inheritance](divine-inheritance-and-plant-god.md) also expands rewards to passive survival, defense and spell-focused builds. Exact names, rewards and passive slots remain proposals.

## Proposed complete loadout

Names are working names. The first four remain proposals from the preceding responsiveness review; this is not approval of exact effects or balance.

| Key | Technique | Job and meaningful choice | Distinct visual/action |
|---|---|---|---|
| 1 | Crosscut Advance | Frequent small-fan pressure; two cuts with an optional dodge exit | Planted feet and opposing white steel trails |
| 2 | Faultline / Griefwake | Choose a ground point; medium eruption sets up a pack or hits a ranged threat while King regains control | Ground strike, racing crack, concentrated rising stone |
| 3 | Breakstep | Directional evasive reposition; a real successful evade can earn a compact basic-attack riposte | Low body movement, scarf and fading silhouettes; no required landing explosion |
| 4 | Last Oath | Short committed finisher: high-damage inner impact, weaker outward crowd-clearing rim | One decisive blade contact, ground scar, sharp camera accent |
| 5 | Venom Bloom | Place a poison seed; valuable against enemies that remain in an area, less useful against fast repositioning | Seed drops, thorn petals unfold, low green-violet vapor stays near the ground |
| 6 | Storm Thread | Aim at an enemy/point; an arc strikes the first valid target and branches to nearby targets within a bounded hop distance | Hand gathers sparks, one readable main bolt and quick branching arcs |
| 7 | Gravitic Knot | Place a short-lived pull field to gather susceptible enemies before an area attack | Stones lift, a dark central lens contracts, thin inward streaks; King remains free after release |
| 8 | Facet Ward | Brief directional defense against one eligible attack; a deliberate timing alternative to dodging | Several translucent plates snap together, flex on contact and fracture outward |
| 9 | Veilflare | A short flash that disrupts ordinary enemies' tracking, creating breathing room to reposition | Bright local burst followed by dim eye-marked motes; no full-screen blackout |
| 0 | Falling Firmament | Place a large field with several readable meteor impacts; strong area denial, less reliable against mobile bosses | Raised hand, converging embers, distinct falling stones and short-lived craters |

For ranged spells, aiming starts from the player's selected target or pointer/controller reticle; it never silently chooses an unrelated nearest enemy. Confirmation commits the target point or flight direction according to the individual spell. Storm Thread's later branches are visible, range-bounded secondary effects; each enemy is struck at most once per cast.

## Earned powers, not ten variations of sword mastery

Proposed reward structure:

1. Defeat a major domain-bearing enemy or complete its scenario.
2. Receive a guaranteed, uniquely identified **Domain Echo** as part of the existing claimed-reward/save flow.
3. The first qualifying Echo teaches a new technique; later distinct milestones can evolve it or offer a meaningful variant.
4. Ordinary replay rewards stay within existing capped materials/mastery rules. Repeating one boss never grants unlimited permanent damage, copies of a unique unlock or extra equipped slots.

Do not put a mandatory new skill behind a low-probability drop. The reward should visibly recall an attack the enemy used, adapted to King's short commitment and readable silhouette. An enemy's five-second channel should not become a five-second player lock.

Candidate anchors, not locked campaign events:

- **Stage X:** a regional guardian or divine beast could grant Venom Bloom, giving the first major off-sword domain spell. Stage X already has planned relic/signature progression, so the new reward must be coordinated with that pacing. This does not establish that a true god occupies Stage X.
- **Stage XX:** Examiner's required trial could grant Facet Ward, presented as a blessing or lesson. This fits the false-mentor direction, but his production reward is still undecided and the current F7 outcome remains rewardless.
- **Later divine encounters:** storm, gravity, illusion and celestial-fire enemies could teach Storm Thread, Gravitic Knot, Veilflare and Falling Firmament. Their identities and stage numbers remain open.

Early story can portray these as gifts and signs that King is worthy. Later he may recognize that his abilities echo the methods used to control him, then learn to reshape that power himself. This is a proposed progression theme, not a confirmed hidden curse, mandatory loss of powers or change to the family's established deaths.

Not every boss needs a new button. When ten slots are filled, later rewards can expand the collection, deepen an existing technique or introduce a branch with a real tradeoff.

## Status and weakness language

The live game already has armor/ward mitigation, knockback/stagger tiers and enemy-specific control resistance. Poison, blind and the generic status framework below are proposed additions, not current systems.

| Effect | Proposed rule | Readable cue |
|---|---|---|
| Poison | Bounded stacks and duration, damage based on caster skill power; no automatic percentage-of-boss-health deletion | Droplet icon with duration; a few low motes |
| Fracture | Temporarily reduces armor by a capped amount; never grants negative armor or infinite stacking | Cracked shield icon and brief fractured outline |
| Shock / stun | A short interruption on an eligible target, with resistance and reapplication limits | Sharp electric snap and a distinct stagger/recovery pose |
| Blind | Temporarily stops ordinary enemies refreshing their aim; they attack the last known point. Already committed attacks and warnings remain consistent | Crossed-eye icon; no random unexplained miss roll |
| Pull | Applies bounded movement influence to susceptible enemies; reduced on Elites, rejected by Boss movement authority | Inward-moving debris shows direction and field boundary |
| Ward | Explicit direction, duration and capacity. Reflect only projectiles explicitly marked reflectable; major Verdicts remain governed by their own rules | Facets show facing; a contact crack indicates consumption |

Poison ticks do not grant Resolve, stun every tick, repeatedly shake the camera or recursively trigger other status applications. Only named interactions are supported initially; avoid an opaque reaction matrix.

Bosses retain ordinary knockback/stun immunity unless their encounter explicitly opens a vulnerability. A resisted control effect should say so briefly; its legal damage may still apply. Examiner's existing charge-seal break remains the owner of his earned stun window. Do not turn generic Shock into a bypass.

Weakness should also be situational: an armored enemy exposes its back after a missed charge; an enemy ward is powered by breakable conductors. A matching domain spell may exploit the opportunity efficiently, but the encounter should retain an ordinary-attack solution instead of requiring one exact equipped skill.

## Useful combinations, with competing choices

- **Gather and contain:** Gravitic Knot groups ordinary enemies in Venom Bloom. Use Storm Thread to exploit the cluster, or save it and place Faultline if ground control matters more.
- **Break and finish:** Faultline's precise impact can apply Fracture to armored enemies; Last Oath then rewards landing its narrow center.
- **Defend and retaliate:** Face Facet Ward into an eligible hit, or use Breakstep to escape and earn a riposte. One defends position; the other changes position.
- **Cover a retreat:** Veilflare disrupts tracking; reposition and leave a Falling Firmament field behind. Enemies that move out avoid later meteors.

All ten being equipped must not imply pressing all ten whenever they become ready. Use different cooldown bands and situational payoffs: short pressure tools, medium setup/control tools and longer area/defensive powers. Start without introducing a second mandatory mana/stamina bar; add a resource only if playtests expose spam that cooldowns and opportunity costs cannot solve.

## Growth and presentation constraints

Stage upgrades improve bounded damage, range or functionality according to role. Keep Crosscut compact, Venom sustained, Storm Thread dependent on target spacing, Gravitic Knot primarily utility, Last Oath concentrated and Firmament broad but spread over time. Do not independently maximize every skill's damage, radius, crowd control and uptime.

Preserve current equipment and stage-cap authority. Resolve's existing caster-skill bonus needs a defined snapshot for delayed/status damage so one use cannot amplify repeated applications unpredictably. Exact numerical curves are intentionally deferred until the ten-slot prototype and early gear measurements.

Ordinary control should return shortly after a spell is released. Damage fields may continue under separate attack authority, while cosmetic debris persists quietly. Defensive timing stays distinct from an excuse to add invulnerability to every spell. Keep each powerful effect to a clear preparation, decisive contact and short decay; effects must not conceal enemy danger.

Animate actual hand/weapon/body poses and preserve King C's small anatomy. Use different silhouettes and sounds, not only different colors: seed growth, branching lightning, inward gravity, glasslike ward plates, a local flash and falling stones. Reserve the strongest camera/hit pause for major accepted impacts and coalesce crowd hits.

## Next prototype and runtime boundary

First settle the core responsiveness concepts and build ten configurable equipped slots without changing the default player's learned powers. Then prototype one new status and one ranged spell, verify target/control/damage lifetimes, and expand incrementally. Review the full bar and targeting at 960×540 before generating every new sheet.

Runtime changes will involve input mappings, slot/loadout/catalog validation, saved-loadout migration, collection/HUD layout, controller access and optional auto-skill selection. A reusable status authority should own application, duration, caps, resistance, source attribution and cleanup; animation/HUD should only observe. Tests must cover old saves, all ten bindings, input ownership, interruptions, overlapping released skills, invulnerability exceptions, boss immunity, effect expiry, death/unload and reward claims.
