# Project Context

Updated 2026-10-15. Read this, ROADMAP.md and KNOWN_ISSUES.md first. Implemented code/scenes are runtime truth. Cleanup and fresh-history boundaries remain in Decisions197/198 and docs/maintenance/repository-cleanup.md / repository-migration.md. Current repository: Dling11/Godot---Battle-of-gods; earlier deliveries stay in Dling11/godot-practice-first-game.

## Current playable state

Godot 4.7.2 standard, Compatibility renderer, 960×540 logical viewport. F5 opens the randomized campfire title. Continue/New Journey enters the renewed Sanctuary. Campaign reaches Stage VI; later arcs and Stage XX routing are planned.

King has five weapon families through normal catalog/Bag: Sword, Iron Beard, Royal Greatsword V2, Twinsteel V2 and Iron Reaper.212 establishes the canonical fixed-size axe/back carry;213 supplies corrected complete running-sized attacks and normal jump/spin. Accepted scythe running BODY pixels and other families stay exact. Five techniques/ten slots and separate non-saving debug grants remain.

Sanctuary is temporarily complete. Eira opens training to the right of her lectern; Nema crafts; Umi sells/reconstructs materials; Orren's workshop requires F at the door. Map remains hidden. Compact portrait HP/XP and centered paper-doll Bag are current. Do not resume house/map work by default.

F9 grants a session-only non-saving review kit. F7 opens the actual Combat Lab; the Weapons tab/Tab Bag equip current families. Lab actors cannot award rewards or mutate campaign progress. Examiner is an isolated divine-trial encounter, not a completed Stage XX campaign.

## Current priority

The owner approves Decision213's Iron Beard pass on2026-10-15: "now thats an axe you know what this would do". Preserve current running/idle, complete attacks, proportions, canonical axe/grips/back carry and normal jump/spin as the accepted baseline. Do not restart axe redesign by default. Remaining family migrations come next when requested; F9/F7/Bag select the current21 clips.

Current source/prompts/recipe/approval snapshot: art_source/generated/characters/king/iron_beard_motion_2026_10_15/;212's canonical source still supplies weapon/idle. Builder delegates to king_axe_technique_baker.gd. Combat3.19s, FX/audio, saves and other families stay exact. The owner permits visible Godot again. Art/motion approval does not close campaign balance, earned acquisition or device profiling.

## Read next by task

- Design/rules/lore: GAME_DESIGN.md and STORY_BIBLE.md; distinguish implemented rules from proposals.
- Implementation: ARCHITECTURE.md and STYLE_GUIDE.md.
- Art: ART_DIRECTION.md, ASSET_CATALOG.md, docs/design/character-animation-pixel-contract.md and docs/design/king-shared-body-library.md.
- Current weapons: CONTINUE_WEAPONS.md; king-axe-cardinal-motion.md, king-greatsword-front-combo.md and king-dual-v2-cardinal.md under docs/design/.
- Sanctuary: CONTINUE_SANCTUARY.md and docs/design/sanctuary-closeout.md.
- Stages/enemy progression: expedition-renewal-and-world-life-recommendations.md, forest-enemy-mechanics-recommendations.md and stage content contracts under docs/design/.
- Persistence/economy: current autoload services plus the Nema/Umi/crafting design docs.
- Cleanup/packaging: docs/maintenance/repository-cleanup.md and Decision 197.
- Repository/clone setup: docs/maintenance/repository-migration.md and Decision 198. Ordinary clones of the new repository do not include the old art history.
- Major choices: DECISIONS.md and the relevant decision. Read AI_NOTES.md only for missing context. CHANGELOG.md contains compact completed milestones.

## Durable boundaries

Commits and pushes require an explicit owner request. On 2026-10-13 the owner authorized cleanup delivery, then created Dling11/Godot---Battle-of-gods for a fresh history baseline. The existing project folder keeps its current game files while its Git metadata is switched to the new repository; original metadata is retained separately for recovery. Do not push old branches/objects into the new repository or rewrite/force-push the original. Keep changes scoped to the request. Runtime authority belongs to Player/combat/services; presentation does not apply damage or move collision. Preserve native palette/density/origins and immutable body-library hashes. Do not replace complete approved anatomy with a height-only check or a detached head/arm rig. Test actual movement, attack handoffs, idle retrieval, controls and current scenes. Passing technical checks is not owner visual approval.

Test captures go under ignored tmp/review/. Twinsteel running rebuild reads current run metadata plus the three freshly generated complete source sheets and bake_recipe.json under art_source/generated/characters/king/twinsteel_running_complete_2026_10_13. Frozen King references are visual guides, never transplanted pixel inputs to this gait. The earlier leg sheet is historical provenance only. Source distributions exclude Git history, caches, source art and captures.
