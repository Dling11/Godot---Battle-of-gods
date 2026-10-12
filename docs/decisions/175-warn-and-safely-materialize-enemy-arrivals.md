# Decision175: Warn and safely materialize enemy arrivals

Date: 2026-10-03.
Status: Implemented; owner mix/feel, broader profiling and balance remain open.

## Context

Owner accepts the randomized homepage, confirms loading is already done, and authorizes next work from the earlier mob-spawn/sound/contact/stutter program. Decisions171/173 remain the existing campaign/skill/presentation baseline.

## Decision

Use a short planted code-native ground warning before actual actor creation in the world. EncounterController owns timing, cap reservation, navigation/body checks, retries, death/pause/teardown and actor installation. SummonEffect owns only Timer-stepped pixel light/dust. Reuse one restrained positional audio player per encounter, throttled across batches. Preserve native Rootling/Mireling scale instead of their old flattening spawn tween. Existing safe spawn states, counts, damage, grants and routes remain intact.

## Alternatives

Keeping the legacy tall lightning does not warn before an attackable actor exists. Independently generated near-matching frames risk reintroducing geometry wobble. A global spawn manager, generic pooling framework or combat rewrite is unnecessary for this bounded presentation slice.

## Consequences

The0.3s warning adds intentional arrival pacing, including after existing reinforcement delays. Warnings count as live slots. Unsafe locations may defer an enemy; they never drop it or silently relocate a warned arrival. Initial navigation must exist before wave consumption. First/repeated1/5/8-target profiles retain zero global Skill 1 pauses but include one first-cast physics spike; broader measurements remain open. Review is playable and rewardless with isolated storage. Loading re-art is optional and deferred; the existing implementation remains complete.

See [implementation, evidence and next work](../design/enemy-arrival-and-horde-profiling.md).
