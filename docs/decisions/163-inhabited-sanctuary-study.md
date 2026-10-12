# Decision 163: Make the Sanctuary study an inhabited settlement

**Closeout amendment:** Decision165 promotes current town/placement to normal play and archives old comparison. This document remains decision history; docs/design/sanctuary-closeout.md owns current runtime status.

**2026-10-02 priority correction:** Owner redirected effort from additional houses/interiors to NPC service functionality and skill arrangement. Further interiors are deferred. Eira placement/name clarity and the shared training/loadout presentation are corrected using existing service/library authority; the accepted furniture scale and F-required entry remain. See ../design/sanctuary-npc-usability.md. This does not promote campaign environment art or grant new progression.

**2026-10-02 interior follow-up:** Continue with one walkable Orren workshop proof composed in the optional study. Reuse the same Player, DialoguePanel and service authorities; give furniture shared physics/navigation footprints, reversible bounds/camera/tolerance changes and explicit doorway return. Suspend outdoor overlays without discarding destination selection. Inspection remains rewardless and Orren remains outside. Other interiors and campaign promotion are pending. See ../design/sanctuary-workshop-interior.md.

**2026-10-01 follow-up:** Owner feedback rejects diagonal artisan buildings and requests clearer screen UI. The same optional study now uses overhead houses with left-positioned entrances, a persistent corner minimap, compact action frame and reversible generated nine-slice modal theme. Reuse actual menu/service controls and live map coordinates; preserve old assets. Only the crafting-body overflow fix also applies outside the study. See ../design/sanctuary-interface-renewal.md. Campaign promotion and final visual acceptance remain pending.

- Date: 2026-10-01
- Status: Implemented in optional review; owner visual/feel review pending.

## Context

The owner identified the old red merchant cart beside Orren's accepted new workshop, mismatched old trees, randomly scattered broken walls and passive NPC presentation. They requested cohesive surroundings, clearer NPC discovery, interaction and a walking civilian. Earlier F5/Continue confusion also exposed the need for an accessible in-game review entry.

## Alternatives

- Retain mixed old/new props and add only labels.
- Make service NPCs wander, moving interaction targets around town.
- Rebuild the entire campaign map immediately.
- Compose a reversible town-life pass on the existing study, keeping reliable service positions.

## Decision

Use the last approach. Hide/disable the legacy cart and six trees only in the study. Replace them with generated planted linden/cedar silhouettes, a modest anvil/tool station, Eira's lectern, a noticeboard and continuous limestone garden boundaries with intentional openings. Preserve accepted workshop/lodge art and the portal.

All four service NPCs gain role-colored ground rings, labels and throttled approach greetings. Orren/Eira briefly hold their attentive pose, then resume authored working frames. Their DialogueNpc and service authorities remain intact; Orren does not gain a shop. A town map exposes existing services and the expedition gate, tracks King and highlights one chosen destination with a compass cue. It gives direction, not automatic pathfinding or movement. F at the noticeboard opens the same map; M toggles it.

One rewardless, nonblocking courier follows an authored collision-checked circuit with service pauses, directional contact/passing and standing poses, and yields near King. Following owner feedback, stride phase derives from actual displacement; waiting and obstruction select idle. Rowan now has an optional F conversation routed through existing DialogueNpc/SanctuaryFlow, with fixed services taking priority if ranges overlap. No rewards or save authority are added.

F5/Continue retains original campaign presentation. In debug builds, F10 exposes `SANCTUARY REVIEW · NO SAVES`. Entering mounts one study instance, suppresses saving for the rest of that process, starts beside Orren and closes admin mode. The existing launcher reaches the same study directly. Old/new comparison restores original props/collision/presentation but does not re-enable saves. Restart normal play to resume saving.

## Consequences

The town has recognizable destinations, purposeful work corners and ambient circulation. The owner's follow-up authorized Nema then Umi: both now have working presentations/portraits and angled houses; Eira's lectern is off-road, foliage has bounded wind and two swallows fly occasionally. Sources/rejected versions remain recoverable. Interiors, campaign promotion, mobile profiling and owner feel acceptance remain future work. `../design/sanctuary-courtyard-renewal.md` owns current correction details.
