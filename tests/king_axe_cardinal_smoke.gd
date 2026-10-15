extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const OTHER = preload("res://data/items/equipment/king_iron_reaper.tres")
var output := "res://tmp/review/iron_beard_unified_2026_10_15/"
var started: Array[int] = []
var frames: Array[Dictionary] = []
var ribbon_rows: Array[Dictionary] = []

func _run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-folder=res://tmp/review/"): output=argument.trim_prefix("--capture-folder=").trim_suffix("/")+"/"
	root.size=Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(output)
	root.get_node("SaveService").configure_storage_path_for_testing("user://axe_unified_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	root.get_node("RunSession").reset_run()
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene=hub
	await process_frame
	check(not inventory.owns_weapon(ITEM.item_id),"Fresh save unexpectedly owns test axe")
	await key(KEY_F9)
	check(inventory.owns_weapon(ITEM.item_id),"F9 does not grant axe")
	await key(KEY_F7)
	var deadline := Time.get_ticks_msec()+15000
	while current_scene==hub and Time.get_ticks_msec()<deadline: await process_frame
	check(current_scene!=hub and current_scene!=null,"F7 did not enter Lab")
	if current_scene==hub or current_scene==null: quit(1); return
	var lab: Node = current_scene
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab._set_examiner_arena(false)
	var actor: Player = lab.player
	actor.set_physics_process(false)
	actor.position=Vector2(350,300)
	var attack := actor.attack_component
	attack.set_equipment_attack_speed_bonus(0)
	CombatFeedbackPresenter.find_for_player(actor).hitstop_enabled=false
	var review: Node = lab.review_tabs.get_node("Weapons")
	lab.review_tabs.current_tab=review.get_index()
	review.buttons[ITEM.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item()==ITEM and attack.weapon==ITEM.weapon_definition,"Weapons tab equips wrong axe")
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	check(family.profile.is_valid_profile(),"Invalid complete axe family")
	check(is_equal_approx(WeaponCombatReadout.duration(attack.weapon),3.19),"Art pass changed axe cadence")
	check(attack.weapon.basic_damage_minimum==14 and attack.weapon.basic_damage_maximum==16 and attack.weapon.knockback_strength==60,"Art pass changed damage/knockback")
	await key(KEY_TAB)
	var bag: CharacterMenu = lab.get_node("UI/CharacterMenu")
	check(bag.visible and paused,"Tab cannot open Bag")
	bag._on_equipment_selected(ITEM)
	bag.equipment_detail_panel.equip_requested.emit(ITEM)
	check(is_instance_valid(bag._family_portrait) and bag._family_portrait.definition==family.profile.idle_poses,"Bag uses previous axe body")
	await capture("bag.png")
	await key(KEY_ESCAPE)
	check(not paused and not bag.visible,"Bag blocks normal controls")
	actor.set_process_unhandled_input(false)
	attack.attack_started.connect(func() -> void: started.append(attack.combo_step))
	var directions := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
	var labels := ["right","left","up","down"]
	if "--record-only" in OS.get_cmdline_user_args():
		for index in 4:
			if "--attacks-only" not in OS.get_cmdline_user_args(): await record_locomotion(actor,lab,directions[index],labels[index])
			await record_combo(actor,lab,directions[index],labels[index])
		lab.queue_free()
		current_scene=null
		await process_frame
		print("AXE_CAPTURE checks=",checks," failures=",failures)
		quit(1 if failures else 0)
		return
	for index in 4:
		var direction: Vector2 = directions[index]
		actor.position=Vector2(350,300)
		actor._set_facing_direction(direction)
		await physics_frame
		actor.velocity=direction*100
		await physics_frame
		var pose: int = family.presenter.pose_index
		await create_timer(.09).timeout
		check(family.presenter.pose_index==pose,"Blocked King still cycles run")
		actor.position+=direction*18
		await physics_frame
		await physics_frame
		check(family.presenter._running and family.presenter.definition==family.profile.run_for(direction) and family.presenter.pose_index!=pose,"Gait does not advance with travel")
		await capture("running_"+labels[index]+".png")
		actor.velocity=Vector2.ZERO
		await physics_frame
		await physics_frame
		check(family.presenter.definition==family.profile.idle_for(direction),"Stop uses wrong carry")
		family.presenter._rest_timer.stop()
		attack.reset_combo()
		started.clear()
		check(actor.request_primary_attack(),"Axe input rejected")
		for step in 5:
			await until(attack,MeleeAttackComponent.Phase.ACTIVE)
			check(attack.combo_step==step and attack.get_attack_direction()==direction,"Combo drops cut or turns")
			check(family.presenter.visible and not actor.get_node("VisualRoot/Body").visible,"Axe renders two bodies")
			check(family.presenter.weapon_sprite.texture==family.profile.attack_poses.weapon_texture,"Fixed axe texture changes")
			if DisplayServer.get_name()!="headless": check(family._audio.stream==family.profile.swing_sounds[step] and family._audio.playing,"Missing owned axe air cue")
			if step==2:
				# The complete generated push owns both drawn hands and steel.
				# Testing the hidden legacy rig cannot certify its cutting direction.
				check(not family.presenter.weapon_rig.visible and not family.presenter.definition.interpolate_blade_angles,"Head push still uses a separately rotating axe")
			await verify_slash(family,labels[index],step)
			if step<4:
				check(actor.request_primary_attack(),"Next cut does not buffer")
				await next_step(attack,step+1)
		await until(attack,MeleeAttackComponent.Phase.IDLE)
		check(started==[0,1,2,3,4],"Five-hit chain repeats or drops a cut")
		family.presenter._rest_timer.stop()
		family.presenter._rest()
		await create_timer(1.85).timeout
		check(family.presenter._resting and family.presenter.definition==family.profile.idle_for(direction),"Calm idle loses facing")
		await capture("idle_"+labels[index]+".png")
		check(actor.request_primary_attack() and family.presenter._drawing,"Idle does not retrieve on input")
		await until(attack,MeleeAttackComponent.Phase.ACTIVE)
		attack.cancel_attack()
		family.presenter.cancel_presentation_transition()
	actor._set_facing_direction(Vector2.RIGHT)
	attack.reset_combo()
	actor.request_primary_attack()
	await until(attack,MeleeAttackComponent.Phase.ACTIVE)
	review.buttons[OTHER.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item()==ITEM,"Switching weapons succeeds during contact")
	actor._clear_buffered_action()
	attack.cancel_attack()
	check(not family.trail.slash_sprite.visible,"Cancelled cut leaks white frames")
	check(actor.request_evade(Vector2.LEFT),"Axe blocks dodge")
	await process_frame
	check(not family.presenter.visible,"Dodge renders two actors")
	actor.evade_component.cancel_evade()
	check(actor.request_ability(2),"Axe blocks skills")
	await process_frame
	check(not family.presenter.visible,"Skills leave axe actor visible")
	actor.get_active_ability_component().cancel_cast()
	lab.queue_free()
	current_scene=null
	await process_frame
	var arena := preload("res://levels/test_arena/test_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	check(arena.player.attack_component.weapon==ITEM.weapon_definition,"Stage I loses equipped axe")
	check(arena.player.get_node("WeaponFamilyPresentation").profile==ITEM.weapon_definition.family_presentation,"Campaign retains old axe art")
	arena.queue_free()
	current_scene=null
	await process_frame
	FileAccess.open(output+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"native":DisplayServer.get_name()!="headless","ribbons":ribbon_rows},"\t")+"\n")
	print("AXE_GAMEPLAY checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func verify_slash(family: Node,label: String,step: int) -> void:
	if DisplayServer.get_name()=="headless": return
	paused=true
	var trail: Node2D = family.trail
	for frame in (range(8) if "--all-slash-frames" in OS.get_cmdline_user_args() else [3]):
		trail._set_frame(frame)
		await capture("cut_%d_%s_%d.png"%[step,label,frame])
		var masked := root.get_texture().get_image()
		trail.slash_sprite.material=null
		await process_frame
		await RenderingServer.frame_post_draw
		var raw := root.get_texture().get_image()
		trail.slash_sprite.material=trail.contact_mask
		trail.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		var none := root.get_texture().get_image()
		var bright := 0
		var outside := 0
		var clipped := 0
		var inverse := trail.get_global_transform_with_canvas().affine_inverse()
		var area := Rect2()
		var transform: Transform2D = trail.slash_sprite.get_global_transform_with_canvas()
		for corner in [Vector2(-128,-128),Vector2(128,-128),Vector2(-128,128),Vector2(128,128)]:
			var point: Vector2 = transform*corner
			area=Rect2(point,Vector2.ONE) if area.size==Vector2.ZERO else area.expand(point)
		var scan := Rect2i(area.grow(2)).intersection(Rect2i(Vector2i.ZERO,masked.get_size()))
		for y in range(scan.position.y,scan.end.y):
			for x in range(scan.position.x,scan.end.x):
				var a := masked.get_pixel(x,y)
				var b := none.get_pixel(x,y)
				var c := raw.get_pixel(x,y)
				if minf(a.r,minf(a.g,a.b))>.55 and a.r+a.g+a.b-b.r-b.g-b.b>.4:
					bright+=1
					if not Geometry2D.is_point_in_polygon(inverse*Vector2(x+.5,y+.5),trail._points): outside+=1
				if c.r+c.g+c.b-b.r-b.g-b.b>.4 and c.r+c.g+c.b-a.r-a.g-a.b>.2: clipped+=1
		check(bright>0,"Missing painted stroke %s/%d/%d"%[label,step,frame])
		check(outside==0,"Stroke exceeds actual contact")
		check(clipped==0,"Mask cuts painted stroke")
		ribbon_rows.append({"view":label,"cut":step,"frame":frame,"bright":bright,"outside":outside,"clipped":clipped})
		trail.show()
	paused=false

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame


func until(attack: MeleeAttackComponent, phase: int) -> void:
	var deadline := Time.get_ticks_msec() + 6000
	while attack.phase != phase and Time.get_ticks_msec() < deadline: await physics_frame
	check(attack.phase == phase, "Timed out waiting for phase " + str(phase))


func next_step(attack: MeleeAttackComponent, step: int) -> void:
	var deadline := Time.get_ticks_msec() + 6000
	while (attack.combo_step != step or attack.phase == MeleeAttackComponent.Phase.IDLE) and Time.get_ticks_msec() < deadline: await physics_frame
	check(attack.combo_step == step and attack.phase != MeleeAttackComponent.Phase.IDLE, "Buffered cut timed out")


func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output + file) == OK, "Native capture failed")


func record_combo(actor: Player, lab: Node, direction: Vector2, label: String) -> void:
	lab.get_node("UI").hide()
	actor.position = Vector2(350, 300)
	actor._set_facing_direction(direction)
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	family.presenter._rest_timer.stop()
	var camera: Camera2D = lab.camera
	var old_camera_position := camera.position
	camera.enabled = true
	# The Lab camera is already a child of Player: offset is local, not world.
	camera.position = Vector2(0, -12) + direction * 52
	camera.zoom = Vector2.ONE * 2
	camera.position_smoothing_enabled = false
	await process_frame
	check(Rect2(160, 80, 640, 380).has_point(actor.get_global_transform_with_canvas().origin), "Recorded actor is outside the camera viewport")
	var attack := actor.attack_component
	attack.reset_combo()
	frames.clear()
	var start := Time.get_ticks_msec()
	var queued := -1
	DirAccess.make_dir_recursive_absolute(output + label + "/")
	actor.request_primary_attack()
	while attack.phase != MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec() - start < 6000:
		if attack.phase == MeleeAttackComponent.Phase.ACTIVE and attack.combo_step < 4 and queued != attack.combo_step:
			actor.request_primary_attack()
			queued = attack.combo_step
		await process_frame
		await RenderingServer.frame_post_draw
		var file := "frame_%03d.png" % frames.size()
		root.get_texture().get_image().save_png(output + label + "/" + file)
		frames.append({"file": file, "elapsed_ms": Time.get_ticks_msec() - start, "step": attack.combo_step, "phase": attack.phase, "pose": family.presenter.pose_index})
	FileAccess.open(output + label + "/timeline.json", FileAccess.WRITE).store_string(JSON.stringify(frames, "\t") + "\n")
	camera.enabled = false
	camera.position = old_camera_position
	camera.zoom = Vector2.ONE
	lab.get_node("UI").show()

func record_locomotion(actor: Player, lab: Node, direction: Vector2, label: String) -> void:
	lab.get_node("UI").hide()
	actor.position = Vector2(350,300)
	actor._set_facing_direction(direction)
	var camera: Camera2D = lab.camera
	var previous := camera.position
	camera.position = Vector2(0,-12)
	# Match record_combo: different review zooms falsely suggest body shrinkage.
	camera.zoom = Vector2.ONE*2
	camera.position_smoothing_enabled = false
	camera.enabled = true
	var folder := output + "run_" + label + "/"
	DirAccess.make_dir_recursive_absolute(folder)
	var timeline := []
	var start := Time.get_ticks_msec()
	var last := start
	while Time.get_ticks_msec()-start<1600:
		await physics_frame
		var now := Time.get_ticks_msec()
		actor.velocity = direction*75
		actor.move_and_collide(direction*75*minf((now-last)/1000.0,0.05))
		last = now
		await process_frame
		await RenderingServer.frame_post_draw
		var file := "frame_%03d.png" % timeline.size()
		root.get_texture().get_image().save_png(folder+file)
		timeline.append({"file":file,"elapsed_ms":now-start})
	actor.velocity = Vector2.ZERO
	await physics_frame
	FileAccess.open(folder+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	family.presenter._rest()
	folder = output + "idle_" + label + "/"
	DirAccess.make_dir_recursive_absolute(folder)
	timeline.clear()
	start = Time.get_ticks_msec()
	while Time.get_ticks_msec()-start<5100:
		await process_frame
		await RenderingServer.frame_post_draw
		var file := "frame_%03d.png" % timeline.size()
		root.get_texture().get_image().save_png(folder+file)
		timeline.append({"file":file,"elapsed_ms":Time.get_ticks_msec()-start})
	FileAccess.open(folder+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	family.presenter.cancel_presentation_transition()
	camera.enabled = false
	camera.position = previous
	camera.zoom = Vector2.ONE
	lab.get_node("UI").show()
