# Sword, axe and dual swords: combat / Bag / contact audio closure

**2026-10-07 cadence/input:** Owner authorizes faster axe loading/recovery and held world LMB across weapons. Axe totals3.19s/28.9 nominal base DPS; contact/art/reach/damage/audio stays. V2 is separately authorized; V1 art/data remains. Earlier freeze/no-new-input scope below records the original closure. [Latest rules/proof](king-greatsword-front-combo.md).

2026-10-06. Implemented initial role tuning and presentation, after owner accepts the axe motion. **Royal Greatsword is explicitly frozen** until the owner's fresh idea. It receives no new art, icon, damage, description, cadence or sound profile. This pass preserves all installed King body/weapon/FX animation assets; only new Bag icons and contact recordings are produced.

## Current numbers

These are unempowered physical base rolls. Skills still use25 Skill Power. No new crit chance, stun, unlock, recipe, save field or input is introduced.

| Weapon | Base roll | Hits / nominal chain | Per-cut multiplier | Complete-chain range | Mean base DPS |
|---|---|---|---|---|---|
| King's Sword |10–12|3 /1.91s|1.00,1.15,1.65|38.0–45.6|21.9|
| Iron Beard Axe |14–16|5 /3.19s|1.15,1.10,1.05,1.50,1.35|86.1–98.4|28.9|
| Twinsteel |9–11|5 /2.20s|0.80,0.85,1.05,1.10,1.50|47.7–58.3|24.1|

Sword is the balanced three-cut starter. Axe is the committed heavy exchange: base knockback60 (before each authored multiplier),0.12s flinch; its existing25% wind /0% contact /60% recovery walking is retained. Dual swords have lighter hits and more contacts per second, existing40 knockback/0.08s flinch and50/0/75% walking. Two drawn blades still yield **one damage result per enemy per input**. Existing dodge/skills/interrupt/reset/buffering remain authoritative. Damage tuning never changes body playback or Skill Power.

Sword keeps the36px-forward fan. Axe keeps72px fans,78px head push and68px radial fifth. Twinsteel keeps72px thrust/fans,58px radial fourth and80px final fan. Only the designated radial steps hit behind. Approved timing, shapes, movement and animation resources are unchanged.

Base DPS = mean integer base roll × sum of combo multipliers ÷ sum of all wind/contact/recovery phases. It assumes a continuous full chain on **one target**. The estimate excludes armor/ward, criticals, empowered King modifiers, missed contacts, hitstop, equipment speed, dodge/cast gaps and multi-target totals. It is useful for comparing initial roles, not measured encounter DPS or final campaign balance. Equipment speed still divides actual phases under its existing50% cap. The Bag calls this **BASE DPS**, describes each actual damage range, and provides a tooltip with the exclusions.

## Contact audio

Normal accepted hits for these three items use **Impact** by Iwan “qubodup” Gabovitch, [CC0 source/license](https://opengameart.org/content/impact). Two body-impact recordings supply three static variations; the third is a40/60 blend. Mono decode, near-silence trim, short fade and peak normalization to approximately-4dBFS occur offline. No metallic sample is used. Sword playback1.0pitch/-6dB, axe0.82/-4dB, dual1.14/-8dB; small deterministic pitch offsets accompany the three-sample rotation.

CombatFeedbackPresenter plays one positional SFX cue at the first accepted target of each swing. Misses have no impact cue; broad cleaves do not allocate one sound per target. Existing swing-air audio remains separate and unchanged. Skills and incoming enemy/player-damage audio retain their existing cues. A null hit_audio keeps exact old stream,1.0pitch and0dB behavior, including Greatsword. There is no random loop or per-frame audio synthesis.

Original attachment, extracted originals, source page and unused early synthesis are retained under `art_source/audio/weapon_contact_2026_10_06/` with `.gdignore`. Credit and processing are in [Audio Attribution](../../assets/audio/ATTRIBUTION.md). Pack SHA256: `98D72B55D6F78A32072439ED4D052FC43FDD80B8B409D18A9BB3150FC2CCD97B`.

## Bag ownership and files

`build_weapon_bag_icons.gd` composes approved raster steel into64×64 transparent icons. Sword keeps its approved diagonal design; axe shows the complete broad iron head; Twinsteel shows **two full outlined blades**. It does not modify canonical world steel or character sprites. Nearest/lossless/no mipmaps/no alpha-border fixing preserve native edges. Existing immutable inputs remain needed; they are not unused assets to delete.

Only these three EquipmentDefinition resources opt into show_combo_details, a64px inspection, data-derived stats and per-cut ranges. Greatsword and other equipment retain42px inspections and legacy descriptions. The centered paper doll retains its approved family presentation. HIT sorts by maximum base roll; DPS sorts by nominal full-chain mean damage/second, highest first. Nonweapons fall back to slot/name ordering; material sorting remains unchanged.

- `data/weapons/weapon_hit_audio_definition.gd`, `audio/{sword,axe,dual}_contact.tres`: immutable sound profiles, referenced from the three weapon resources.
- `data/weapons/weapon_combat_readout.gd`: shared pure readout; no damage authority.
- `data/items/equipment/{king_signature_sword,king_iron_beard_axe,king_twinsteel}.tres`: icons, truthful lore/roles, readout opt-in.
- `gameplay/presentation/combat_feedback_presenter.gd`: bounded accepted-contact observer and backward-compatible gain argument.
- `ui/equipment/equipment_detail_panel.gd`, `ui/character_menu.gd`: opted-in preview/readout, numeric sorting.
- `assets/ui/inventory/weapons/`: three icons. `assets/audio/sfx/player/weapon_contact/`: three PCM recordings, decoded offline.
- `retired generation tool (recover from Git history only)`, `tools/build_weapon_contact_audio.gd`: reproducible offline builders.

## Play and verification

Restart F5 → F9 → Tab → choose/equip one of these three → F7 Combat Lab. F9 is a non-saving testing kit; crafting/acquisition remains pending. Normal gameplay shares these definitions. Test air swings, clustered targets, switching weapons, Bag/ESC controls and the full combo.

Native proof, Bag captures and audio auditions documents checks and actual limits. Automated assertions are not owner audio/feel approval. Next is scythe design samples before animation; see [handoff](../../CONTINUE_WEAPONS.md).

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
