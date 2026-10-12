# Decision 046: Buffer Basic Attack Through Dash Recovery

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

The supernatural dash has 0.15 seconds of invulnerable movement followed by 0.25 seconds of vulnerable recovery. Requiring that entire recovery to finish before a normal attack makes dash-to-attack input feel lost or delayed. Opaw should be able to deliberately chain the two actions without creating an invulnerable sword hit, shortening the authored dash, or adding a second untested damage path.

This decision supersedes only Decision 010's initial prototype rule that attack and evade never cancel one another. The dash presentation, distance, and movement-phase invulnerability remain unchanged.

## Alternatives Considered

- Keep full mutual exclusion and require the player to wait through recovery.
- Start the sword attack immediately during invulnerable dash movement.
- Remove dash recovery for every follow-up action.
- Create a separate dash-attack hitbox, damage value, animation, and weapon formula immediately.
- Buffer one normal attack during movement and allow that attack to cancel only vulnerable recovery.

## Decision

Left mouse/right trigger remains the basic attack input; right mouse stays unassigned until a later reviewed action needs it.

When basic attack is pressed during `EvadeComponent.DASHING`, `Player` stores one non-stacking request and its movement-owned facing. The active dash completes its full distance and invulnerability. On the transition to `RECOVERY`, `Player` calls the recovery-specific `EvadeComponent.cancel_recovery()` boundary and begins the ordinary equipped-weapon attack. If basic attack is first pressed after recovery has already begun, the same recovery-only cancel happens immediately.

The chain uses the existing `MeleeAttackComponent`, `WeaponDefinition`, hitbox, damage, knockback, three-swing sequence, VFX, and SFX. It grants no damage multiplier or additional invulnerability. Skills remain mutually exclusive with dash until their own authored cancel rules exist.

## Consequences

- Dash-to-attack input feels responsive even when pressed slightly early.
- The sword never becomes active during dash invulnerability, and the dash never loses distance.
- Choosing to attack replaces passive vulnerable recovery with the sword's vulnerable wind-up and full attack commitment rather than granting a free safe cancel.
- Only one attack can be buffered, preventing repeated input from creating duplicate attacks.
- A visually or mechanically unique dash attack may still be authored later, but it must replace this presentation through the existing combat authority rather than layering duplicate damage on top.
- Dash recovery and the new chain still require human feel testing against current enemy telegraphs.
