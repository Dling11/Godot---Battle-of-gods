# Decision227 — Bounded Bag and equipment inspection

Status: implemented2026-10-17; owner accepts the floorless gradient follow-up. Phone/touch review remains open.

The owner reports HUD skill numbers above the Bag, equipment descriptions escaping the modal, weak item/King previews and poor equipment search. Preserve inventory, saves, combat and current weapon art while improving the shared Bag.

Use a proper modal draw depth and a Container page host. Keep item identity/equip fixed while all variable detail text scrolls in a clipped inspector. Equipment browsing uses weapon/armor icons and explicit sorting; material search remains. Use live definition-derived coloured statistics and mechanics, with rarity order independent of historical serialized enum IDs. The owner-selected floorless native gradient and thin slate border replace the rejected illustrated chamber. Complete existing King rest poses retain one common scale and boot-row positioning; no new background raster is retained. Existing steel supplies whole, fitted item icons; rarity affects inspection styling according to actual tier.

This replaces unbounded text columns, cycling sort, equipment search and the rotating polygon/shadow preview. It does not create earned mastery, item levels, upgrades or new weapon balance. Read docs/design/bag-inspection-refresh.md for exact layout, data ownership, asset retention and verification.
