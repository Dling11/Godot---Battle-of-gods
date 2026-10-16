extends "res://tests/king_production_art_contract.gd"

const PROFILE = preload("res://data/weapons/families/twinsteel/presentation.tres")

func verify_lanes(lanes: Array) -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	verify_production_baseline(["assets/characters/playable/king/twinsteel_unified/", "data/weapons/families/twinsteel/"])
	check(PROFILE.is_valid_profile(), "Current Twinsteel family is not installed")
	check(PROFILE.attack_poses.weapon_texture.get_size() == Vector2(16,68), "Paired steel changed size")
	var combo: Resource = load("res://data/weapons/families/twinsteel/combo.tres")
	var total := 0.0
	for step in 5: total += combo.windups[step]+combo.contacts[step]+combo.recoveries[step]
	check(is_equal_approx(total,2.2), "Twinsteel combo rhythm changed")
	check(combo.hitbox_shapes[0].points[3].x == 88 and combo.hitbox_shapes[3].radius == 72 and combo.hitbox_shapes[4].points[3].x == 100, "Painted AoE differs from actual contacts")
	for direction in [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		var attack: Resource = PROFILE.attack_for(direction)
		var clips: Array = []
		if "run" in lanes: clips.append(PROFILE.run_for(direction))
		if "idle" in lanes: clips.append(PROFILE.idle_for(direction))
		if "attacks" in lanes: clips.append_array([attack]+Array(attack.follow_up_clips))
		for clip: Resource in clips:
			verify_complete_clip(clip,Vector2i(256,256))
			check(clip.weapon_texture == PROFILE.attack_poses.weapon_texture and clip.offhand.texture == clip.weapon_texture, "Directions replace a paired blade")
			check(clip.weapon_primary_grip == Vector2(8,56) and clip.offhand.grip == Vector2(8,56), "Paired grip changed")
			for key in clip.pose_count:
				check(clip.offhand.visible_poses[key] == 0, "Baked pair receives duplicate offhand")
		if "run" in lanes: check(PROFILE.run_for(direction).pose_count == 8, "Running lost stride frames")
	if "attacks" in lanes: verify_white_strokes(PROFILE.swing_atlas.get_image(),12,5)
