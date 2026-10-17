# 232 — Veyr's first weapon proof and the Sanctuary gate

Placement/scale superseded by233 after owner rejection: the actor was rendered twice the approved NPC world height. Keep the first-proof/unlock/forging rules below; current coordinates, bounds, station and world-scale contract are in Decision233 and SanctuaryLayout.

Date: 2026-10-18. Status: implemented for owner play/visual review.

## Context and choice

After accepting Cyclone231, the owner approves creating the proposed weapons mentor and asks for a sensible spot, allowing a map extension or work around the old stage portal. Use Veyr the Godscarred as the working mentor identity and add a modest northern training terrace. The owner explicitly confirms that the portal request means Sanctuary's gate and stage-selection screen. Stage-completion threat portals remain unchanged.

The first family lesson uses demonstrated actions rather than a second XP bar. Keep King level, learned family techniques and item ownership separate. Do not introduce all-family trees, rank curves, evolution or additional combat statuses in this slice.

## Installed rules

- Find Veyr at (680,112), approach (680,148), north of the Veil Gate. The 32px ground extends eight rows north to -256; player bounds start at -200. A checked path passes around existing planters, pillars and the gate. Existing service positions/approaches, hidden map, courier and workshop F entry remain.
- F opens a themed lesson card. A temporary training Axe and Cyclone loan do not mutate inventory. Cleave three different posts with normal Axe contacts; touch three posts and steer at least36px during one Cyclone; then use a dodge to leave a harmless44px warning before its one-second deadline. Walking alone is insufficient. Failed warnings repeat; leaving restores equipment/bounds and awards nothing.
- The completed proof permanently unlocks Axe F1. `WeaponTraining` stores the stable `axe_cyclone` proof in an optional version1 SaveService extension; old profiles receive no proof. A failed save rolls the proof back and can be claimed again. Replays cannot duplicate rewards; debug/Lab grants cannot become permanent.
- The proof also opens Nema's Iron Beard Axe pattern:4 Weathered Fittings,6 Root Fiber,75 gold. These are initial tuning values. This recipe requires the live Sanctuary scene and proximity to Nema at the crafting authority. It uses the existing atomic cost/output/save transaction and unique ownership. Legacy crafting rules are otherwise preserved; all-family base permissions and recipe migration remain future work.
- The mastery ribbon shows `1 PROOF · F1 LEARNED` only for the learned Axe family; other families stay sealed. Eira's curriculum includes only KingSkillCatalog powers, preventing weapon-technique rank lookups.
- The Veil Gate has one fixed generated stone frame and a fixed aperture with independent flowing light. A wider front apron still requires F. Route selection shows the current description/requirements and requires an explicit Enter action; inspecting a sealed route cannot bypass its existing access rule.

## Architecture and retention

`weapon_court.gd` composes placement/menu/warnings. `axe_mastery_trial.gd` owns temporary equipment, real contact evidence and restoration. `WeaponTraining` owns proof validation and durable unlock; UI grants nothing. CraftingService suppresses the Sanctuary inventory-signal autosave during its transaction so an acquired weapon is never saved before payment.

Keep only four final rasters (94,985 bytes), compact source/prompt/registration metadata at `art_source/reference/environment/weapon-court.json`, and current review evidence under ignored tmp. Three obsolete Sanctuary gate sheets/imports are removed. All687 unrelated prior guarded assets remain exact, including King's accepted five-family art and Cyclone231. No permanent generation archives are added.

## Review boundary

Headless checks cover real contacts, steering/dodge proof, cancellation, save rollback/reload, debug refusal, crafting costs/location/one-save commit, UI bounds and gate access. CPU composition supplies a placement preview. Native rendering/audio/feel and owner acceptance remain pending while the owner's no-window-interruption preference applies. This does not certify device performance or campaign weapon balance.
