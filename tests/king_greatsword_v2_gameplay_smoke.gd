extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword_v2.tres")
const ALTERNATIVE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
var OUT := "res://tmp/review/combat/weapon_impact_closure_2026_10_07/greatsword/"
var started: Array[int] = []
var target_hits: Array[Array] = [[],[],[]]
var timeline: Array[Dictionary] = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): OUT = arg.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").configure_storage_path_for_testing("user://greatsword_v2_gameplay_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	root.get_node("RunSession").reset_run()
	var snapshot: Dictionary = inventory.create_snapshot()
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	check(not inventory.owns_weapon(ITEM.item_id),"V2 was granted to a fresh campaign")
	await key(KEY_F9)
	check(inventory.owns_weapon(ITEM.item_id),"Real F9 did not grant V2")
	await key(KEY_F7)
	var deadline := Time.get_ticks_msec()+15000
	while current_scene==hub and Time.get_ticks_msec()<deadline: await process_frame
	check(current_scene!=hub and current_scene!=null,"Real F7 could not enter Combat Lab")
	if current_scene==hub or current_scene==null: quit(1); return
	var lab: Node = current_scene
	await process_frame
	await process_frame
	lab.clear_simulation()
	var actor: Player = lab.player
	actor.set_physics_process(false)
	var attack := actor.attack_component
	var feedback := CombatFeedbackPresenter.find_for_player(actor)
	if feedback!=null: feedback.hitstop_enabled = false
	check(lab.review_tabs.get_tab_count()==3,"Weapons tab missing")
	lab.review_tabs.current_tab = 2
	var review: Node = lab.review_tabs.get_child(2)
	check(review.buttons.size()==actor.weapon_catalog.weapons.size(),"Tab omits catalog weapons")
	await key(KEY_F9)
	check(lab.review_tabs.current_tab==2,"F9 navigated away from Weapons")
	for item: EquipmentDefinition in actor.weapon_catalog.weapons:
		review.buttons[item.item_id].pressed.emit()
		check(actor.get_equipped_weapon_item()==item,"Tab cannot equip "+item.display_name)
		await process_frame
	review.buttons[ITEM.item_id].pressed.emit()
	await process_frame
	var family := actor.get_node("WeaponFamilyPresentation")
	check(family.presenter.weapon_sprite.texture.get_size()==Vector2(30,140),"Original huge steel changed")
	check(family.trail.get_script().resource_path.ends_with("greatsword_v2_swing.gd"),"New raster landing presenter not installed")
	await capture("weapons_tab.png")
	await key(KEY_TAB)
	var bag: CharacterMenu = lab.get_node("UI/CharacterMenu")
	check(bag.visible,"Tab could not open real Bag")
	bag._on_equipment_selected(ITEM)
	bag.equipment_detail_panel.equip_requested.emit(ITEM)
	check(actor.get_equipped_weapon_item()==ITEM,"Bag equip path does not support V2")
	await capture("bag_v2.png")
	await key(KEY_ESCAPE)
	check(not bag.visible and not paused,"Bag close did not restore playable controls")
	actor.set_process_unhandled_input(false)
	attack.configure_random_seed_for_testing(52)
	attack.attack_started.connect(func() -> void: started.append(attack.combo_step))
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor.position = Vector2(320,300)
		actor._set_facing_direction(direction)
		family.presenter._rest_timer.stop()
		attack.reset_combo()
		started.clear()
		check(actor.request_primary_attack(),"Primary input rejected")
		for step in 4:
			await until(attack,MeleeAttackComponent.Phase.ACTIVE)
			check(attack.combo_step==step and attack.get_attack_direction()==direction,"Combo step or facing changed")
			var clip: Resource = ITEM.weapon_definition.family_presentation.attack_for(direction)
			check(family.presenter.definition==(clip if step==0 else clip.follow_up_clips[step-1]),"Wrong directional body clip")
			if step<3: check(actor.request_primary_attack(),"Buffered continuation rejected")
			else:
				check(family.presenter.hand_sprite.visible==(direction!=Vector2.UP),"Upward landing draws front hands over King's back")
				check(family.presenter.definition.hands_are_occluded(family.presenter.pose_index)==(direction==Vector2.UP),"Wrong landing occlusion data")
				check(family.trail.landing_sprite.visible,"Jump has no landing burst at contact")
				var point: Vector2 = family.trail.last_landing_world
				if absf(direction.x)>0:
					check(absf(point.y-actor.global_position.y+.5)<.1,"Blade lands below or above the ground plane")
				else:
					var tip: Vector2 = family.presenter.weapon_sprite.to_global(family.presenter.definition.weapon_tip)
					check(point.distance_to(tip)<.1,"Vertical ground contact does not match the rendered blade tip")
					check((family.trail.slash_sprite.texture as AtlasTexture).atlas==family.trail.VerticalSlash,"Vertical jump still rotates the side slash")
					check((family.trail.landing_sprite.texture as AtlasTexture).atlas==family.trail.VerticalLanding,"Vertical jump still uses a side-on ground burst")
					check(is_zero_approx(family.trail.slash_sprite.rotation),"Authored vertical cleave was rotated out of its camera plane")
					check(family.trail._landing_row==(0 if direction.y<0 else 1),"Wrong rear/front floor-impact row")
				await until(attack,MeleeAttackComponent.Phase.RECOVERY)
				check(family.trail.landing_sprite.visible and family.trail.last_landing_world==point,"Ground impact disappeared at recovery or followed King")
			if step<3: await next_step(attack,step+1)
		await until(attack,MeleeAttackComponent.Phase.IDLE)
		check(started==[0,1,2,3],"Four-cut input chain skipped or repeated a move")
		check(not family.trail.landing_sprite.visible,"Landing effect leaked after the combo")
	check(family.trail.landing_count==4,"Jump impact played more than once per strike")
	# Actual target contact: front cuts stay frontal, only spin reaches behind.
	var targets: Array[Node2D] = []
	for index in 3:
		var target: Node2D = TARGET.instantiate()
		lab.actors.add_child(target)
		target.get_node("HealthComponent").set_maximum_health(10000,false)
		target.get_node("HealthComponent").set_current_health(10000)
		target.get_node("HealthComponent").damaged.connect(func(info: DamageInfo) -> void: target_hits[index].append(info))
		targets.append(target)
	for step in 4:
		for hits in target_hits: hits.clear()
		actor.position = Vector2(320,300)
		actor._set_facing_direction(Vector2.RIGHT)
		family.presenter._rest_timer.stop()
		targets[0].position = actor.position+Vector2(65,0)
		targets[1].position = actor.position+Vector2(-80 if step==2 else -40,0)
		targets[2].position = actor.position+Vector2(160,0)
		await physics_frame
		attack.reset_combo()
		attack._next_combo_step = step
		check(actor.request_primary_attack(),"Target test attack failed")
		await until(attack,MeleeAttackComponent.Phase.IDLE)
		check(target_hits[0].size()==1,"Front target contact was missed or repeated at step "+str(step))
		check(target_hits[1].size()==(1 if step==2 else 0),"Rear target contact does not match radial spin")
		check(target_hits[2].is_empty(),"Attack hits outside the declared range")
		if not target_hits[0].is_empty():
			var info: DamageInfo = target_hits[0][0]
			check(info.damage_type==DamageInfo.DamageType.PHYSICAL,"Wrong damage type")
			check(is_equal_approx(info.knockback_strength,48.0*attack.weapon.combo.knockback_multipliers[step]),"Wrong per-cut knockback")
	for target in targets: target.queue_free()
	for hits in target_hits: hits.clear()
	await process_frame
	# New jump cels actually leave the ground, with both palms on the hilt.
	actor.position = Vector2(320,300)
	actor._set_facing_direction(Vector2.RIGHT)
	family.presenter._rest_timer.stop()
	attack.reset_combo()
	attack._next_combo_step = 3
	check(actor.request_primary_attack(),"Jump-only test rejected")
	await create_timer(.18).timeout
	check(family.presenter.definition.lift_pixels[family.presenter.pose_index]<-10,"Jump lacks an airborne load")
	check(not family.trail.landing_sprite.visible,"Impact appeared before landing")
	await capture("jump_airborne.png")
	await until(attack,MeleeAttackComponent.Phase.ACTIVE)
	check(family.presenter.definition.lift_pixels[family.presenter.pose_index]==0,"Contact occurs while King is airborne")
	await capture("jump_landing.png")
	await until(attack,MeleeAttackComponent.Phase.IDLE)
	# Physical stepping cannot push King through a solid obstacle.
	var wall := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(8,80)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = actor.position+Vector2(18,0)
	lab.actors.add_child(wall)
	await physics_frame
	var before := actor.position
	attack.reset_combo()
	actor.request_primary_attack()
	await until(attack,MeleeAttackComponent.Phase.ACTIVE)
	check(family.steps.blocked and actor.position.x<wall.position.x,"Forward step crossed a solid wall")
	check(actor.position.distance_to(before)<8,"Blocked attack still completed its full step")
	check(is_zero_approx(attack.weapon.get_attack_movement_ratio(attack.phase)),"Contact permits walking with a heavy swing")
	review.buttons[ALTERNATIVE.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item()==ITEM,"Weapons tab swaps mid-contact")
	await until(attack,MeleeAttackComponent.Phase.RECOVERY)
	check(is_equal_approx(attack.weapon.get_attack_movement_ratio(attack.phase),.6),"Recovery movement changed")
	await until(attack,MeleeAttackComponent.Phase.IDLE)
	wall.queue_free()
	await process_frame
	if OS.get_cmdline_user_args().has("--record") and DisplayServer.get_name()!="headless":
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			await record_combo(actor,lab,direction)
	# Cancellation, skill fallback, and switching cannot strand FX or bodies.
	attack._next_combo_step = 3
	actor.request_primary_attack()
	await until(attack,MeleeAttackComponent.Phase.ACTIVE)
	actor._clear_buffered_action()
	attack.cancel_attack()
	check(not family.trail.landing_sprite.visible and not family.trail.slash_sprite.visible,"Cancelled jump leaks FX")
	check(actor.request_evade(Vector2.LEFT),"V2 blocks evade")
	review.buttons[ALTERNATIVE.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item()==ITEM and actor._pending_weapon_definition==null,"Weapons tab queued a misleading mid-dodge swap")
	await process_frame
	check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Evade duplicates the body")
	actor.evade_component.cancel_evade()
	check(actor.request_ability(2),"V2 blocks skills")
	await process_frame
	check(not family.presenter.visible,"Skill fallback duplicates the V2 body")
	actor.get_active_ability_component().cancel_cast()
	await process_frame
	actor.set_cinematic_locked(true)
	review.buttons[ALTERNATIVE.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item()==ITEM,"Weapons tab swaps during a cinematic lock")
	actor.set_cinematic_locked(false)
	check(actor.equip_owned_weapon(ALTERNATIVE),"Cannot switch from the accepted Greatsword to axe")
	check(attack.weapon.combo.step_count()==5 and family.profile==ALTERNATIVE.weapon_definition.family_presentation,"Weapon swap retained the retired Greatsword profile")
	check(inventory.can_restore_snapshot(snapshot) and inventory.restore_snapshot(snapshot),"Old inventory snapshot cannot restore")
	DirAccess.make_dir_recursive_absolute(OUT)
	lab.queue_free()
	current_scene = null
	await process_frame
	# The same item travels into an ordinary campaign Player/arena.
	inventory.acquire_weapon(ITEM)
	inventory.equip_weapon(&"king",&"warrior",ITEM)
	var arena := preload("res://levels/test_arena/test_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	var stage_player: Player = arena.player
	stage_player.set_physics_process(false)
	stage_player.set_process_unhandled_input(false)
	stage_player._set_facing_direction(Vector2.RIGHT)
	check(stage_player.attack_component.weapon==ITEM.weapon_definition,"Stage I lost the equipped V2")
	check(stage_player.get_node("WeaponFamilyPresentation").presenter.visible,"Campaign Player shows the old sword/body")
	await capture("stage_1_v2.png")
	arena.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	inventory.restore_snapshot(snapshot)
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"engine":Engine.get_version_info().string,"native":DisplayServer.get_name()!="headless","scope":"F9/F7, current catalog/Bag equip, four-facing contacts/buffering, landing, collision steps, cancels, axe swap and Stage I carry"},"\t")+"\n")
	print("GREATSWORD_V2_FINAL: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func record_combo(actor: Player,lab: Node,direction: Vector2) -> void:
	# Capture the actual Player/FX/physics clock, with enlarged camera only.
	lab.get_node("UI").hide()
	var camera: Camera2D = lab.camera
	camera.enabled = true
	camera.zoom = Vector2.ONE*2.5
	camera.position_smoothing_enabled = false
	actor.position = Vector2(320,300)
	actor._set_facing_direction(direction)
	var family := actor.get_node("WeaponFamilyPresentation")
	family.presenter._rest_timer.stop()
	var attack := actor.attack_component
	attack.reset_combo()
	var record_started := Time.get_ticks_msec()
	var frame := 0
	var queued_step := -1
	var output := OUT
	if direction!=Vector2.RIGHT:
		output += ("left/" if direction==Vector2.LEFT else "up/" if direction==Vector2.UP else "down/")
	var folder := output+"motion_frames/"
	DirAccess.make_dir_recursive_absolute(folder)
	actor.request_primary_attack()
	while (attack.phase!=MeleeAttackComponent.Phase.IDLE or frame<1) and Time.get_ticks_msec()-record_started<6000:
		if attack.phase==MeleeAttackComponent.Phase.ACTIVE and attack.combo_step<3 and queued_step!=attack.combo_step:
			actor.request_primary_attack()
			queued_step = attack.combo_step
		await process_frame
		await RenderingServer.frame_post_draw
		var filename := "motion_frames/frame_%03d.png" % frame
		root.get_texture().get_image().save_png(output+filename)
		timeline.append({"file":filename,"elapsed_ms":Time.get_ticks_msec()-record_started,"cut":attack.combo_step,"phase":attack.phase,"pose":family.presenter.pose_index})
		frame += 1
	check(queued_step==2 and attack.phase==MeleeAttackComponent.Phase.IDLE,"Recorded actual combo did not complete")
	FileAccess.open(output+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	timeline.clear()
	camera.enabled = false
	camera.zoom = Vector2.ONE
	lab.get_node("UI").show()

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

func until(attack: MeleeAttackComponent,phase: int) -> void:
	var deadline := Time.get_ticks_msec()+6000
	while attack.phase!=phase and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==phase,"Timed out waiting for phase "+str(phase))

func next_step(attack: MeleeAttackComponent,step: int) -> void:
	var deadline := Time.get_ticks_msec()+6000
	while (attack.combo_step!=step or attack.phase==MeleeAttackComponent.Phase.IDLE) and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.combo_step==step and attack.phase!=MeleeAttackComponent.Phase.IDLE,"Buffered cut timed out")

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file)==OK,"Capture failed")
