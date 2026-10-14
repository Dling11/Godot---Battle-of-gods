# Decision204 — Finish oversized Iron Reaper as playable equipment

Date:2026-10-14. Status: implemented after owner acceptance of the oversized preview and authorization to finish. Full-weapon art/feel review and earned acquisition remain separate.

Superseded in part by Decision205: owner rejects this pass's running/idle and replaces its local third-cut spin with throw/linger/recall/catch. Current rules/art/evidence are in king-iron-reaper.md and CONTINUE_WEAPONS.md; the values below record the earlier implementation.

## Context

The owner asks to finish the accepted large scythe so work can move on. Existing Sword, Axe, Greatsword and Twinsteel art must remain intact. Prior trials repeatedly broke body proportions through pasted heads/torso or detached grips; complete connected poses are required. Decisions202–203 remain historical motion-study deliveries.

## Choice

Install Iron Reaper using existing equipment/inventory/Player/family presentation. Retain accepted oversized side sources; generate64 complete vertical action poses and48 whole running/idle poses, with LEFT mirrored from RIGHT. Use a single whole-board anatomy density, padded256×256 cells at sole158/half scale/offset−16 and shared empty overlays. No copied anatomical fragments. Retain exact source images, prompts, registration and protection hashes.

Implement Hook and Reap as optional data-owned per-cut rules: Light-only24px return pull with28px stand-off, and25% final-reap bonus strictly below40% pre-hit HP. Keep normal critical/resistance/armor/guard authority and deduplicated contact. Bosses resist pulling and never receive an automatic execution. Activation clears absent rules so skills/equipment switches cannot inherit specialty state.

Use separate generated white ribbons with floor projection and a soft mask of the authoritative convex shape. Raster gutters preserve all blade tips; emphasized FX cannot advertise extra contact area. Configure existing licensed impact streams, with a stronger finisher. Data-owned four-cut timing totals2.38s; base DPS23.1 deliberately trades single-target output for range/grouping.

## Root causes corrected

Native physical-wall testing revealed that enemy controllers subtracted a blocked old impulse on the next tick, creating opposite-direction rebound. Project surviving impulse through slide normals after movement for all seven controllers using that bookkeeping. Pull speed includes one physics-tick allowance; continuous-time integration alone exceeded the cap in discrete parent-before-child movement. Physical free-pull and wall checks now verify the bounds.

Preview padding was trimmed without resampling characters. Eighteen unique blank overlays were replaced with two shared atlases. The recorder uses Player's child camera LOCAL offset, and a2× camera leaves room for complete vertical effects. Changes to preview recording do not change gameplay camera settings.

## Alternatives

Leave the scythe in a standalone viewer; defer a complete family and fail the requested playable outcome. Reuse cropped King anatomy or generic rotated side actions; rejected because it recreates the owner's visible frame/proportion problems. Hard-code scythe effects in Player; rejected in favor of optional resources and reusable collision-aware impulse authority. Give unconditional high damage/execute bosses; rejected because it removes weapon-role tradeoffs.

## Consequences and evidence

Normal catalog/Bag/Weapons supports the scythe and existing snapshots; F9/launch review is non-saving. No campaign recipe/drop is silently granted. Current runtime art adds about1.48MiB and selected new source28.05MiB remains excluded from runtime packaging. Existing532 King assets remain byte-exact. Detailed rules and current validation are in docs/design/king-iron-reaper.md. Gameplay assertions, visible contact effects and real-enemy comparisons pass; these do not replace owner visual judgement or phone/cold-load profiling.
