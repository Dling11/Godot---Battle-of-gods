# 234 — Hooded Veyr and responsive training court

Date: 2026-10-18. Status: installed for owner review. Refines the provisionally accepted 233 layout; supersedes the old veteran/pavilion/post artwork only. Decisions 232/233 still own learning rules and placement.

The owner likes the relocated services and practice-dummy idea, but requests Veyr's missing shadow, a younger hooded character with visible weapons, a better equipped base and improved dummies. Keep the corrected NPC world scale.

- Replace the veteran sheet with eight complete young hooded actors: dark teal hood, charcoal short cloak, brown gloves/boots and visible sword/axe gear. All frames remain 57 source pixels tall, boot baseline 78 inside 96px cels; runtime 0.5 scale and y=-15 yield 28.5 world pixels. No head/body pieces are reused.
- Add the same 18x6 foot-shadow polygon, colour, y=-2 and depth used by Orren. Shadow, body collision and interaction area remain stationary during idle.
- Replace the pavilion with the same-size slate/timber lodge, teal banners, greatsword, crossed swords, axe, scythe, sharpening wheel and gear chest. Its 232x152 canvas, base registration, shallow collision and canopy reveal stay compatible with 233's placement.
- Replace the post image in place with a four-cel 256x64 sheet: rest, two yielding poses and settle. One common reduction ratio preserves complete props. Sole row 54, scale 0.65 and y=-14.3 keep the cross base grounded. Correct the old generic target shadow's misplaced y=12 offset.
- `entities/training/presentation/weapon_training_post.gd` observes accepted HealthComponent damage. It plays a bounded 0.24s recoil/settle, slight material flash and four reused straw flecks. Repeated hits replace the active tween. It cannot move collision, grant proof, award loot or change damage. Nothing updates continuously while idle.

The northwest yard, northeast gate, paths/walls, service coordinates, trial conditions, saves, forging costs, player weapons and settled Cyclone art/audio are unchanged.

Validation: mentor 181/0, Sanctuary 67/0, Eira 73/0, import and runtime/archive boundary pass. Added checks cover mentor shadow, all eight mentor world heights/soles, four grounded post cels, real-damage reaction/settle and unchanged target collision/proof authority. CPU scene previews include actual shadow polygons; native art/feel approval remains pending. Keep Godot windows closed under the current Monster Hunter preference.

Replace only the three requested PNGs; preserve the other 689 guarded assets. Keep the same 692 runtime asset paths and compact current prompts/provenance at `art_source/reference/environment/weapon-court.json`. No permanent art archive. `CONTINUE_SANCTUARY.md` is the current cross-chat handoff.
