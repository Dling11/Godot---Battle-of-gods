# Decision 139: Examiner breakable seal, Borrowed Sun and Unbound

## Status

Decision 140 supersedes the Sun presentation, 1.15s flight, 0.42s release and 76/108px radii below, and adds Crimson Firmament. Seal/stun and phase rules remain current.

Owner-authorized, implemented in the F7 combat proof on 2026-09-12. Supersedes Decision 138's after-HP damage check, earned-sanctuary success and 70%/35% repeated-trial rules. Its Stage XX false-mentor story direction remains current. Final owner feel-testing and Stage XX integration remain pending.

## Decision

- The gold seal bar is separate from the red HP bar. During a charge, armor/ward-mitigated hits consume the seal and leave HP unchanged. Even the breaking hit has no HP overflow. Breaking it cancels the pending attack, clears its pressure cuts, plays the approved kneeling pose, and grants 2.6 seconds of stun plus 0.45 seconds of standing recovery. Following hits damage HP normally. Phase changes wait until this punish window and committed attacks finish.
- Trial of Worth occurs at/below 60% HP after the existing short dialogue. The seal requires 240 mitigated damage in 7 seconds, with the existing warned ground cuts. Success cancels Divine Descent entirely. Failure commits the existing 800-raw-damage Verdict, which pierces dodge invulnerability but respects armor, ward and explicit lab immunity. No sanctuary is awarded by this version. Court protection geometry remains a reusable dormant API. This is a deliberately severe gear/burst check, not a forced-death command.
- Borrowed Sun first becomes available after 10 seconds, then has a 15-second cooldown measured from charge start. Its separate seal requires 210 mitigated damage in 5.5 seconds. Breaking it causes the same stun. Failure enters a 0.42-second throw stance, snapshots King's location, then launches an airborne Sun over props to that fixed point. The crimson 76px ground radius warns throughout 1.15 seconds of flight. Impact deals 155 raw damage once; ordinary dodge works. The subsequent detonation is visual decay only.
- First Measure approaches at 66px/s. Second Measure follows the 60% trial at 86px/s and slightly shorter normal recoveries. At/below 35% HP, Third Measure: Unbound uses a 1.5-second awakening, 106px/s approach, 1.65x ordinary attack damage and 22% shorter ordinary recoveries. Warnings, guard windows and earned stuns are not sped up. A threshold crossed during a committed action is evaluated on return to approach.
- Unbound enlarges Borrowed Sun's radius to 108px and damage to 255.75. Its new Crownfall skill marks three fixed 88px-radius seals across King's snapshotted position. They fall at 1.1/1.8/2.5 seconds for 272.25 raw damage each, allowing a perpendicular escape. Crownfall has a 13-second cooldown and commits Examiner for 2.9 seconds. It opens the berserk phase and repeats through normal action selection.
- Character PNGs, SpriteFrames, pixel density, weapon silhouette and body origins stay unchanged. Charging reuses the approved overhead raise, release uses thrust contact/recovery, and guard break uses kneeling landing/recovery. One new eight-frame white/gold/navy Sun atlas supplies buildup and detonation; six original synthesized cues supply charging, shatter, release, impact and awakening. The existing single music foundation rises in intensity through mix level, without overlapping songs.

## Ownership and validation

`HealthComponent.damage_absorber` is an optional callable after mitigation and before HP mutation. A consumed hit emits `damage_absorbed`, returns accepted, and does not emit `damaged`, change HP or trigger death. `ExaminerTrial` owns seal health, time, warned cuts and cancellation. `Examiner` owns state/phase transitions and each `ExaminerSun` lifetime. Sun warning and damage use the same landing point/radius, and owner death/reset removes all pending Suns. The boss HUD only observes values.

Focused checks cover absorption/no overflow, stun vulnerability, threshold deferral, successful cancellation, failed release, fixed landing geometry, one impact, dodge/armor, three Crownfall seals and cleanup. Existing movement, body identity, HUD and Court checks remain applicable. Review assets live under `art_source/review/characters/disciples/examiner/ascendant_2026_09_12/`. Generation prompt and body hashes live in the matching generated-source directory.

## Limits

This does not implement Stage XX route, rewards, final scenario outcome or saving. Gear progression is insufficient to guarantee exact Stage I-X versus later-equipment survival or whether a given loadout can break either seal. Numbers are prototype tuning; the owner should review with F7 immunity off when testing actual difficulty.
