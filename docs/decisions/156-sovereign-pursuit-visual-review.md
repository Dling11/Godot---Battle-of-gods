# 156 - Sovereign Pursuit blade-cut presentation review

Date: 2026-09-26. Status: historical Lab comparison; Decision 157 promoted its blade-cut art to normal play. Owner feel review remains pending.

## Context

The owner prefers Sovereign Pursuit's targeted aggressive mobility over Breakstep. Skill 1 and Skill 2 now have stronger animated identities, while the existing Skill 3 uses three travel drawings, three impact drawings and a thin drawn ring. The jump remains useful, so this pass changes presentation only.

## Decision

Keep Pursuit's 220px target range, collision-safe .28s traversal, travel-only invulnerability, 52px/125% landing hit, .14s windup, .24s recovery, 8.5s cooldown and existing rupture link. Add a reversible F7 -> KING REVIEW -> SKILL 3 comparison. It swaps in eight blue-white travel drawings and a ground atlas with fifteen visible drawings plus an empty cleanup cell: takeoff scuff, blade-first contact, open blue-white pressure arcs and a brief fixed afterglow. The first rock-heavy landing candidate was rejected in favor of this cleaner cut. A maximum of four faint, short-lived travel-sheath snapshots clarifies direction. The landing requests one restrained camera pulse; the existing separate launch and landing sounds remain. The longer impact animation continues after control returns, then fades. Review-only ground art renders behind King. The toggle waits for aiming, casting and lingering impact to finish and restores original SpriteFrames and layering on exit.

## Alternatives and consequences

Replacing Pursuit with an evasive step loses the mobility the owner explicitly favored. Enlarging the landing radius or adding extra hit pulses would duplicate Molten Crash and change balance before the art is reviewed. Stretching King's recovery to fit the new frames would make the skill sluggish. The present review retains gameplay authority in the component and keeps the expanded effect visual-only. It is not a campaign replacement, an approved upgrade ladder, or a mobile performance claim.

## Evidence

The original Pursuit smoke and the new review smoke pass. The latter exercises switching, early control return with a continuing world-fixed impact, restoration and cleanup. Runtime atlases use binary alpha; fifteen landing cells and all eight travel cells carry drawings, while the final landing cell is intentionally transparent for cleanup. Godot Compatibility at 60 FPS supplied the corrected in-game comparison with audio under `art_source/review/characters/king/sovereign_pursuit_2026_09_26/`. The capture waits for the original crater to finish and asserts that the art toggle succeeded, avoiding a previous comparison that showed original art twice. The owner's proposed range/charge ladder is documented separately and has no implementation in this decision.
