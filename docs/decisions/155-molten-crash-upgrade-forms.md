# 155 - Molten Crash upgrade forms

Date: 2026-09-26. Status: implemented in the opt-in Combat Lab; campaign unlocks pending.

## Context and decision

The owner approved Molten Crash's quick local contact, but its full orange lava treatment read like an upgraded form. Keep one Skill 2 slot and one .36s sword action while making each rank visibly and mechanically useful:

| Form | Contact | Delayed pulse | Presentation |
| --- | --- | --- | --- |
| Foundation | 72px, 200% weapon | None | The same sixteen-drawing sword/ground motion in blue stone and white-cyan light. |
| Advanced | 80px, 230% weapon | None | The already approved molten-orange treatment. |
| Awakened | 84px, 192% weapon | At the original contact after .34s: 86px, 48% weapon, damage only | Sixteen new moving heat-wave drawings show pressure charging and releasing outward. |
| Mature | 86px, 216% weapon in the 48px core; 72% of that contact value in the rim | 86px, 54% weapon, damage only | A separate sixteen-frame basalt core buckles under the sword before the outward heat wave. |

The percentages describe unmitigated, noncritical damage per target before existing equipment/mastery/combo modifiers. Awakened totals 240% for a target present for both hits. Mature totals 270% in its core and 209.52% in the rim for targets hit by both. An enemy first entering the field at the pulse can take the pulse alone. All forms retain the initial .55s authored stun and 65 radial knockback, subject to target resistance. The later pulse never reapplies stun. The Mature damage core is separate from its stun area, so outer targets still receive the initial stun. The largest radius is below the planned 1.2x Foundation radius limit.

## Ownership and tradeoffs

`MoltenCrashDefinition` owns form values and the 80/20 contact/pulse budget. The component snapshots the resolved weapon damage at cast and uses the existing hitbox for contact. A short-lived world-fixed aftershock node owns the delayed area query and ordinary accepted-hit delivery, with one hit per target at that pulse; the ring visual has no damage authority. Terrain and foot-radius checks apply to both contacts. The review adapter lets the owner compare forms without changing saved loadout IDs, and blocks form changes while the pulse is pending. Defeat/review exit cancels the pulse.

Pure color swaps were insufficient because the owner asked for growing area and gameplay. Longer player lockout and repeated stun were rejected because they would make the skill less responsive and crowd control excessive. A full-damage second hit was rejected because it would double the cast budget. The owner's visual review rejected the earlier gold Foundation and found Awakened/Mature too similar. Foundation is blue; the newer heat wave has a clear outward contour, and Mature gets a compact animated center. The first generated heat-ring draft had eight transparent atlas cells and was replaced; the previous complete ring is retained as source provenance. The selected wave and core sheets each have sixteen populated, padded cells. Existing approved King body art and sword design are reused.

## Evidence and limits

Molten Foundation 40 and upgrade 38 checks pass, including exact radii/budgets, delayed world-fixed pulse, wall checks, no repeat stun, Mature rim stun and visible core, defeat/review-exit cancellation, form gating, and original skill restoration. Godot Compatibility capture shows all four forms at game scale and early movement. This is a Lab comparison, not a campaign unlock or phone performance claim. Stage gates, persistence and final gear/boss tuning remain for integration.
