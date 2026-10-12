extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await create_timer(.8).timeout
	var boss := lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	boss._deactivate_hitboxes()
	check(not boss._begin_firmament(), "Crimson barrage available outside berserk")
	boss._berserk = true
	boss._phase_two = true
	boss._phase_transition_requested = true
	check(boss._begin_firmament(), "Berserk missing barrage")
	boss.trial.set_physics_process(false)
	var hp := boss.health_component.current_health
	boss.health_component.apply_damage(DamageInfo.new(300,lab.player,Vector2.UP))
	check(boss.state == Examiner.State.GUARD_BROKEN and not boss.firmament.active, "Barrage guard break did not interrupt")
	check(boss.health_component.current_health == hp and boss._owned_suns.is_empty(), "Broken barrage leaked HP or projectiles")
	boss._begin_firmament()
	boss.trial.set_physics_process(false)
	boss.trial._physics_process(boss.definition.firmament_charge_seconds + .01)
	boss.firmament.set_physics_process(false)
	check(boss.state == Examiner.State.FIRMAMENT_BARRAGE and boss._owned_suns.size() == 3, "Timeout did not release first wave")
	check(boss.firmament.points.size() == 3, "Rain should generate each wave from current player position")
	for wave_index in boss.definition.firmament_wave_count:
		var opening := boss.firmament.escape_point
		check(opening.distance_to(lab.player.global_position) <= 79, "Opening is beyond short walking distance")
		for index in range(boss.firmament.points.size() - 3, boss.firmament.points.size()):
			check(boss.firmament.points[index].distance_to(opening) > boss.definition.firmament_radius + 15, "New wave filled its local opening")
		lab.player.global_position = opening
		if wave_index < boss.definition.firmament_wave_count - 1:
			boss.firmament._physics_process(boss.definition.firmament_wave_interval + .01)
	check(boss._owned_suns.size() == 24, "Eight random waves lost or duplicated meteors")
	for node in boss._owned_suns:
		var sun := node as ExaminerSun
		sun.set_physics_process(false)
		check(sun.crimson and sun.warning_seconds >= .8, "Crimson meteor lost tint/readable warning")
	# Compare random layouts from distinct reproducible seeds.
	boss._cancel_suns()
	boss.firmament.begin(boss, 123)
	var first_layout := boss.firmament.points.duplicate()
	boss._cancel_suns()
	boss.firmament.begin(boss, 456)
	check(first_layout != boss.firmament.points, "Different seeds reused the same rain layout")
	boss._cancel_suns()
	boss.firmament.cancel()
	lab.set_player_invincible(false)
	lab.player.health_component.set_current_health(140)
	# A planted player inside a circle is hit; ordinary dodge remains valid.
	var hazard := boss._spawn_sun(Vector2(365,280),58,50,.85,true)
	hazard.set_physics_process(false)
	lab.player.global_position = hazard.destination
	hazard._physics_process(.86)
	check(lab.player.health_component.current_health == 90, "Meteor missed stationary target")
	lab.player.evade_component.request_evade(Vector2.RIGHT)
	hazard = boss._spawn_sun(Vector2(365,280),58,50,.85,true)
	hazard.set_physics_process(false)
	hazard._physics_process(.86)
	check(lab.player.health_component.current_health == 90, "Meteor ignored dodge")
	lab.player.evade_component.cancel_evade()
	lab.set_player_invincible(true)
	# Faster basic Sun snapshots modest movement prediction, never homes later.
	boss._begin_orb()
	boss.trial.set_physics_process(false)
	lab.player.global_position = Vector2(400,300)
	lab.player.velocity = Vector2(120,0)
	boss.trial._physics_process(5.6)
	check(boss._sun_target.x > 400 and boss._sun_target.x <= 428, "Sun prediction unbounded or absent")
	var aim := boss._sun_target
	lab.player.velocity = Vector2.ZERO
	lab.player.global_position += Vector2(0,80)
	boss._tick_state(.25)
	hazard = boss._owned_suns.back() as ExaminerSun
	check(hazard.destination == aim and hazard.warning_seconds == .62, "Berserk Sun did not commit faster fixed flight")
	# Actual pause propagation, followed by death mid-wave, then reset.
	boss._cancel_suns()
	# Let the preceding real hit's short hitstop finish before owning pause.
	await create_timer(.4, true, false, true).timeout
	boss.firmament.begin(boss, 2)
	var paused_wave := boss.firmament.wave
	paused = true
	await create_timer(1.1,true,false,true).timeout
	check(boss.firmament.wave == paused_wave, "Paused barrage advanced")
	paused = false
	boss._withdraw()
	check(not boss.firmament.active, "Death retained pending waves")
	await process_frame
	check(not is_instance_valid(hazard), "Death retained projectiles")
	lab.clear_simulation()
	lab.queue_free()
	await process_frame
	for message in failures:
		push_error(message)
	print("Examiner Firmament: gate, break/timeout, 24 random meteors, local openings, dodge, prediction, pause/death cleanup: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
