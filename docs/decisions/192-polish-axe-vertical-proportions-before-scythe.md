# Decision192 — Polish axe UP/DOWN before Iron Reaper

2026-10-07. Owner requests another axe vertical polish/refactor before the scythe. Use the owner-approved Twinsteel/Greatsword proportion baseline from Decision191 while preserving accepted axe side art and the faster five-cut rules.

Status: installed size correction, **rejected by the owner as a sufficient motion redesign on2026-10-07**. The old attacks/spin/impact remained wrong; [Decision193](193-rebuild-axe-vertical-choreography-with-fresh-art.md) replaces those vertical attacks with newly generated motion/effects. Corrected carry/gait remain dependencies. Historical verification: native anatomy/motion2582/0, actual gameplay138/0 and58 reproducible outputs; the fixture retained57-object exit debt. These passes did not establish owner visual approval.

The native body audit found vertical ready heights of 47/49 pixels versus 54–57 for accepted King weapon references. Older vertical heads and carry/gait registration caused shrinkage between facing and attack states. Extend the shared offline registration with an optional attack-lane Y density, defaulting to the previous behavior for other families. Axe attacks reuse their facing's registered ready density; complete body/hand rasters, real palms and orientation guides move together. Keep the shaft basis unchanged for one-hand axe poses, so the cutting head still leads the third thrust. Retain actual sleeves/forearms through head isolation. No per-cel fitting or runtime scaling.

The flow builder writes sibling UP/DOWN idle/run outputs and normalizes original vertical cuts before copying released/queued endpoints. Legacy cardinal outputs remain read-only builder sources. Side bodies, canonical axe, full white FX, 3.19-second phases, damage, reach, voluntary walking, collision steps, audio, equipment/save IDs and the approved dual/Greatsword assets remain unchanged. The scythe is deferred until the owner reviews this axe pass.

Alternatives rejected: shrinking the whole actor would alter steel/FX/gameplay readability; independently fitting each pose would pump body size; rewriting side motion would discard accepted work. Existing full-body raster sources are sufficient for this correction, so it introduces no new generated character concept or runtime rig.

[Current guide and proof](../design/king-axe-cardinal-motion.md).
