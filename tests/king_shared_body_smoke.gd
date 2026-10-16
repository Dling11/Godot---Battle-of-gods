extends "res://tests/king_production_art_contract.gd"

## Enforce exact approved bodies, not merely a plausible sprite height.
const LIBRARY := "res://assets/characters/playable/king/body_library/baseline/"
const KING_FRAMES := "res://assets/characters/playable/king/shared_bodies/sword/frames.tres"
const ORIGINAL_FRAMES := "res://assets/characters/playable/king/spellward/spellward_frames.tres"
const AXE_PROFILE := "res://data/weapons/families/iron_beard/presentation.tres"
const DUAL_PROFILE := "res://data/weapons/families/twinsteel/presentation.tres"
const GREAT_PROFILE := "res://data/weapons/families/royal_greatsword/presentation.tres"
const PROOF := "res://tmp/review/combat/king_body_consistency_2026_10_11/"
var proof := PROOF

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"): proof=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(proof))
	super._initialize()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	verify_production_baseline([])
	var view_names := ["side","up","down"]
	var directions := [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
	var stock: Array[Resource] = [load(AXE_PROFILE),load(DUAL_PROFILE),load(GREAT_PROFILE)]
	var contract: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY+"contract.json"))
	for key in contract.poses:
		check(FileAccess.get_sha256(LIBRARY+key+"_body.png")==contract.poses[key].sha256,"Frozen whole body changed: "+key)
	for index in 3:
		var view: String = view_names[index]
		for family in stock:
			var gait: Resource = family.run_for(directions[index])
			if family==stock[2]:
				check(gait.pose_count==8,"Greatsword lost dedicated run frames")
				verify_complete_clip(gait,Vector2i(384,384))
				continue
			if family==stock[0]:
				# Decision212 retains complete accepted Reaper running actors for axe.
				# Compare their real cell sizes, not an empty old 192x128 corner.
				var approved: Resource=load("res://assets/characters/playable/king/iron_reaper/"+view+"/run.tres")
				check(gait.pose_count==8 and gait.has_valid_layout(),"Invalid current complete gait")
				for key in 8:
					var cell: Image=gait.body_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*gait.cell_size,gait.cell_size))
					var native: Image=cell.get_region(Rect2i((gait.cell_size-Vector2i(256,256))/2,Vector2i(256,256)))
					var original: Image=approved.body_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*256,Vector2i(256,256)))
					check(same_opaque(native,original),"Current weapon changed complete accepted running anatomy")
					var used:=native.get_used_rect()
					var seed:=used.position
					for x in range(used.position.x,used.end.x):
						if native.get_pixel(x,used.position.y).a>.8:
							seed=Vector2i(x,used.position.y)
							break
					check(anatomy_connected(native,seed,used),"Complete running actor has disconnected anatomy")
				continue
			if family==stock[1]:
				check(gait.pose_count==8,"Twinsteel lost complete stride frames")
				verify_complete_clip(gait,Vector2i(256,256))
				for key in gait.pose_count:
					check(gait.offhand.visible_poses[key]==0,"Duplicate blade over complete Twinsteel")

		var ready: Resource = stock[0].idle_for(directions[index])
		check(ready.has_valid_layout(),"Current axe has no complete ready pose")
		var cuts: Resource = stock[0].attack_for(directions[index])
		var poses: Array = [cuts]+Array(cuts.follow_up_clips)
		for step in 5:
			var clip: Resource = poses[step]
			for key in clip.pose_count:
				var box := Rect2i(Vector2i(key%4,key/4)*clip.cell_size,clip.cell_size)
				var body: Image = clip.body_atlas.get_image().get_region(box)
				var changed: bool = clip.stowed_poses[key]==1
				if changed:
					check(same_opaque(body,ready.body_atlas.get_image().get_region(Rect2i(Vector2i.ZERO,ready.cell_size))),"Axe recovery/entry changes King's standing anatomy")
				if not clip.identity_regions.is_empty():
					check(anatomy_connected(body,Vector2i(clip.identity_regions[key].get_center()),Rect2i(clip.identity_regions[key])),"Axe attack head/body is disconnected: "+view+"/"+str(step)+"/"+str(key))
	var frames: SpriteFrames = load(KING_FRAMES)
	var old_frames: SpriteFrames = load(ORIGINAL_FRAMES)
	for animation in old_frames.get_animation_names():
		if str(animation).begins_with("idle_") or str(animation).begins_with("walk_"): continue
		check(frames.get_frame_count(animation)==old_frames.get_frame_count(animation),"Sword action count changed")
		for key in frames.get_frame_count(animation): check(same_opaque(frames.get_frame_texture(animation,key).get_image(),old_frames.get_frame_texture(animation,key).get_image()),"Sword action art changed: "+str(animation))
	for index in 3:
		for lane in ["idle","walk"]:
			var view: String = view_names[index]
			var master: Resource = load(LIBRARY+view+("_ready.tres" if lane=="idle" else "_run.tres"))
			var animation := StringName(lane+"_"+("right" if view=="side" else view))
			if lane=="walk": check(frames.get_animation_speed(animation)==frames.get_animation_speed("walk_right"),"Sword vertical cadence differs from side gait")
			for key in frames.get_frame_count(animation):
				var body_key: int = 0 if lane=="idle" else key
				var body: Image = master.body_atlas.get_image().get_region(Rect2i(body_key%4*192,body_key/4*128,192,128))
				var baked: Image = frames.get_frame_texture(animation,key).get_image()
				var matches := true
				for y in 128:
					for x in 192:
						if body.get_pixel(x,y).a>.65 and baked.get_pixel(x,y)!=body.get_pixel(x,y): matches=false
				check(matches,"Sword composition modified King's canonical body texels")
				if view=="side":
					var mirror: Image = baked.duplicate(); mirror.flip_x()
					check(same_opaque(mirror,frames.get_frame_texture(StringName(lane+"_left"),key).get_image()),"Sword left gait is not an exact mirror")
	# A mutation that preserves height must fail the actual equality gate.
	var control: Image = stock[0].run_for(Vector2.DOWN).body_atlas.get_image().duplicate()
	var mutant := control.duplicate(); mutant.set_pixel(50,65,Color.RED)
	mutant.save_png(proof+"rejected_same_height_body.png")
	check(not same_opaque(control,mutant),"Body gate accepts a same-height foreign torso pixel")
	FileAccess.open(proof+"body_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Immutable library/Sword; exact accepted Reaper gait for axe; hash-verified installed complete Greatsword and Twinsteel actors, connected running anatomy and current axe carry at declared cell sizes"},"\t")+"\n")
	print("KING_SHARED_BODY checks=",checks," failures=",failures)
	quit(1 if failures else 0)
