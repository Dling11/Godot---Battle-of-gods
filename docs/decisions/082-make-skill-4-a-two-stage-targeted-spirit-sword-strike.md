# Decision 082: Make Skill 4 a Two-Stage Targeted Spirit-Sword Strike

- **Date:** 2026-08-12
- **Status:** Accepted

## Context

King's first three skills cover a directional double hit, immediate self-area control, and a targeted leap. The fourth slot needed a long-cooldown payoff capable of materially damaging later bosses without repeating those movement patterns. The owner rejected a defensive counter, transformation state, ordinary physical falling sword, and generic one-beat explosion. The approved image is a giant spiritual sword-shaped manifestation that crashes, remains embedded, visibly fights the ground, drives deeper, and only then releases the real AOE.

Generated animation consistency is a production risk. The sword therefore needs one exact-grid sequence normalized to a shared point baseline; Godot retains physical travel so the generated poses describe energy state rather than spatial movement.

## Alternatives Considered

- A defensive counter/reprisal.
- A temporary shadow transformation that replaces the skill kit.
- A forward cinematic cross-lane slash with screen overlays.
- One physical metal sword that lands and explodes immediately.
- One baseline-normalized spiritual-sword sequence coordinated with separate ground-effect frames and two authoritative damage windows.

## Decision

Skill 4 is a confirmed ground-targeted cast up to 260 pixels. After a 0.48-second vulnerable wind-up, the first 58-pixel contact deals 220% weapon damage and stagger without displacement. The sword remains embedded for 0.4 seconds; presentation gives it a small rebound, resistance wobble, and automatic second downward drive. The second authoritative contact expands to 104 pixels, deals 300% weapon damage, and owns the heavy outward knockback. Recovery is 0.35 seconds and cooldown is 20 seconds. A target inside both circles can receive both hits.

One generated 4x2 binary-alpha sword atlas owns eight chronological energy poses: three formation frames, four embedded resistance/drive frames, and one dissolve frame. Deterministic normalization produces `144x192` cells and fixes every point at local y=188. Godot still renders the physical fall, rebound/wobble offsets, accelerated deeper drive, and dissolve timing, then clips the lower 20 pixels against the fixed ground plane so the point is visibly swallowed instead of sliding over the floor. The embedded point sits two visual pixels inside the impact core, hiding the hard cutoff beneath the authored ground energy. Following owner rejection of a mismatched 6-frame base plus 4-frame overlay, a separate generated 4x2 binary-alpha atlas owns eight coherent chronological ground poses: contact, spreading cracks, split plates, resistance ring, compressed energy, downward drive, final explosion, and settled crater. The last crater pose is lowered nine pixels to keep it centered on the shared impact. Every authored sword and ground frame has a runtime phase and regression coverage; no partial-sheet selection or concurrent atlas is allowed. Every child layer uses one world-space target anchor; the crater outlives recovery and fades independently. Separate formation, first-impact, and explosion audio cues observe the same events.

`GroundPointTargeting` accepts any `AbilityComponent` that explicitly implements the shared ground-targeting range/radius/cast-at-point contract. Confirmation remains free to cancel and is the point at which cooldown and damage snapshot authority begin.

## Consequences

- Skill 4 has a readable two-beat promise and a boss-scale 520% center payoff without transformation or hidden state.
- The first contact cannot accidentally knock normal enemies out of the delayed explosion.
- The larger blast still respects encounter-owned damage, hurtboxes, control resistance, and ordinary cooldown rules.
- Shared-baseline sword normalization prevents generated point wobble while preserving authored formation, resistance, drive, and dissolve energy changes.
- Future ground-targeted skills can reuse the same preview/confirmation authority without being typed as Sovereign Pursuit.
- Dedicated King casting body art, camera/hitstop tuning, and final balance remain optional owner-review follow-ups rather than part of the authority contract.
