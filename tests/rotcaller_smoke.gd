extends SceneTree

const Trial = preload("res://tools/rotcaller_trial_setup.gd")
const Caster = preload("res://entities/enemies/rotcaller/rotcaller.tscn")
const EVIDENCE := "res://tmp/review/characters/rotcaller_2026_10_03/"
var checks := 0
var failures := 0
var stage: Node
var player: Player
var caster: Rotcaller

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	if DisplayServer.get_name() != "headless":
		root.mode = Window.MODE_WINDOWED
		root.grab_focus()
	stage = Trial.create()
	root.add_child(stage)
	current_scene = stage
	player = stage.player
	player.global_position = Vector2(768,560)
	player.set_physics_process(false)
	player.get_node("Camera2D").reset_smoothing()
	await create_timer(.3).timeout
	var before := root.get_node("SaveService").create_profile_snapshot() as Dictionary
	stage.encounter_controller.start_encounter()
	# Reserved arrivals may retry occupied footing; await materialized actors.
	var arrival_deadline := Time.get_ticks_msec()+3000
	while stage.encounter_controller.actors.get_children().filter(func(actor: Node) -> bool: return actor != player and actor.get("health_component") != null).size()<3 and Time.get_ticks_msec()<arrival_deadline:
		await physics_frame
	var foes: Array = stage.encounter_controller.actors.get_children().filter(func(actor: Node) -> bool: return actor != player and actor.get("health_component") != null)
	_check(foes.size() == 3 and stage.encounter_controller.max_active_enemies == 3,"Trial does not have exactly three ordinary enemy slots")
	for actor: Node in foes:
		_check(actor.get_node_or_null("EnemyRewardComponent") == null,"Trial enemy retains a reward component")
		if actor is Rotcaller: caster = actor
		else: actor.set_physics_process(false)
	_check(caster != null,"Generic spawn entry did not spawn the caster")
	if caster == null:
		quit(1)
		return
	await _wait_cast()
	_check(caster.state == Rotcaller.State.WIND_UP,"Caster never began its warning")
	_check(caster.get_node("Visual/Body").animation == &"windup_south","Caster does not show its staff-rise pose")
	await _capture("warning.png")
	var locked: Vector2 = caster._zone.global_position
	player.global_position += Vector2(90,0)
	await physics_frame
	_check(caster._zone.global_position == locked,"Warning follows the player instead of the cast snapshot")
	var remaining := caster._state_timer.time_left
	paused = true
	await create_timer(.3).timeout
	_check(caster.state == Rotcaller.State.WIND_UP and is_equal_approx(caster._state_timer.time_left,remaining),"Pause advances cast authority")
	paused = false
	_check(caster.health_component.apply_damage(DamageInfo.new(1,player,Vector2.UP)),"Accepted damage could not reach caster")
	await process_frame
	_check(caster.interrupted_casts == 1 and caster.state == Rotcaller.State.RECOVERY and caster._zone == null,"Accepted basic damage does not cancel the warning into recovery")
	_check(caster.get_node("Visual/Body").animation == &"recovery_south","Interrupted cast does not display a distinct reaction pose")
	await _capture("interrupted.png")
	await create_timer(.4).timeout
	_check(caster.state == Rotcaller.State.RECOVERY,"Interrupt recovery is not punishable for the authored duration")
	# A real directional sword swing uses Player -> hitbox -> Hurtbox -> health.
	player.global_position = caster.global_position+Vector2(0,34)
	caster._cooldown.stop()
	await _wait_cast()
	_check(player.request_directional_primary_attack(caster.global_position),"Player could not request its normal sword attack")
	await create_timer(.42).timeout
	_check(caster.interrupted_casts == 2 and caster.health_component.current_health < 54,"Real sword contact did not interrupt a second cast")
	await _capture("sword_interrupt.png")
	# Rejected damage must leave a valid cast intact.
	player.global_position = Vector2(768,560)
	caster.health_component.is_damage_immune = true
	caster._cooldown.stop()
	await _wait_cast()
	_check(not caster.health_component.apply_damage(DamageInfo.new(1,player,Vector2.UP)) and caster.state == Rotcaller.State.WIND_UP,"Blocked damage incorrectly interrupts")
	var zone: Node2D = caster._zone
	var old_health := player.health_component.current_health
	await create_timer(1.18).timeout
	await _capture("eruption.png")
	await create_timer(.38).timeout
	var expected: float = player.health_component.resolve_damage(caster.definition.attack_damage,caster.definition.damage_type)
	_check(is_equal_approx(old_health-player.health_component.current_health,expected),"A full warning does not produce exactly one 10-damage mitigated contact")
	_check(caster.state == Rotcaller.State.RECOVERY,"Cast release does not expose recovery")
	_check(not is_instance_valid(zone) or zone.is_queued_for_deletion(),"Released zone outlives its one contact window")
	await _capture("released.png")
	caster.health_component.is_damage_immune = false
	# Leaving a valid fixed warning is a real alternative to interruption.
	caster._cooldown.stop()
	await _wait_cast()
	var evade_health := player.health_component.current_health
	player.global_position += Vector2(100,0)
	await create_timer(1.55).timeout
	_check(is_equal_approx(player.health_component.current_health,evade_health),"Leaving the marked ground does not avoid its contact")
	# Navigation/physical exclusions include the broken gateway bases.
	_check(not caster._safe_zone(stage.get_node("World/Actors/EntryTreeWest").global_position),"Caster accepts a zone through a tree footprint")
	_check(not caster._safe_zone(Vector2(-100,-100)),"Caster accepts out-of-bounds ground")
	_check(caster._safe_zone(Vector2(768,560)),"Caster rejects reachable open ground")
	# Footstep drawing must advance only with real movement.
	player.global_position = Vector2(768,740)
	caster._cooldown.start(3)
	await create_timer(.9).timeout
	var body: AnimatedSprite2D = caster.get_node("Visual/Body")
	var position := caster.global_position
	var frame := body.frame
	await create_timer(.15).timeout
	_check(caster.global_position.distance_to(position) > 2 and body.animation == &"walk_south" and body.frame != frame,"Walking is a static sprite sliding across the ground")
	await _capture("walking.png")
	for direction: String in ["south","east","north","west"]:
		_check(body.sprite_frames.get_frame_count(StringName("walk_"+direction)) == 4,"Missing directional walk poses: "+direction)
		_check(body.sprite_frames.get_frame_count(StringName("windup_"+direction)) == 2,"Missing anticipation/staff-rise transition: "+direction)
	# Cancel a pending cast on death and observe ordinary slot completion.
	player.global_position = caster.global_position+Vector2(0,100)
	caster._cooldown.stop()
	await _wait_cast()
	var pending: Node2D = caster._zone
	caster.health_component.apply_damage(DamageInfo.new(999,player,Vector2.UP))
	await process_frame
	_check(caster.state == Rotcaller.State.DEAD and (not is_instance_valid(pending) or pending.is_queued_for_deletion()),"Caster death leaves an unfinished zone")
	await _capture("death.png")
	for actor: Node in foes:
		if actor != caster and is_instance_valid(actor): actor.health_component.apply_damage(DamageInfo.new(999,player,Vector2.UP))
	await create_timer(1.6).timeout
	_check(stage.encounter_controller.get_progress().state == "complete" and stage.encounter_controller._active_enemies == 0,"Trial enemy deaths do not finish normal wave-slot accounting")
	_check(stage.get_node("World/Effects").find_children("*","StagePortal",true,false).is_empty(),"Trial completion created a campaign portal")
	var after := root.get_node("SaveService").create_profile_snapshot() as Dictionary
	_check(before.story_state == after.story_state and before.extensions.material_inventory == after.extensions.material_inventory and before.extensions.stage_claims == after.extensions.stage_claims,"Trial completion changes campaign story/material claims")
	_check(before.run_session.total_experience == after.run_session.total_experience and before.run_session.coins == after.run_session.coins,"Trial enemies grant campaign XP/coins")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Trial did not suppress normal saves")
	var ranged := Trial.create(true)
	_check(ranged.encounter_controller.waves[0].total_enemy_count() == 4 and ranged.encounter_controller.max_active_enemies == 4,"Optional Spitter comparison has incorrect slots")
	ranged.free()
	# A defeated target must not receive a delayed warning eruption.
	var probe: Rotcaller = Caster.instantiate()
	probe.target = player
	stage.encounter_controller.actors.add_child(probe)
	probe.global_position = Vector2(768,440)
	probe.set_projectile_parent(stage.get_node("World/Projectiles"))
	player.global_position = Vector2(768,560)
	caster = probe
	await _wait_cast()
	var cancelled: Node2D = probe._zone
	player.health_component.set_current_health(0)
	await create_timer(1.2).timeout
	_check(not is_instance_valid(cancelled) and stage.get_node("World/Projectiles").get_child_count() == 0,"Defeated player leaves a queued root eruption")
	probe.queue_free()
	print("ROTCaller: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _wait_cast() -> void:
	var deadline := Time.get_ticks_msec()+6500
	while caster.state != Rotcaller.State.WIND_UP and caster.state != Rotcaller.State.DEAD and Time.get_ticks_msec() < deadline: await physics_frame

func _capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(EVIDENCE)
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(EVIDENCE+file) == OK,"Native trial capture failed")

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
