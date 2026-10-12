# Decision 136: Rework Examiner Animation, Court, and Audio

## Status

Implemented in the F7 combat proof on 2026-09-12 at the owner's request to redo the boss and improvise its presentation. Final owner feel approval and production Stage VII integration remain pending.

Follow-up: the owner accepted the overall look and attacks. Decision 137 supersedes the gait extraction and skill-effect details after reported repeated feet and clipped weapon tips.

## Context

The owner reported weak animation, oversized UI, simple terrain, and imprecise collision. Inspection found that the old thrust wind-up already contained contact poses and then held a prior pose during damage; other actions also shared anticipation/contact frames. Grounded charge directly assigned position, bypassing physics. The shared boss HUD inferred three health phases even though Examiner owns two phases and a 70% transition.

## Alternatives

- Keep the existing sheets and add more effects: leaves pose and timing problems intact.
- Replace the combat controller: unnecessary risk to the tested trial, cover, and story boundaries.
- Replace coherent action families and repair the presentation/physics seams: selected.

## Decision

- Ten new generated eight-column/four-direction action sheets retain the ivory mask, navy underlayer, gold halo, and Split Glaive identity with stronger filled shapes. The owner authorized this rework; older V3/V5/V6 visual approvals are historical references rather than a restriction on this replacement.
- Runtime cells are padded `192x160`, baseline `y=128`, body origin `(0,-48)`. One scale derives from the standing locomotion reference. Import recovers connected actors across imperfect source gutters, removes exterior matte, retains binary alpha, and anchors dark feet separately from the downward blade. Reviewed right profile actions supply mirrored left profiles; the landing source's reversed profile rows are normalized before packing.
- `build_examiner_rework_frames.gd` owns 116 named clips. Anticipation and contact spans are disjoint; thrust, slam, and Descent contacts actually animate. Direction changes during allowed wind-up tracking preserve frame/progress. Controller signals continue to own contact/damage timing.
- Ground Judgment's final wind-up uses a dedicated four-direction overhead-raise supplement with complete glaive and braced legs. Its source density is normalized once before the common runtime scale. The fixed-position red-eye overlay is retired; the short impact silhouette now follows the actual body only.
- Grounded charge and Axiom travel use `move_and_collide`; physical blockers terminate travel. The lab has four physical walls aligned with its existing rectangular movement/navigation area. Aerial Descent retains its explicit collision-disabled lifecycle.
- The Court has one generated flat engraved-slate floor, a circular central motif, and traversable recessed cyan ward plates. The same four positions and exact 54-pixel radii own protection. Floor motifs do not create collision. Charge, slam, and lane warnings remain data/controller driven; Axiom floor lanes render below actors. Restraint in aura/seal brightness keeps body poses readable.
- Sixteen original synthesized cues separate air/steel swishes, metal counters, stone transients, charging tones, Descent, and walking contacts. Footsteps observe walk frames, action/impact players observe existing state/contact signals, and the single existing music foundation stays encounter-owned. Audio stops on exit and does not start a dummy playback in headless verification.
- Compact lab controls fit the logical viewport. The boss HUD accepts explicit boss-owned phase/technique text; other bosses retain existing health-band behavior. The lab still grants no rewards or saves.

## Consequences

The complete replacement is reviewable in F7 and through the rendered capture helper. Damage values, phase threshold, cover duration, finite impact damage, and progression remain as before. This does not complete Stage VII or a project-wide terrain/UI redesign. Final sound mix and perceived animation weight require the owner's playtest.
