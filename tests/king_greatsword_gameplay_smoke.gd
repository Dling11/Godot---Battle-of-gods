extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const ALTERNATIVE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
var OUT := "res://tmp/review/combat/weapon_impact_closure_2026_10_07/greatsword/"
var started: Array[int] = []
var target_hits: Array[Array] = [[],[],[]]
var timeline: Array[Dictionary] = []
var ribbon_rows: Array[Dictionary] = []
var spin_cadence: Array[Dictionary] = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): OUT = arg.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").configure_storage_path_for_testing("user://greatsword_gameplay_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	root.get_node("RunSession").reset_run()
	var snapshot: Dictionary = inventory.create_snapshot()
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	check(not inventory.owns_weapon(ITEM.item_id),"Greatsword was granted to a fresh campaign")
	await key(KEY_F9)
	check(inventory.owns_weapon(ITEM.item_id),"Real F9 did not grant Greatsword")
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
	check(family.trail.get_script().resource_path.ends_with("greatsword_swing.gd"),"New raster landing presenter not installed")
	await capture("weapons_tab.png")
	await key(KEY_TAB)
	var bag: CharacterMenu = lab.get_node("UI/CharacterMenu")
	check(bag.visible,"Tab could not open real Bag")
	bag._on_equipment_selected(ITEM)
	bag.equipment_detail_panel.equip_requested.emit(ITEM)
	check(actor.get_equipped_weapon_item()==ITEM,"Bag equip path does not support Greatsword")
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
			if step<3 and "--all-slash-frames" in OS.get_cmdline_user_args():
				await verify_slash(family,str(direction),step)
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
					check(absf(tip.x-actor.global_position.x)<10,"Vertical finisher lands sideways outside its frontal lane")
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
	# Complete new actors also need a real running/carry/rest handoff. Checking
	# attack sheets alone missed earlier body-size and planted-idle regressions.
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		actor.velocity=direction*75
		await physics_frame
		await physics_frame
		var before_pose: int=family.presenter.pose_index
		await create_timer(.08).timeout
		check(family.presenter.pose_index==before_pose,"Blocked greatsword cycles its gait")
		actor.position+=direction*16
		await physics_frame
		await physics_frame
		check(family.presenter.definition==family.profile.run_for(direction) and family.presenter._running and family.presenter.pose_index!=before_pose,"Greatsword run does not follow real travel")
		actor.velocity=Vector2.ZERO
		await physics_frame
		await physics_frame
		check(family.presenter.definition==family.profile.idle_for(direction),"Stopped greatsword loses carry facing")
		family.presenter._rest_timer.stop()
		family.presenter._rest()
		var rest_until:=Time.get_ticks_msec()+1450
		var maximum_lift:=0.0
		var grip_attached:=true
		while Time.get_ticks_msec()<rest_until:
			await physics_frame
			maximum_lift=maxf(maximum_lift,absf(family.presenter.body_sprite.position.y))
			var hand: Vector2=family.presenter.body_sprite.to_global(family.presenter.definition.primary_hands[family.presenter.pose_index]-Vector2(192,192))
			var hilt: Vector2=family.presenter.weapon_sprite.to_global(family.presenter.definition.weapon_primary_grip)
			grip_attached=grip_attached and hand.distance_to(hilt)<.1
		check(maximum_lift<.01,"Shoulder rest lifts the complete body off the floor")
		check(grip_attached,"Shoulder glove detaches from the canonical hilt")
		check(family.presenter._resting and family.presenter.pose_index==11 and family.presenter.definition.single_hand_poses[11]==1,"Shoulder rest does not settle into its neutral one-hand pose")
		var blade_tip: Vector2=family.presenter.weapon_sprite.to_global(family.presenter.definition.weapon_tip)
		var hilt: Vector2=family.presenter.weapon_sprite.to_global(family.presenter.definition.weapon_primary_grip)
		check(is_equal_approx(blade_tip.distance_to(hilt),56.5),"Shoulder rest shrinks the huge blade")
		check(family.presenter.definition.planting==null and family.presenter.definition.released_poses[11]==0 and not family.presenter.weapon_rig.visible,"Shoulder rest plants/drops or duplicates the baked sword")
		await capture("shoulder_%s.png"%str(direction))
		check(actor.request_primary_attack() and family.presenter._drawing,"Shoulder rest does not retrieve before attacking")
		await until(attack,MeleeAttackComponent.Phase.ACTIVE)
		actor._clear_buffered_action()
		attack.cancel_attack()
		family.presenter.cancel_presentation_transition()
	await verify_spin_cadence(actor,family)
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
		await record_weapon_swaps(actor,lab,review)
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			await record_combo(actor,lab,direction)
			await record_carry(actor,lab,direction)
	# Cancellation, skill fallback, and switching cannot strand FX or bodies.
	attack._next_combo_step = 3
	actor.request_primary_attack()
	await until(attack,MeleeAttackComponent.Phase.ACTIVE)
	actor._clear_buffered_action()
	attack.cancel_attack()
	check(not family.trail.landing_sprite.visible and not family.trail.slash_sprite.visible,"Cancelled jump leaks FX")
	check(actor.request_evade(Vector2.LEFT),"Greatsword blocks evade")
	review.buttons[ALTERNATIVE.item_id].pressed.emit()
	check(actor.get_equipped_weapon_item()==ITEM and actor._pending_weapon_definition==null,"Weapons tab queued a misleading mid-dodge swap")
	await process_frame
	check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Evade duplicates the body")
	actor.evade_component.cancel_evade()
	check(actor.request_ability(2),"Greatsword blocks skills")
	await process_frame
	check(not family.presenter.visible,"Skill fallback duplicates the Greatsword body")
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
	check(stage_player.attack_component.weapon==ITEM.weapon_definition,"Stage I lost the equipped Greatsword")
	check(stage_player.get_node("WeaponFamilyPresentation").presenter.visible,"Campaign Player shows the old sword/body")
	await capture("stage_1_v2.png")
	arena.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	inventory.restore_snapshot(snapshot)
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"engine":Engine.get_version_info().string,"native":DisplayServer.get_name()!="headless","ribbons":ribbon_rows,"spin_cadence":spin_cadence,"scope":"F9/F7, catalog/Bag equip, four-facing contacts/buffering, spin timing and body/ribbon synchronization at base/+50% attack speed, landing, real-distance running, walls, stop/rest/retrieve, cancels, axe swap and Stage I carry"},"\t")+"\n")
	print("GREATSWORD_FINAL: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func verify_spin_cadence(actor: Player,family: Node) -> void:
	var attack:=actor.attack_component
	for bonus in [0.0,.5]:
		attack.set_equipment_attack_speed_bonus(bonus)
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			actor._set_facing_direction(direction)
			family.presenter._rest_timer.stop()
			attack.reset_combo()
			attack._next_combo_step=2
			var phases: Array[Dictionary]=[]
			var observe:=func(phase: int,duration: float) -> void: phases.append({"phase":phase,"seconds":duration})
			attack.phase_changed.connect(observe)
			var start_tick:=Engine.get_physics_frames()
			check(actor.request_primary_attack(),"Quicker spin cannot start")
			var samples: Array[Vector2i]=[]
			var deadline:=Time.get_ticks_msec()+6000
			while attack.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline:
				await physics_frame
				if attack.phase==MeleeAttackComponent.Phase.ACTIVE:
					var body: int=family.presenter.pose_index
					var slash: int=family.trail._frame
					check(body>=4 and body<=11 and family.trail._row==2 and family.trail.slash_sprite.visible,"Quicker spin lost its active body/slash")
					check(absi(body-4-slash/2)<=1,"Spin body and white slash run on different clocks")
					samples.append(Vector2i(body,slash))
			attack.phase_changed.disconnect(observe)
			var elapsed:=float(Engine.get_physics_frames()-start_tick)/Engine.physics_ticks_per_second
			check(attack.phase==MeleeAttackComponent.Phase.IDLE and phases.size()==3,"Quicker spin stalled or repeated a phase")
			for index in phases.size():
				check(phases[index].phase==index+1 and is_equal_approx(phases[index].seconds,[.14,.18,.14][index]/(1.0+bonus)),"Spin phase does not follow the faster authored cadence/equipment speed")
			check(absf(elapsed-.46/(1.0+bonus))<=2.0/Engine.physics_ticks_per_second,"Actual spin does not finish within its faster physics clock")
			check(samples.size()>=4 and samples.back().x>samples.front().x and samples.back().y>samples.front().y,"Quicker spin freezes/skips its full rotation")
			check(not family.trail.slash_sprite.visible,"Spin leaves a slash after recovery")
			spin_cadence.append({"view":str(direction),"attack_speed_bonus":bonus,"measured_seconds":elapsed,"phases":phases,"body_slash_samples":samples})
	attack.set_equipment_attack_speed_bonus(0.0)

func record_weapon_swaps(actor: Player,lab: Node,review: Node) -> void:
	var scythe: EquipmentDefinition=load("res://data/items/equipment/king_iron_reaper.tres")
	# Exercise the same actual Weapons buttons used for the owner's comparison.
	lab.get_node("UI").hide()
	lab.camera.enabled=true
	lab.camera.zoom=Vector2.ONE*2.5
	lab.camera.position_smoothing_enabled=false
	actor.position=Vector2(320,300)
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var label: String="right" if direction==Vector2.RIGHT else ("left" if direction==Vector2.LEFT else ("up" if direction==Vector2.UP else "down"))
		for item: EquipmentDefinition in [scythe,ITEM]:
			review.buttons[item.item_id].pressed.emit()
			check(actor.get_equipped_weapon_item()==item,"Rapid weapon comparison cannot equip current item")
			actor._set_facing_direction(direction)
			await physics_frame
			actor.get_node("WeaponFamilyPresentation").presenter._rest_timer.stop()
			await capture("swap_%s_%s.png"%[label,"scythe" if item==scythe else "greatsword"])
	lab.camera.zoom=Vector2.ONE
	lab.camera.enabled=false
	lab.get_node("UI").show()

func verify_slash(family: Node,label: String,step: int) -> void:
	if DisplayServer.get_name()=="headless": return
	paused=true
	var trail: Node2D=family.trail
	for frame in (16 if step==2 else 8):
		trail._set_frame(frame)
		await process_frame
		await RenderingServer.frame_post_draw
		var masked:=root.get_texture().get_image()
		trail.slash_sprite.material=null
		await process_frame
		await RenderingServer.frame_post_draw
		var raw:=root.get_texture().get_image()
		trail.slash_sprite.material=trail.contact_mask
		trail.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		var none:=root.get_texture().get_image()
		var bright:=0
		var outside:=0
		var clipped:=0
		var inverse:=trail.get_global_transform_with_canvas().affine_inverse()
		var area:=Rect2()
		var transform: Transform2D=trail.slash_sprite.get_global_transform_with_canvas()
		for corner in [Vector2(-128,-128),Vector2(128,-128),Vector2(-128,128),Vector2(128,128)]:
			var point: Vector2=transform*corner
			area=Rect2(point,Vector2.ONE) if area.size==Vector2.ZERO else area.expand(point)
		var scan:=Rect2i(area.grow(2)).intersection(Rect2i(Vector2i.ZERO,masked.get_size()))
		for y in range(scan.position.y,scan.end.y):
			for x in range(scan.position.x,scan.end.x):
				var a:=masked.get_pixel(x,y)
				var b:=none.get_pixel(x,y)
				var c:=raw.get_pixel(x,y)
				if minf(a.r,minf(a.g,a.b))>.55 and a.r+a.g+a.b-b.r-b.g-b.b>.4:
					bright+=1
					if not Geometry2D.is_point_in_polygon(inverse*Vector2(x+.5,y+.5),trail._points): outside+=1
				if c.r+c.g+c.b-b.r-b.g-b.b>.4 and c.r+c.g+c.b-a.r-a.g-a.b>.2: clipped+=1
		check(bright>0,"Missing greatsword painted stroke %s/%d/%d"%[label,step,frame])
		check(outside==0,"Greatsword stroke exceeds real contact")
		check(clipped==0,"Greatsword contact mask cuts painted stroke")
		ribbon_rows.append({"view":label,"cut":step,"frame":frame,"bright":bright,"outside":outside,"clipped":clipped})
		trail.show()
	paused=false

func record_carry(actor: Player,lab: Node,direction: Vector2) -> void:
	lab.get_node("UI").hide()
	actor.position=Vector2(320,300)
	actor._set_facing_direction(direction)
	var camera: Camera2D=lab.camera
	camera.enabled=true
	camera.zoom=Vector2.ONE*2.5
	camera.position_smoothing_enabled=false
	var label: String="right" if direction==Vector2.RIGHT else ("left" if direction==Vector2.LEFT else ("up" if direction==Vector2.UP else "down"))
	var family: Node=actor.get_node("WeaponFamilyPresentation")
	for mode: String in ["run","idle"]:
		var folder: String=OUT+mode+"_"+label+"/"
		DirAccess.make_dir_recursive_absolute(folder)
		var entries: Array[Dictionary]=[]
		if mode=="idle": family.presenter._rest()
		var start:=Time.get_ticks_msec()
		var previous:=start
		while Time.get_ticks_msec()-start<(1250 if mode=="run" else 6500):
			await physics_frame
			var now:=Time.get_ticks_msec()
			if mode=="run":
				actor.velocity=direction*75
				actor.move_and_collide(direction*75*minf((now-previous)/1000.0,.05))
			previous=now
			await process_frame
			await RenderingServer.frame_post_draw
			var file:="frame_%03d.png"%entries.size()
			root.get_texture().get_image().save_png(folder+file)
			entries.append({"file":file,"elapsed_ms":Time.get_ticks_msec()-start,"pose":family.presenter.pose_index})
		actor.velocity=Vector2.ZERO
		await physics_frame
		await physics_frame
		FileAccess.open(folder+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(entries,"\t")+"\n")
	family.presenter.cancel_presentation_transition()
	camera.enabled=false
	camera.zoom=Vector2.ONE
	lab.get_node("UI").show()

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
