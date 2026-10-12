# Decision 074: Give King a Shoulder Greatsword and Weapon-Bound Crescents

- **Status:** Accepted
- **Date:** 2026-08-02
- **Related:** Decisions 071-073
- **Supersedes:** Decision 073 only where it specifies a modest straight sword, a `48x48` armed cell, and rejection of a starter greatsword

## Context

The approved coarse King identity was correct, but its small straight sword did not communicate the requested heavy warrior class. The first generated motion boards also had irregular dimensions and were review strips rather than exact-cell sprite sheets. Their thin or attached smear effects did not deliver the desired body-sized sword arc.

The owner explicitly redirected King toward a heavy greatsword resting on his shoulder and an exaggerated slash whose physical blade becomes white-hot and generates a thick crescent from its actual swing path.

## Alternatives

- Keep the modest straight sword and enlarge only the VFX. Rejected because the weapon silhouette and animation weight would disagree.
- Put the greatsword on King's back between attacks. Rejected because the shoulder-rest silhouette is part of the requested warrior identity.
- Bake every crescent into King's body sheet. Rejected because it couples damage readability, effect timing, and body animation and makes later effect variants harder.

## Decision

King retains Decision 073's approved body, clothing, palette, coarse pixel density, and cardinal top-down three-quarter view. His signature weapon changes to a broad, heavy silver-white greatsword with a dark steel core, restrained broken-halo guard, crimson cord, and angular tip.

At idle, the greatsword rests on King's weapon-side shoulder. The hand and hilt stay close to the shoulder/body; the blade extends upward and outward away from the head. It is not placed through the head and is not sheathed on the back. Directional poses must preserve this relationship and communicate the weapon's weight through stance and shoulder drop.

Attack presentation uses a weapon-bound crescent:

- the physical greatsword brightens before contact and may overexpose nearly white during the active frame;
- a thick white-hot crescent grows directly from the blade path, with a cold-blue inner edge and restrained pale-violet fragments;
- the effect is a broad melee silhouette, not a disconnected wind projectile;
- body/weapon and VFX use separate runtime animation layers even when a combined proof is used for composition review;
- the authoritative contact shape remains the gameplay truth, and every opaque damaging edge and tip must fit within it.

King's armed idle and locomotion target `64x64` cells while the body stays approximately 28-32 visible pixels tall. Extended attacks may use `96x80` or `128x96` cells. Exact equal-cell geometry is mandatory. Decision 075 establishes one action-owned sheet with four direction rows as the production default; for example, four `64x64` frames across four rows produce a `256x256` sheet. A one-row strip is allowed only as a documented exception and must still use exact cell-count-multiple dimensions.

The review references are:

- `art_source/generated/characters/playable/king/greatsword_proofs/king_greatsword_turnaround_reference_v1.png` — weapon/body direction approved, but its up/back pose is rejected because the sword-side hand hangs below the hilt and the weapon reads as back-mounted;
- `art_source/generated/characters/playable/king/greatsword_proofs/king_greatsword_opening_cut_vfx_reference_v1.png` — attack composition, white-hot blade, crescent, particles, recoil, and recovery approved.

They are irregular-size dark-background source references, not runtime sheets.

## Consequences

- The old modest-sword motion proofs are superseded and must not be integrated. They remain provenance until replacement exact-cell strips pass review, then move to the Godot-ignored archive.
- Production begins with an exact `64x64` armed turnaround, then one exact-cell right-facing Opening Cut with separate body/weapon and crescent sheets.
- Decision 075 requires the turnaround's rear pose to be corrected before normalization and replaces universal eight-frame idle/walk targets with purposeful action-specific frame ranges.
- The larger cells protect the weapon silhouette; they do not increase King's body scale or allow painterly detail.
- Opaw and his weapon presentation remain unchanged.
