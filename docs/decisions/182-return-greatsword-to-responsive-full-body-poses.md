# 182 — Use responsive complete body poses for Greatsword

- Status: Rejected by owner for startup appearance drift; superseded by Decision183
- Date: 2026-10-05
- Supersedes: Decision181's installed modular-arm presentation

The owner rejects the modular-arm result's whole motion, grip/rotation and slow pacing, citing the accepted axe. Geometry/identity assertions did not establish good animation. The experiment moved detached arms and steel across only four repeated torso poses per view.

Use complete installed raster body/hand cels, with event-selected drawn queued/released recovery branches and actual rendered opening inheritance. Shorten the chain4.26→3.00s, especially the slam's0.64→0.32s preparation, while retaining sword size and damage/contact rules. Keep existing source density/style, carry/run/rest and axe behavior. No replacement image generation is required.

The faster combo raises damage throughput; comparative balance remains provisional. Discrete authored cel playback trades continuous independent bone movement for coherent silhouettes at each key. Complete endpoints and real input/native axe comparison supplement authority tests; final owner feel remains open.

Current implementation and evidence: Responsive Greatsword.
