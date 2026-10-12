# Unbroken Vow — playable Skill 4

Status: implemented 2026-09-27. Role and blue barrier approved; current numbers are first playable tuning, pending owner combat-feel review. Worldsplitter is now slot5 and stays learned.

## Gameplay

King braces for .16s, releases pressure, then finishes recovery at .32s. Shielded movement, dodge, basic attacks and other skills remain available after the cast. A single 42px pulse pushes eligible Light enemies without damage/stun, respecting terrain and control resistance.

| Rank | Manual Eira requirement | Shield | Duration | Damage while shielded | Added effect |
|---|---|---|---|---|---|
| Foundation | Core technique | 25% max HP | 6s | +12% | Pressure activation |
| Advanced | Level 7 | 30% max HP | 7s | +15% | +8% movement, sharing the 35% gear cap |
| Mature | Level 10 | 35% max HP | 8s | +18% | Third basic-combo cut gains +30% damage and a small rising/downcut pressure accent |

Cooldown is20s from activation. Startup can be interrupted before protection arrives. The shield is a separate transient pool after armor/ward, not armor or invulnerability; excess breaking damage reaches HP. Full absorption prevents the normal HP-damage reaction. Break, expiry, defeat, rank replacement or unequipping Vow removes its bonuses. Recasts replace rather than stack the shield. Mature does not add a second hit, stun, movement teleport or airborne invulnerability; equipment attack timing still applies. Already committed damage snapshots retain their accepted modifiers.

Resolve, Pursuit-link and Vow bonuses combine additively. Casting Vow does not spend Resolve or the Pursuit link. Level and equipment progression still affect damaging techniques; shield capacity scales with maximum HP.

## Presentation

Production reuses the approved generated barrier and pressure atlases at .5 scale and King's existing foot registration. A generated eight-slot down-facing brace plays on the actual body; left/right/up use existing approved heavy-cleave anticipation/release frames at the same size. Bespoke brace drawings for those directions remain an art follow-up. Hit flash, low-shield flicker, reverse-frame collapse and crimson current use the accepted atlas; no new painted crack sheet is claimed. Mature reuses the approved cleave with a 5px visual rise and one compact Earthsplitter contact accent. No collision movement comes from these visuals.

A numeric shield/time readout and bar sit below the character-menu control. Activation has one existing pressure sound; sustain remains quiet. Prior generated-source/GIF directories are retained as provenance, while the old pose rehearsal remains optional in Lab.

## Worldsplitter — Skill 5

The approved Molten Crash summoned sword now lands at the chosen point, then four small Earthsplitter faults spread into a radial pressure release. King commits .18s startup + .03s contact + .11s recovery; the released follow-up happens .24s after contact while movement/dodge are available. Initial radius54px at220% weapon damage; final radius90px at300%, with .5s designated stun and100 knockback. Range260px, cooldown20s. Preview and commit share terrain clipping; each pulse checks foot radius and line of sight. Presentation owns no hits, and pending attacks cancel on source defeat/scene teardown. Existing generated sword/eruption/pressure art and sound are reused, not a new character design. Later Worldsplitter forms are not implemented; normal equipment/level/Resolve scaling still applies.

## Persistence and testing

Vow rank and layout version are optional fields in the existing version-1 save format. Legacy default Worldsplitter moves4→5; Vow occupies4; displaced techniques move to empty slots, and existing custom Worldsplitter positions remain. The migration is idempotent. Temporary shield/duration never save. Eira level caps still apply; no automatic rank-up.

F7 opens Combat Lab; F9 restores all five skills. Skills tab offers Vow rank selection without training/saving. Use4 to buff and5 to target Worldsplitter; disable AI-tab invincibility to test absorption. Combat, save/trainer, terrain, cancellation and native GPU review live in the focused tests and review README. Phone profiling and subjective balance remain open.
