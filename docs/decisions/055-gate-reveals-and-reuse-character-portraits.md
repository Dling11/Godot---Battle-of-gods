# 055 - Gate Authored Reveals and Reuse Character Portraits

- **Status:** Accepted
- **Date:** 2026-07-23

## Context

The Rootbound Husk needs to react after Opaw defeats its Rootling brood, but the mini-boss must not spawn, attack, or begin its music behind paused dialogue. The project also lacked close-up character art that could be shared by dialogue, expedition descriptions, and a future bestiary.

## Alternatives

1. Spawn the Husk before dialogue and rely only on scene-tree pause.
2. Put Stage 3-specific spawn logic in `Stage3Flow`.
3. Add a reusable optional inter-wave gate to `EncounterController`, and make portraits optional presentation data in `DialoguePanel`.

## Decision

Use the third option. Authored stages may list gated next-wave numbers. After ordinary recovery, `EncounterController` emits a gate request and awaits explicit release while retaining all spawn authority. Stage-owned flow may present dialogue and release the gate on completion or skip.

Recurring named characters and enemy archetypes should receive a reusable square portrait when dialogue, descriptions, previews, or bestiary reuse is plausible. The current runtime contract is a transparent 96x96 PNG preserving the approved gameplay model, palette family, and upper-left lighting. Portraits remain optional presentation metadata and are never parsed for gameplay rules.

## Consequences

- Rootbound Husk cannot become hostile or start its wave-owned music during its introduction.
- Skipping and completing dialogue use the same encounter release seam.
- NPC dialogue remains compatible without a portrait.
- Rootling, Rootbound Husk, Mireling, Forsaken Thrall, and Bramble Spitter now have one reusable portrait family.
- Portrait readability and Stage 3 brood length still require human playtesting at 960x540.
