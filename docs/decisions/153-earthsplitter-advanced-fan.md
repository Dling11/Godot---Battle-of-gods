# 153 - Earthsplitter Advanced Fan

Date: 2026-09-26. Status: implemented in Lab; owner accepted as Skill 1 direction. Owner-approved center follow-up is implemented; campaign promotion remains pending.

## Context

The owner clarified that three waves meant three spatial lanes spreading from one sword impact, not three successive waves. They requested preserving the previous Cascade as a possible later/third upgrade and authorized resuming the documented fan work.

## Decision

FORM now cycles Foundation, Fan, Cascade. The existing --earthsplitter-advanced-review flag opens Fan. All use one .36s cast and the approved sword/eruption art. Foundation and Cascade retain their existing damage/timing/reach. These forms share Skill 1; no additional equipped slot or campaign save is created.

Fan starts its first three fronts at the same sword contact, 34px forward unless terrain shortens it. Each travels 162px from that contact at center and +/-20 degrees, with radius 19px and .25s travel. Thus center reach is 196px. Every branch performs its own terrain sweep and preview; a wall blocking one branch does not cancel clear branches. The center direction still owns the body/sword action.

The initial fan deals 100% weapon damage once per target across all lanes, with .045s flinch and 12 knockback. The owner-approved follow-up releases .22s after the fan from the same committed origin/direction, travels in .23s to 228px reach with 21px radius, and deals 140% weapon damage once per target, with .10s flinch and 55 knockback. Maximum combined budget is 240%; all have no stun, unchanged five-second cooldown and no new invulnerability. A cast-owned target ledger prevents overlap from multiplying damage. Existing mastery/equipment/eligible committed modifiers apply through the normal ability authority. Values are Lab tuning, not a finalized campaign upgrade ladder.

Presentation reuses the approved assets, chooses pressure orientation per lane, leaves rock/dust upright, and shares one contact, one accented follow-up release and one final terminal sound/camera beat. Player control returns before released fronts finish. Death and review exit remove released authority/presentation.

## Alternatives and consequences

Three parallel rows or delayed same-direction waves would not satisfy the clarified spread. A filled triangular damage cone was not chosen because the owner requested three visible lines; the preview therefore shows actual lane capsules with gaps. Independent full-damage hits in overlapping lanes would create unintended close-range triple damage, so Fan shares a ledger. Cascade retains independent per-wave hit accounting and its original distributed budget.

The combined Fan is now implemented within its existing Lab form. The later rank of the separate Cascade, radial endpoint damage, stage unlock/save integration and mobile optimization remain undecided or pending. Desktop checks and recorded playback do not establish phone FPS.

Validation and footage: `tests/earthsplitter_fan_smoke.gd`, existing Foundation/Cascade regressions, and `art_source/review/characters/king/earthsplitter_fan_2026_09_26/`.
