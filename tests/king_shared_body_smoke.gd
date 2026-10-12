extends "res://tests/king_art_test_base.gd"

## Enforce exact approved bodies, not merely a plausible sprite height.
const LIBRARY := "res://assets/characters/playable/king/body_library/v1/"
const KING_FRAMES := "res://assets/characters/playable/king/shared_bodies/sword/frames.tres"
const ORIGINAL_FRAMES := "res://assets/characters/playable/king/spellward/spellward_frames.tres"
const AXE_PROFILE := "res://data/weapons/families/iron_beard/presentation.tres"
const DUAL_PROFILE := "res://data/weapons/families/twinsteel_v2/presentation.tres"
const GREAT_PROFILE := "res://data/weapons/families/royal_greatsword_v2/presentation.tres"
const PROOF := "res://tmp/review/combat/king_body_consistency_2026_10_11/"
var proof := PROOF

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"): proof=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(proof))
	super._initialize()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var view_names := ["side","up","down"]
	var directions := [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
	var stock: Array[Resource] = [load(AXE_PROFILE),load(DUAL_PROFILE),load(GREAT_PROFILE)]
	var contract: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY+"contract.json"))
	for key in contract.poses:
		check(FileAccess.get_sha256(LIBRARY+key+"_body.png")==contract.poses[key].sha256,"Frozen whole body changed: "+key)
	for index in 3:
		var view: String = view_names[index]
		var canonical: Resource = load(LIBRARY+view+"_run.tres")
		for family in stock:
			var gait: Resource = family.run_for(directions[index])
			if family==stock[1]:
				# Decision196: distinct complete carry cels preserve the approved
				# whole upper pose; the focused gate also checks lower-body motion.
				var master:Image=family.idle_for(directions[index]).body_atlas.get_image().get_region(Rect2i(0,0,192,81))
				for key in 8:
					check(same_opaque(gait.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,81)),master),"Twinsteel changed complete carry upper anatomy")
			else:
				check(same_opaque(gait.body_atlas.get_image(),canonical.body_atlas.get_image()),"Weapon changed King's complete gait: "+gait.resource_path)
			check(gait.pose_count==8 and gait.has_valid_layout(),"Shared body has invalid attachment layout")
			for key in 8:
				var cel: Image = gait.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
				check(anatomy_connected(cel,Vector2i(gait.identity_regions[key].get_center()),Rect2i(gait.identity_regions[key])),"Shared walking body is disconnected")
				if gait.offhand!=null:
					for grip in [gait.primary_hands[key],gait.offhand.hands[key]]:
						var c := cel.get_pixelv(Vector2i(grip.round()))
						check(c.a>.65 and c.r>.18 and c.r>c.g*1.35 and c.g>c.b*1.25,"Shared two-blade gait has a floating grip")
		var master: Resource = load(LIBRARY+view+("_ready.tres" if view=="up" else "_relaxed.tres"))
		var ready: Resource = stock[0].idle_for(directions[index])
		check(same_opaque(ready.body_atlas.get_image().get_region(Rect2i(0,0,192,128)),master.body_atlas.get_image().get_region(Rect2i(0,0,192,128))),"Axe equipment body is not the canonical complete pose")
		var cuts: Resource = stock[0].attack_for(directions[index])
		var poses: Array = [cuts]+Array(cuts.follow_up_clips)
		for step in 5:
			var clip: Resource = poses[step]
			for key in clip.pose_count:
				var box := Rect2i(key%4*192,key/4*128,192,128)
				var body: Image = clip.body_atlas.get_image().get_region(box)
				var changed: bool = key==int(clip.phase_windows[2].y) or (step==0 and key==0) or (step==4 and key==clip.pose_count-1)
				if changed:
					check(same_opaque(body,ready.body_atlas.get_image().get_region(Rect2i(0,0,192,128))),"Axe recovery/entry changes King's standing anatomy")
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
	FileAccess.open(proof+"body_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Exact canonical Sword/axe/Greatsword gait, complete native Twinsteel carry upper, connected anatomy, Sword pixels/mirror/actions, DOWN axe registration, endpoints and immutable library"},"\t")+"\n")
	print("KING_SHARED_BODY checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _translate_cel(cel: Image,shift: Vector2i) -> Image:
	var result := Image.create(192,128,false,Image.FORMAT_RGBA8)
	result.blit_rect(cel,Rect2i(0,0,192,128),shift)
	return result
