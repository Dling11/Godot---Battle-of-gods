# Iron Beard canonical axe — 2026-10-15

Current follow-up: Decision213 / ../iron_beard_motion_2026_10_15 supplies corrected full-size attacks and normal jump/spin. This folder remains the exact canonical weapon and idle source; its short-proportion attack boards/head-reversal recipe are superseded. Owner permits visible Godot again.

Built-in ImageGen produced the corrected single-bit axe and complete body-only guide sources. Exact prompts are adjacent; side/up/down-reference.png are the approved running appearance guides. Source art is excluded from Godot through .gdignore. Rejected drafts stay only under ignored tmp/review/axe_canonical_2026_10_15/.

The owner rejected Decision211's separately redrawn attack weapons: head/shaft geometry drifted into a fan, frontal scale changed and carry was ambiguous. Decision212 replaces those independent weapon drawings with ONE canonical raster. Current104 attack/turn cels use that exact raster at unit scale; current run/idle use the same texture. Native weapon is80x96 padded, about64px high with a compact23px head and narrow straight vertical shaft. Actor density NEVER scales the weapon.

Current running BODY images stay byte-identical to accepted Iron Reaper. Axe is explicitly STOWED across the back in running/idle; UP draws it over the back, SIDE/DOWN behind the body. Attachments follow the existing crown/collar rather than moving boots or synthetic palms. Fresh complete idle bodies have relaxed hands at hips and slow glances.

Body source guides are not runtime artwork. registration-recipe.json records complete connected source components, their own marker endpoints, glove locations/occlusion, boot support and one calibrated density per board/lane. Adaptive connected extraction prevents neighboring row boots/markers entering a cel; cyan/green endpoints can be associated along the same rod across nominal grid gutters. Only guide paint/outlines are removed. Complete anatomy is never transplanted or resized in pieces. Canonical steel is composed with one unit matrix; local fingers overlay only their OWN complete source cel at identical coordinates. UP chop/slam reverse head socket and grip order along the same source shaft for camera direction. Each cut keeps a stable cutting-edge handedness. The low UP chop uses a lower attachment grip on the same shaft so the head clears the crown; registration.json records the exact attachment grip.

Bake tools/build_king_axe_unified.gd → tools/king_axe_technique_baker.gd, then headless editor import. The first tool retains existing FX and licensed audio. Normal equipment, F9/F7 and Bag automatically select the current21 pose resources and new canonical icon. Further axe cosmetics can rebake from these body/shaft sources; no new anatomy generation is necessary solely to change a weapon image. Gameplay/save IDs,3.19s timing, damage, reach, knockback, controller and existing white effects/audio stay unchanged.

| Asset | Selected source | Exact prompt |
|---|---|---|
| One canonical axe | [source](axe-source.png) | [prompt](axe-prompt.txt) |
| Side attacks | [source](side-source.png) | [prompt](side-prompt.txt) |
| Back attacks | [source](up-source.png) | [prompt](up-prompt.txt) |
| Front attacks | [source](down-source.png) | [prompt](down-prompt.txt) |
| Full turn | [source](turn-source.png) | [prompt](turn-prompt.txt) |
| Relaxed idle | [source](idle-source.png) | [prompt](idle-prompt.txt) |

Technical verification and native owner visual approval remain separate. All current work stays headless while the owner plays Monster Hunter World; previews are offline published-frame playback without VFX/audio. See verification.json for final checks.
