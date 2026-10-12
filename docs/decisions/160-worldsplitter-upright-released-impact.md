# 160 — Keep Worldsplitter upright and release it independently of King

Date: 2026-09-27. Status: implemented, owner feel/balance review pending.

The owner rejected the X-shaped four-fault presentation and the subsequent diagonal, undersized concept. Retain the original straight-down sword concept, redraw it larger with a readable shattered-ground field, and allow a longer effect while King escapes the short casting action. Skill4 stays as accepted.

Use dedicated sword/ground atlases, one upright world-fixed descent and two bounded authoritative contacts. The sword releases at .18s, King returns at .32s, initial contact occurs near .60s and eruption near .84s. Visual settling lasts longer without holding input. Ordinary movement/dodge after release preserves the sequence; defeat/reset cancels it.

Support Foundation/Advanced/Mature with increasing blade scale, radius and damage while retaining commitment/cooldown. Eira Level 10/15 training gates are provisional progression tuning, not new cap unlocks; all ranks are previewable in the Lab. Optional saved rank defaults safely for older profiles. Stable ability ID `king_skill_4` remains in slot5 by default to preserve prior ownership/migration.

Alternatives rejected: rotate/angle the whole sword; keep four crossed fracture lanes; stretch King's body animation for the full effect; enlarge particles without changing authored hit radii; grant damage for every debris frame. The detailed implementation and validation are in `docs/design/worldsplitter-upright-descent.md`.
