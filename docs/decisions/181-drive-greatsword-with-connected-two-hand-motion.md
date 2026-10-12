# 181 — Drive the Greatsword with connected two-hand motion

- Status: Owner-rejected motion; superseded by Decision182
- Date: 2026-10-05

## Context

After native review, the owner rejects the whole motion, grip and rotation, and its slow pacing compared to the accepted axe. Geometric checks did not establish animation quality. The following records the rejected experiment, not the current runtime. Current replacement: [Decision182](182-return-greatsword-to-responsive-full-body-poses.md).

The owner reports sloppy five-hit flow, inconsistent grips and awkward descending/rising cuts. They authorize replacing all five animations while retaining blade size. They also identify generated-art style drift and ask to follow the existing documentation/runtime baseline.

## Decision

Use opt-in continuous unwrapped angle/grip tracks with exposure-aware monotone interpolation, real secondary-hilt registration and modular two-bone arm presentation. Recovery travels into the next chamber; unqueued chains brake into existing carry. Retain MeleeAttackComponent/MeleeStepMotion authority and current combat tuning. Legacy weapon families retain their presentation path.

Use installed Spellward sprites as edit references. Reject the armor-heavy generation; protect original head/boot pixels and preserve the compact cloth/leather baseline through a bounded torso/arm patch. Canonical steel and existing carry/run/rest resources remain unchanged.

## Alternatives and consequences

Repeated frame patches/held endpoints did not correct the motion inside each cut. Replacing all complete character/weapon drawings risks identity drift and changing the blade. A full skeletal character migration would broaden scope unnecessarily. The chosen rig adds arm registration/IK and requires native geometry, identity, directional and contact checks. It is cosmetic, data-driven and reusable, but different weapon shapes still require their own authored registration and visual review.

Current implementation and validation: Greatsword motion polish.
