# 211 — Axe-specific complete techniques

**Owner rejected this weapon pass. Superseded by Decision212 and iron_beard_canonical_2026_10_15.** The old independently redrawn axe geometry is no longer the current output. Its technical checks did not establish visual approval.


2026-10-15. Implemented for owner motion review. Supersedes Decision210's attack-body/shaft-angle retrofit; its carry, thin handle, effects, audio and combat remain current.

The owner reports that King holds/swings Iron Beard incorrectly and appears to strike with the back of the head. The old attacks borrowed complete scythe poses and independently rotated an axe around a single palm. Correct pivot/size numbers did not establish a second real grip or an edge-leading axe motion. More angle tuning alone would repeat the same failure.

Generate complete axe-specific actors with the weapon and both holding hands drawn together: downward chop, rising return, head-first push, jumping slam and turning cleave. Select102 complete source cels from five built-in generated sheets, including a separate corrected front rise and eight full turn headings. LEFT mirrors SIDE; UP/DOWN have their own vertical strikes. Exclude missing-head overhead source keys and rejected sideways vertical drafts. No anatomy transplants or separate part rescaling.

The offline technique baker registers the entire actor/weapon using one head-calibrated density per board, traced boot support and the approved running/axe palette. Keep256px cells, sole158 and half scale. Generated attack keys hide the extra rigid overlay and disable its interpolation. Actual carry is inherited on entry; released recovery returns to the exact existing body and rigid attachment. Jump presentation loads above the body and lands at the contact cel. The existing presenter supports these complete cels without runtime code changes or anatomy solving.

Tradeoff: baked attack steel now belongs to the complete action artwork. A future axe cosmetic must rebuild matching attack cels; replacing only the rigid carry texture will not reskin these cuts. This deliberate family-owned presentation follows the existing complete Twinsteel approach and prevents floating grips or reversed independently rotating heads. The hidden rig's anchors are compatibility metadata, not a visual proof of cutting direction.

Keep stable equipment/save ID, five cuts/3.19s, damage/reach/knockback/movement commitment,40 white frames, dedicated audio, current run/idle and thin full-length carry/Bag axe. No changes to scythe or other families. Remove the unused scythe-attack retrofit paths from the production builder.

Source/exact prompts/input references/registration: art_source/generated/characters/king/iron_beard_technique_2026_10_15/. Build tools/build_king_axe_unified.gd, which delegates to king_axe_technique_baker.gd; then headless editor import. Current attack resources stay under iron_beard_unified, so normal Bag/F9/F7 use them automatically.

Verification:742 production checks, including370 prior-family guards and13 retained carry/contact files;1287 complete-cel/carry assertions across336 directional samples;171 real headless equipment/gameplay assertions;953 resources load. Frame hashes compare visible paint after normalizing Godot's transparent alpha-border RGB. The tests no longer certify axe technique from the hidden rig. Existing54-instance gameplay fixture teardown warning remains separate. Offline four-direction GIF/contact sheet is under ignored tmp/review/axe_technique_2026_10_15/. No visible Godot launch while the owner plays Monster Hunter World; native owner motion approval remains pending.
