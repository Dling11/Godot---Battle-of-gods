# Expedition renewal and world-life recommendations

2026-10-03. The owner accepted all five recommendations, particularly distinct biome art and sound. This is the approved work program, not a claim that every feature is implemented. Preserve Stage I's accepted visual direction. Start with Stage II's bramble renewal and outdoor audio, then deliver the remaining slices in the order below.

## Delivery status

| Slice | Status |
|---|---|
| Stage I compact woodland | Implemented; visual direction accepted |
| Stage II bramble art, layout and Stage I/II outdoor audio / shared music handoff | Implemented; owner visual/mix review open |
| Stage III Hollow renewal, wind/wood ambience and optional pressure review | Implemented; owner visual/mix/difficulty review open |
| Stage IV Eastern Rot renewal and regional sound | Implemented; owner art/mix review open |
| Stage V Dead Forest renewal, sentries and sound | Implemented under Decision171; owner review open |
| Stage VI Elder Ascent renewal and sound | Approved; planned |
| Rotcaller / Burrowkin fresh mechanics | Rotcaller trial and bounded III/IV/V campaign placement implemented; Burrowkin planned |
| Field scout with real walk frames and Sanctuary milestone reactions | Approved; planned |
| Authored lore marker, limited cache and breakable supplies | Approved; planned |
| Optional Hunts with known crafting rewards and saved receipts | Approved; planned |

## Preserve the journey

Use Stage I's finer density, readable footprints and living presentation as a quality baseline while giving each biome its own assets, lighting, landmarks and ambient sound. Do not recolor one forest kit and call every stage finished. Preserve top-down perspective, existing scene/encounter/reward authority and clear fight/interaction spaces.

| Stage | Established identity | Recommended renewal |
|---|---|---|
| I — Forgotten Grove | Living woodland, first melee/leap encounters | Accepted compact oak/fir, irregular paths and old paired shrine; add restrained outdoor sound |
| II — Thorns of the Forgotten Grove | Thorn/ranged pressure in living forest | Distinct bramble borders, smaller thorn plants, root-crossed paths and an identifiable ruined crossing; keep ranged sightlines legible |
| III — Rootbound Hollow | Corrupted roots, ritual seal and Husk guardian | Knotted trunks, old carved stones, restrained violet accents and enclosed atmosphere; protect seal/telegraph/chest visibility |
| IV — Eastern Rot | Living west progressively decaying toward the east | Author a visible west/east transition through ground, crowns, debris and sound rather than applying a uniform dark tint; keep the Hog charge lanes readable |
| V — Dead Forest | Full decay, dead-tree edges, approach and Varkuun basin | Compact dead snags, fallen remains and coherent shrine ruins; occasional creaks/insects with sparse music before the boss entrance |
| VI — Elder Ascent | Muted teal forest, pale-stone terraces, cliffs and waterfall | Renew modular rocks/cliff joins and vegetation at the same perspective; water spray and local water audio support the established ascent, with a more open musical arrangement |

Stage VI is a deliberate ecological/altitude contrast after V, not simply more dead woodland. Its existing approved ground, top-down terrace and fixed waterfall bank remain reference points (Decisions125–127).

## Approved additions, in order

1. **Biome art and readable layout.** Start with Stage II; then renew III–VI in their own material families. Generate reusable isolated props and stage-specific ground detail. Review each in-engine beside King and live enemies before archiving its replaced material.
2. **Outdoor sound and music flow.** Add quiet forest wind/birds, hollow root/stone creaks, dead-forest insects and local water sound. Improve scene/boss transitions through the existing AudioDirector rather than starting unrelated complete tracks over one another. A small recurring regional melody can change instrumentation as the forest decays and opens into the ascent. New music/source recordings require a listenable review before adoption; no audio assets are created by this recommendation document.
3. **An optional field scout with a role.** Introduce one recurring NPC at safe entrances or after completion, with real directional walk/work frames, a concise stage briefing and a route into optional Hunts. Define their name, identity and service before generating final character sheets. Give existing Sanctuary NPCs short saved-milestone reactions so Varkuun's defeat and a newly crafted weapon feel acknowledged. Do not place service conversations in active attack lanes.
4. **A small amount of exploration.** Prototype one inspectable lore marker and one authored side cache per selected stage, then a few breakable pots/old supply props. Use real F interaction, one-time/first-clear or explicit replay reward rules and normal saving. Destructible obstacles must release their physical footprint and update navigation through events. Define reward budget before adding drops; no infinite respawn farming.
5. **Replayable Hunts.** Build the already-planned Hunt selection/receipt/save contract with clear conditions and known material rewards; the scout or noticeboard can expose it. Hunt variants should reuse authored encounters deliberately (for example, defeat a marked elite or survive a named reinforcement pattern) rather than invent a daily timer system. Link rewards to actual crafting needs.

## Suggested next concrete build

Stages II–V are renewed; Rotcaller now appears in III/IV/V and expeditions have distinct music. [Decision171 delivery and ordered next work](stage-5-renewal-and-combat-polish.md) puts loading/start UI, portal/spawn presentation, hit audio, pointer/movement and measured performance before VI/scout/Hunts. III uses13+1/five live; IV60/eight; V six/five sentries, then a solo boss. The optional III18+1/six review remains separate. Specific NPC identity, exploration reward budgets and Hunt rules still need concrete design before implementation.

## Verification boundaries

Review native960x540 silhouettes, enemy/projectile telegraphs, roots/obstacle navigation, arrival/exit/chest access and the complete clear/return loop. Listen to the mix with combat enabled: footsteps and attack cues must remain audible; avoid a decorative sound on every small movement. Phone performance, final economy and later campaign content remain open. Stage I acceptance does not claim those finished.

Technical reference for positional ambience: [Godot AudioStreamPlayer2D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html). Mixing reference: [Godot audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html). Existing AudioDirector, Music/SFX/UI separation and accepted project art contracts remain implementation foundations.
