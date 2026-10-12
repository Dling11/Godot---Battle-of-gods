# Worldsplitter — upright descent

**Current terrain/aim correction (2026-10-03,Decision177):** Slot1/5 keep full authored reach through scenery; Slot3 flies over any intervening obstacle to clear, real-foot/nav/bounds-valid ground. Silver/slate/violet circles and hardware pointers replace gold/blue targeting and use actor feet/render-frame aim. This supersedes earlier terrain-aware/clipped or LOS-stopped descriptions below. Current rule/validation: king-targeting-and-terrain.md.

**Current correction (Decision 164, 2026-10-02):** Eira training gates are now Level8/10, both reachable by cap10; previous10/15 statements below are historical. Decision162 and worldsplitter-fractured-light.md own the current fresh-sword/radial-blast presentation. Saved ranks remain compatible; no damage/cooldown/art changed in the curriculum pass.

**Superseded by implemented Decision161:** The owner approved fractured-light impacts and three consecutive same-point Mature plunges with burial/extraction. The triangle and former stone/two-contact progression below are historical. See `worldsplitter-fractured-light.md`.

Implemented 2026-09-27, owner feel/balance review pending. Replaces the X-fault prototype and supersedes the unimplemented angled Severing Descent concept. Skill 4 is unchanged.

## Action and control

King's existing approved directional command frames take .18s windup, .03s active release and .11s recovery. The independent released sword stays upright, briefly lifts, accelerates straight down and impacts the committed point .42 s after release (about .60s from cast). King can move, dodge or attack after .32s, before either hit. Ordinary post-release cancellation does not retract the sword; cancellation before release prevents it. Defeat, scene exit and Lab clear remove pending authority and presentation.

The first hit is concentrated at blade contact. One wider pressure hit follows .24s later, carrying the existing .5s designated stun. Shattered slabs rise, rotate outward, fall and settle for about another second. There are exactly two damage opportunities, regardless of frame count or number of fragments. Every pulse checks target foot radius; Decision177 removes terrain LOS. Preview and commit share the terrain-clamped target. Cooldown is 20s; existing weapon, level, critical and mastery modifiers remain authoritative. No new invulnerability or movement bonus.

## Upgrades

Training is manual at Eira; rank is persisted in the optional `king_worldsplitter_rank` field. Lab previews never save or train. Gates are initial tuning choices; no level cap is raised by this feature.

| Form | Eira requirement | Core / outer radius | Core + eruption weapon damage | Target range |
|---|---|---|---|---|
| Foundation | Existing learned skill |60 /108px|220% +300%|260px|
| Advanced |Level 10|68 /124px|250% +350%|280px|
| Mature |Level 15|76 /140px|280% +420%|300px|

The current campaign cap reaches10, so Advanced can be trained now; Mature remains campaign-locked until future progression allows15, but is fully testable in the Lab. Each rank enlarges the registered blade and ground field together, with subtle lavender accents at higher ranks; no extra crossed trails or duplicated swords. Body size, commitment, cooldown and stun duration stay fixed. Later campaign balance may revise the level gates and multipliers.

## Asset and audio ownership

Two new generated 16-drawing atlases (`assets/vfx/abilities/king/worldsplitter/detailed/`) give32 distinct drawings across formation/descent/dissolution and ground contact/eruption/settling. Runtime cells512x512 with binary alpha, nearest sampling, clipped atlas regions and stable contact origins. The source grid is normalized offline without rescaling individual exceptional frames. King keeps his approved model/outline and existing directional body action; no new King-body drawings are claimed.

Current source prompts and original edited PNGs: `art_source/generated/vfx/king/worldsplitter_detail_2026_09_27/`. The original broader white-blade pass remains historical in `art_source/generated/vfx/king/worldsplitter_2026_09_27/`. Packer: `retired generation tool (recover from Git history only)`. Four original audio cues from `tools/build_worldsplitter_audio.js` cover gather, descent, contact and rupture; event-triggered on SFX with bounded gains, smooth fades and no clipped samples. Two bounded camera impulses coincide with the two authoritative contacts. No external audio downloaded. Perceived sound mix still needs owner listening in combat.

`worldsplitter_sequence.gd` owns snapshotted stats and world-fixed damage timing; `worldsplitter_visual.gd` observes contact events and never grants damage. Two sprite layers replace four traveling faults. The shader preserves source stone brightness rather than multiplying texture color twice. This avoids extra per-fragment nodes; phone performance still requires device profiling.

## Ready review and checks

Run `tools/launch_king_skills.ps1`, or enter F7. Skills tab ->5 WORLDSPLITTER selects Foundation/Advanced/Mature. Press5, aim and click; walk or dodge immediately after the command. F9 restores the full test kit. All upgrade forms remain session-local in the Lab.

`tests/worldsplitter_descent_smoke.gd`: rank radii/damage, exact per-contact hits, movement/dodge before impact, fixed target, upright sword, post-release cancellation, defeat cleanup, blocked rank changes while a sequence is pending, no campaign writes,32 unique padded binary-alpha frames.51 headless checks;60 checks with nine actual 960x540 GPU captures. `worldsplitter_training_smoke.gd`:14 trainer/save/backward-compatibility checks. Existing buff/Worldsplitter 49, sidebar 26 and Vow training 14 checks pass. King production-kit and save-profile snapshot regressions also pass. The existing combined test continues to cover terrain occlusion, preview/commit agreement and pre-release cancellation.

GPU review: `historical Git-only review/characters/king/worldsplitter_upright_2026_09_27/`. The previously documented two 5460-byte GPU texture shutdown leaks/RenderingServer teardown warnings still occur on exit. These checks do not establish mobile performance, final balance or owner approval.

## Activation observer correction (2026-09-27)

Worldsplitter release emits `strike_started` for its body action, but this is not the distant contact. `GreatswordEffects` must skip its generic hitbox-local burst for Worldsplitter, as it already does for Molten Crash. Otherwise the unused legacy hitbox at King's upper body creates an overhead crater before the true impact. `worldsplitter_activation_smoke.gd` reproduced this at all three ranks before the correction and passes 16 rendered checks afterward, including preservation of Pursuit feedback and the real target crater. Captures: `historical Git-only review/characters/king/worldsplitter_activation_fix/`.

## Earthsplitter detail reference pass (2026-09-27)

The owner preferred Skill 1's borders and detail. Built-in image-generation edits refine all 32 source drawings against the actual Earthsplitter sword/rupture references: dark blue inner planes, white edge bevels, defined guard and shards; clear gray stone faces, dark gaps and concentrated crack light. Source anchors and padded runtime origins remain registered; the dissolution tip origin is219 in the normalized source. No authority, timing, scale settings, sound, progression or King-body changes. Active textures are the versioned detailed pair. The test reads these actual runtime textures, rather than a stale hardcoded original path.

Nine actual960x540 after captures plus preserved before captures: `historical Git-only review/characters/king/worldsplitter_detail_2026_09_27/`. The full60 rendered checks and13 activation regression checks pass. Current gameplay/rank checks remain intact; subjective owner approval and mobile profiling remain open.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
