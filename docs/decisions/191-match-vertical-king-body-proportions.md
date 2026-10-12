# Decision191 — Match vertical King proportions to accepted side bodies

2026-10-07. Owner requests slimmer UP/DOWN Twinsteel bodies and the same review for Greatsword. This authorizes a focused revision of the previously accepted vertical presentation; side attacks, steel, effects and gameplay remain the reference.

Status: installed, natively verified and owner-approved on 2026-10-07 ("100% spot on"). Corrected Twinsteel and Greatsword vertical proportions are the accepted baseline for future weapon art.1592/0 anatomy,953/0 dual motion,1529/0 Greatsword native,244/0 +197/0 actual Player and100/0 idle pass. Actual-player fixture shutdown warnings remain separate debt.

The native body-only audit confirms broad Twinsteel vertical attack torsos and undersized Greatsword vertical carry bodies. Fix anatomical registration offline instead of shrinking the runtime actor, blade, hitbox or effect. Keep one torso density per family/view/motion lane, fixed native head dimensions by visible facing, and the same foot plane. Crouches, jumps and actual turns retain authored motion rather than being independently fitted to equal bounding rectangles. Preserve thin source coverage and exact palm texels; resize body/hand rasters and their anchors together. Released blades retain ground attachments. Source-occluded rear hands retain provenance without becoming visible.

`tools/king_cardinal_body_registration.gd` is shared by the existing two builders. Greatsword writes sibling vertical carry/run resources so legacy identity references remain read-only. Its carry writer retains the original planting/rest/stow data. Corrected carry endpoints reconnect release/queue branches; copied metadata describes the actual copied body cel. Normal item/save identity, controller/presenter scale, damage/reach/phases, FX and audio remain.

Alternatives rejected: runtime whole-actor scaling would alter the weapon and effects and hide incorrect anatomy; independent frame fitting would pump proportions during attacks; changing approved side art would discard the owner's reference. No new conceptual art or scythe work is part of this correction.

[Sources, play and proof](../design/king-cardinal-proportions.md). Native connected-head/palm, full combo, carry/idle and actual Player checks pass. The owner's subsequent visual approval is recorded separately from those technical checks; encounter balance and device performance remain open.
