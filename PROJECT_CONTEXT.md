# Project Context

Updated 2026-10-13. Read this, ROADMAP.md and KNOWN_ISSUES.md first. Implemented code/scenes are runtime truth. The repository cleanup removed archives, obsolete models, generation experiments and review recordings. Current repository: Dling11/Godot---Battle-of-gods, with fresh history from the cleaned project. Earlier deliveries remain in the separate Dling11/godot-practice-first-game repository. Do not recreate their dependencies. See Decisions 197/198 and docs/maintenance/repository-cleanup.md / repository-migration.md.

## Current playable state

Godot 4.7.2 standard, Compatibility renderer, 960×540 logical viewport. F5 opens the randomized campfire title. Continue/New Journey enters the renewed Sanctuary. Campaign reaches Stage VI; later arcs and Stage XX routing are planned.

King has the signature Sword, Iron Beard axe, Royal Greatsword V2 and Twinsteel V2 through the normal catalog/Bag. Greatsword is owner-approved. Twinsteel's current complete carry variant is installed for owner motion review: shared_bodies/dual_carry_v3, fixed native upper anatomy, actual leg steps and matched ready/run blades. Do not restore old dual prototypes/gaits. Five current techniques are Earthsplitter, Molten Crash, Sovereign Pursuit, Unbroken Vow and Worldsplitter; ten equipped slots are supported. Campaign acquisition/balance is separate from debug availability.

Sanctuary is temporarily complete. Eira opens training to the right of her lectern; Nema crafts; Umi sells/reconstructs materials; Orren's workshop requires F at the door. Map remains hidden. Compact portrait HP/XP and centered paper-doll Bag are current. Do not resume house/map work by default.

F9 grants a session-only non-saving review kit. F7 opens the actual Combat Lab; the Weapons tab/Tab Bag equip current families. Lab actors cannot award rewards or mutate campaign progress. Examiner is an isolated divine-trial encounter, not a completed Stage XX campaign.

## Current priority

Code/assets cleanup is complete: all 134 active smoke scripts pass assertions; all 868 resources load; all 646 protected assets remain unchanged. Current source is about 54 MiB. Fixture teardown warnings remain tracked separately. Owner motion review of current Twinsteel precedes Iron Reaper scythe. Preserve accepted heavy attacks and weapon scale. After that: acquisition/crafting rules, measured enemy-role balance, phone/cold-load profiling and campaign expansion.

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

Test captures go under ignored tmp/review/. Retained art_source contains only the current Twinsteel gait source, small King references and licensed audio originals. Source distributions exclude Git history, caches, source art and captures.
