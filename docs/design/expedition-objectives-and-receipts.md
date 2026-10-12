# Expedition objectives and collected-reward receipts

Implemented 2026-10-02; Decision 166. Sanctuary remains temporarily complete. This pass covers the six implemented expeditions, not later campaign stages or Hunts.

## Player flow

The compact right-hand tracker shows the current objective, wave number, defeated count against the entire authored wave (including queued reinforcements), incoming reinforcements, and the exit condition. Stages I/II/IV/VI clear through their existing encounter controller. Stage III requires F at the Rootbound Reliquary; Stage V requires the boss conversation, collapse and F at Varkuun's Chest. Boss death alone does not open the completion receipt or its return action.

After the authoritative clear, VIEW REWARDS opens a gold/violet native modal using the approved centered-paperdoll frame. It shows actual credited XP and gold, start/current level, materials actually added to inventory, first/replay chest status, newly available routes, level-cap increases, and the actual Nema crafting unlock. Opening, closing or reopening cannot grant rewards. No new XP, gold, drop rates or recipe costs were added. In particular, Varkuun's current reward is its chest; the encounter does not currently grant XP or gold.

KEEP EXPLORING resumes the stage to collect remaining ground drops. The ledger keeps observing actual pickups until departure and rebuilds on reopening. RETURN TO SANCTUARY uses normal scene transition only after the clear/claim has banked the expedition. The forward portal remains F-required. Uncollected drops are not silently collected by the receipt. Esc/Tab closes the receipt; Page Up/Down and Home/End scroll long contents. Button focus and mouse clicks remain native Godot controls. The report owns its pause and blocks CharacterMenu's global input while open; objectives hide behind dialogue, pause and bag modals.

## Ownership and layout

EncounterController exposes event-driven progress snapshots. PlayerProgressionComponent emits rewards_granted with the actual XP/coin changes after existing cap handling. ExpeditionFeedback observes these events plus LootService's material_granted and stage_reward_granted; authority stays in progression, loot, inventory, story and save services. Stage V's flow explicitly reports its boss milestones. ExpeditionCompletionReturn validates alive/completed/banked state before travel.

ExpeditionFeedbackView owns native controls only and draws on CanvasLayer 5 above the boss HUD. At 960x540 the objective panel occupies x696..948/y90..196, roster y204..354 and loot toast y366..410. Lower the roster scroll minimum before moving its panel, otherwise Godot's minimum-size expansion leaves the old oversized rectangle. The receipt is 640x420 with bounded scrolling and fixed bottom actions.

## Review and verification

Run `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_expedition_review.ps1`. It opens Stage III with explicit no-save fixtures and a damage-immune King for this review only. Click Finish encounter, continue/skip the guardian conversation, click Visit reward chest after it appears, press F, then VIEW REWARDS. `-Stage5` starts the boss stage; enter the clearing and finish the opening conversation before the helper can defeat Varkuun. Restart normal F5 for normal saving. Review helpers accelerate cloned waves and apply real health damage; they never grant a completion or claim directly.

`tests/expedition_feedback_smoke.gd` passed 81 rendered checks at 960x540: real enemy deaths, queued wave totals, actual credited totals, cap-clipped XP, ordinary bank, required chest F interaction, first/replay clear, boss claim and seal, modal geometry/input/pause, voluntary Sanctuary return, normal profile save/load, Nema craft, bag equip and Eira training. Its isolated profile is user://expedition_feedback_smoke.json. Faster waves, lethal health damage, prior-stage ingredients, XP/gold eligibility and NPC visits are test fixtures; this is integration proof, not a claim of normal combat balance or player success.

Stage II/III/IV encounter, Stage VI Crag Bear, Varkuun defeat sequence, progression, loot, reinforcement and defeat-return regressions pass. Native captures are in art_source/review/ui/expedition_feedback_2026_10_02/. Phone readability/performance, whole-kit economy balance, Hunts and future stage content remain unverified/planned. Existing GPU shutdown texture/RID warnings remain.
