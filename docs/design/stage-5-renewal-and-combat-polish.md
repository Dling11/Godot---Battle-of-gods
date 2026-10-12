# Dead Forest renewal, campaign Rotcaller and combat polish

2026-10-03 · Decision171. Owner approved Rotcaller beside Stage III's Rootlings, retained Husk, requested Stage IV/possibly V placement, more hordes, clearer animation/outline, different expedition music and a fix for Skill 1 crowd stutter. Loading/start/portal/spawn/control work follows Stage V.

## Implemented campaign

| Stage | Current encounter | Live ceiling |
|---|---|---|
| III |13 Rootlings +1 Rotcaller, then the unchanged solo280HP Husk behind its dialogue gate |5; solo boss remains1 |
| IV |Five waves of8/10/12/14/16 =60 enemies; one Rotcaller in waves2–5; Hogs remain1/1/2/2/2 |8 |
| V |One Rotcaller +5 Rootlings before Varkuun; finite reinforcements, no adds during the boss fight |5 sentries, then the existing boss |

Rotcaller keeps55HP,46px/s movement,180px reach,1.1s fixed32px warning, accepted-hit interruption, one10-damage contact, .8s recovery and5s cadence. It now grants12XP/2 coins once through EnemyRewardComponent and uses its own existing-material root-fiber/heartwood drop profile. Ordinary level caps, mitigation, bag capacity, bad-luck counters and chest rewards remain authoritative. Trial setup still removes rewards before readiness; trial completion cannot bank/unlock/save.

Stage III's optional comparison is now18 Rootlings +1 caster/6 live using a duplicated wave. It never edits the canonical13+1/five configuration. More horde means a longer bounded queue, not an unlimited spawn loop.

## Animation and readability

Sixteen new walk drawings show separated wooden knees/feet, alternating contacts and passing poses. Dedicated front/back and opposite south strips correct missing staffs and repeated leading feet in the first generated sheet. South uses the caster's right-hand staff on the viewer's left; north keeps it on the viewer's right. East/west retain consistent hand placement. Staff remains visible in every live walk frame. The existing action drawings remain; anticipation now transitions from the new body into the staff-rise pose before holding the warning.

All use64px cells, y56 foot baseline and approximately40px body height with nearest filtering, binary alpha and no mipmaps. The established King outline shader supplies a one-texel dark silhouette across walk/cast/recovery/death; the existing hit-flash observer restores that original material. Animation follows actual displacement and stops when blocked/casting. It does not move the actor or determine damage.

Sources/prompts/normalization: `art_source/generated/characters/enemies/rotcaller_v2_2026_10_03/`. Active derivatives: `assets/characters/enemies/rotcaller/`. The original V1 sources/actions remain recoverable in their original source directory. New poses await owner feel review; they are not claimed to match eight-frame hand-authored animation quality.

## Stage V environment and gate

Normal Dead Forest now has1728 baked32px cells over unchanged1536x1152 bounds. Newly generated ash/soil/litter/crack materials replace repeating purple ornamental flooring. An authored curved worn approach joins a quiet northern clearing; offline transition masks feather its edges. No terrain generation runs in gameplay.

Eight new families: bare ash, splintered snag, open ruined gateway, stump, fallen bark log, collapsed stone, carrion and dry bracken.50 authored placements plus the retained four-fly carrion landmark preserve broad combat space.24 compact edge trees frame the field. Solid bases feed18px navigation clearance; tree branches subtly sway/fade while roots remain planted. Dry bracken is passable. No living birds/green canopy are added to the fully dead biome.

Gateway pillars are separate12x20 bodies at±44px, each with its own cutout; a shared convex hull must not close the opening. Varkuun still pursues across Rect2(72,72,1392,1008), not just the northern clearing.

StageApproachEncounter reuses normal spawning/death/reinforcement accounting but its completion only emits progress/clear. It does not commit expedition rewards, spawn a chest/portal or mark stage completion. Its authored spawn points stay on the southern approach. Stage5Flow alone owns Varkuun's entrance, boss death, required F chest, bank, unlock and Stage VI portal. The boss stays hidden/inactive/damage-immune until the sentries fall and King reaches the basin. Clearing the guards while already inside the trigger starts the entrance without requiring exit/reentry. Guard objectives and earned XP/coins appear in ExpeditionFeedback; its completion button remains unavailable until the actual boss chest claim.

All campaign casters die before their encounter's chest/portal exists. Stage V adds no NPC service during active combat. This avoids caster warnings in service spaces for these finite placements. Future persistent Hunts/scouts still need explicit safe-zone exclusions.

Old V scene/layout/test: `historical Git-only archive/stage_5_pre_renewal_2026_10_03/` with `.gdignore`. Shared old textures/props remain required by the separate legacy boss proof and other stages; they are not deleted.

## Audio

Normal I–IV now use **Dark Forest Theme** by The Cynic Project/cynicmusic (guitar/strings) instead of Sanctuary's Cathedral composition. V exploration uses **Dark Place** by SkyleTheFrench; the existing Varkuun battle music still takes over after dialogue. Both newly added recordings are verified CC0 on their primary OpenGameArt pages; attribution/download hashes live in `assets/audio/ATTRIBUTION.md`. They are licensed compositions, not claimed as AI-generated/original music made here. The MP3 is lossy; gap-free musical seams and subjective mix need listening review.

AudioDirector retains one music player and cancelable handoffs. V exploration/sentry-clear uses−19/−20dB, sentries−16dB, existing Varkuun−7dB. Quiet wind−34dB and sparse woody creaks−28dB sit on Ambience→Music; guards/boss duck those beds6dB and death restores them. No repeated complete-track stacking. Sanctuary keeps its accepted composition.

## Skill 1 stutter: reproduced and corrected

A real Foundation wave swept eight stationary high-health Mirelings on seven distinct physics ticks. Before correction, the rendered AMD Compatibility test accepted8 hits but globally paused6 times for369.85ms total (headless7 pauses/334.78ms). The presenter only coalesced contacts within one physics tick, so the travelling wave repeatedly froze the entire tree as it met new targets.

Earthsplitter now explicitly owns shared contact feedback. Every accepted target keeps its number/burst/flash; the existing authored release/wave/terminal sequence supplies bounded camera/audio events. Generic contact hitstop/audio/camera is bypassed for this released sequence. Basic attacks, incoming hits and other ability weights retain their existing feedback. Damage, reach, timing, ranks and counterplay are unchanged.

Player-owned feedback lookup replaces the hardcoded Services/CombatFeedback path that missed GameplayServices in normal I–IV. Earthsplitter/Molten/Worldsplitter resolve on effect creation; Pursuit resolves when a phase starts because its child is ready before the stage's service. Matching the Player avoids selecting an outgoing scene's presenter.

Each released wave now reuses its terrain query, circle and contact capsule/query instead of allocating three physics objects each tick. Motion resets before overlap checks; terrain is still rechecked as the wave travels. This removes allocation work without skipping authoritative geometry checks.

After correction, native Foundation keeps8 contacts on7 ticks with0 global pauses/0ms paused time. Headless Fan retains16 contacts and Cascade24, also0 pauses. The fixture disables enemy AI and raises health to isolate feedback; it does not establish whole-game FPS, live difficulty or phone performance. Other cold shader/audio/VFX stalls remain candidates for profiling.

## Ready test

Run `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_5_renewal.ps1`.

The no-save scene opens peacefully. **Start six sentries** runs the real finite approach; defeat them and walk into **Northern basin** for Varkuun. **King safe** defaultsON and can be switchedOFF for actual damage. **Reset Stage V** creates a fresh full-health Player, including after defeat. **Arrival gateway / Sentry approach / Northern basin / Overview** inspect layout; two compact control columns stay above the action bar. **Outdoor sound / Local dead wood creak** review the bed/cues. **Stage IV / Rotcaller → Try Rotcaller → Start trial** reopens the isolated caster test. WASD, attack/skills, Tab bag and Esc closing/pause remain normal. Close the review and use F5/normal expeditions for ordinary saving.

The launcher is a review fixture, not a minimum-gear Stage V balance test. Do not describe safe-mode clears as proof of difficulty or enjoyment.

## Verification

-139 headless and139 rendered production V environment/guard checks:32px ground, compact bases, all guard/basin routes, doorway sweep, immunity/gate, six/five accounting, actual57XP/7 coins, no guard bank/completion, inside-trigger handoff, boss activation and audio duck.
-47 rendered Rotcaller checks including seven captures plus the separate trial-control capture: real sword interruption, actual walk/frame advancement, four anticipation transitions, fixed marker, one contact, pause/recovery/death, Spitter slots and no trial progression.
-18 rendered IV review checks; 42 rendered V mouse checks verify bounded controls, start, actual defeat/full-health reset, safety, Tab/Esc, audio and IV/trial navigation.
-27 rendered regional audio checks include imported complete looping expedition music, device playback and existing single-player handoff/duck/cleanup.
-Stage III/IV resource smokes,137/153 navigation,10 pressure, basic feedback, King kit and49 Vow/Worldsplitter checks pass.108 rendered full expedition/service/save assertions include real normal I–IV clears and V guard→boss→F chest→receipt→Sanctuary/Continue with an isolated profile.

Known existing GPU shutdown texture/RID warnings persist. Some headless early-exit runs also reported transient ObjectDB/resource references; a verbose retest exited cleanly. These are not claimed solved. Owner art/mix/minimum-gear balance and representative-phone frame profiling remain open.

## Next work after Stage V: ordered acceptance plan

**Current progress (Decision173):** Native portal/loading/title/existing-chest production is implemented and verified in stage-exits-and-quiet-transitions.md. The owner instructed implementation after selecting all six portals and quiet loading; earlier selection/hold statements below are historical and superseded. No need to ask again between Grasp/Maw. Actual resource progress, paused King/seal motion, title/save/F/failure and rendered108-check expedition flow pass. Owner native art/feel acceptance remains open. Step1/loading and Step3/title are implemented; Step2 gate/chest art is implemented, but new chest audio and enemy emergence are still pending. Steps4–7 remain planned. CONTINUE_PROGRESS.md is the next-chat entry point.

Decision172 supersedes the earlier portal-choice pauses below: owner selects ALL SIX latest threat designs, including both red Boss alternatives. No further selection between3 and4 is needed. The internal [divine patron expansion](divine-patrons-and-manufactured-invasion.md) documents apparent invasion, genuine divine help and gradual late betrayal while keeping specific monster origins/mechanisms proposed. Proceed to native asset/animation production; concept selection does not imply completed integration. Reusable spoiler-free loading/title art and current destination-tier/claim/save contracts remain the baseline.

Latest owner feedback: the generic ENTERING THE NEXT STAGE layout is liked, but should have light entertaining movement. `retired generation tool (recover from Git history only)` now exports a40-frame no-save mascot/glimmer rehearsal, with a static illustrative bar and no actual loading. Revised six-option destination-threat portal art includes a reaching shadow hand or hungry rim as two red Boss alternatives; ordinary blue, restrained purple and future white-gold/near-black remain distinct under Decisions119/129. No prior P1/P2/P3 gate is accepted. See `art_source/generated/ui/threat_portal_previews_2026_10_03/README.md` for GIF, art, provenance and limits. Show the portal board and wait for owner selection before integration. Existing reward-chest art and title/homepage renewal remain queued.

Owner clarification2026-10-03: the requested portals are stage-completion exits; include existing reward chests in the art pass. The Sanctuary portal is outside this scope. Implementation is paused at the owner's request while selecting static A/B/C portal, chest and loading-screen concepts in `art_source/generated/ui/stage_completion_previews_2026_10_03/`. These boards are illustrative, not approved runtime assets or animations. Selection may mix components; native size/motion still needs an in-engine review after selection.

Latest discussion: owner prefers C's fractured-light idea but finds the board graphics outside the native game theme. Next previews should use simpler hard-pixel silhouettes and a generic reusable loading composition across biomes; only destination text/accent need vary. Lore should suggest passage through the constructed divine Game while protecting the slow-burn reveal in Decision131. No final design or implementation is approved by that preference.

Owner now chooses quiet/mysterious mood with no spoilers. Revised loading and P1/P2/P3 exit/chest static previews live in `art_source/generated/ui/quiet_threshold_previews_2026_10_03/`. Portal integration must wait for the owner's explicit choice. Title/homepage art renewal is also requested after loading/exit design selection; it should use the selected language and retain the real Continue/New Journey/settings behavior.

1. **Loading and starting an expedition.** Use a compact runic loading frame, small fractured seal and generic quiet dark background reusable across regions; show actual loading progress, destination name and one neutral control hint. Avoid landscape-specific identity and narrative spoilers. Keep background art separate from dynamic UI text. Prefetch/import required resources before the first cast. Keep start/Continue/load failure tied to real saved state; no fake progress or long forced animation. Test cold start, repeated Continue, route change and resize with the accepted compact HUD.
2. **Stage-completion portals, reward chests and enemy arrival.** Renew the exits that appear after clearing stages with compact forming/open/idle/travel presentation and destination-tier clarity; preserve F, routing and physical/navigation footprints. Give existing reward chests distinct closed/open/claimed art, restrained manifestation/opening effects, clear F feedback and short matching audio; preserve tier silhouettes, III/V claim gates, real contents, one-shot grants and bank/save order. Do not add chests/rewards to chest-free stages as an art change. Rework enemy emergence into a short ground warning/materialization, with readable facing and one quiet arrival cue per spawn/batch. Avoid audio stacking and spawn zones over King, service/chest spaces or blocked ground. Review actual clear→chest claim→portal→loading travel at native scale, then use the eight-live IV scenario to compare one/three enemy arrivals.
3. **Title/homepage art.** After the loading and stage-exit direction is selected, preview a matching quiet pixel-art title screen with restrained mystery and no narrative reveals. Use the same material palette/abstract seal, readable logo and compact Continue/New Journey/Settings controls. Keep buttons and navigation separate from artwork; preserve valid-save gating, overwrite confirmation and real input focus. Owner review precedes promoting its art into normal startup.
4. **Combat impact and audio.** Preserve the accepted King body and skill shapes. Prototype blade/wood/armor-specific hits, a short guard clang, interruption snap and a distinct heavy impact. Show local damage on every accepted enemy but bound shared camera/audio per swing/sequence. Audit visible blade/contact reach in four directions against physical hurtboxes, terrain and occlusion; do not increase range only to make a VFX connect. Compare one target and eight targets with vulnerable King and representative gear before promoting.
5. **Pointer and movement clarity.** Generate a small neutral/target/blocked cursor set and clear ground-target feedback, while preserving left-click/assisted controls and keyboard use. Check walk→stop, diagonal facing, dash cancel and skill recovery using actual displacement; animate planted feet/cloth instead of translating a static idle. Test UI input suppression and blocked targets/terrain; do not make input wait for cosmetic effects.
6. **Frame-time and allocation work.** Capture cold/warm casts on desktop and representative phone; record physics/render frame times, allocations, active VFX/audio players and nodes at1/5/8 live enemies. Treat16.7ms as the60FPS target, not a measured result. Only pool/limit effects after a profile identifies the cost; preserve damage/contacts and readability. Fix shared shutdown ownership separately from gameplay frame spikes.
7. **More variety after those checks.** Renew VI as muted teal altitude/stone/water rather than more dead forest. Prototype Burrowkin as one warned flank/emergence, with interrupt/recovery counterplay and one normal slot. Add one useful safe-entrance scout and short saved Sanctuary reactions; then authored lore/cache/breakables and the existing Hunt/reward/save contract. Do not add more simultaneous casters or endless horde scaling before balance/mix testing.

These seven steps form the authorized program. The Decision173 paragraph above records the implemented presentation subset; the remaining emergence/audio/combat/control/profiling/content steps are planned. The strongest gameplay question remains whether a vulnerable player can read and act on melee, armor and one caster warning without the interface/camera/sound hiding them. Owner playtesting is required to assess enjoyment.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
