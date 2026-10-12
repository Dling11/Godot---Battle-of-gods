# Decision178: Typed damage and registered critical impact

Date: 2026-10-04. Status: Implemented for approved damage families and critical presentation. Counter/reach comparisons are review-only; promotion remains open.

## Context

The owner approves the proposed physical/magic/pure rules, requests noticeable red critical frames/larger digits, and authorizes continued implementation. The shared11px LabelSettings masked the old critical font override. The Hog's braced contact reconstructed DamageInfo, discarding critical metadata and disconnecting displayed damage from the accepted amount. Existing armor protected against every damage source; changing spell types without initial resistance would silently weaken established enemies and gear.

## Decision

DamageInfo carries an explicit normalized enum; missing/invalid values default to physical. Weapon/ability/zone tuning supplies type. Every committed contact, released wave, descent and aftershock preserves it. Physical resolves armor then universal ward; magic resolves separate magic resistance then ward. Pure bypasses these reductions, while guard, temporary shield and invulnerability remain authoritative. Critical, stun and knockback are independent.

Basic sword/Earthsplitter/Pursuit are physical. Molten Crash/Worldsplitter/Rotcaller ground spells are magic. Unbroken Vow is a self buff. Existing armored enemy definitions and Heartwood Plate initially receive magic resistance matching armor, keeping established mitigation. Pure has no blanket700% Worldsplitter assignment or production starter skill.

CombatFeedbackPresenter uses a shared generated192x48 atlas: four48px drawings,25fps,0.16s, nearest/binary alpha, common(24,24) contact origin and one0.075 source scale. A critical replaces the ordinary contact burst, without new global freezes. Local17px red CRIT settings preserve11px ordinary digits; normal type tint is ivory/blue/pale violet. Source/exact prompt/registration are retained. Hog brace modifies its per-target incoming payload and preserves all other metadata and existing stun rejection.

The isolated rewardless review owns50% test crit, defense/type overrides and36/42px forward reach comparison, keeping44px width. It alone installs the perfect-dodge counter:0.12s early dash plus an actual blocked enemy strike earns0.75s to land one pure basic counter (+25% additive weapon multiplier). First accepted positive-damage contact consumes it; the committed cleave remains consistent. Misses may retry before expiry. Same-dash crowd contacts cannot refresh it; late/empty dashes, debug immunity and self damage cannot farm it. Damage/defeat clear readiness; pause freezes timers. Production Player has no counter component.

## Alternatives

UI-only type labels would misrepresent damage authority. Reusing ward as magic resistance would reinterpret existing equipment. Turning all spectacular skills pure would discard balance. Increasing damage/font globally to emphasize criticals would affect ordinary hits. Generated frames without registration recreate prior animation wobble. Permanent reach/counter tuning before a playable comparison would combine unrelated balance choices with approved type work.

## Consequences and evidence

Version1 save identities/ranks need no migration; types and resistance live in resources. Review clones cannot mutate shared weapon/ability shapes. Existing damage budgets, starter0%/Varkuun8% crit, stun, dash and scenery rules remain.

Native review46/0 includes real typed sword contacts, atlas/alpha/frame captures, resource restoration and an actual early-dodged Rootling jab. Typed authority50/0 covers reductions, guard/shield/immunity, Hog metadata, real Foundation wave/Mature heat pulses/Mature descent, equipped Heartwood defenses and copy. Counter25/0 covers consumption/expiry-state/pause/farming protections. Sanctuary training73 headless/84 native, Worldsplitter118, Vow/Worldsplitter49 and legacy control/armor/crit regressions pass.

Short native Stage IV moving-AI1/5/8 samples are retained alongside screenshots/logs in art_source/review/combat/critical_impact_2026_10_04/. They do not prove cold campaign/GPU/phone performance, final difficulty, owner art acceptance or permanent counter/reach tuning. Existing shutdown-resource warnings remain. Elite break, charged hold and further material-hit audio remain future work.
