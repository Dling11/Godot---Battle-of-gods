# Decision196 — Steady Twinsteel carry with frozen upper anatomy

2026-10-12. Status: installed for owner motion review. Owner rejects the grip-only walking pass as insufficient and explicitly authorizes remodeling running/idle and correcting cut, missing or wobbling frames. Supersedes Decision195's exact shared full-gait selection for Twinsteel only; its frozen-reference/identity protections remain. Iron Reaper stays deferred. No commits or pushes.

Reviewing native idle → walk → idle beside accepted Greatsword exposes a pose mismatch, not just bad grip detection: Twinsteel replaces the entire upper carry pose at movement start, and vertical swords drop much farther during travel. A correct palm coordinate over a changing chest/head cannot by itself solve that visual transition.

Bake a distinct eight-cel complete carry gait per view. Copy the approved whole upper carry pixels through the waist, including head/neck/arms/fists, into every complete cel. Use canonical side legs and fresh generated front/back stepping legs at one fixed density per view and native palette. Mirror the vertical lower half-cycle to alternate feet. Keep complete connected body atlases, original density, origin and soles; never operate a detached head, runtime limb rig or per-frame body scaling. The immutable body library remains byte-for-byte unchanged.

Match the ready and walking blade angles/depth at genuine palms. Retain hidden side rear handle and source closed-fist masks. Only normal carry entry/release/final endpoints of the existing attacks inherit the new ready blade pose. Protected contact/load/queue cels, proud planting/folded/glance poses and timings, weapon textures/effects, attack clock, damage/reach/audio, controls and save IDs remain. The stock profile selects `shared_bodies/dual_carry_v3`; the previous gait remains rollback provenance.

Rejected: another grip-only correction, resizing a newly generated torso to pass a height check, stamping a separate head onto unreviewed anatomy, freezing the entire character/feet, and altering accepted attacks or other weapons. The new full-body variant is checked independently: exact upper identity, connected waist/feet, distinct alternating steps, source preservation, margins/soles, unchanged rest/contact art, normal equipment, actual travel/walls and transition continuity. Automated checks do not establish owner approval of motion quality.

[Source and brief](../../art_source/generated/characters/king/dual_carry_gait_2026_10_12/README.md) · moving comparison, verification and play.
