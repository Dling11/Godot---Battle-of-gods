# Iron Beard current contract

Updated 2026-10-13. Normal Iron Beard selects shared_bodies/axe/{side,up,down} poses with canonical steel and its current camera-specific effects. Historical axe experiment folders/builders are removed; active texture dependencies keep their existing paths even when a folder name contains an old version.

Five cuts: downward chop → rising cut → **axe-head push** → jump slam → spin. Head push leads with the actual pale cutting edge at(8,30), with the butt trailing; it is not a handle jab. Nominal combo budget is3.19s, retaining current damage/reach/knockback and movement commitment. UP/DOWN use authored complete body/effect frames; side art remains the accepted baseline.

Standing/gait use frozen complete King references. DOWN neutral ready/rest uses the complete relaxed pose; existing registered DOWN attacks move whole body/masks/grips together. Source palette/density, sole/lift, real palm and current queue/release endpoints remain. Approved frame content and combat are byte-preserved by cleanup.

Test F5 → F9 → F7 → Weapons → Iron Beard or tools/launch_king_axe_training.ps1. Native tests/king_axe_cardinal_smoke.gd exercises four-facing contacts, head-first push, visible slashes, connectivity and normal Player selection. Actual weapon role tests cover damage/knockback/recovery against current enemies. Geometry alone does not establish animation approval.

New axe art needs a separately reviewed complete-pose update against body_library/v1. Do not restore old art-generation inheritance chains or archive inputs. New evidence writes to ignored tmp/review/.
