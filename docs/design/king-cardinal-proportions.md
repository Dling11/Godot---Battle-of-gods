# King UP/DOWN body proportion correction

2026-10-07, Decision191. Owner reports broader vertical dual-sword attacks and smaller UP presentation, and authorizes reviewing Greatsword too. LEFT/RIGHT bodies are the accepted reference.

Owner approved the installed correction on 2026-10-07: "100% spot on". These Twinsteel and Greatsword proportions now form the accepted baseline for future weapon art. Preserve their body density, native palette and outlines across facings and motion states.

## Cause and correction

Before work, native Twinsteel first-cut body area was1333 source pixels in side view versus1597 UP and1652 DOWN. Ready heights were54/48/54 logical pixels. Greatsword ready heights were54/44/45, while first-cut bodies were58/52/52: small vertical carry exaggerated apparent growth at attack start. Body-only native comparisons isolate these differences from huge steel/slashes.

Offline registration contracts Twinsteel vertical non-spin torso width to82% UP and86% DOWN. Greatsword vertical non-spin attack torso width uses96%; complete turning spin bodies retain their accepted body density. Native heads use25×24 rear/side and27×29 frontal provenance (front rectangles also contain neck/scarf detail), retaining the original palette and outlines. A constant anatomical Y density per idle/run lane targets the accepted side ready/run baseline. Transparent crown padding is excluded from visible-height calibration. Every complete cel retains its authored crouch/stride/turn; no per-cel zoom or runtime body/head rig.

Original coverage sampling preserves thin wrists/necks, and palm landmarks retain original source texels through contraction. Both complete body/hand rasters and hilt anchors register together. Rear occlusion keeps front palms hidden; released blades keep their ground attachment. Source-copy endpoints use actual normalized head metadata and exact body copies.

Greatsword's new `greatsword_v2_cardinal_carry/up|down/` outputs preserve the original rest/stow/plant definitions and leave legacy native identity resources unchanged. The family profile selects these vertical idle/run resources. Existing Twinsteel resources rebuild from the original source sheets with the new offline registration. Side art, canonical blades, slash/landing art, animation clocks, reach/damage/knockback, movement authority and item/save identities stay unchanged.

## Play and review

Restart F5 → F9 → F7 → Weapons → Twinsteel or Royal Greatsword. WASD/held world LMB/Tab Bag retain existing controls. The direct Twinsteel training launcher opens the same real Combat Lab; its Weapons tab can equip both families. Four seconds still triggers the existing proud idle.

Native before/after, assertions and backup. Owners should judge silhouette consistency in movement and held combos; automated checks do not approve art. Body-only sheets intentionally omit steel and slash FX.
