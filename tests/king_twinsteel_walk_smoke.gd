extends "res://tests/king_art_test_base.gd"

## Fresh complete cels: no cropped identity fragments or extra rigid blades.
const CURRENT = "res://data/weapons/families/twinsteel_v2/presentation.tres"
const BAKER = preload("res://tools/king_twinsteel_walk.gd")
const OUT = "res://tmp/review/twinsteel_fresh/"
const VIEWS = ["side","up","down"]
const WALK_DIRECTIONS = [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var current: Resource = load(CURRENT)
	var records: Array = JSON.parse_string(FileAccess.get_file_as_string(BAKER.REGISTRATION))
	check(records.size()==24,"Missing complete generated running poses")
	var baker=BAKER.new()
	for index in 3:
		var view: String = VIEWS[index]
		var gait: Resource = current.run_for(WALK_DIRECTIONS[index])
		var ready: Resource = current.idle_for(WALK_DIRECTIONS[index])
		var standing_head := _cel(ready,0).get_region(Rect2i(ready.identity_regions[0])).get_used_rect()
		var rebuilt: Resource = baker.build_run(view,gait,ready)
		check(same_opaque(rebuilt.body_atlas.get_image(),gait.body_atlas.get_image()),"Published gait differs from whole generated source")
		var bodies := {}; var upper := {}; var feet := {}
		for key in 8:
			var record: Dictionary = records[index*8+key]
			var body := _cel(gait,key)
			var anatomy: Image=baker.protected_cels[view+str(key)]
			var preserved:=true
			for y in 128:
				for x in 192:
					var original:=anatomy.get_pixel(x,y)
					if original.a>.9 and body.get_pixel(x,y)!=original: preserved=false
			check(preserved,"Blade replacement changes accepted head/body/hand/boot pixels")
			check(record.mode=="generated_complete_cels" and record.integrated_weapons,"Stale transplanted anatomy or detached blades")
			check(record.source.begins_with("res://art_source/generated/characters/king/twinsteel_running_complete_2026_10_13/"),"Walking reads reused body/head input")
			check(FileAccess.get_sha256(record.source)==record.source_sha256,"Source provenance changed")
			check(is_equal_approx(record.density,records[index*8].density),"Per-frame density changed")
			check(gait.lift_pixels[key]==0,"Detached body bob")
			check(gait.primary_visible_poses[key]==0 and gait.offhand.visible_poses[key]==0,"Duplicate rigid swords over complete drawn blades")
			check(_mask(gait,key).is_invisible(),"Hand fragment pasted over complete anatomy")
			var blades := _blade_pixels(body,view)
			check(blades.x>=14 and blades.y>=14,"A drawn sword is missing/merged: "+view+str(key))
			for grip in [gait.primary_hands[key],gait.offhand.hands[key]]:
				check(anatomy_connected(body,Vector2i(grip),Rect2i(gait.identity_regions[key])),"Disconnected head/neck/arm/waist/feet: "+view+str(key))
			var used := body.get_used_rect()
			check(used.position.x>4 and used.end.x<188 and used.position.y>4 and used.end.y<124,"Cut whole-cel boundary")
			var calibration: Dictionary=record.normalization
			check(calibration.mode=="standing_head_landmark" and calibration.standing_head_height==standing_head.size.y,"Gait normalized by total height rather than standing anatomy")
			check(absi(roundi(gait.identity_regions[key].size.y)-standing_head.size.y)<=1,"Running shrinks King's head/upper body relative to standing: "+view+str(key))
			var anatomy_bounds: Rect2i=str_to_var(record.body_bounds)
			check(anatomy_bounds.size.y>=calibration.body_height_range[0] and anatomy_bounds.size.y<=calibration.body_height_range[1],"Generated pose violates its calibrated whole-character density")
			check(anatomy_bounds.end.y==95,"Boot origin drifts between keys")
			if view!="side":
				check(record.fixed_weapon_scale and record.weapon_length==gait.weapon_primary_grip.distance_to(gait.weapon_tip),"Vertical running changes the standing weapon length")
				for pair in [[gait.primary_hands[key],gait.secondary_hands[key]],[gait.offhand.hands[key],gait.offhand.axes[key]]]:
					var direction: Vector2=(pair[0]-pair[1]).normalized()
					var tip: Vector2=pair[0]+direction*50
					check(_steel_near(body,tip),"Fixed blade tip absent/clipped: "+view+str(key))
			var data:=body.get_data()
			var binary:=true
			for pixel in data.size()/4:
				if data[pixel*4+3] not in [0,255]: binary=false
			check(binary,"Blur/glow left in runtime art")
			bodies[data]=true
			upper[body.get_region(Rect2i(0,0,192,78)).get_data()]=true
			feet[body.get_region(Rect2i(0,78,192,50)).get_data()]=true
		check(bodies.size()==8 and feet.size()>=6,"Run lacks distinct support/passing poses")
		check(upper.size()>=6,"Upper body is still frozen")
		var first: Resource = current.attack_for(WALK_DIRECTIONS[index])
		for clip in [first]+Array(first.follow_up_clips):
			check(clip.has_valid_layout(),"Protected attack invalid")
			var endpoint: int = int(clip.phase_windows[2].y)
			check(same_opaque(_cel(clip,endpoint),_pad(_cel(ready,0),clip.cell_size)),"Accepted attack endpoint changed")
			check(same_opaque(_mask(clip,endpoint),_pad(_mask(ready,0),clip.cell_size)),"Accepted endpoint hands changed")
	print("KING_TWINSTEEL_WALK checks=",checks," failures=",failures)
	FileAccess.open(OUT+"anatomy_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Fresh complete generated cels, protected accepted anatomy, fixed vertical blade length, uniform density, binary alpha, connected anatomy, safe boundaries and protected attack endpoints"},"\t")+"\n")
	quit(1 if failures else 0)

func _cel(clip: Resource,key: int) -> Image:
	return clip.body_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*clip.cell_size,clip.cell_size))

func _mask(clip: Resource,key: int) -> Image:
	return clip.hand_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*clip.cell_size,clip.cell_size))

func _pad(image: Image,size: Vector2i) -> Image:
	var result:=Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	result.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),(size-image.get_size())/2)
	return result

func _steel_near(body: Image,tip: Vector2) -> bool:
	for y in range(roundi(tip.y)-2,roundi(tip.y)+3):
		for x in range(roundi(tip.x)-2,roundi(tip.x)+3):
			if not Rect2i(0,0,192,128).has_point(Vector2i(x,y)): continue
			var color:=body.get_pixel(x,y)
			if color.a>.9 and minf(color.r,minf(color.g,color.b))>.55: return true
	return false

func _blade_pixels(body: Image,view: String) -> Vector2i:
	# Separate blade-only lanes, excluding the eyes and silver waist trim.
	# Rear cels naturally hide part of the nearer sword behind the body.
	var count := Vector2i.ZERO
	for y in 128:
		for x in 192:
			var c:=body.get_pixel(x,y)
			if c.a<.9 or minf(c.r,minf(c.g,c.b))<120.0/255 or maxf(c.r,maxf(c.g,c.b))-minf(c.r,minf(c.g,c.b))>=38.0/255: continue
			if view=="up":
				if x<91 and y<65: count.x+=1
				if x>103 and y<66: count.y+=1
			elif view=="down":
				if x<85 and y>65: count.x+=1
				if x>108 and y>65: count.y+=1
			else:
				if x>109 and y<70: count.x+=1
				if x>103 and y>=70: count.y+=1
	return count
