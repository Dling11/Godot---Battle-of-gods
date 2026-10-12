extends "res://tests/sanctuary_test_base.gd"

## Regression for true carry grips and real travel-driven walking.
const PLAYER = preload("res://entities/player/player.tscn")
const ITEM = preload("res://data/items/equipment/king_twinsteel.tres")
const LIB := "res://assets/characters/playable/king/body_library/v1/"
const OUT := "res://tmp/review/combat/king_dual_carry_motion_2026_10_12/"
const DIRECTIONS := [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
const ACTIONS := [&"player_move_left",&"player_move_right",&"player_move_up",&"player_move_down"]

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_dual_gait_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.size=Vector2i(1280,720); root.content_scale_size=root.size
	_verify_sources()
	var actor: Player=PLAYER.instantiate()
	actor.movement_bounds=Rect2(-5000,-5000,10000,10000)
	root.add_child(actor)
	actor.apply_debug_testing_preset()
	actor.set_process_unhandled_input(false)
	check(actor.equip_owned_weapon(ITEM),"Normal equipment cannot select corrected gait")
	var family:=actor.get_node("WeaponFamilyPresentation")
	for index in 4:
		actor.position=Vector2(640,360); actor.velocity=Vector2.ZERO
		actor._set_facing_direction(DIRECTIONS[index])
		await physics_frame
		var seen := {}
		Input.action_press(ACTIONS[index])
		for tick in 85:
			await physics_frame
			var rig: Node2D=family.presenter
			if rig._running and rig.definition==family.profile.run_for(DIRECTIONS[index]):
				seen[rig.pose_index]=true
				_assert_rendered_grips(rig)
		check(seen.size()==8,"Actual walking skips gait keys in direction "+str(DIRECTIONS[index]))
		check(family.presenter.scale==Vector2(-.5 if index==0 else .5,.5),"Left gait or character density differs")
		var rig: Node2D=family.presenter
		var before_body: Image=rig.body_sprite.texture.get_image()
		var before_main: Vector2=rig.weapon_sprite.to_global(rig.definition.weapon_primary_grip)
		var before_far: Vector2=rig.offhand_sprite.to_global(rig.definition.offhand.grip)
		Input.action_release(ACTIONS[index])
		check(actor.request_primary_attack(),"Walking cannot enter an attack")
		check(rig.body_sprite.texture.get_image().get_data()==before_body.get_data(),"Attack entry flashes a different walking body")
		check(rig.weapon_sprite.to_global(rig.definition.weapon_primary_grip).distance_to(before_main)<.01,"Attack entry detaches near grip")
		check(rig.offhand_sprite.to_global(rig.definition.offhand.grip).distance_to(before_far)<.01,"Attack entry detaches far grip")
		actor._clear_buffered_action(); actor.attack_component.cancel_attack(); actor.velocity=Vector2.ZERO
		await physics_frame; await physics_frame
		check(rig.definition==family.profile.idle_for(DIRECTIONS[index]),"Walking/released attack cannot return to accepted idle")
		# Continue holding a movement key into a genuine collision. The adapter
		# may remain in running mode; zero displacement must freeze its key.
		var wall:=StaticBody2D.new(); wall.collision_layer=1; wall.collision_mask=0
		wall.position=actor.position+DIRECTIONS[index]*35
		var collider:=CollisionShape2D.new(); var shape:=RectangleShape2D.new()
		shape.size=Vector2(4,160) if index<2 else Vector2(160,4)
		collider.shape=shape; wall.add_child(collider); root.add_child(wall)
		await physics_frame
		Input.action_press(ACTIONS[index])
		for tick in 65: await physics_frame
		var stopped_at:=actor.global_position; var blocked_pose: int=rig.pose_index
		for tick in 12: await physics_frame
		check(actor.global_position.distance_to(stopped_at)<.01 and actor.get_slide_collision_count()>0,"Blocked-travel fixture did not reach its real wall")
		check(rig.pose_index==blocked_pose,"Feet continue cycling against a blocking wall")
		Input.action_release(ACTIONS[index]); actor.velocity=Vector2.ZERO; wall.queue_free()
		await physics_frame; await physics_frame
		check(not rig._running and rig.definition==family.profile.idle_for(DIRECTIONS[index]),"Movement release fails to settle to idle")
	actor.queue_free()
	await process_frame
	FileAccess.open(OUT+"gait_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Reviewed palm lanes, cyclic attachment continuity, complete body and accepted asset preservation, actual four-direction input/travel, blocked feet and run-to-attack/idle"},"\t")+"\n")
	print("KING_DUAL_GAIT checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _verify_sources() -> void:
	var profile: Resource=ITEM.weapon_definition.family_presentation
	for view in ["side","up","down"]:
		var direction: Vector2=Vector2.RIGHT if view=="side" else (Vector2.UP if view=="up" else Vector2.DOWN)
		var clip: Resource=profile.run_for(direction)
		check(clip.has_valid_layout() and clip.pose_count==8,"Invalid gait layout")
		var idle:Resource=profile.idle_for(direction)
		check(clip.body_atlas.resource_path=="res://assets/characters/playable/king/shared_bodies/dual_carry_v3/"+view+"/run_body.png","Incorrect authored carry selection")
		for key in 8:
			check(clip.identity_regions[key]==idle.identity_regions[0] and clip.lift_pixels[key]==0,"Walking alters upper anatomy metadata or lift")
		check(not clip.allow_rest and not clip.interpolate_weapon and not clip.interpolate_blade_angles,"Gait introduces floating interpolation or a rest tween")
		for key in 8:
			var origin:=Vector2i(key%4*192,key/4*128)
			var body: Image=clip.body_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
			var mask: Image=clip.hand_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
			var expected_mask:=Image.create(192,128,false,Image.FORMAT_RGBA8)
			var head: Rect2=clip.identity_regions[key]
			var next: int=(key+1)%8
			for hand in [0,1]:
				var grip: Vector2=clip.primary_hands[key] if hand==0 else clip.offhand.hands[key]
				var following: Vector2=clip.primary_hands[next] if hand==0 else clip.offhand.hands[next]
				var pixel:=body.get_pixelv(Vector2i(grip))
				check(pixel.a>.65 and pixel.r>.18 and pixel.r<.8 and pixel.r>pixel.g*1.35 and pixel.g>pixel.b*1.25,"Blade misses drawn leather palm")
				check(grip.distance_to(following)<=(5.0 if view=="side" else (9.0 if view=="up" else 12.0)),"Blade jumps between unrelated source regions at cyclic seam")
				if view=="side": check(grip.y>=head.end.y+4,"Side blade attached to shoulder/face instead of glove")
				else: check(grip==idle.primary_hands[0] if hand==0 else grip==idle.offhand.hands[0],"Vertical blade leaves approved carry palm")
				check(grip.y<=77,"Vertical blade picked a boot")
				var box:=Rect2i(Vector2i(grip)-Vector2i(5,5),Vector2i(11,11))
				expected_mask.blit_rect(body,box,box.position)
			check(mask.get_data()==expected_mask.get_data(),"Closed-palm mask redraws/truncates source fist")
			check(clip.weapon_behind_body[key]==(1 if view=="up" else 0) and clip.offhand.behind_body[key]==(0 if view=="down" else 1),"Camera-relative sword depth changed")
		if view=="side":
			check(clip.offhand.texture.get_image().get_region(Rect2i(0,43,16,19)).is_invisible(),"Hidden rear handle returned to side gait")

func _assert_rendered_grips(rig: Node2D) -> void:
	var clip: Resource=rig.definition
	var center:=Vector2(clip.cell_size)*.5
	check(rig.weapon_sprite.to_global(clip.weapon_primary_grip).distance_to(rig.to_global(clip.primary_hands[rig.pose_index]-center))<.01,"Rendered primary sword slips off its current cel")
	check(rig.offhand_sprite.to_global(clip.offhand.grip).distance_to(rig.to_global(clip.offhand.hands[rig.pose_index]-center))<.01,"Rendered rear sword slips off its current cel")
