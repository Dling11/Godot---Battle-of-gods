# Approved B HUD: native fidelity review

Update232: the mastery chassis now observes the first real Axe proof and shows `1 PROOF · F1 LEARNED`; other families stay sealed. Hover routes untrained Axe users to Veyr. This adds no XP gauge or invented rank; all artwork and dimensions below remain unchanged.

Updated 2026-10-17. The B concept is approved; the owner rejected the simplified native rendition. The owner provisionally accepts the sealed mastery and larger level follow-up. Preserve the current HUD while reviewing the Bag under Decision227.

## Visual target

The single maintained target is [approved_mastery_ribbon.png](../../art_source/reference/ui/approved_mastery_ribbon.png), a compact crop of the owner-supplied image. Match its shapes and typography as well as its placement. Do not treat passing functional checks as artistic acceptance.

| Part | Current implementation |
| --- | --- |
| Portrait and level | Round King medallion, larger48×22 engraved cyan LV plaque and separately bound14px white level digits |
| Vitality | Red highlighted fill, actual current/max digits, illustrated frame; immediate HP and finite damage trail retained |
| Mastery | Slim violet chassis, live family emblem, lock seal and subdued engraved SEALED inlay |
| Currency | Framed coin plaque; ordinary amounts exact, large amounts compact with exact gold on hover |
| Effects | Illustrated cyan/rose frames, dedicated shield/Resolve/root/stun glyphs, real counters and concise cards |
| Cards | Gemmed borders, title icon, serif hierarchy, separator and live effect values; compact effect cards, fuller skill cards |
| Skills | Six fresh illustrated symbols; 72px glyphs drawn at 24px within 40px dense medallions |
| XP and utilities | Original approved artwork restored from larger sources; positions, XP authority and Tab/Esc remain unchanged |

At 960×540 logical resolution the status group is 244×89, growing to 244×122 with twelve effects. Effects use six 22px icons per row with 4px gaps. The mastery chassis is 184×30; HP and the dormant mastery inlay share160px width, with heights12px/7px. Level badge enlargement adds6px of vertical clearance before coins/effects; the portrait, HP and mastery chassis stay in place. The dock remains 269×62 for the starting loadout, 2px above the bottom edge. Absent slots collapse; the existing ten-slot model and 9/0 keys remain compatible.

## Actual values versus the reference study

Production family mastery is not implemented. Its designed inactive state uses a real equipped-family emblem, lock seal and subdued violet inlay labeled SEALED. Remove the former missing-value readout, numeric-rank label and unbound ProgressBar. Hover identifies the family and states that weapon training is coming in a future update. Do not invent earned XP or thresholds. King Resolve/link remain separate existing combat effects.

The older reference_sample_status.png is a historical, isolated concept-value study; its5/340/600 values are not production data. Current native reviews use the designed sealed state. Vow, Resolve and root examples observe existing component state; no poison/blind/mastery systems are introduced by this UI work.

## Source and ownership

Exact built-in prompts: hud-reference-fidelity-prompts.json. Selected component bounds, original hashes, output dimensions, glyph padding and alpha rules: ../../art_source/reference/ui/veil-sigils-hud.json. Discarded board parts and raw generation files are not project dependencies. Keep final runtime PNGs and this one compact approved reference; do not create another archive.

VeilStyle.artwork scales fixed shapes. framed_backdrop renders variable tooltip/XP borders on a threefold physical NinePatchRect beneath a 1/3-scale Node2D wrapper, keeping source margins out of logical Container sizing. Current UI art uses local linear sampling; world sprite filtering is unchanged. Source ownership follows complete visible components across nominal grid boundaries; each glyph has 3px padding before display reduction. Lora is bundled under its included SIL OFL license; FontVariation selects weight 600 for display text. No system-font dependency.

HP uses a 160×12 inset aperture with 3px chamfered corners. Both immediate HP and the damage trail share its native alpha mask; neither can cover the illustrated lower lip or squared corner areas. The portrait rim draws in front of the HP socket, and digits remain centered over the gauge. Mastery hover uses “Weapon proficiency” with the actual availability state; product cards contain no design-discussion resource comparisons.

Clear the original LEVEL placeholder before sizing its badge label. Otherwise its old minimum width survives a later numeric text update and pushes the digits outside the plaque. Regression checks cover level 1 and level 10. Focus outlines render below keycaps. Hover cards preserve actual mouse/focus lifecycle, ignore input and release focus for Space.

28 final UI PNGs total 512,584 bytes; the font is 212,196 bytes. The one approved reference is 309,955 bytes. Two obsolete former stat textures and the unused rail helper are removed. The updated manifest guards 683 files; all previously guarded non-UI assets are byte-identical. Actor/weapon art, attack/movement clocks, skills, rewards, damage and saved identities are unchanged.

## Verification and test route

Native Compatibility HUD audit: 261 checks, zero failures. This includes real mouse hover, live shield updates, all-family emblem changes, twelve-effect containment, root counts, stun expiry, sparse/legacy slots, physical Space, Bag click isolation, resizing and badge containment. Bag/progression 74, Sanctuary skills 73, Vow/Worldsplitter 49, theme/icon checks and action controls pass. All 925 retained code/scene/resource loads pass. Phone/touch and owner artistic acceptance remain separate.

Latest true1920×1080 captures are under ignored tmp/review/ui/hud_sealed_level_2026_10_17: level_1.png, level_10.png, actual_game_1080p.png and mastery_sealed_hover.png. These show the current sealed presentation and larger level badge. Prior reference/health/skill studies remain historical evidence. No flattened screenshot is installed as UI.

Stop the existing run, press F5, then Continue. Hover mastery, active effects and skills; use F9 → F7 → Weapons for family-emblem changes. Family mastery earning/techniques remain future work under Decision 226. No commit or push is performed.
