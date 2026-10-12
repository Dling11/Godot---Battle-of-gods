# Worldsplitter — summoned swords and radial shatter

Current runtime: Decision 162, 2026-09-27. This supersedes Decision 161's rejected single-blade extraction cycle. The owner clarified that repeated strikes mean NEW summoned swords, not the same sword bouncing out of the ground.

## Rank rules

| Form | Summoned blades | Damage per blast | Contact radii | Reach | Training |
|---|---|---|---|---|---|
| Foundation | One blue-white sword | 520% | 88px | 260px | Already learned |
| Advanced | Blue-white sword, then a fresh crimson sword | 220% + 380% | 72 / 96px | 280px | Eira Level 8 |
| Mature | Three fresh crimson swords in rapid succession | 180% + 200% + 320% | 72 / 80 / 104px | 300px | Eira Level 10 |

All swords strike the SAME chosen point. Total damage remains 520/600/700% weapon damage, with ordinary equipment, mastery and critical modifiers. Only the final detonation has the designated .5s stun and 100 knockback; earlier impacts use light 8 push. Terrain LOS, foot-distance checks and one hit per target per contact remain authoritative.

Decision 164 (2026-10-02) sets Eira gates to Level 8/10, so both trained ranks are reachable within the current Level 10 cap. All forms remain available in F7 testing. Saved ranks, cooldown and slot 5 mapping are unchanged.

## Motion and control

King commits for .18s windup + .03s active + .11s recovery: movement/dodge return at .32s. The released sequence starts at .18s. First blast is .42s after release, near .60s from input. Additional blasts are .28s apart: Advanced near .60/.88s, Mature near .60/.88/1.16s.

Each blade has its own sprite and summoning overlay. The first forms during King's windup; follow-ups form .34s before their contact. A torn blue/crimson light seam and descending energy filaments frame the incoming blade. Each travels only DOWN. The momentum pass raises blade arrival from 86px to 144px above the target. Follow-up formation starts .34s before contact (previously .26s), with about .095s to assemble before accelerating into the ground. Impact cadence, damage, burial and player recovery are unchanged. It crosses the floor during the final fifth of descent and reaches 60px burial before the damage event. A ground-plane shader hides the embedded tip. During its .245s destruction the exposed blade fractures and continues 12px deeper; it never rises or reappears for another hit.

A new sixteen-frame radial sheet expands into a broad broken disk of outlined light shards and ground fissures, then fades over .52s. The footprint matches the circular damage scale, with final radii 88/96/104px. It replaces the narrow sideways splash. Early entry uses compressed fissures; damage triggers the expanded blast. Generated blue-white drawings are remapped crimson while retaining white highlights and dark outlines.

An incoming blade can briefly coexist with the previous sword's destruction and fading blast. There are at most three blade groups per cast, each with sword, summon and ground sprites. The observer clears .95s after the final hit. The sequence remains the sole damage authority. Movement and post-release cancel leave the skill running; startup cancel, defeat, Lab clear and scene exit cancel appropriately. No extra player invulnerability or locking.

## Assets and sound

Approved sword art remains at `assets/vfx/abilities/king/worldsplitter/detailed/sword.png`. New original ImageGen sources/prompts live in `art_source/generated/vfx/king/worldsplitter_summoned_2026_09_27/`. `retired generation tool (recover from Git history only)` packs two 16-frame atlases into `assets/vfx/abilities/king/worldsplitter/summoned/`, using 512px padded cells, nearest sampling and binary alpha. The old recoil/sideways-splash assets are historical and no longer referenced by the active visual.

The existing original gather/descent cues sound for every fresh sword. Contact, light-shard and low rupture accents accompany each burst, with softer earlier hits and the strongest final impact/camera pulse. No King model or Skill 4 changes, and no downloaded audio.

## Verification and review

Focused rendered tests cover distinct sword instances, no upward bounce, deep burial before blast, summoning overlays, all-direction rim hits/outside-radius exclusion, exact damage budgets, final-only stun, movement/dodge, rank colors, target locking, defeat cleanup and all 48 available frames' padding/alpha/distinctness. The source atlas is also checked for a round footprint and damage-scale agreement. Latest GPU captures are in `historical Git-only review/characters/king/worldsplitter_momentum_2026_09_27/`; the previous summon revision remains in `worldsplitter_summoned_2026_09_27/`.

Latest momentum rendered run: **142 checks, 0 failures**, with 24 native captures including the higher arrival pose. Additional activation (13), combined Vow/combat (49), training (14), sidebar (26) and production-kit (zero failures) tests pass. Final editor import has no script/import errors. Existing shared GPU shutdown texture warnings persist; owner feel/audio judgment and representative-phone profiling remain open.

Run `tools/launch_king_skills.ps1`. The review opens Mature as a session-only preview. Press **5**, aim/click, then move or dodge. **F7 -> Skills -> Worldsplitter** compares forms; **F9** refills the kit. No training/save mutations.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
