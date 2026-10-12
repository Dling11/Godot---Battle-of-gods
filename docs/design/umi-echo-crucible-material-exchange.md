# Umi's Echo Crucible

## Player flow

Umi stands east of Sanctuary's center avenue, facing left toward a narrow Echo Crucible. Speak to her and complete the short introduction to open a compact two-tab surface.

- **Sell Materials:** choose an owned, sellable material, set quantity, preview exact gold, and confirm.
- **Reconstruct Echo:** choose an Uncommon, Rare, or Boss catalog target. Every target row and the selected-target detail show the currently owned output quantity before the player spends anything. Inspect source-memory progress, click owned fuels to add one unit, right-click to remove one, or use Auto Fill. Confirm only when meld, gold, source memory, catalysts, and any boss-memory charge are valid.

Both operations save at the Sanctuary safe point. A failed spend, output grant, or save restores the material, coin, and boss-memory snapshots.

## Presentation contract

- Umi stands on the right and faces left. The compact workbench sits immediately to her left, with its shallow usable bowl on the workbench's right edge beneath her working hand.
- The runtime prop is a 72x64 lateral, asymmetrical workstation: reservoir/shelf on the far left, low work surface through the middle, and restrained cyan bowl on the right. It is not a Sanctuary landmark.
- Reject symmetrical altars, shrines, stairs, arches, entrances, mirrored towers, giant orbs, and front-facing facades. The silhouette must read as practical side-facing furniture at Umi's 48x48 world scale.
- Author portrait and prop details at their native logical density. Do not disguise high-resolution illustrations as project pixel art through simple downscaling.
- Collision follows only the low furniture footprint. Bowl pulse/orbit presentation remains separate and must not move collision, interaction, or navigation authority.

## Automatic material contract

Umi never owns a material list. `material_catalog.tres` is canonical and each `MaterialDefinition` supplies:

- stable identity, region, rarity, family, icon, and description;
- stable source enemy ID and display name;
- optional overrides for sell value, meld value, reconstruction meld/gold cost, required defeats, and same-region Rare catalysts;
- explicit sell, fuel, and reconstruction permission flags.

Rarity defaults provide usable behavior for new content, while overrides handle exceptional materials. Common materials are never reconstruction targets: their high supply is reserved for crafting, selling, and crucible fuel. Uncommon, Rare, and Boss materials can become targets automatically when their metadata permits it. Boss rarity defaults to protected sale/fuel values and the four-Rare-catalyst reconstruction rule; authored boss resources also disable sale and fuel explicitly.

## Balance defaults

| Rarity | Sell | Meld per unit | Target meld | Target gold | Source defeats |
|---|---:|---:|---:|---:|---:|
| Common | 1 | 1 | Not a target | — | — |
| Uncommon | 5 | 10 | 100 | 75 | 10 |
| Rare | 18 | 35 | 400 | 200 | 20 |
| Boss | Protected | Protected | 1500 | 1000 | 10, override per boss |

Boss reconstruction additionally consumes four Rare materials from the same region and one boss-memory charge. A charge is earned every ten recorded victories. Rootbound Core unlocks at ten Rootbound Husk victories; Varkuun Core unlocks at twenty Varkuun victories.

Auto Fill reserves required Rare catalysts first, then consumes the lowest meld-value owned materials until the target threshold is met. It does not select the target itself, protected Boss materials, or unavailable quantities.

## Campaign unlock

Umi's intended campaign arrival is after Stage VIII, when the player has encountered enough low-drop materials for reconstruction to solve a real problem rather than trivialize the opening economy. Stage VIII and its completion authority are not implemented yet, so the current Sanctuary instance remains available for production testing. The eventual gate must use the canonical Stage VIII completion state and hide or lock the whole service consistently; do not invent an interim flag that can strand a save.
