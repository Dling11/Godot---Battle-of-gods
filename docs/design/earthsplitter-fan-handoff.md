# Earthsplitter: owner correction and next-session handoff

**Current terrain/aim correction (2026-10-03,Decision177):** Slot1/5 keep full authored reach through scenery; Slot3 flies over any intervening obstacle to clear, real-foot/nav/bounds-valid ground. Silver/slate/violet circles and hardware pointers replace gold/blue targeting and use actor feet/render-frame aim. This supersedes earlier terrain-aware/clipped or LOS-stopped descriptions below. Current rule/validation: king-targeting-and-terrain.md.

**Skill 1 accepted direction (2026-09-26):** Earthsplitter Fan now releases three simultaneous lanes at center and +/-20 degrees, followed .22s later by one stronger, longer center wave. One sword smash and .36s base commitment remain. Initial lanes reach 196px (19px radius), deal 100% weapon damage once per enemy across the fan, and use light push/flinch. The follow-up reaches 228px (21px radius), deals 140% once more, and has heavier impact/55 knockback. Maximum unmitigated noncritical weapon budget is 240% per target; side targets usually receive only the fan. No stun. Foundation and Cascade remain separate Lab comparisons. Campaign promotion, upgrade gates, phone testing and the requested later cleanup remain pending.

**Handoff complete:** the owner approved fan then one stronger center wave. That combination is now implemented in the existing Fan form. Next planned skill work is Molten Crash; campaign promotion/upgrade gates and deferred cleanup remain separate. Historical September 14 handoff follows for reference.

September 14, 2026. Documentation-only handoff requested as credits run low. No gameplay/art changes in this correction.

## Owner intent - overrides the Advanced interpretation in Decision 152

The owner meant THREE SPATIAL LANES from one smash: center plus an angled lane on either side, making a fan/triangular spread for greater AOE. For right-facing aim these look like upper, center and lower lanes. The whole formation rotates with the aim; these are not fixed world-up/world-down attacks, three parallel rows, or three consecutive waves down the same lane.

The current cascading prototype misunderstood that request. Preserve it: the owner likes enough of the idea to consider it for a later, possibly third upgrade. That rank and whether it combines with the fan are not finalized. Do not delete it or describe it as the accepted Advanced design.

## Runtime truth at handoff

- Foundation remains the accepted single lane, 164px reach, 17px radius, 165% weapon damage once per enemy, no stun.
- The Lab FORM: ADVANCED button still selects Cascading Rupture: three sequential same-direction waves at 0/.16/.32s after contact, reach 164/196/228px, radius 17/19/21px, total 225% weapon damage split 20/25/55%.
- The requested three-lane fan is NOT implemented. Current cascade tests and captures do not validate it.
- Both existing forms have one summoned sword action, .36s body commitment and released effects independent of later King movement. Preserve the approved sword, fuller ground eruption, clipped atlas cells and early control return.
- Stage/save unlocks, new Molten Crash and later damaging endpoint explosions remain unimplemented.

## Next bounded implementation

1. Keep Foundation and the current Cascade available as separately named Lab comparisons. Make the intended Advanced comparison the three-lane fan. These are forms of Skill 1, not additional equipped slots.
2. Author a center lane plus two symmetric angled lanes released together from the single impact. A starting angle around +/-20 degrees is a proposal for visual testing, not an owner-approved number. Keep fixed form-owned lengths; cursor distance controls heading only. Preserve upright ground art in every direction.
3. Preview all three exact lane paths. Each must resolve its own radius-aware wall stop, including a wall blocking one branch while others remain clear. Reuse the current preview/commit geometry; do not draw a filled triangle unless damage actually covers that entire area.
4. Give the fan an explicit per-cast damage budget and cross-lane target accounting. Recommended starting rule: a target takes one lane hit per fan cast, so overlap near the sword cannot accidentally triple damage. Do not blindly reuse Cascade's 20/25/55 allocation: spreading those shares into separate lanes could make AOE hits feel weak. Exact damage, angles and lengths need testing, not inherited approval.
5. Keep one .36s cast, no stun, existing equipment/mastery/eligible combo modifiers, ten-slot bindings, dash rules and source-defeat/review-exit cleanup. Audio/camera should accent the shared smash rather than triple the boom at simultaneous launch.
6. Capture Foundation / Fan / preserved Cascade at normal speed. Verify cardinal, diagonal and intermediate aim, side-lane targets, overlap accounting, per-branch walls, release snapshots, cancellation and original loadout restoration. Then review the fan before deciding on the third upgrade.

## Code and evidence pointers

- `data/abilities/king/earthsplitter_definition.gd`: current two-form configuration and wave recipes. Replace the binary form choice with explicit identities when adding the third comparison; keep existing behavior available.
- `gameplay/abilities/king/earthsplitter_component.gd`: cached templates, path snapshots and release wiring. Currently resolves every recipe toward the same point; fan needs per-lane headings while the sword/body retain the center heading.
- `gameplay/abilities/king/earthsplitter_path.gd`: shared fixed-range, scenery-independent resolver.
- `gameplay/abilities/king/earthsplitter_sequence.gd`: released-wave scheduler and combat-stat snapshots. Child attacks currently deduplicate individually; fan cross-lane accounting needs explicit ownership.
- `gameplay/abilities/king/earthsplitter_visual.gd` and `earthsplitter_ground_visual.gd`: preserve approved sword atlas clipping and upright eruption presentation.
- `levels/combat_lab/earthsplitter_review.gd`: reversible adapter; replacing definitions must refresh loadout references or hotkey 1 loses its binding.
- `levels/combat_lab/king_spellward_review.gd`: comparison button; `gameplay/abilities/targeting/ground_point_targeting.gd`: multi-path preview.
- Existing regression baseline: Foundation 116, Cascade 49, rendered atlas 29, targeted Riftbreak 28, Spellward 232, mastery 385 checks passed in the preceding implementation turn (839 total). No tests rerun for this documentation-only handoff.
- Existing footage: `art_source/review/characters/king/earthsplitter_advanced_2026_09_14/`. This folder shows the preserved CASCADE, not the requested fan.

Resume request: "Continue the Earthsplitter fan handoff: three spatial lanes from one smash; preserve Cascading Rupture as a later-upgrade candidate."
