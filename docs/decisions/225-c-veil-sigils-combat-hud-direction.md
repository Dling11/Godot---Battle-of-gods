# 225 — C Veil Sigils combat HUD direction

Date:2026-10-17. Current status: B concept remains approved; the owner rejects the simplified native fidelity even after density correction. The current reference/skill-art pass is installed for owner review; earning authority remains deferred.

## Context

The owner compares complete Ashsteel, Bloodstone and Veil Sigils artwork, selects C, and corrects its reversed top-left status order: avatar first on the LEFT, HP extending RIGHT. A supplied earlier HUD image is a reference only for the weapon-mastery readout and small attack/defense/status indicators. Its bottom avatar, twenty square skills and long bottom HP are not selected.

## Direction

Keep C's portrait identity, round rune skill medallions and original pixel glyphs. Keep player status at top left, skills at bottom center, numeric player XP below the dock and accepted Bag/TAB plus Settings/ESC at bottom right. The working review capacity remains8 King plus6 equipped-weapon techniques with separate SPACE; existing runtime ten-slot data is unchanged. The installed HUD shows equipped active definitions and collapses absent slots/rows without placeholders; future unlock rules still require mastery authority.

The owner selects the second/B refinement, C2 Status Card: group exactly one weapon-mastery readout below HP beside the avatar, followed by small ATK/DEF/AS indicators. Preserve C's portrait and round skill artwork. Mastery remains separate from King level and blue player XP. Native UI must remove the generated C2 decorative duplicate-track artifact and render one authoritative mastery meter. The source picture's illustrative MASTERY5 and the new examples' ATK32/DEF18/AS+8% are design data, not verified player stats.

The owner prioritizes saving screen space: shrink the visible dock, keep it close to the bottom edge, and put descriptions in themed hover cards. Initial native review target is about300x80 logical pixels with2-4px bottom clearance at960x540, subject to real font/icon/hit-area checks. The owner confirms the instruction applies ONLY to the skill dock's visible floating gap. Keep avatar/HP/mastery/stats top-left and Bag/Settings bottom-right; use a minimal inset so the dock frame remains fully visible. No further anchor clarification is needed.

Skill hover/focus cards should briefly delay appearance, show the name/key and concise description plus applicable actual damage/type, cooldown, charges and effects, fit above the bottom dock and clamp inside the viewport. Mastery/stat/status cards explain their own data and units. They remain non-blocking, dismiss on exit/focus change and do not pause combat or trap focus. Reuse existing skill-slot descriptions/authority; current basic text tooltips already exist. Final detailed values and mastery progression still need real data.

## Alternatives

Ashsteel, Bloodstone, C1 and C3 remain historical review alternatives. Do not restart their artwork/placement selection when continuing this task. C's HP-first orientation is explicitly rejected. Previous below-only HP and twenty-slot preview layouts are superseded. C2's grouped readouts are selected; only exact native metrics remain open; skills-only bottom anchoring is confirmed.

## Consequences and limits

Mastery needs an actual family-owned progression authority before production can show earned rank/progress; it cannot reuse King XP or hardcode sample values. ATK must have a defined resolved attack-power/damage meaning, DEF must reflect actual armor rather than imply a flat damage reduction, and AS should mean attack speed rather than movement speed. Active buffs/debuffs should appear only when their real state exists. No new rewards, levels, weapon swap policy, skill migration or balance follows automatically from a mockup.

Keep artwork size, font metrics, circular icon padding, tooltip/mouse targets, cooldown legibility and safe margins measurable in native Godot after visual review. Current production bytes and accepted actors remain protected. Final concepts stay temporary, ignored and Godot-excluded; no permanent raw-image archive. Current proposal: docs/design/combat-interface-and-weapon-progression-proposal.md. Exact input roles/prompts: docs/design/combat-hud-c-mastery-prompts.json.

## Installed native implementation2026-10-17

See ../design/veil-sigils-hud.md. Generated64px portrait/40px medallion/five24px glyphs feed native controls rather than a flattened screenshot. At960x540, the five-skill/dodge dock is269x62 with2px bottom clearance; the status group is254x76. Forty-pixel hit targets preserve readability within the proposed compact budget. Current component/equipment data owns cards and ATK/DEF/AS. The deferred mastery region shows equipped weapon identity, with no fabricated rank/XP. Mastery techniques will be unique animated actions.

Existing ten-slot data and9/0 keys remain intact; empty definitions collapse and there is no absent weapon row. Future8+6 is a progression/migration decision, not a lossy UI cap. Native focus lives in a screen CanvasLayer; real delayed mouse hover and physical Space/Bag requests pass. Sanctuary's obsolete wide-frame override is removed. All actor art and gameplay clocks stay exact.

## Visual fidelity correction2026-10-17

Owner asks whether the first playable pass is final because it does not resemble the selected example. A passing geometry/input audit does not approve artistic fidelity. Replace the simplified portrait/ring and native flat rails with illustrated beveled frames, red/blue/green stat chips, numeric portrait badge, rune keycaps, complete diamond XP caps and illustrated Bag/Settings faces. Remove the rectangular skill-dock backing. Dynamic fills/text and all gameplay/saves remain authoritative; there is still no fabricated mastery row or absent weapon skills. Reference remains C2, not a newly selected art direction. Show actual in-game captures before calling visual work final. Details and exact prompts: ../design/veil-sigils-hud.md and ../design/combat-hud-fidelity-prompts.json.

## Owner status-only redraw2026-10-17

The owner provisionally passes the skill dock, finds the top-left composition wrong, asks to remove ATK/DEF/AS and questions the item-name strip and missing mastery UI. This supersedes the earlier permanent stat-chip requirement for the next status design. Keep accepted skills/XP/utilities while reviewing three new status-only layouts. Use an explicit weapon-family mastery label, separate rank and purple progress meter; keep King level distinct. Preview values are illustrative. Mastery gameplay remains deferred; the selected UI must include a designed unbound state rather than silently substituting an item name or omitting the control. No new runtime installation occurs before choosing the new composition. See ../design/player-status-mastery-redraw.md.

## Selected B and status visibility2026-10-17

Owner selects B Mastery Ribbon, asks whether Sword Mastery is the right universal name, and requests matching HP/lower-bar widths plus hoverable buff/debuff icons. Use WEAPON MASTERY with the current family icon and a family-specific hover heading. Match gauge endpoints/widths while keeping HP visually stronger. Put active-only beneficial/harmful icons below mastery, separated by rim color and a small gap; cards expose actual strengths, duration/stacks and damage only when applicable. Keep King level, family rank, player XP and forged-item tier separate. Refined concept scope and verified Vow example: ../design/player-status-mastery-redraw.md. B replaces the earlier A/C alternatives; no additional runtime systems are installed by this design refinement.

## Refined B approved and installed2026-10-17

Owner approves B and specifically requires mastery hover and readiness for10–12 simultaneous effects. Install the round portrait, level badge, aligned HP/mastery gauges and active-only status strip. Mastery hover identifies the equipped family and describes weapon proficiency. Family rank/XP has no authority yet: use an explicit empty/pending state, never sample5 or340/600. Twelve22px icons wrap into two rows with live hover values; this is not a mechanical cap or new status gameplay. Existing Vow, Resolve/link, root and stun/stagger signals provide actual values. Remove rejected permanent ATK/DEF/AS/item-name rows, old VowStatus/ResolveLabel and unused UI art/readouts. Skills/XP/utilities, ten-slot data, saves and accepted actors/weapons stay exact. Native implementation/verification: ../design/veil-sigils-hud.md. Earning/unlocks and phone/touch remain open under226.

## Runtime density correction2026-10-17

HUD density correction2026-10-17: the original64px nearest-filtered portrait and low-resolution frames were enlarged by the normal1920x1080 window over the960x540 logical canvas. Re-export the same source art at3x logical density with Lanczos/graded alpha and use local linear filtering only on the portrait and fixed HP/mastery artwork. Their layout sizes/gauge endpoints remain exact; skills/world sprites and global filtering stay unchanged. Native960x540 UI audit256/0 and true1920x1080 before/after captures verify the correction;15 UI PNGs total217,922 bytes. No new design selection or gameplay/progression change. Fixed-frame rendering separates physical raster density from logical UI dimensions.

## Reference fidelity and skill artwork correction2026-10-17

Latest HUD review2026-10-17: the owner approves the B concept but rejects the simplified native rendition and requests matching skill quality. Rebuild the missing details from the approved reference: attached cyan Lv plaque, framed coin readout, slimmer30px mastery chassis with emblem/rank lozenges and inset gauge, illustrated status rims/glyphs, icon-headed gemmed hover cards and serif typography. Fresh72px skill glyphs still render24px inside40px medallions; XP/utility art is also dense at its unchanged footprint. Current base status is244x83;12 effects fit244x116 with six22px icons per row. Actual family mastery remains unbound (rank —, gauge — / —); hover describes weapon proficiency. Concept5/340/600 exists ONLY in the isolated native comparison fixture. Native258 checks and true1080p captures pass; these do not constitute owner art approval. Start next review from docs/design/hud-reference-fidelity.md and the single compact approved reference. Preserve all actor/weapon artwork, inputs, progression and saves. Rebuild approved details rather than interpreting rendering checks as final artwork acceptance. Lora font is bundled with OFL attribution; keep one small approved reference and only selected current runtime textures, no raw-board archive.

## HP inset and professional hover wording2026-10-17

Owner reports the red HP fill looking overlaid and rejects resource-comparison copy in mastery hover. Match the frame’s inner opening with a 160×12 shared chamfer mask for immediate HP and the damage trail; keep the lower bevel visible and the portrait rim in front of the HP socket. Center HP digits on the aperture. Mastery uses “Weapon proficiency”, family-specific title and the actual unavailable-rank/XP state. Remove unrelated progression comparisons from Resolve’s effect card. The approved artwork and all gameplay/save authorities stay unchanged. Native Compatibility261/0 includes rendered corner/lower-lip checks; Bag/progression74/0 and full resource loading pass.

## Sealed mastery presentation and readable player level2026-10-17

Owner rejects the empty mastery meter and missing-value slashes, asks for a designed default appearance and a more noticeable player level. Keep family XP/earning deferred: present a subdued illustrated violet inlay, equipped-family emblem, lock seal and SEALED label. The hover says weapon training is coming in a future update. Remove unused numeric-rank/ProgressBar controls rather than displaying invented progress. Enlarge the player-level plaque from34×15 to48×22 and digits from10px to14px, retaining its real progression binding. Move coins/effects6px down; base status is244×89, twelve-effect state244×122. Existing artwork bytes, HP join, skills, controls, saves and mechanics remain exact. Native Compatibility261/0, Bag/progression74/0 and925 resource loads pass; actual1080p captures cover level1/10 and mastery hover.
