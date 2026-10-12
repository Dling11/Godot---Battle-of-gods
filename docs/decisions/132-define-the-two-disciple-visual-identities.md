# Decision 132: Define the Two Disciple Visual Identities

## Status

Accepted and amended — 2026-08-24

The owner subsequently rejected the preliminary numeric size limits, then approved the deliberately tall, long-legged Examiner direction shown in the 2026-08-24 same-baseline preview. The first four-cardinal board was rejected as excessively large beside King and too feminine in silhouette. The corrected preview-only V2 static design is now approved; exact runtime pixel height, cell, baseline, and normalization remain unapproved.

## Context

Decision 131 established a calm first Disciple for Stage VII and a harsher future counterpart, but left their silhouette, gender presentation, equipment, shared divine language, and gameplay-scale translation open. The owner supplied a written two-character concept direction and later reattached the accompanying `1536x1024` image. The exact reference is now preserved outside runtime assets with provenance and checksum. Preliminary scale measurements remain comparison evidence only, not production limits.

## Alternatives Considered

1. Treat both Disciples as generic armored knights and differentiate them mainly through color.
2. Copy or shrink the high-detail concept directly into runtime sprites.
3. Preserve their high-level masks, silhouettes, impossible weapons, and shared divine order while producing original top-down hard-pixel interpretations whose deliberately large relative scale is approved visually before runtime packing.

## Decision

Choose option 3.

- The first Disciple uses the role title **The Examiner** and a masculine, tall, lean, athletic silhouette. Pale ivory/white-stone armor, restrained gold geometry, long elegant pieces, a smooth fully covered mask, controlled stillness, and sudden precise speed define him.
- The Examiner's signature weapon is a **Divine Split Glaive**. The first production contract is limited to a precise thrust/sweep sequence, explosive dash, bounded parry/escape, and one split-blade technique. Physical body/weapon animation precedes VFX.
- No Examiner or Executioner runtime pixel height, cell, baseline, or upper size limit is approved yet. The first deliverable is a preview-only art-style and same-baseline scale board; large or huge humanoid scale is allowed, and approval must precede animation sheets, collision, or code.
- The second Disciple uses the role title **The Executioner** and a feminine/subtly feminine, taller, broader, heavily armored silhouette. Darker divine material, restrained violet accents, a smooth covered mask, four to six broken halo fragments, and overwhelming force distinguish her.
- The Executioner's signature weapon is a broken circular **Divine Execution Wheel**. Her attacks remain future design only.
- Both share mask construction, white-stone divine material, restrained gold geometry, a future repeated emblem, limited floating components, and impossible weapon construction without reading as demons or obvious villains.
- `Examiner` and `Executioner` are role titles; personal names and the exact shared emblem remain open.
- Runtime/source ownership uses `characters/disciples/<identity>` and other identity/purpose paths, never `stage_7`.
- The Examiner is the only production priority. The Executioner receives no runtime art, animations, scene, dialogue, or combat implementation from this decision.
- The reattached concept image is preserved outside `assets/` as a non-runtime reference with provenance and checksum. It must not be copied pixel-for-pixel.
- The 2026-08-24 same-baseline board approves the Examiner's tall, long-legged direction. Static four-cardinal V1 is rejected for excessive King-relative scale and feminine read; corrected V2 is the accepted static design reference. Runtime packing must normalize that design at an owner-reviewed gameplay scale instead of importing the concept board literally.

The complete scale, animation, palette, folder, production-order, and rejection contract lives in `docs/design/disciples-of-the-one-above-visual-contract.md`.

## Consequences

- Stage VII character generation now has a defined identity and an owner-controlled art/scale approval gate rather than an undefined “god-tier follower.”
- The Examiner does not need to match King's scale; both Disciples may be tall, huge, and imposing if the preview remains readable in the top-down world.
- The Split Glaive's impossible behavior remains readable and reusable without allowing VFX to hide weak body animation.
- The Executioner can be foreshadowed consistently while remaining unimplemented.
- A shared divine language can become recognizable before the story explains The One Above, but the permanent emblem and mask mystery remain protected.
- The static art gate is now passed. Exact runtime scale/baseline, special-arena composition, and a body-authored Split Glaive motion proof remain required before bulk animation or combat implementation.
