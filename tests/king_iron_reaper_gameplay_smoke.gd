extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_iron_reaper.tres")
const AXE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const ROOTLING = preload("res://entities/enemies/rootling/rootling.tscn")
var output := "res://tmp/review/iron_reaper_unified_2026_10_14/"
var started: Array[int] = []
var frames: Array[Dictionary] = []


func _run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-folder="):
			var folder := argument.trim_prefix("--capture-folder=")
			if folder.begins_with("res://tmp/review/") and not folder.contains(".."):
				output = folder.trim_suffix("/")+"/"
	root.size = Vector2i(960, 540)
	DirAccess.make_dir_recursive_absolute(output)
	root.get_node("SaveService").configure_storage_path_for_testing("user://iron_reaper_gameplay_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	root.get_node("RunSession").reset_run()
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	check(not inventory.owns_weapon(ITEM.item_id), "Fresh campaigns receive the test scythe")
	await key(KEY_F9)
	check(inventory.owns_weapon(ITEM.item_id), "F9 does not grant Iron Reaper")
	await key(KEY_F7)
	var deadline := Time.get_ticks_msec() + 15000
	while current_scene == hub and Time.get_ticks_msec() < deadline: await process_frame
	check(current_scene != hub and current_scene != null, "F7 cannot enter the Combat Lab")
	if current_scene == hub or current_scene == null: quit(1); return
	var lab: Node = current_scene
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab._set_examiner_arena(false)
	var actor: Player = lab.player
	actor.set_physics_process(false)
	actor.position = Vector2(350, 300)
	var attack := actor.attack_component
	var feedback := CombatFeedbackPresenter.find_for_player(actor)
	feedback.hitstop_enabled = false
	attack.set_equipment_attack_speed_bonus(0)
	var review: Node = lab.review_tabs.get_node("Weapons")
	lab.review_tabs.current_tab = review.get_index()
	review.buttons[ITEM.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item() == ITEM and attack.weapon == ITEM.weapon_definition, "Weapons tab cannot equip the scythe")
	check(ITEM.weapon_definition.family_presentation.is_valid_profile(), "Scythe has an incomplete directional profile")
	check(is_equal_approx(WeaponCombatReadout.duration(attack.weapon), 2.59), "Bag cadence differs from the four-cut chain")
	await key(KEY_TAB)
	var bag: CharacterMenu = lab.get_node("UI/CharacterMenu")
	check(bag.visible and paused, "Real Tab does not open the Bag")
	bag._on_equipment_selected(ITEM)
	bag.equipment_detail_panel.equip_requested.emit(ITEM)
	check(is_instance_valid(bag._family_portrait) and bag._family_portrait.definition == attack.weapon.family_presentation.idle_poses, "Paper doll uses old weapon art")
	await capture("bag.png")
	await key(KEY_ESCAPE)
	check(not paused and not bag.visible, "Bag close leaves controls blocked")
	actor.set_process_unhandled_input(false)
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	attack.attack_started.connect(func() -> void: started.append(attack.combo_step))
	var directions := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	var labels := ["right", "left", "up", "down"]
	if "--record-only" in OS.get_cmdline_user_args():
		for index in 4:
			if "--attacks-only" not in OS.get_cmdline_user_args(): await record_locomotion(actor,lab,directions[index],labels[index])
			await record_combo(actor, lab, directions[index], labels[index])
		lab.queue_free()
		current_scene = null
		await process_frame
		print("IRON_REAPER_CAPTURE checks=", checks, " failures=", failures)
		quit(1 if failures else 0)
		return
	for index in 4:
		var direction: Vector2 = directions[index]
		actor.position = Vector2(350, 300)
		actor._set_facing_direction(direction)
		await physics_frame
		actor.velocity = direction * 100
		await physics_frame
		var old_pose: int = family.presenter.pose_index
		actor.position += direction * 18
		await physics_frame
		check(family.presenter._running and family.presenter.definition == family.profile.run_for(direction) and family.presenter.pose_index != old_pose, "Running glides or uses the wrong facing")
		await capture("running_" + labels[index] + ".png")
		actor.velocity = Vector2.ZERO
		await physics_frame
		await physics_frame
		check(family.presenter.definition == family.profile.idle_for(direction), "Running does not settle into the correct carry")
		family.presenter._rest_timer.stop()
		attack.reset_combo()
		started.clear()
		check(actor.request_primary_attack(), "Scythe attack rejected")
		for step in 4:
			await until(attack, MeleeAttackComponent.Phase.ACTIVE)
			check(attack.combo_step == step and attack.get_attack_direction() == direction, "Combo changes committed cut or facing")
			if step == 2:
				check(is_instance_valid(attack.released_attack) and not attack.hitbox._enabled, "Throw does not release or retains a local spin hitbox")
			else:
				check(attack.hitbox._contact_rule == attack.weapon.combo.contact_rule(step), "Melee did not commit its per-cut rule")
			check(family.presenter.visible and not actor.get_node("VisualRoot/Body").visible, "Scythe draws two King bodies")
			if DisplayServer.get_name() != "headless":
				check(family._audio.stream==family.profile.swing_sounds[step] and family._audio.playing,"Cut does not play its family-owned scythe swing")
			await verify_slash(family, labels[index], step)
			if step < 3:
				check(actor.request_primary_attack(), "Next cut cannot be buffered")
				await next_step(attack, step + 1)
		await until(attack, MeleeAttackComponent.Phase.IDLE)
		check(started == [0, 1, 2, 3], "Buffered four-cut chain drops or repeats cuts")
		if "--record" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless": await record_combo(actor, lab, direction, labels[index])
	actor._set_facing_direction(Vector2.RIGHT)
	attack.reset_combo()
	actor.request_primary_attack()
	await until(attack, MeleeAttackComponent.Phase.ACTIVE)
	review.buttons[AXE.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item() == ITEM, "Weapon switch succeeds in active contact")
	actor._clear_buffered_action()
	attack.cancel_attack()
	check(not family.trail.slash_sprite.visible, "Cancelled cut leaks white FX")
	check(actor.request_evade(Vector2.LEFT), "Scythe blocks dodge")
	await process_frame
	check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible, "Dodge leaves two bodies")
	actor.evade_component.cancel_evade()
	check(actor.request_ability(2), "Scythe blocks skills")
	await process_frame
	check(not family.presenter.visible, "Skill fallback leaves the scythe body visible")
	actor.get_active_ability_component().cancel_cast()
	await process_frame
	await hook_collision(actor, lab)
	check(actor.equip_owned_weapon(AXE) and attack.weapon.combo.contact_rule(1) == null, "Switching retains the hook modifier")
	check(actor.equip_owned_weapon(ITEM), "Cannot re-equip the scythe")
	actor._set_facing_direction(Vector2.DOWN)
	await physics_frame
	family.presenter._rest()
	await create_timer(1.3).timeout
	check(family.presenter._resting and family.presenter.definition == family.profile.downward_idle_poses, "Front idle uses the wrong rest animation")
	await capture("idle_down.png")
	lab.queue_free()
	current_scene = null
	await process_frame
	var arena := preload("res://levels/test_arena/test_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	check(arena.player.attack_component.weapon == ITEM.weapon_definition, "Equipped scythe does not travel into Stage I")
	check(arena.player.get_node("WeaponFamilyPresentation").profile == ITEM.weapon_definition.family_presentation, "Campaign does not use the scythe family")
	arena.queue_free()
	current_scene = null
	await process_frame
	FileAccess.open(output + "validation.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checks, "failures": failures, "real_f9_f7": true, "bag": true, "directional_cuts": 16, "campaign_stage": 1}, "\t") + "\n")
	print("IRON_REAPER_GAMEPLAY checks=", checks, " failures=", failures)
	quit(1 if failures else 0)


func hook_collision(actor: Player, lab: Node) -> void:
	actor.position = Vector2(350, 300)
	var light: Rootling = ROOTLING.instantiate()
	light.target = actor
	lab.actors.add_child(light)
	light.position = Vector2(420, 300)
	await create_timer(0.8).timeout
	light.position = Vector2(420, 300)
	light.velocity = Vector2.ZERO
	light.knockback_component.clear()
	var wall := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(8, 60)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector2(400, 300)
	lab.actors.add_child(wall)
	await physics_frame
	var hit := DamageInfo.new(1, actor, Vector2.RIGHT, 16, 0.5)
	ITEM.weapon_definition.combo.contact_rule(1).apply_to_hit(hit, light.get_node("Hurtbox"))
	light.get_node("Hurtbox").receive_hit(hit)
	await create_timer(0.2).timeout
	check(light.position.x >= wall.position.x + 4 and light.position.x < 420, "Hook teleports through a solid wall or fails to move")
	check(420 - light.position.x <= 24.01, "Physical hook exceeds its distance cap")
	light.queue_free()
	wall.queue_free()
	await process_frame


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


func verify_slash(family: Node, label: String, step: int) -> void:
	if DisplayServer.get_name() == "headless": return
	if step == 2:
		await capture("cut_3_" + label + ".png")
		check(is_instance_valid(family.actor.attack_component.released_attack) and not family.trail.slash_sprite.visible, "Throw is missing its detached visual or retains local arcs")
		return
	var all_frames := "--all-slash-frames" in OS.get_cmdline_user_args()
	paused = true
	for ribbon_frame in (range(family.trail.FRAME_COUNT) if all_frames else [0]):
		family.trail._set_frame(ribbon_frame)
		await capture("cut_%d_%s_frame_%d.png" % [step+1,label,ribbon_frame])
		var with_fx := root.get_texture().get_image()
		var unmasked := with_fx
		if all_frames:
			family.trail.slash_sprite.material = null
			await process_frame
			await RenderingServer.frame_post_draw
			unmasked = root.get_texture().get_image()
			family.trail.slash_sprite.material = family.trail.contact_mask
		family.trail.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		var without_fx := root.get_texture().get_image()
		var bright_pixels := 0
		var outside_pixels := 0
		var clipped_pixels := 0
		var to_actor: Transform2D = family.trail.get_global_transform_with_canvas().affine_inverse()
		for y in with_fx.get_height():
			for x in with_fx.get_width():
				var a := with_fx.get_pixel(x,y)
				var b := without_fx.get_pixel(x,y)
				if minf(a.r,minf(a.g,a.b))>0.55 and a.r+a.g+a.b-b.r-b.g-b.b>0.4:
					bright_pixels += 1
					if not Geometry2D.is_point_in_polygon(to_actor*Vector2(x+0.5,y+0.5),family.trail._points): outside_pixels += 1
				if all_frames:
					var raw := unmasked.get_pixel(x,y)
					if raw.r+raw.g+raw.b-b.r-b.g-b.b>0.4 and raw.r+raw.g+raw.b-a.r-a.g-a.b>0.2: clipped_pixels += 1
		check(bright_pixels>30,"White slash missing from %s cut%d frame%d" % [label,step+1,ribbon_frame])
		check(outside_pixels==0,"Opaque white effects exceed the real melee boundary")
		if all_frames: check(clipped_pixels==0,"Contact mask cuts a painted ribbon frame")
		print("REAPER_EFFECT ",label," cut=",step+1," frame=",ribbon_frame," bright=",bright_pixels," outside=",outside_pixels," clipped=",clipped_pixels)
		family.trail.show()
	paused = false


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
		if attack.phase == MeleeAttackComponent.Phase.ACTIVE and attack.combo_step < 3 and queued != attack.combo_step:
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
	camera.zoom = Vector2.ONE*3
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
