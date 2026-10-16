extends "res://tests/king_production_art_contract.gd"

const PROFILE = preload("res://data/weapons/families/royal_greatsword/presentation.tres")
const OUTPUT := "res://assets/characters/playable/king/greatsword_unified/"
const READY_BLADE_KEYS := {"front":[0,10], "return":[10], "spin":[0], "slam":[10], "idle":[0,1,2,3], "run":[]}

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	verify_production_baseline(["assets/characters/playable/king/greatsword_unified/", "data/weapons/families/royal_greatsword/"])
	check(PROFILE.is_valid_profile(), "Invalid current Greatsword profile")
	check(PROFILE.attack_poses.weapon_texture.get_size() == Vector2(30,140), "Canonical huge steel changed size")
	for row in [["side",Vector2.RIGHT],["up",Vector2.UP],["down",Vector2.DOWN]]:
		var view: String = row[0]
		var direction: Vector2 = row[1]
		var attack: Resource = PROFILE.attack_for(direction)
		for clip: Resource in [attack]+Array(attack.follow_up_clips)+[PROFILE.run_for(direction),PROFILE.idle_for(direction)]:
			verify_complete_clip(clip,Vector2i(384,384),READY_BLADE_KEYS[clip.resource_path.get_file().get_basename()])
			check(clip.weapon_texture == PROFILE.attack_poses.weapon_texture, "A view replaces the huge blade")
		var run: Resource = PROFILE.run_for(direction)
		check(run.pose_count == 8, "Greatsword running lost stride frames")
		var current: Image = run.body_atlas.get_image()
		for key in 8:
			var own := current.get_region(Rect2i(Vector2i(key%4,key/4)*384,Vector2i(384,384)))
			check(run.primary_visible_poses[key] == 0 and run.single_hand_poses[key] == 0 and run.stowed_poses[key] == 0, "Run duplicates or releases its two-handed blade")
			check(run.primary_hands[key].distance_to(run.secondary_hands[key]) >= 5, "Two running grips collapse into one palm")
			if view != "up":
				for grip in [run.primary_hands[key],run.secondary_hands[key]]:
					var brown := false
					for y in range(-2,3):
						for x in range(-2,3):
							var color := own.get_pixelv(Vector2i(grip)+Vector2i(x,y))
							if color.a > .8 and color.r > .18 and color.r > color.g*1.3 and color.g > color.b*1.2: brown = true
					check(brown, "Running grip floats away from its brown glove")
	var audio: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_source/audio/greatsword_heavy_2026_10_15/manifest.json"))
	for clip: Dictionary in audio.clips:
		check(FileAccess.get_sha256("res://assets/audio/sfx/player/greatsword_heavy/"+str(clip.file)) == clip.sha256, "Heavy metal recording differs from audit")
		check(clip.duration <= .4 and clip.peak_dbfs < -3.9, "Metal cue clips or has an excessive tail")
	for row in [["slash.png",4],["landing.png",1],["vertical_slash.png",2],["vertical_landing.png",2]]:
		verify_white_strokes((load(OUTPUT+str(row[0])) as Texture2D).get_image(),8,int(row[1]))
	verify_white_strokes((load(OUTPUT+"spin_slash.png") as Texture2D).get_image(),16,3)
	for direction in [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		var idle: Resource = PROFILE.idle_for(direction)
		check(idle.planting == null and idle.pose_count == 16, "Shoulder rest still uses the rejected plant")
		check(idle.rest_transition_end_pose == 11 and idle.retrieval_start_pose == 11 and idle.rest_loop_window == Vector2(11,15), "Shoulder entry/retrieval includes rapid glance keys")
		check(idle.rest_loop_seconds/5.0 >= 1.5, "Shoulder rest glances too quickly")
		for key in range(4,16):
			check(idle.primary_visible_poses[key] == 0 and idle.released_poses[key] == 0 and idle.ground_clipped_poses[key] == 0, "Shoulder drops, duplicates or clips its sword")
	print("GREATSWORD_PRODUCTION_ASSETS checks=",checks," failures=",failures)
	quit(1 if failures else 0)
