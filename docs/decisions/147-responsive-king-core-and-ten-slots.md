# 147 — Responsive King core and ten equipped slots

Date: 2026-09-13. Status: implemented; combat feel and campaign balance await owner review.

## Context and authorization

After reviewing the responsive-kit, ten-skill and divine-inheritance proposals, the owner instructed us to finalize King's skills first and follow the roadmap. This authorizes the core responsiveness prototype and coordinated ten-slot migration. Forest Goddess art/encounter, Examiner passive additions and future divine rewards remain separate work.

## Decision

Keep approved compact greatsword C anatomy, existing equipment and level caps, manual movement authority and one action buffer. Rework the four Oath families while retaining their stable IDs for saved selections:

| Stable ID | Display family | Control commitment before hit pauses | Role |
|---|---|---|---|
| crosscut_advance | Crosscut Advance | 0.48 s | Two advancing cuts; Dash cancels unreleased contacts |
| griefwake | Griefwake | 0.42 s | Ground-targeted eruption; releases at 0.20 s, impacts about 0.46 s |
| starfall_step | Breakstep | 0.32 s | Collision-controlled 0.20 s step with a short middle protection window |
| oathstorm | Last Oath | 0.62 s | One forward precision impact with a weaker wide crowd-clearing rim |

Forms improve bounded damage/range without extending commitment or adding mandatory hits. Resolve is consumed by damaging skills; Breakstep preserves it. Completing Breakstep opens the existing 1.2 s rupture link. An eligible incoming hit blocked during Breakstep's protection primes the next accepted basic attack for +50% damage and a return-cut animation within two seconds. Another skill, expiry or defeat clears it; debug immunity and dodge-piercing Verdict do not qualify. Space Dash stays independent.

Griefwake and Last Oath create released world-space authority with immutable damage, critical profile, point and tuning snapshots. Subsequent casts, movement, recovery cancellation and rank updates cannot change that attack. Defeat/scene teardown removes it. One outer hitbox selects either core or rim damage per hurtbox. Griefwake's rim applies a 25% ordinary-movement slow for 1.2 s only to Light-tier enemies; existing Elite/Heavy/Boss control rules remain intact.

Ten equipped slots use 1–9 and 0. D-pad left/right chooses a slot, D-pad down activates it; existing controller shortcuts and target confirmation remain. AUTO SKILL scans all ten but leaves the timing-dependent Breakstep manual. The HUD and collection expose empty positions. Four-entry saves expand without rearranging choices or granting powers; absent loadouts retain the original defaults. Eight techniques currently exist, so ten slots do not imply ten learned techniques.

Sanctuary's Equip core kit assigns only learned core skills to 1–4, preserves other nonduplicated selections and saves once. Lab can preview every core form without saving. Original four skills remain alternatives. Empty slots can be cleared explicitly; unavailable powers do not become unlocked by a save migration.

## Presentation and consequences

Retimed approved directional body frames, opposing white trails, raster impact sequences and existing layered audio preserve C's identity. Released ground effects keep animating after player recovery. No new character sheets, god skills, blanket invulnerability or future stage grants are claimed.

The ten-slot collection/HUD, two-row Character skill cards, center/rim aiming preview and riposte cue were rendered at the logical 960x540 resolution. Lab collection access moved above the wider action tray. Automated coverage includes real contacts, fixed cast snapshots, cancellation/buffering, return of movement, wall stopping, riposte, save migration, zero-key activation, old skill/equipment behavior and UI boundaries. Actual campaign difficulty and final sound/animation preference need player testing.

## Follow-up

Build earned domain spells and their encounter/reward gates after the core feel review. Preserve Stage X female Forest Goddess and Stage XX god-and-Disciple Examiner direction from Decision 146; their signature passives and inheritance rewards remain proposals. Ascendant/Unbound remain isolated Lab previews until production milestones exist. No final Stage 100 damage curve or passive slot count is established here.
