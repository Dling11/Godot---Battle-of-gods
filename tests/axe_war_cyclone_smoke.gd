extends SceneTree

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const PLAYER = preload("res://entities/player/player.tscn")
const TARGET = preload("res://entities/training/training_target.tscn")
const OUT := "res://tmp/test_logs/war_cyclone/"
var checks := 0
var failures := 0
var hits: Dictionary = {}
var pulses: Array[int] = []
var targets: Array[Node2D] = []

func _initialize() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS,true)
	call_deferred("_run")

func _run() -> void:
	AudioServer.set_bus_mute(0,true)
	root.content_scale_size = Vector2i(960,540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.size = Vector2i(1920,1080) if DisplayServer.get_name()!="headless" else Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(OUT)
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing("user://axe_war_cyclone_smoke.json"),"Cannot isolate profile")
	save.delete_profile()
	save.suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.get_node("WeaponInventory").reset_inventory()
	var fresh: Player = PLAYER.instantiate()
	root.add_child(fresh)
	fresh.set_physics_process(false)
	check(not fresh.war_cyclone.is_available() and not fresh.request_weapon_technique(),"Fresh character receives an unearned technique")
	fresh.queue_free()
	await process_frame
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await settle()
	lab.clear_simulation()
	lab._set_examiner_arena(false)
	var actor: Player = lab.player
	actor.set_physics_process(false)
	actor._debug_unlimited_skills = false
	actor.position = Vector2(350,300)
	actor.movement_bounds = Rect2(40,92,650,390)
	actor.velocity = Vector2.ZERO
	var cyclone: WarCycloneComponent = actor.war_cyclone
	var axe: EquipmentDefinition = actor.weapon_catalog.find_weapon(&"weapon_king_iron_beard_axe")
	root.get_node("WeaponInventory").acquire_weapon(axe)
	check(not cyclone.is_available(),"Sword exposes Axe technique")
	check(actor.equip_owned_weapon(axe),"Cannot equip owned axe")
	await settle()
	check(cyclone.is_available() and lab.combat_hud.weapon_technique_dock.visible,"Axe F1 slot is not discoverable")
	check(lab.combat_hud.weapon_technique_dock.slot.key_label.text=="F1","Technique overwrites King skill bindings")
	check(actor.request_ability(1) and actor.is_targeting_any_ability(),"Skill1 cannot prepare its uncommitted target")
	check(actor.request_ability(2) and not actor.is_targeting_any_ability(),"Skill2 cannot replace an unconfirmed Skill1 target")
	for ability in actor.get_all_ability_components():
		ability.cancel_cast()
		ability.clear_cooldown()
	check(actor.request_ability(1) and actor.is_targeting_any_ability(),"Skill1 target cannot be prepared for F1 switch")
	check(actor.request_weapon_technique() and not actor.is_targeting_any_ability(),"F1 cannot replace an unconfirmed Skill1 target")
	cyclone.cancel_cast()
	cyclone.clear_cooldown()
	var card: Dictionary = lab.combat_hud.weapon_technique_dock._tooltip()
	check(card.facts.contains("150.0") and card.facts.contains("30.0") and card.facts.contains("50%"),"Cyclone tooltip confuses total/DPS and protection values")
	cyclone.strike_started.connect(func(index: int,_count: int,_duration: float) -> void: pulses.append(index))
	cyclone.hit_landed.connect(_record_hit)
	for offset in [Vector2(50,0),Vector2(-50,0),Vector2(0,-50),Vector2(0,50),Vector2(35,35),Vector2(130,0)]:
		var target: Node2D = TARGET.instantiate()
		target.get_node("HealthComponent").maximum_health = 10000
		lab.actors.add_child(target)
		target.global_position = actor.global_position+offset
		targets.append(target)
	targets[4].get_node("HealthComponent").armor_rating = 100.0
	await settle()
	var visual := actor.get_node("VisualRoot/WarCycloneVisual")
	var twister := (cyclone.definition as WarCycloneDefinition).motion_atlas.get_image()
	check(twister.get_size()==Vector2i(1024,1024),"Final paired motion atlas has an invalid grid")
	var tuning := cyclone.definition as WarCycloneDefinition
	check(tuning.outer_atlas.get_size()==Vector2(320,320) and tuning.ground_atlas.get_size()==Vector2(1024,512),"Final outer/C-contact grids are invalid")
	var ground_image := tuning.ground_atlas.get_image()
	for key in 16:
		var paint := twister.get_region(Rect2i(Vector2i(key%4,key/4)*256,Vector2i(256,256))).get_used_rect()
		check(paint.has_area() and Rect2i(24,24,208,208).encloses(paint),"Paired motion has missing or edge-clipped paint")
	for key in 8:
		var paint := ground_image.get_region(Rect2i(Vector2i(key%4,key/4)*256,Vector2i(256,256))).get_used_rect()
		check(paint.has_area() and Rect2i(16,16,224,224).encloses(paint),"C contact has missing or clipped paint")
	_check_motion_direction(twister)
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		cyclone.clear_cooldown()
		actor._set_facing_direction(direction)
		var start_tick := Engine.get_physics_frames()
		check(actor.request_weapon_technique(),"Directional cast rejected")
		await phase(cyclone,AbilityComponent.Phase.ACTIVE)
		check(Engine.get_physics_frames()-start_tick<=4,"Cyclone activation still has a long windup")
		await physics_frame
		check(visual.visible and visual.spin_body.visible and not visual.body.visible,"Twister is absent or overlaps the old actor")
		check(not actor.get_node("VisualRoot/Body").visible and not actor.get_node("WeaponFamilyPresentation").presenter.visible,"Two King bodies render during technique")
		check(visual.spin_body.texture == tuning.motion_atlas,"Active spin does not use the accepted paired artwork")
		check(visual.spin_body.scale == Vector2(.5,.5) and visual.spin_body.position==Vector2(0,-21) and not visual.spin_body.flip_h,"Paired motion loses its half-density foot pivot or mirrors the full turn")
		check(visual.ground.visible and is_equal_approx(visual.ground.modulate.a,.76),"Selected C contact is missing or overbright")
		check(visual.slash.texture==tuning.outer_atlas and visual.front_slash.texture==tuning.outer_atlas,"Outer layers use different/rejected templates")
		var seen_headings: Dictionary = {}
		var transitions := 0
		var previous_pose: int = visual.spin_body.frame
		var spin_deadline := Time.get_ticks_msec()+520
		while Time.get_ticks_msec()<spin_deadline:
			await physics_frame
			seen_headings[visual.spin_body.frame] = true
			if visual.spin_body.frame!=previous_pose:
				transitions += 1
				previous_pose = visual.spin_body.frame
		check(seen_headings.size()==16,"Paired spin stays frozen or omits authored phases")
		check(transitions>=22,"Paired spin does not keep the accepted quick cadence")
		if DisplayServer.get_name()!="headless":
			check(visual.audio.loop.playing and visual._contact.playing,"Native loop/contact audio is absent")
		await capture("active_"+str(direction)+".png")
		cyclone.cancel_cast()
		await settle()
		check(not visual.visible and actor.get_node("WeaponFamilyPresentation").presenter.visible,"Cancellation loses normal Axe presentation")
		check(not visual.is_physics_processing(),"Hidden Cyclone animation keeps updating")
		check(not actor.health_component._incoming_damage_modifiers.has(WarCycloneComponent.GUARD_KEY),"Cancelled Cyclone leaks incoming protection")
	# A complete channel hits each reachable target once per revolution.
	cyclone.clear_cooldown()
	hits.clear()
	pulses.clear()
	var initial_health: float = targets[0].get_node("HealthComponent").current_health
	var armored_health: float = targets[4].get_node("HealthComponent").current_health
	check(actor.request_weapon_technique(),"Baseline channel rejected")
	await idle(cyclone)
	check(not visual.visible and actor.get_node("WeaponFamilyPresentation").presenter.visible,"Natural finish loses the normal weapon actor")
	check(pulses.size()==10,"Baseline does not make ten complete turns")
	for index in 5:
		check(hits.get(targets[index].get_node("Hurtbox").get_instance_id(),0)==10,"Target receives duplicate/missing turn damage")
	check(hits.get(targets[5].get_node("Hurtbox").get_instance_id(),0)==0,"Damage exceeds authored range")
	check(is_equal_approx(initial_health-targets[0].get_node("HealthComponent").current_health,150.0),"Baseline Physical total is not150")
	check(is_equal_approx(armored_health-targets[4].get_node("HealthComponent").current_health,75.0),"Cyclone bypasses ordinary armor")
	check(not actor.request_weapon_technique(),"Cooldown accepts a second cast")
	check(cyclone.cooldown_remaining > 9.0,"Cooldown is silently removed")
	actor.attack_component.set_equipment_attack_speed_bonus(.5)
	cyclone.clear_cooldown()
	pulses.clear()
	var haste_health: float = targets[0].get_node("HealthComponent").current_health
	check(actor.request_weapon_technique(),"Haste cast rejected")
	await phase(cyclone,AbilityComponent.Phase.ACTIVE)
	var started := Time.get_ticks_msec()
	await idle(cyclone)
	var seconds := (Time.get_ticks_msec()-started)/1000.0
	check(pulses.size()==15,"Attack speed does not increase contact cadence")
	check(is_equal_approx(haste_health-targets[0].get_node("HealthComponent").current_health,150.0),"Haste must distribute the same total budget across more pulses")
	check(seconds > 4.9 and seconds < 6.1,"Attack speed shortens the five-second channel")
	actor.attack_component.set_equipment_attack_speed_bonus(0)
	# Repressing F1 acknowledges use, never cancels/restarts duration or damage.
	cyclone.clear_cooldown()
	pulses.clear()
	check(actor.request_weapon_technique(),"Repeated-key cast rejected")
	await phase(cyclone,AbilityComponent.Phase.ACTIVE)
	var elapsed_before := cyclone.active_elapsed
	var cooldown_before := cyclone.cooldown_remaining
	check(actor.request_weapon_technique(),"Second F1 cannot acknowledge an active cast")
	check(cyclone.phase==AbilityComponent.Phase.ACTIVE and cyclone.active_elapsed>=elapsed_before and cyclone.cooldown_remaining<=cooldown_before,"Second F1 stops/restarts spin or cooldown")
	if DisplayServer.get_name()!="headless": check(visual.audio.cue.playing,"Repeated F1 has no on-use cue")
	await phase(cyclone,AbilityComponent.Phase.RECOVERY)
	check(visual.body.visible and not visual.spin_body.visible,"Finishing loses the ordinary Axe settle or overlaps paired motion")
	await idle(cyclone)
	check(pulses.size()==10,"Repeated F1 changed the full-duration pulse budget")
	cyclone.clear_cooldown()
	check(actor.request_weapon_technique(),"Dodge test cast rejected")
	await phase(cyclone,AbilityComponent.Phase.ACTIVE)
	check(not actor.set_weapon_definition(actor.weapon_catalog.default_weapon.weapon_definition),"Weapon swaps during channel")
	check(actor.request_evade(Vector2.RIGHT),"Space cannot dodge-cancel")
	check(not cyclone.is_casting() and not visual.visible,"Dodge leaves technique/contact active")
	await wait_seconds(.8)
	# Owner-selected ACTIVE guard halves all types and rejects stun/flinch.
	cyclone.clear_cooldown()
	check(actor.request_weapon_technique(),"Interruption cast rejected")
	await phase(cyclone,AbilityComponent.Phase.ACTIVE)
	var health := actor.health_component
	var defenses := Vector3(health.armor_rating,health.ward_reduction_ratio,health.magic_resistance_rating)
	health.is_damage_immune = false
	health.set_invulnerable(false)
	health.set_equipment_defenses(100.0,.2,100.0)
	health.set_temporary_shield(0)
	var effects: Control = lab.combat_hud.status_presenter.effect_strip
	check(effects._effects.has(&"cyclone_guard"),"Active protection has no visible status/hover card")
	for kind in [DamageInfo.DamageType.PHYSICAL,DamageInfo.DamageType.MAGIC,DamageInfo.DamageType.PURE]:
		var before := health.current_health
		var hit := DamageInfo.new(20,null,Vector2.RIGHT,0,.2,true,.4,kind)
		var expected := health.resolve_damage(20,kind)*.5
		check(health.apply_damage(hit),"Guard accidentally blocks the entire incoming hit")
		check(is_equal_approx(before-health.current_health,expected),"50%% active reduction is incorrect for damage type%d" % kind)
		check(hit.raw_amount==20 and hit.is_critical and hit.damage_type==kind,"Guard destroys incoming type/raw/critical metadata")
		check(cyclone.has_guard() and not actor.is_in_hit_recovery() and not actor.stagger_component.is_stunned(),"Incoming stun/flinch interrupts protected spin")
		if DisplayServer.get_name()!="headless":
			var feedback := CombatFeedbackPresenter.find_for_player(actor)
			check(feedback!=null and not feedback._hitstop_active,"Guarded hits stall the continuous spin")
	var before_shield := health.current_health
	health.set_temporary_shield(5)
	health.apply_damage(DamageInfo.new(20,null,Vector2.RIGHT))
	check(is_equal_approx(health.shield_health,1.0) and is_equal_approx(health.current_health,before_shield),"Guard reduction must compose before temporary shield")
	health.set_temporary_shield(0)
	var absorbed: Array[float] = []
	health.damage_absorber = func(hit: DamageInfo) -> bool: absorbed.append(hit.amount); return true
	health.apply_damage(DamageInfo.new(20,null,Vector2.RIGHT))
	check(absorbed.size()==1 and is_equal_approx(absorbed[0],4.0),"Cyclone replaces another guard/absorber")
	health.damage_absorber = Callable()
	check(not cyclone.definition.grants_invulnerability and not cyclone.definition.grants_super_armor,"Guard grants whole-cast invulnerability/superarmor")
	cyclone.cancel_cast()
	await settle()
	check(not effects._effects.has(&"cyclone_guard"),"Inactive Cyclone retains a guard status")
	var after_guard := health.current_health
	health.apply_damage(DamageInfo.new(20,null,Vector2.RIGHT,0,.2,false,.2))
	check(is_equal_approx(after_guard-health.current_health,health.resolve_damage(20)) and actor.stagger_component.is_stunned(),"Guard reduction/stun immunity leaks outside ACTIVE")
	health.set_equipment_defenses(defenses.x,defenses.y,defenses.z)
	await wait_seconds(.5)
	# Interacting must not release a buffered King power after cancellation.
	cyclone.clear_cooldown()
	check(actor.request_weapon_technique(),"Interaction test cast rejected")
	await phase(cyclone,AbilityComponent.Phase.ACTIVE)
	actor._buffer_action(Player.BufferedAction.ABILITY,Vector2.RIGHT,1)
	actor.begin_interaction(actor.global_position+Vector2.RIGHT)
	check(not actor.is_any_ability_casting() and actor._buffered_action==Player.BufferedAction.NONE,"NPC interaction releases a buffered attack")
	actor.finish_interaction()
	await settle()
	# Manual steering uses normal movement/collision authority.
	# Clear earlier damage dummies: the quicker cast reaches their colliders
	# before the wall and must not mistake a dummy contact for a wall failure.
	for target in targets: target.queue_free()
	targets.clear()
	await settle()
	cyclone.clear_cooldown()
	actor.position = Vector2(350,300)
	actor.velocity = Vector2.ZERO
	check(actor.request_weapon_technique(),"Steering cast rejected")
	await phase(cyclone,AbilityComponent.Phase.ACTIVE)
	actor.set_physics_process(true)
	actor.combat_targeting.request_click_move(actor.global_position+Vector2(180,0))
	await wait_seconds(.2)
	check(actor.global_position.x>360,"Right-click movement is ignored during steerable Cyclone")
	actor.combat_targeting.cancel_click_move()
	Input.action_press("player_move_right")
	await wait_seconds(.3)
	check(actor.velocity.x > actor.movement_component.max_speed*.85 and actor.velocity.x <= actor.movement_component.max_speed*.90+.1,"Cyclone steering does not reach its quicker90% movement speed")
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 2
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(10,150)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	lab.actors.add_child(wall)
	wall.global_position = actor.global_position+Vector2(20,0)
	var contacted_wall := false
	var wall_deadline := Time.get_ticks_msec()+500
	while Time.get_ticks_msec()<wall_deadline:
		await physics_frame
		for index in actor.get_slide_collision_count():
			if actor.get_slide_collision(index).get_collider()==wall: contacted_wall = true
	check(actor.global_position.x < wall.global_position.x-5,"Cyclone steering passes through a wall")
	check(contacted_wall,"Cyclone bypasses normal body collisions")
	wall.queue_free()
	Input.action_release("player_move_right")
	await wait_seconds(.2)
	check(actor.velocity.length()<.1,"Cyclone keeps sliding after steering is released")
	actor.set_physics_process(false)
	actor.velocity = Vector2.ZERO
	cyclone.cancel_cast()
	await settle()
	# Physical F1 is discoverable and keeps existing King slots intact.
	cyclone.clear_cooldown()
	actor.set_physics_process(true)
	var press := InputEventKey.new()
	press.physical_keycode = KEY_F1
	press.keycode = KEY_F1
	press.pressed = true
	Input.parse_input_event(press)
	await physics_frame
	await physics_frame
	press = press.duplicate()
	press.pressed = false
	Input.parse_input_event(press)
	check(cyclone.is_casting(),"Physical F1 does not activate the technique")
	cyclone.cancel_cast()
	actor.set_physics_process(false)
	await settle()
	check(actor.equip_owned_weapon(actor.weapon_catalog.default_weapon),"Cannot restore Sword")
	await settle()
	check(not lab.combat_hud.weapon_technique_dock.visible and not actor.request_weapon_technique(),"Other families retain Axe skill")
	check(actor.get_ability_component_for_slot(1)==actor.ability_1_component,"Weapon technique replaced King skill1")
	paused = false
	lab.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("AXE_WAR_CYCLONE: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func _check_motion_direction(atlas: Image) -> void:
	var points: Array[Vector2] = []
	var center := Vector2.ZERO
	for key in 16:
		var cell := atlas.get_region(Rect2i(Vector2i(key%4,key/4)*256,Vector2i(256,256)))
		var total := 0.0
		var moment := Vector2.ZERO
		for y in 256:
			for x in 256:
				var p := cell.get_pixel(x,y)
				if minf(p.r,minf(p.g,p.b))>.52 and p.a>.18:
					var weight := p.a*minf(p.r,minf(p.g,p.b))
					moment+=Vector2(x,y)*weight
					total+=weight
		check(total>12,"A paired key loses its silver cut")
		points.append(moment/maxf(total,.01))
		center+=points.back()
	center/=16
	for key in 16:
		var a := ((points[key]-center)/Vector2(1,.5)).angle()
		var b := ((points[(key+1)%16]-center)/Vector2(1,.5)).angle()
		var step := rad_to_deg(wrapf(b-a,-PI,PI))
		check(step>0 and step<35,"Silver motion reverses or snaps at key%d/loop"%key)

func _record_hit(target: HurtboxComponent, info: DamageInfo) -> void:
	var id := target.get_instance_id()
	hits[id] = int(hits.get(id,0))+1
	check(info.damage_type==DamageInfo.DamageType.PHYSICAL and info.stun_seconds==0 and info.stagger_seconds==0,"Spin applies the wrong damage/control type")

func settle() -> void:
	for frame in 6: await process_frame

func phase(component: AbilityComponent, expected: int) -> void:
	var deadline := Time.get_ticks_msec()+7000
	while component.phase != expected and Time.get_ticks_msec()<deadline: await physics_frame
	check(component.phase==expected,"Phase deadline expired")

func idle(component: AbilityComponent) -> void:
	var deadline := Time.get_ticks_msec()+8000
	while component.is_casting() and Time.get_ticks_msec()<deadline: await physics_frame
	check(not component.is_casting(),"Channel cannot finish")

func wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout

func capture(filename: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(OUT+filename)==OK,"Cannot capture native skill")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
