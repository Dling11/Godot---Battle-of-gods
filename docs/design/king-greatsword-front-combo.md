# Royal Greatsword V2 current contract

Updated 2026-10-13. This is the owner-approved Greatsword baseline. Cleanup preserves all active body/steel/slash/impact/carry/idle pixels and gameplay. V1 and discarded return-swing trials are not supported runtime content.

Four cuts: large front slash → return slash → spin → rear-loaded jump cleave. The current two-hand choreography, contact timing, directional impacts and four-facing carry/walk/proud idle are approved. Total nominal combo time2.34s; each move retains its existing data-driven damage/reach/knockback and movement commitment. Side and dedicated UP/DOWN jump impacts remain distinct.

The stable weapon/item identity is the V2 catalog entry; supported V1/2 save ownership/equipped IDs migrate without duplicate grants. Normal cuts use weighty body impact, the finisher a stronger smash, once per accepted cleave. Signature sword/axe/dual audio roles stay separate.

Normal profile: data/weapons/families/royal_greatsword_v2/presentation.tres. Active dependencies may still live under greatsword_front_combo_preview, greatsword_confidence_v2 or greatsword_v2_cardinal_carry; names do not make used assets disposable. Only unreferenced trials were deleted.

Test F5 → F9 → F7 → Weapons → Royal Greatsword or tools/launch_king_greatsword_v2_training.ps1. Maintained gameplay/held-input/contact/weapon-role/save-migration tests exercise the actual Player. Campaign acquisition, later variants, balance and phone profiling remain separate.

No legacy generator remains capable of replacing this accepted art accidentally. Future motion/weapon changes require a new complete-pose design against frozen King references. Logs/captures belong in ignored tmp/review/.
