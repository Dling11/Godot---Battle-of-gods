extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await create_timer(.85).timeout
	var boss := lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	boss._deactivate_hitboxes()
	boss.global_position = Vector2(320,280)
	boss._set_facing(Vector2.RIGHT)
	lab.player.global_position = Vector2(445,280)
	boss._choose_follow_up()
	check(boss.state == Examiner.State.PURSUIT_WIND_UP, "Retreat did not trigger Reprisal")
	var locked_endpoint := boss.judgment_charge_endpoint()
	lab.player.global_position += Vector2(0,90)
	boss._track_target_before_commit()
	check(boss.judgment_charge_endpoint() == locked_endpoint and boss.facing_direction == Vector2.RIGHT, "Reprisal tracked after its warning")
	boss._set_facing(Vector2.RIGHT)
	lab.player.global_position = boss.global_position - Vector2(35,0)
	boss._choose_follow_up()
	check(boss.state == Examiner.State.COMBO_RECOVERY, "Getting behind did not earn recovery")
	lab.player.global_position = boss.global_position + Vector2(65,0)
	boss._choose_follow_up()
	check(boss.state == Examiner.State.SWEEP_WIND_UP, "Close target did not trigger sweep")
	boss._begin_combo(Vector2.RIGHT)
	boss._state_remaining = 0
	boss._tick_state(0)
	var before_step := boss.global_position
	boss._physics_process(.06)
	check(boss.global_position.x > before_step.x, "Thrust has no physical advancing step")
	boss._deactivate_hitboxes()
	boss._begin_trial()
	boss.trial.set_physics_process(false)
	check(not lab.player.is_cinematic_locked() and not boss.health_component.is_invulnerable, "Trial is not attackable/player-controlled")
	check(lab.court_arena.active_wards.is_empty(), "Trial granted free sanctuary")
	# Real accepted health damage, rather than a fabricated meter event.
	boss.health_component.apply_damage(DamageInfo.new(138.0, lab.player, Vector2.UP))
	check(is_equal_approx(boss.trial.damage, 100.0), "Meter ignored actual armor-mitigated damage")
	check(lab.boss_hud.phase_label.text.contains("140/240"), "HUD did not expose damage progress")
	boss.health_component.apply_damage(DamageInfo.new(200.0, lab.player, Vector2.UP))
	check(boss.state == Examiner.State.GUARD_BROKEN and boss._trial_succeeded, "Breaking seal did not cancel into stun")
	check(lab.court_arena.active_wards.is_empty(), "Guard break should cancel, not grant sanctuary")
	# Reusable Court geometry remains independently testable.
	var sanctuary: Vector2 = CourtOfFirstMeasure.PYLON_POINTS[0]
	lab.court_arena.set_sanctuary(true, sanctuary)
	var health := lab.player.health_component as HealthComponent
	lab.set_player_invincible(false)
	health.set_maximum_health(1000.0, false)
	health.set_current_health(1000.0)
	health.set_equipment_defenses(100.0, 0.0)
	lab.player.global_position = sanctuary
	lab.court_arena.resolve_divine_descent(lab.player, 800.0, boss)
	check(health.current_health == 1000.0, "Earned sanctuary did not block Verdict")
	lab.player.global_position = Vector2(365,287)
	# Exercise actual dodge signal wiring; Verdict must pierce these i-frames.
	lab.player.evade_component.request_evade(Vector2.RIGHT)
	lab.court_arena.resolve_divine_descent(lab.player, 800.0, boss)
	check(is_equal_approx(health.current_health, 600.0), "Verdict failed to pierce dodge with armor mitigation")
	lab.player.evade_component.cancel_evade()
	health.set_current_health(1000.0)
	lab.set_player_invincible(true)
	lab.court_arena.resolve_divine_descent(lab.player, 800.0, boss)
	check(health.current_health == 1000.0, "Verdict bypassed explicit lab immunity")
	# A real movement/hitbox regression for the owner's back-walk exploit.
	boss._phase_transition_requested = true
	boss._phase_two = true
	boss._close_exchange_count = 0
	lab.player.global_position = boss.global_position + Vector2(65,0)
	boss._set_facing(Vector2.RIGHT)
	boss._choose_follow_up()
	check(boss.state == Examiner.State.HELD_JUDGMENT, "Second measure lacked the held strike")
	boss._tick_state(.5)
	check(boss.state == Examiner.State.HELD_JUDGMENT and not boss.slam_hitbox._enabled, "Held strike damaged during the hold")
	var straight_damage := await exercise_retreat(lab, boss, false)
	var sidestep_damage := await exercise_retreat(lab, boss, true)
	check(straight_damage > 0, "Straight back-walking still escaped the entire combo")
	check(sidestep_damage < straight_damage, "Reading Reprisal and sidestepping did not improve the outcome")
	lab.set_player_invincible(true)
	# Failure clears the previously earned sanctuary and cancels pending cuts.
	boss._begin_trial()
	boss.trial.set_physics_process(false)
	boss.trial._warn_cut()
	var pending_visual: Node = boss.trial._pending[0].visual
	boss.trial._physics_process(boss.definition.trial_duration_seconds + .1)
	check(not boss._trial_succeeded and lab.court_arena.active_wards.is_empty(), "Failure retained old protection")
	check(not boss.trial.active and boss.trial._pending.is_empty(), "Failed trial retained authority")
	await process_frame
	# A resolved visual is allowed its short contact decay; none may survive it.
	await create_timer(.4).timeout
	check(not is_instance_valid(pending_visual), "Trial cut leaked after resolution")
	boss._phase_two = true
	boss._berserk = false
	boss.health_component.set_invulnerable(false)
	boss.health_component.set_current_health(boss.health_component.maximum_health * .36)
	boss._enter(Examiner.State.APPROACH, 0)
	boss.health_component.apply_damage(DamageInfo.new(50.0, lab.player, Vector2.UP))
	check(boss.state == Examiner.State.BERSERK_AWAKEN and boss.is_berserk(), "35 percent did not begin berserk")
	boss._begin_trial()
	boss.trial.set_physics_process(false)
	boss.trial._warn_cut()
	pending_visual = boss.trial._pending[0].visual
	lab.court_arena.set_sanctuary(true, sanctuary)
	lab.court_arena.begin_divine_descent_charge(2.8)
	lab.clear_simulation()
	check(lab.court_arena.active_wards.is_empty() and is_zero_approx(lab.court_arena._descent_energy), "Reset retained a sanctuary or dangerous floor")
	await process_frame
	await process_frame
	check(not is_instance_valid(pending_visual), "Reset left an armed trial cut")
	lab.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("Examiner Worth: branch/commit, advancing step, guard meter, guard-break stun, Court geometry, Verdict mitigation/i-frames/immunity, timeout and cleanup: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)


func exercise_retreat(lab: Node, boss: Examiner, sidestep: bool) -> float:
	boss.trial.cancel()
	boss._deactivate_hitboxes()
	boss.global_position = Vector2(270,280)
	lab.player.global_position = Vector2(340,280)
	lab.set_player_invincible(false)
	lab.player.health_component.set_current_health(1000)
	lab.player.health_component.set_equipment_defenses(0,0)
	boss._phase_two = false
	boss._begin_combo(Vector2.RIGHT)
	for frame in 100:
		await physics_frame
		var direction := Vector2.DOWN if sidestep and boss.state in [Examiner.State.PURSUIT_WIND_UP, Examiner.State.PURSUIT_TRAVEL, Examiner.State.PURSUIT_RECOVERY] else Vector2.RIGHT
		lab.player.global_position += direction * 120.0 / 60.0
		if boss.state != Examiner.State.APPROACH:
			boss._physics_process(1.0/60.0)
	var accepted: float = 1000.0 - lab.player.health_component.current_health
	boss._deactivate_hitboxes()
	print("Retreat fixture / sidestep=", sidestep, " / damage=", accepted)
	return accepted
