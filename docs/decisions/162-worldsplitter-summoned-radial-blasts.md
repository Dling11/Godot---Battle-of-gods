# 162 — Fresh summoned swords and radial ground detonation

Date: 2026-09-27. Status: implemented, pending owner visual/feel acceptance.

The owner rejected Decision 161's bouncing/extracting blade and narrow ground splash. “Repeated” means another sword spawns for each strike. The sword should drive deep into the ground, shatter into a visible AOE and have a summoning/energy effect.

Foundation summons one blue-white blade; Advanced adds a newly summoned crimson blade; Mature summons three fresh crimson blades at the same target. Contacts are .28s apart. Each blade moves only down, is buried before damage and is destroyed into an outward radial light blast. Two newly generated atlases supply a torn summoning seam/energy filaments and a circular floor detonation. Existing outlined sword art remains the reference.

Preserve .32s King commitment, 520/600/700% total damage, 88/96/104px final radii, final-only stun, Eira Level 10/15 training, saves and existing control rules. Authority stays in the released sequence; individual blade groups only present the events.

This supersedes Decision 161's single sword, extraction frames and final held dissolve. Its old art remains historical pending the owner's later cleanup task. Detailed current design: `docs/design/worldsplitter-fractured-light.md`.

Owner follow-up: The momentum pass raises blade arrival from 86px to 144px above the target. Follow-up formation starts .34s before contact (previously .26s), with about .095s to assemble before accelerating into the ground. Impact cadence, damage, burial and player recovery are unchanged. This is presentation timing only; no authority or progression changes.
