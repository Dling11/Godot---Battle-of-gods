# Player status and family mastery redraw

2026-10-17. Status: B concept approved; simplified native fidelity rejected, replacement/reference-and-skill pass installed for owner play review. Family progression authority remains deferred.

The owner provisionally passes the current skill dock. The screenshot calls out the top-left group: the standalone King's Sword item name is confusing, ATK/DEF/AS should be removed, and weapon mastery is missing. The native presenter currently confirms those chips/name row and contains no family-mastery control. Geometry/functional checks do not constitute visual approval.

## Selected composition and earlier alternatives

Keep the King portrait first on the left, red HP to the right and a readable player-level badge. Remove the permanent ATK/DEF/AS tiles and standalone item-name strip. Add a clear family mastery label, separate mastery rank and exactly one purple mastery progress meter; family learning differs from King level, blue player XP and forged-item tier. Detailed weapon statistics/descriptions belong in hover/Bag presentation. Keep the current skill dock, bottom XP, utility buttons, hidden map and accepted actor art intact.

Three genuinely different proposals: A Linked Crest connects an octagonal portrait to two compact parallel HP/mastery rails; B Mastery Ribbon places one continuous mastery ribbon under the whole portrait/HP group; C Quiet Status Card puts portrait/HP/mastery inside one restrained cohesive card. Avoid many small overlapping decorative strips and excessive gem borders. Design near230–240px width and66–78px height at960x540; final native metrics still require actual rendering.

All three use the same illustrative comparison values: King Lv10, HP248/248, Sword Mastery5 and340/600 mastery progress. These are review numbers, not earned gameplay values or approved thresholds. Preview imagery stays temporary, ignored and Godot-excluded under tmp/review/player_status_redraw_2026_10_17. All three previews are generated and visually reviewed: no permanent stats/item-name row, separate player level/mastery and a single purple progress bar. A uses attached parallel rails; B has a circular portrait and full-width ribbon; C has one cohesive quiet card. The owner selects B Mastery Ribbon. C's earlier recommendation is superseded; keep the round portrait/ribbon flow while refining proportions and naming. The previews are enlarged corner studies, not a native Godot capture or proof of final pixel metrics. The selected mastery control needs an explicit unbound/empty state while progression authority remains deferred; do not invent earned XP, reuse King progression or silently replace mastery with an item name.

## Initial review boundaries (historical)

Only design/progress documentation changes in this review. No new mastery XP rule, rewards, technique animation, NPC, crafting behavior, progression/profile schema, gameplay or production texture is installed. Mastery techniques remain future distinct actions with their own animation/combo frames under226. Those boundaries describe the earlier preview-only pass. The approved B installation below now replaces the rejected runtime composition.

## Selected B refinement2026-10-17

Owner selects B, questions Sword Mastery naming, requests consistent HP/lower-bar widths and asks for small active buff/debuff icons with hover values. Use WEAPON MASTERY on the compact HUD; the actual family icon and a family-specific hover heading (Sword/Axe/Greatsword/Dual Swords/Scythe Mastery) distinguish the learning track. Do not hardcode Sword or an individual item name into a universal label. King level and weapon rank remain separate.

Match the visible HP/mastery gauge widths and align their left/right edges. HP fill is taller/stronger than mastery. A compact mastery header and progress gauge belong within one ribbon, not a third wide empty label strip. Preserve B's round portrait and integrated ribbon silhouette. Native targets remain approximately240px wide and90px high including active effects; these are targets, not validated engine geometry.

An active-only row of about18px icons sits directly below mastery, separated from the currency readout under the portrait. Beneficial effects align left with cyan/blue rims; harmful effects follow after a small gap with crimson/violet rims. Show duration or stacks/escape count where meaningful; do not label a tap count as seconds. Hide expired/absent effects and leave no permanent empty tiles. Avoid resurrecting ATK/DEF/AS as status chips. A bounded overflow indicator can expose extra effects while retaining important control conditions visibly. These are player effects; enemy effects belong with the selected enemy's HUD.

Hover cards show effect name, source/description, actual strength, time remaining and stacks. Show damage only for effects that deal damage, with actual damage type and tick interval when applicable. Shields show remaining absorption; damage buffs show their real percentage; roots/stuns show control/escape rules. Poison/other future statuses are not installed by this preview. The illustrated Unbroken Vow example follows the current Foundation definition:25% of248 HP gives62 shield and+12% outgoing damage, with an illustrative4 seconds remaining. Real cards must observe the live component/rank/shield/timer, not these sample numbers. Existing KingMastery is Resolve/link, not weapon-family progression.

Refinement previews and exact built-in prompts: player-status-b-refinement-prompts.json. Current runtime remains unchanged in this design pass; family XP/technique authority is deferred. B is selected, not the former A/C alternatives.

Final enlarged B refinement: tmp/review/player_status_redraw_2026_10_17/b_refined.png. Visual check confirms two main frames, matched visible red/purple gauge endpoints, a single sword-family symbol, separate Lv10/rank5 badges, three small status icons and one Vow hover example. No third standalone label strip. This remains a concept image, not a native runtime capture.

## Owner approval and native installation2026-10-17

Owner explicitly approves b_refined.png and requires mastery hover to prevent confusion with mana plus capacity for10–12 active effects. Do not reopen selection or restore C2 stat chips. Native B is installed; see veil-sigils-hud.md for actual dimensions and evidence. WEAPON MASTERY remains visible; its mouse/focus card follows the equipped family and clearly identifies proficiency, separate from King level/XP and item upgrades. Rank/XP is explicitly unavailable until a real family-owned authority exists. No mana system or casting resource is introduced.

Use active-only22px icons with4px gaps and six columns, fitting12 in two rows; no empty tiles, fabricated statuses or mechanical12-effect cap. Buffs/control effects use their actual signals/countdowns. Hover shows current name, strength, duration, stacks or escape inputs, with damage/type/ticks only for damaging effects. Existing Vow, Resolve/link, restraint and stun/stagger are bound; other statuses remain deferred. Open cards refresh current values and all expired entries collapse. No gameplay clocks, balance, profile or actor/weapon artwork changes. Native play review remains separate from concept approval.

2026-10-17 density follow-up: owner reports the game looks pixelated compared with generation. Same-source3x portrait/HP/mastery exports and local linear filtering correct the64px nearest/2x-window mismatch while preserving B dimensions and world/skill art. Details/evidence: veil-sigils-hud.md.

Latest2026-10-17: density correction alone did not match the reference. Current native work rebuilds the missing plaque/gauge/status/card details and skill art. See hud-reference-fidelity.md; approved concept numbers remain isolated review data, the current inactive mastery state is a sealed violet inlay with family emblem/lock, and the player-level plaque is larger. Unknown-value slashes are retired.
