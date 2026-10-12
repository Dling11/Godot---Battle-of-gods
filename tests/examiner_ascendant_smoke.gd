extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await create_timer(.8).timeout
	var boss := lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	boss._deactivate_hitboxes()
	check(boss.movement_speed() == 66, "Opening pace not restored")
	boss._begin_orb()
	boss.trial.set_physics_process(false)
	var hp := boss.health_component.current_health
	var accepted := boss.health_component.apply_damage(DamageInfo.new(138, lab.player, Vector2.UP))
	check(accepted and boss.health_component.current_health == hp, "Seal hit leaked into HP or was rejected")
	check(is_equal_approx(boss.trial.damage, 100), "Seal did not use mitigated damage")
	check(lab.boss_hud.guard_bar.visible and is_equal_approx(lab.boss_hud.guard_bar.value, 110), "Separate guard bar missing/wrong")
	boss.health_component.apply_damage(DamageInfo.new(1000, lab.player, Vector2.UP))
	check(boss.state == Examiner.State.GUARD_BROKEN and not boss.trial.active, "Guard break failed to interrupt Sun")
	check(boss.health_component.current_health == hp and boss._owned_suns.is_empty(), "Breaking hit overflowed or fired Sun")
	check(not lab.boss_hud.guard_bar.visible, "Broken seal left guard bar")
	boss.health_component.apply_damage(DamageInfo.new(138, lab.player, Vector2.UP))
	check(is_equal_approx(boss.health_component.current_health, hp - 100), "Stunned boss HP not vulnerable")
	# Crossing phase thresholds cannot steal the earned damage window.
	boss.health_component.set_current_health(500)
	boss.health_component.apply_damage(DamageInfo.new(1, lab.player, Vector2.UP))
	check(boss.state == Examiner.State.GUARD_BROKEN, "Phase change interrupted earned stun")
	boss._tick_state(1.0)
	check(boss.state == Examiner.State.GUARD_BROKEN, "Stun ended too early")
	boss.health_component.set_current_health(hp)
	boss._tick_state(2.0)
	boss._tick_state(.5)
	check(boss.state == Examiner.State.APPROACH, "Stun did not recover")
	boss._begin_trial()
	boss.trial.set_physics_process(false)
	boss.health_component.apply_damage(DamageInfo.new(1000, lab.player, Vector2.UP))
	check(boss.state == Examiner.State.GUARD_BROKEN and lab.court_arena.active_wards.is_empty(), "Descent break should cancel jump, not grant sanctuary")
	boss._begin_trial()
	boss.trial._physics_process(7.1)
	check(boss.state == Examiner.State.DESCENT_PREPARE, "Failed seal did not commit Verdict")
	boss._begin_orb()
	boss.trial.set_physics_process(false)
	lab.player.global_position = Vector2(440, 300)
	boss.trial._physics_process(5.6)
	check(boss.state == Examiner.State.ORB_RELEASE, "Failed Sun seal did not enter throw stance")
	var locked := boss._sun_target
	lab.player.global_position += Vector2(0, 120)
	boss._tick_state(.43)
	var sun := boss._owned_suns.back() as ExaminerSun
	sun.set_physics_process(false)
	check(sun.destination == locked and sun.radius == boss.definition.orb_radius, "Sun homed after throw or changed radius")
	lab.set_player_invincible(false)
	var health := lab.player.health_component as HealthComponent
	health.set_maximum_health(1000, false)
	health.set_current_health(1000)
	health.set_equipment_defenses(0, 0)
	lab.player.global_position = locked + Vector2(boss.definition.orb_radius + 1, 0)
	sun._physics_process(1.16)
	check(health.current_health == 1000, "Sun damaged outside warned radius")
	sun = boss._spawn_sun(locked, 76, 155, 1.15, false)
	sun.set_physics_process(false)
	lab.player.global_position = locked + Vector2(75,0)
	sun._physics_process(1.16)
	check(health.current_health == 845, "Sun did not hit inside warned radius")
	sun._physics_process(.1)
	check(health.current_health == 845, "Sun hit more than once")
	# Natural expiry must not leave a freed reference that breaks the next cast.
	sun._physics_process(1.0)
	await process_frame
	var followup := boss._spawn_sun(locked, 76, 155, 1.15, false)
	check(is_instance_valid(followup) and boss._owned_suns.has(followup), "Next cast lost ownership after previous Sun expired")
	followup.set_physics_process(false)
	# Verify shared mitigation and real evade handling remain intact.
	health.set_equipment_defenses(100,0)
	lab.player.evade_component.request_evade(Vector2.RIGHT)
	lab.court_arena.resolve_divine_descent(lab.player,800,boss)
	check(is_equal_approx(health.current_health,445), "Verdict must pierce dodge but respect armor")
	lab.player.evade_component.cancel_evade()
	lab.set_player_invincible(true)
	# Disconnect cinematic presentation; exercise the real 60% authority boundary.
	lab.examiner_director.bind(null)
	boss._enter(Examiner.State.APPROACH, 0)
	boss.health_component.set_current_health(1081)
	check(not boss._try_phase_transition(), "Second measure activated above 60 percent")
	boss.health_component.set_current_health(1080)
	check(boss._try_phase_transition() and boss.state == Examiner.State.PHASE_STANCE, "60 percent did not request Trial of Worth")
	boss.begin_divine_descent()
	boss.trial.set_physics_process(false)
	boss.health_component.apply_damage(DamageInfo.new(1000, lab.player, Vector2.UP))
	boss._tick_state(2.7)
	boss._tick_state(.5)
	check(boss.is_phase_two(), "Breaking first trial did not unlock Second Measure")
	check(boss.movement_speed() == 86, "Second measure speed wrong")
	boss.health_component.set_current_health(631)
	check(not boss._try_phase_transition(), "Berserk activated above 35 percent")
	boss.health_component.set_current_health(630)
	check(boss._try_phase_transition() and boss.is_berserk(), "Berserk missing at 35 percent")
	check(boss.movement_speed() == 106 and is_equal_approx(boss.scaled_damage(100),165), "Berserk tuning not applied")
	boss._cancel_suns()
	boss._tick_state(1.6)
	check(boss.state == Examiner.State.CROWNFALL and boss._owned_suns.size() == 3, "Berserk did not release three Crownfall seals")
	check((boss._owned_suns[0] as ExaminerSun).warning_seconds >= 1.0, "Crownfall lacked readable warning")
	var pending: Node = boss._owned_suns[2]
	lab.clear_simulation()
	await process_frame
	await process_frame
	check(not is_instance_valid(pending), "Reset leaked damaging Sun")
	check(not lab.boss_hud.guard_bar.visible, "Reset retained guard UI")
	lab.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("Examiner Ascendant: seal absorption/overflow/stun, cancel/failure, fixed Sun geometry, phase tuning, Crownfall, reset: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
