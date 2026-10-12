# 144 — King Unwritten Oath and skill collection

Date: 2026-09-13. Status: implemented; future campaign milestones pending.

## Context

The owner requested new dramatic AOE techniques, moving animation frames, sound and progression toward endgame, while preserving King's C identity, mobility, equipment laws and four-button control budget. The earlier brainstorm was advisory; the latest request authorizes implementation and permits a new mobile alternative to the jump.

## Decision

Add four families and four finite forms to an eight-technique collection. Preserve the original four as the default loadout. Equip four unique stable IDs in Sanctuary; changing an already equipped technique swaps slots. Store IDs in an optional backwards-compatible RunSession snapshot field, not ranks or mutable resource objects. Components retain cooldowns while unequipped.

Crosscut Advance and Starfall Step are learned initially, Griefwake after II, Oathstorm after V. Stage V also grants Resonant forms. Ascendant/Unbound have named future story hooks and debug Lab previews; do not silently mark Stage XX or later campaign rewards complete. Preview selection is session-local and restores the prior campaign loadout on exit.

KingOathDefinition configures family/rank resources; KingOathComponent owns timed contacts and travel intent. Player owns actual movement, input buffering, interruption and collisions. Existing Health/Hurtbox authority owns mitigation and boss control response. Rank replacement waits until casts finish. Resolve and level mastery apply once per cast; the landing link accepts both mobile techniques and both ruptures.

Presentation observes signals with approved compact body art, separate 16-frame effects, distinct icons and original SFX. It never spawns damage or changes positions. Detached HUD slots disconnect their observers so immediate equip-and-cast cannot target removed timers.

## Alternatives

Replacing all old skills would remove useful choices; adding more active buttons would undermine the accepted inputs. Infinite level/radius growth would defeat stage caps. Automatically granting endgame forms in the campaign would invent unfinished milestones. A second saved mana/mastery economy is unnecessary for this collection.

## Consequences

The collection can grow without adding active buttons. Current ordinary mastery/caps remain bounded. Four-direction pose commits and growing contact patterns produce distinct forms while retaining identity. Later route rewards and full gear/boss balance remain open. See [runtime design](../design/king-unwritten-oath.md) for exact controls, form names and boundaries.
