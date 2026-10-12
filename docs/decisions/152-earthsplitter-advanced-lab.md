# 152 - Earthsplitter Advanced Lab form

**Owner correction (2026-09-14):** Intended Advanced is three spatial lanes in a rotating fan (center plus two angled sides) for wider AOE. The current sequential Cascade remains implemented and preserved as a possible later/third upgrade; it is not the accepted Advanced design. Fan implementation is pending. Resume from [the handoff](../design/earthsplitter-fan-handoff.md).

Date: 2026-09-14. Status: implemented prototype; owner feel review pending.

The owner approved Foundation's summoned sword and fuller eruption and requested an upgrade with three waves, the third longer and more explosive. Build the comparison now before campaign progression integration.

One .36s cast releases three waves after .20s contact. Release offsets are 0/.16/.32s, reaches 164/196/228px, radii 17/19/21px and travel .25s each. Total weapon multiplier is 2.25, allocated .20/.25/.55 per wave. Each enemy can take one hit per wave, not three full-budget hits. First two light pushes keep enemies in the lane; the last carries stronger push/visual impact. No stun, new invulnerability, repeated sword casts or increased player commitment.

Foundation remains selectable at 1.65 weapon multiplier and 164px. Form selection changes the same local Skill 1, never adds an equipped slot. The Lab adapter refreshes slot references and restores original definitions/scripts/loadout on exit. No saves, stage grants, unlock currency or campaign skill removal are introduced.

A released sequence snapshots paths and combat stats and owns wave scheduling independently of Player recovery. Each ground attack retains radius-aware terrain sweeps and per-wave target accounting. Source defeat and review exit cancel pending waves. Presentation observes authoritative fronts, reuses approved artwork and settles early-wave aftermath sooner.

The third endpoint is visually stronger but has no additional radial damage. Awakened's damaging endpoint, later stages and exact unlocks remain planned. The earlier illustrative 1.15x Developed target is superseded by this Lab's 225/165 budget; later tiers require fresh balance testing. Creating three full damage hits or extending King's cast was rejected because it would inflate power or reduce responsiveness.

Evidence: `tests/earthsplitter_advanced_smoke.gd` covers 49 assertions; review capture and validation are in `art_source/review/characters/king/earthsplitter_advanced_2026_09_14/`. These checks establish behavior, not final boss/gear balance.
