# Decision 164: Give Eira a reachable training curriculum

**Closeout amendment:** Decision165 promotes current town/placement to normal play and archives old comparison. This document remains decision history; docs/design/sanctuary-closeout.md owns current runtime status.

- Date: 2026-10-02
- Status: Implemented; owner usability/balance review pending.
- Source: Owner requested useful Eira functionality, improved skill arrangement and authorized mechanic refactoring.

## Context

Eira's service required multiple menus, Skills 1/2 higher forms were confined to Lab, and Worldsplitter Mature required Level 15 while the released campaign caps at 10. Her study placement was too far below the book rather than directly beside it.

## Alternatives

Keep information-only services; add spendable training points/material costs; raise the campaign cap without content; or use existing experience levels to gate free, manual training of existing forms.

## Decision

Choose free manual level-gated training, keeping expedition XP as progression authority. Earthsplitter Fan trains at 2; Molten Advanced/Awakened/Mature at 3/6/9; Pursuit at 5/8; Vow at 7/10; Worldsplitter at 8/10. All base skills remain known. Existing accepted combat art, commitment, cooldown and form tuning stay intact. Cascade remains a Lab alternative rather than a linear upgrade.

A shared data catalog drives UI copy and authoritative level/rank validation. Eira opens Training directly after dialogue; a separate Loadout tab arranges ten combat positions. Ordinary inventory permits arrangement and requirement inspection without remote training. Save new ranks compatibly and preserve customized slots; failed saves roll back the attempted rank.

Place Eira at (384,410), immediately to the right of the lectern at (344,410), with a clear approach (384,446). Placement remains optional-study presentation. Shared training is normal campaign behavior. The launcher offers a no-save temporary Level-10 demo.

## Consequences

Every current technique has a visible, reachable progression path without adding grind or claiming unreleased content. Decision 164 supersedes earlier Lab-only Skills 1/2 production plans and Worldsplitter 10/15 gates. Existing trained ranks and version-1 saves remain readable. Balance, owner usability, phone testing and study-art promotion are still separate milestones. Further houses/interiors remain deferred.

See ../design/sanctuary-npc-usability.md for runtime ownership, effects, controls and evidence.