extends "res://tests/sanctuary_test_base.gd"
## Complete axe techniques plus retained thin rigid carry. Headless-safe.
const PROFILE = preload("res://data/weapons/families/iron_beard/presentation.tres")
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const SOURCE := "res://art_source/generated/characters/king/iron_beard_motion_2026_10_15/"
var samples: Array[Dictionary] = []
func _run() -> void:
	var steel: Resource = PROFILE.attack_poses
	var image: Image = steel.weapon_texture.get_image()
	check(image.get_size()==Vector2i(80,96),"Canonical axe texture changed")
	check(_one_connected_weapon(image),"Canonical axe has loose fragments")
	var used := image.get_used_rect()
	check(used.size.y>=62 and used.size.y<=65 and used.size.x<=25,"Axe head/length grew into a broad fan")
	for y in [51,56,61,66]:
		var low := 80
		var high := -1
		for x in 80:
			if image.get_pixel(x,y).a>.95: low=mini(low,x); high=maxi(high,x)
		check(high-low+1>=2 and high-low+1<=6 and absf((low+high)*.5-44)<1.5,"Straight narrow shaft bends or changes width")
	var registration: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"registration.json"))
	check(registration.count==69,"Incomplete accepted whole-actor bake")
	check(registration.weapon_sha256==FileAccess.get_sha256(steel.weapon_texture.resource_path),"Attack template differs from carry axe")
	for entry: Dictionary in JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"retained-assets.json")):
		check(FileAccess.get_sha256("res://"+entry.path)==entry.sha256,"Accepted running/contact asset changed: "+str(entry.path))
	for record: Dictionary in registration.actors:
		var values: Array=record.canonical_basis
		var basis:=Transform2D(Vector2(values[0],values[1]),Vector2(values[2],values[3]),Vector2(values[4],values[5]))
		check(is_equal_approx(absf(basis.determinant()),1.0) and is_equal_approx(basis.x.length(),1.0) and is_equal_approx(basis.y.length(),1.0),"Baked axe scales/shears with view or body generation")
		if record.view=="up" and int(record.index) in [2,14]:
			check(basis.y.y>0,"Actual baked UP chop/slam points axe head toward viewer instead of away")
		if record.view in ["side","up","down"]:
			check(basis.determinant()<0 if int(record.index) in ([0,1,2,3,4,5,6,7,24,25,26,28,29,30,31] if record.view=="side" else [0,1,2,3,12,13,14,15]) else true,"Jump reverses cutting edge relative to normal overhead chop")
		if record.view=="turn":
			var expected:=Vector2.RIGHT.rotated(int(record.index)*PI/4)
			check((-basis.y).dot(expected)>.94,"Spin skips/reverses a head direction instead of completing one orbit")
			check((-basis.x).dot(Vector2(-expected.y,expected.x))>.94,"Spin presents the blunt back instead of the cutting edge")
		var head: Array=record.head_bounds
		check(float(head[2])>=18 and float(head[2])<=27,"Attack head shrinks or grows beyond running scale")
		if int(record.index)==0:
			var body: Rect2i=str_to_var(record.body_bounds)
			check(body.size.y>=53 and body.size.y<=62,"Attack guard is shrunken relative to accepted running")
			check(158-float(head[1])-float(head[3])>=32,"Matching hair width hides a compressed chest and legs")
	var dummy := MeleeAttackComponent.new()
	root.add_child(dummy)
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var root_clip: Resource = PROFILE.attack_for(direction)
		var ready: Resource = PROFILE.idle_for(direction)
		var p := Presenter.new()
		check(p.configure(root_clip,dummy,false),"Cannot configure axe")
		p.scale=Vector2(-.5,.5) if direction==Vector2.LEFT else Vector2.ONE*.5
		root.add_child(p)
		p.select_clip(ready)
		p.set_pose(0)
		var ready_basis: Transform2D = p.weapon_rig.transform
		var ready_body: Image = ready.body_atlas.get_image().get_region(Rect2i(0,0,256,256))
		var clips: Array[Resource] = [root_clip]
		clips.append_array(root_clip.follow_up_clips)
		for action in 5:
			var clip: Resource = clips[action]
			p.select_clip(clip)
			check(clip.has_valid_layout(),"Invalid complete axe layout")
			check(not clip.interpolate_blade_angles and not clip.interpolate_weapon,"Separate rigid interpolation overrides drawn axe technique")
			var body: Image = clip.body_atlas.get_image()
			for key in clip.pose_count:
				p.set_pose(key)
				var cel := body.get_region(Rect2i(Vector2i(key%4,key/4)*256,Vector2i(256,256)))
				var neutral: bool = key in ([0,13,15] if action==4 else [0,9,10])
				check(Rect2i(8,8,240,240).encloses(cel.get_used_rect()),"Complete axe/anatomy hits frame boundary")
				check(p.weapon_rig.visible==neutral,"Duplicate or absent axe overlay on baked technique")
				if neutral:
					check(cel.get_data()==ready_body.get_data(),"Released recovery fails to return exact carry body")
					check(p.weapon_rig.transform.is_equal_approx(ready_basis),"Carry grip snaps on released recovery")
				else:
					# Godot's alpha-border import fills RGB in transparent pixels.
					# Compare visible paint; hidden border RGB is not actor artwork.
					var bytes := cel.get_data()
					for offset in range(0,bytes.size(),4):
						if bytes[offset+3]==0:
							bytes[offset]=0
							bytes[offset+1]=0
							bytes[offset+2]=0
					var hash := HashingContext.new()
					hash.start(HashingContext.HASH_SHA256)
					hash.update(bytes)
					var digest := hash.finish().hex_encode()
					var found := false
					for record: Dictionary in registration.actors:
						if record.cel_sha256==digest: found=true; break
					check(found,"Runtime selects obsolete or incomplete actor instead of generated whole technique")
					p._advance_pose(key+.5)
					check(not p.weapon_rig.visible,"Fractional pose brings back drifting rigid overlay")
				samples.append({"direction":var_to_str(direction),"action":action,"key":key,"baked":not neutral})
		for mode in ["idle","run"]:
			var carry: Resource = PROFILE.idle_for(direction) if mode=="idle" else PROFILE.run_for(direction)
			check(carry.has_valid_layout() and carry.weapon_texture==steel.weapon_texture,"Retired axe selected for carry")
			p.select_clip(carry)
			for key in carry.pose_count:
				p.set_pose(key)
				var grip: Vector2 = p.weapon_sprite.to_global(carry.weapon_primary_grip)
				var palm: Vector2 = p.to_global(carry.primary_hands[key]-Vector2(128,128))
				check(grip.distance_to(palm)<.001 and p.weapon_rig.visible and carry.stowed_poses[key]==1,"Stowed axe loses its back attachment")
				check(carry.weapon_behind_body[key]==(0 if direction==Vector2.UP else 1),"Back-mounted axe has wrong camera depth")
				check(is_equal_approx(absf(p.weapon_rig.transform.determinant()),1),"Carry axe changes scale")
				samples.append({"direction":var_to_str(direction),"mode":mode,"key":key})
		p.queue_free()
	dummy.queue_free()
	await process_frame
	DirAccess.make_dir_recursive_absolute("res://tmp/review/axe_technique_2026_10_15")
	FileAccess.open("res://tmp/review/axe_technique_2026_10_15/pose-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"samples":samples},"	")+"
")
	print("AXE_TECHNIQUE checks=",checks," failures=",failures," samples=",samples.size())
	quit(1 if failures else 0)

func _one_connected_weapon(image: Image) -> bool:
	var opaque := {}
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a>.95: opaque[Vector2i(x,y)]=true
	if opaque.is_empty(): return false
	var queue: Array[Vector2i] = [opaque.keys()[0]]
	opaque.erase(queue[0])
	var cursor := 0
	while cursor<queue.size():
		var point := queue[cursor]
		cursor+=1
		for y in range(-1,2):
			for x in range(-1,2):
				var next := point+Vector2i(x,y)
				if opaque.erase(next): queue.append(next)
	return opaque.is_empty()
