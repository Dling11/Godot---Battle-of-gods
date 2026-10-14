# 207 — Give Iron Reaper deliberate swing momentum

Current correction: [Decision208](208-iron-reaper-complete-ribbons-and-ground-pivot.md) retains these swing angles/timings while registering attack supports to the ground circle, limiting whole-cel effort and fitting complete white strokes inside contact space.

2026-10-14. Implemented for motion review. The owner accepts Decision206's appearance and asks for more convincing swings, weapon angles, body effort and recoil. Preserve that design, running and simple idle.

The previous action axes were folded into a frontal half-plane; most UP contact keys used the identical180° shaft direction. Collar registration also held the upper body in one spot throughout a cut. These choices flattened the generated body's anticipation and follow-through despite consistent proportions.

Keep all approved connected actor pixels, palette and density. Author motion separately in motion-authoring.json beside the existing complete sources. The offline baker applies small integer translations to entire attack cels and their primary palms, authors full per-view one-hand shaft arcs and sets relative pose exposure inside the unchanged gameplay phases. No head, torso or limb is rotated/resized independently. Every translated cel is checked byte for byte against its original occupied anatomy. All running and idle clips remain exact; no shared family presenter or gameplay authority is modified.

The first cut loads back/high, accelerates through a downward arc, overshoots and recovers. The hook rises through the opposite arc with a backward weight transfer. The throw winds back, releases, recoils, waits and absorbs the catch. The final reap loads overhead, lifts11 world pixels, commits quickly and holds a compressed landing before recovery. Body shifts stay within3.5 world pixels in the authored lane, with vertical projection compressed to0.6. These are presentation weight shifts; existing collision-bounded steps4/3/−3/6px remain authoritative.

Primary shaft pivots remain on traced palms. Secondary attack anchors are explicitly one-hand direction hints; they do not claim a second physical grip. Rigid steel stays at unit held scale/half flight scale. LEFT is still the exact mirrored side. UP/DOWN receive the authored arcs rotated into their attack lanes rather than a constant vertical-view angle.

Released steel now projects its launch and catch from the complete actor's authored hand transforms. Spin accelerates outward and brakes during recall, then aligns with the catch. The raster pivot correction accounts for held(40,112) versus flight(40,98). Flight position, terrain handling, hit radius, damage shares, linger clock and deduplication stay under ReturningWeaponAttack and are unchanged.

All combat timings, damage, reach, control, audio and existing white effects remain exact. Motion uses current event/phase tweens; no passive per-frame system is added. The existing live projectile observer calculates its raster transform from normalized authority progress.

Validation:1512 production source/head/palm/gutter/anatomy/preservation checks;160 motion checks covering four directions at baseline/+50% attack speed, opposite active arcs, grip/scale, launch/catch attachment and completion;181 native gameplay,250 returning-authority,46 held-input,28 idle and14 native capture checks. The current resource scan is recorded in CONTINUE_WEAPONS.md. Existing gameplay fixture teardown warnings remain separate from passing assertions. Native clips are under ignored tmp/review/iron_reaper_weight_2026_10_14/. Owner motion judgement remains open; this is not a balance or target-device performance claim.
