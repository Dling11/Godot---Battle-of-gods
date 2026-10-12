# 151 - Earthsplitter directional pressure

Status: implemented in the opt-in Foundation Lab review, September 14, 2026. Sword accepted by owner. Pressure-only art was rejected as thin; the owner subsequently approved the fuller eruption revision below.

## Follow-up - upward-cast atlas sliver

The reported seven-o'clock white line after upward casts was reproduced with Compatibility rendering, .7 sword scale, 45-degree rotation, and both vertex/transform pixel snapping. The full-sheet frame quad sampled an adjacent atlas row. Default SubViewport snapping did not reproduce the defect. Explicit per-frame 512px regions with region_filter_clip_enabled remove the leaked samples while preserving the source, frame order, registration, scale and timing. The ground effect and combat authority are unchanged.

`tests/earthsplitter_atlas_render_smoke.gd` passes 29 GPU checks, including a positive control reproducing the old line and all seven windup frames at two scales/two subpixel positions through the production selector. The existing Earthsplitter gameplay smoke passes 116 checks. Before/after evidence: `art_source/review/characters/king/earthsplitter_bleed_2026_09_14/`.

## Context and decision

The owner approved the separate sword strongly and requested this theme for future skills. They rejected the ground's digging/trench look and the sideways/upside-down appearance caused by rotating a right-facing rubble sheet. They requested fixed-length line aiming with freely chosen heading.

Preserve the sword source, packed atlas, frame order, transforms and phase timing. Replace only the ground stamps with a white-blue pressure front, short illuminated fractures and sparse upright chips. Five authored camera views of eight drawings each supply eight facings through horizontal mirrors. Raised art never rotates; flat cracks and authority follow the exact angle, including intermediate headings. The pressure sprite is decorative and follows the swept front; its scale is not a second damage radius.

The cursor chooses direction from King's feet. Nominal reach remains 164px, independently of cursor distance. A shared resolver supplies contact, endpoint, radius and blocked state to preview and committed cast. Terrain can shorten the lane, shown by an amber endpoint bar. The cyan capsule shows the actual 17px radius from initial contact to end. Existing circle targeting remains unchanged through default-off ability hooks.

Stationary overlap checks must use zero motion before a separate motion sweep. Passing the intended travel to the overlap check can treat a wall ahead as an initial overlap and incorrectly collapse the lane. Released damage still rechecks terrain during travel.

## Alternatives and consequences

Retaining rotated rubble would preserve the perspective defect. A curved crescent or heavy trench would contradict the requested appearance. Eight separate sheets would add maintenance without benefit for horizontal mirror pairs. The selected nearest-view art is an eight-facing visual approximation; damage and flat-floor geometry retain continuous aim.

The summon is a reusable animation language, not a rule that every future skill must use a sword. New skills still need distinct purposes and bounded milestone upgrades. No new upgrade forms, Skill 2 implementation, stun, campaign replacement or terrain deformation is added here. Damage, cooldown, control-return timing and existing audio remain from Decision 150.

## Evidence

Earthsplitter smoke passes 116 assertions, including near/far/center cursor, exact intermediate-angle aim, confirmed casts hitting directional targets, width-aware wall stops, one-hit damage, zero stun, recovery and cleanup. Targeted Riftbreak passes 28, Spellward preview 232, and original Echoing Sever smoke passes. Godot Movie Maker review covers eight facings, 17-degree aim, live damage and a wall stop in `art_source/review/characters/king/earthsplitter_pressure_2026_09_14/`.

Approved sword SHA256 remains `610C2D2C52B67498D0D9C160E6DC869EFC289B6C8AA5434469E4FBCEED56A0DF`; source remains `83A1156319142ABDF363F1C4970081A77A72BBB5EF8781F6938D2413CF37F7A2`. Ground-only generation prompt and source are under `art_source/generated/vfx/king/earthsplitter/`; rebuild with `tools/build_earthsplitter_pressure.gd`, not the original sword-and-ground builder.

## September 14 owner correction - restore explosive ground weight

The owner called the thin blue trail a downgrade: the splitter idea was good, but the ground needed more explosive character. Reuse the original sixteen-drawing centered rock/dust eruption, upright for every heading, as stamps every 18px along the released front. Accelerate to its crest, then let stones and dust settle. The five-view pressure atlas now supplies short white-blue bursts inside the eruptions. A connected flat fracture bed prevents vertical casts reading as separate steps; fractured floor spokes, ballistic chips and a slightly stronger terminal stamp add spice without the previous continuous thin line.

The terminal stamp replaces a nearby stamp on short lanes to avoid stacking. All ground bursts are presentation only: 165% once per target, 17px damage radius, cooldown, .36s player commitment, wall stops and stun rules remain unchanged. This is not implementation of the future upgraded damaging endpoint explosion.

Corrected the impact camera lookup: the Lab owns Services above World/Actors, so the previous immediate-parent lookup missed it. Resolve the existing presenter once through ancestors, then request 2.2px contact and 1.4px terminal pulses through its shared tween. Reuse the existing slam with a lower contact pitch and a quieter higher terminal crack, with no per-stamp audio stacking. Sword source, atlas and motion are untouched. No new image generation was needed; this composes existing assets.

Earthsplitter's 116 assertions pass after this presentation revision. Current real-speed nine-heading, damage and terrain evidence is in `art_source/review/characters/king/earthsplitter_eruption_2026_09_14/`; the pressure-only review remains historical comparison.
