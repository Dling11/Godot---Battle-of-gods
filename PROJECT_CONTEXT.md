# Project Context

Updated2026-10-16. Start meaningful tasks with this file, ROADMAP.md and KNOWN_ISSUES.md. Implemented code/scenes remain runtime truth. Current repository: Dling11/Godot---Battle-of-gods; do not import the old repository's art history.

## Current Sword review (Decision224)

The owner provisionally accepts the new eight-frame Sword side run and requests a natural grip. The earlier(10,70) grasp sat too close to the pommel. The current full-size sword uses middle-leather grasp(10,66), retracted four source pixels and lowered from15 to10 degrees, with the guard/handle in front of the forearm and the existing closed glove over the grip. Complete poses, two-pixel hand travel and stride stay unchanged. Top/down, idle/attacks, combat/audio and other weapons remain exact. Grip review is pending; do not reopen accepted running motion. Audit/prompts: art_source/reference/characters/king/sword-side-run.json.

## Current playable state

Godot4.7.2 standard, Compatibility renderer,960×540 logical viewport. F5 opens randomized campfire artwork. Continue/New Journey enters the renewed Sanctuary. Six campaign stages are implemented; later arcs/StageXX are planned. Examiner remains an isolated Lab trial.

King's five current families are Sword221/224, Iron Beard213, Royal Greatsword217, Twinsteel219 and Iron Reaper206–209. The other families remain settled; preserve their accepted complete anatomy, sizes, palette, motion, sounds and combat. Sword224’s targeted hilt visibility correction awaits review; its running motion is provisionally accepted. CONTINUE_WEAPONS.md owns current routes and values. Greatsword's stable saved ID still ends in _v2, with old-ID migration; only one Greatsword is selectable.

Sanctuary is temporarily complete: Eira training/loadout beside her lectern, Nema crafting, Umi exchange, Orren workshop F entry, compact portrait HP/XP and centered paper-doll Bag. Map remains hidden. Do not restart house/map/art redesign by default. F9 grants session-only non-saving equipment; F7 opens the actual Combat Lab. Normal WASD/heldLMB/Space/Tab/Escape remain.

## Minimal art retention - Decision223

The owner clarifies that current bulk source sheets must also be discarded to prevent repeated project growth. art_source/generated is permanently deleted from the working tree, ignored by Git and rejected by the runtime/archive boundary test. The final PNG/animation/resources under assets/ are authoritative and remain byte-identical. Their image builders and raw-source-only checks are retired.

Keep only compact approved reference art, two small numeric motion/grounding contracts, production-assets.json validation hashes and licensed audio sources/attribution under art_source/. Frozen complete body references remain under assets/characters/playable/king/body_library/baseline. Never paste reference heads/limbs into fresh poses.

For future artwork, stage generation trials/raw sheets under ignored tmp/, publish only approved runtime assets, then clear staging after validation. Do not recreate a permanent generated/archive/review tree or retain every iteration. Exact old raw-source rebaking is intentionally unavailable; native play, installed-byte/frame/grip/layout checks and small approved references replace that dependency. Update production hashes only for an explicitly approved art/gameplay change, never to mask drift.

## Read next by task

- Implementation: ARCHITECTURE.md and STYLE_GUIDE.md.
- Significant design/rules/lore: GAME_DESIGN.md and STORY_BIBLE.md.
- Current weapons: CONTINUE_WEAPONS.md and current family guides under docs/design/.
- Art: ART_DIRECTION.md, ASSET_CATALOG.md, character-animation-pixel-contract.md and king-shared-body-library.md under docs/design/.
- Sanctuary: CONTINUE_SANCTUARY.md and docs/design/sanctuary-closeout.md.
- Stages/enemies: expedition-renewal-and-world-life-recommendations.md and forest-enemy-mechanics-recommendations.md under docs/design/; inspect stage content contracts/code.
- Persistence/economy: current autoload authorities and Nema/Umi/crafting design docs.
- Cleanup/source retention: docs/maintenance/repository-cleanup.md and Decision223;222/197 are earlier cleanup evidence.
- Repository/clone setup: docs/maintenance/repository-migration.md and Decision198.
- Major decisions: DECISIONS.md and the relevant entry. Read AI_NOTES.md only for missing context; CHANGELOG.md for change history.

## Durable boundaries

No commit/push without explicit owner request. Preserve existing work and saves. Gameplay authority belongs to Player/combat/services; presentation observes phases and cannot apply damage or move collision. Preserve complete approved anatomy, density, palette and origins. Validate native movement/walls/attack handoff/idle retrieval/Bag and current resources; technical tests alone do not grant art approval. Phone/cold/large-horde performance and earned family acquisition/balance remain open.
