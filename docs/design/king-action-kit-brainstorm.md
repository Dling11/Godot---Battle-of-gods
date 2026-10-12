# King action kit brainstorm - 2026-09-13

Status: historical proposal, superseded by [the implemented Unwritten Oath collection](king-unwritten-oath.md), Decision 144. The original four remain alternatives; the new mobile option is Starfall Step. The ideas below record the earlier comparison, not current runtime rules.

## Direction

King should feel like a progressing greatsword fighter who earns openings through movement and sword work. His ordinary clothing and compact silhouette stay. White steel crescents are his common visual language; they follow the blade, distinguish actual contact from anticipation, and clear quickly enough to read enemy attacks.

Resolve already supports this: three successful basic swings earn one stronger skill. Keep it as a choice of where to spend power, not a second mana bar. One swing earns one pip regardless of crowd size. The player can spend on an opener to reach an enemy, on a punish after dodging, or on a finisher during a boss recovery. No new resource is needed.

## Recommended kit

| Slot | Proposed action | Purpose and counterweight | Animation / effect identity |
|---|---|---|---|
| 1: Crosscut Advance | A short collision-safe step into a horizontal cut, a visible reset, then an opposing cut. Direction commits before movement. | Close a small gap while attacking. No invulnerability; an enemy can punish careless entry. Each cut has its own contact window, with no damage during the reset. | Low shoulder coil, leading foot plants, white crescent, visible blade return, opposing white crescent, weighted settle. Two real sword actions rather than standing in a pose while an echo fires. |
| 2: Faultline | Plant the blade and send a short ground fracture forward, opening near King and then farther along the same lane. | A directional punish/space-control tool rather than another circular explosion. Strong contact stagger still respects enemy resistance and boss control immunity; no guaranteed boss stun. | A deliberate raised-blade anticipation, one grounded impact, sequential cracks emerging from that exact point, debris settling in place. A narrower readable lane trades coverage for reach. |
| 3: Sovereign Pursuit | Preserve the existing targeted jump, physical travel and landing. | Reposition, evade during the existing travel window, then choose a follow-up. Preserve collision stops and the actual-landing requirement for the Skill 2 link. | Compress before launch, clear airborne silhouette, downward landing, short settle. The landing point and residual remain fixed when King walks away. |
| 4: Last Oath | King performs a committed three-cut sequence: close crosscut, reverse cut, then one broad white crescent finisher projected forward. | A powerful punish during a real opening. Recovery makes it risky to throw into an attacking boss. It does not teleport between enemies or automatically track a retreating target. | Each hit gets a distinct stance and contact frame. The final swing uses the largest white crescent; avoid covering King with a giant light blob. Strongest audio and brief impact pause belong to the final accepted hit. |

This changes the jobs of 1, 2 and 4: engage, control a lane, and commit to a finisher. The jump remains the mobile centerpiece. The proposed sequence is jump -> Faultline during the landing link, or build Resolve -> Crosscut to engage -> Last Oath when an opening exists. It must remain possible to stop attacking and dodge rather than requiring long uninterruptible input strings.

## Alternatives worth comparing

- **Steel Reversal instead of Faultline:** a short timed guard followed by a countercut if struck. More enemy interaction and a higher skill ceiling, but adds guard rules and needs clear treatment of unblockable boss attacks. A missed guard has ordinary recovery, not free invulnerability.
- **Draw Cut instead of Crosscut:** a short retreating slash, then an optional existing-buffer forward strike. Strong spacing identity, but less useful for the current problem of reaching enemies with a greatsword.
- **Keep Worldsplitter as a future alternate slot-4 loadout:** the summoned blade fits later divine power. Last Oath better emphasizes early King's own physical swordsmanship. Do not add a fifth button or unlock it without a progression decision.

## Implementation boundaries for a future kit change

- Prototype Crosscut first, then compare its close-range pressure against the current delayed echo. Do not claim the new kit plays better before testing it.
- Player/movement owns displacement and wall collisions. Components own contact windows, cooldowns, damage, target selection and cancellation; animation only observes.
- Keep current equipment speed rules, input buffering, level mastery, stage caps and save contracts. Decide timing from the established ability rules rather than silently applying basic-attack haste to every skill.
- Resolve is consumed once on a committed skill, not once per cut. Shared definitions remain immutable. The pursuit link opens only after real landing and cannot be refreshed by visual replay.
- Check each direction, walls, arena edges, moving targets, armored enemies, boss resistance, interruption between hits, death, scene unload and simultaneous buffered inputs.
- Generate small action proofs against the approved C reference before whole sheets. Reject missing blades, wrong-facing frames and stretched anatomy. All blade tips need padding; floor art uses explicit fixed contact anchors, never debris bounds.

## Completed in this review

The front/back gait correction, separate basic finishing sweep, back-facing defeat correction, clearer Resolve wording and continuous anchored Riftbreak crater are installed. Pursuit's legacy 16px world-space landing offset is also corrected to zero so damage and presentation share King's actual feet. Skill damage values, radii, cooldowns, movement authority, Skill 3's jump and progression rules are preserved. Decision 144 subsequently implements the collection direction; see its runtime document for the final mechanics and remaining balance work.
