extends SceneTree

const BossScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var effects := Node2D.new()
	effects.add_to_group("boss_effects")
	root.add_child(effects)
	var target := _build_target()
	target.global_position = Vector2(430.0, 260.0)
	target.velocity = Vector2(120.0, 0.0)
	root.add_child(target)

	var boss := BossScene.instantiate() as Stage5Boss
	boss.target = target
	boss.global_position = Vector2(260.0, 260.0)
	boss.desperation_first_warning_seconds = 0.05
	boss.desperation_repeat_warning_seconds = 0.04
	boss.desperation_final_warning_seconds = 0.05
	boss.desperation_travel_seconds = 0.06
	boss.desperation_between_jump_seconds = 0.03
	boss.desperation_final_recovery_seconds = 0.04
	boss.desperation_root_wind_up_seconds = 0.12
	boss.desperation_root_tracking_seconds = 0.08
	boss.desperation_anti_kite_distance = 190.0
	boss.desperation_anti_kite_hold_seconds = 0.05
	root.add_child(boss)
	await process_frame
	await physics_frame
	boss.state = Stage5Boss.State.CHASE

	if boss._jump_tier() != Stage5Boss.JumpTier.SINGLE or boss._next_jump_chain_count(Stage5Boss.JumpTier.SINGLE) != 1:
		_fail("80-100% health did not retain one ordinary jump.")
		return
	boss.health_component.set_current_health(boss.health_component.maximum_health * 0.79)
	var mid_counts := [
		boss._next_jump_chain_count(Stage5Boss.JumpTier.MULTI),
		boss._next_jump_chain_count(Stage5Boss.JumpTier.MULTI),
		boss._next_jump_chain_count(Stage5Boss.JumpTier.MULTI),
	]
	if boss._jump_tier() != Stage5Boss.JumpTier.MULTI or mid_counts != [2, 3, 2]:
		_fail("Below-80% jump cadence did not alternate 2/3 pursuits: %s" % [mid_counts])
		return
	boss._multi_chain_step = 0

	var desperation_events := [0]
	var locks: Array[Vector2] = []
	var target_positions: Array[Vector2] = []
	var landing_strengths: Array[float] = []
	var jump_damages: Array[float] = []
	var root_wind_up_durations: Array[float] = []
	boss.desperation_started.connect(func() -> void: desperation_events[0] += 1)
	boss.jump_target_locked.connect(func(position: Vector2) -> void:
		locks.append(position)
		target_positions.append(target.global_position)
		jump_damages.append(boss._active_jump_damage)
	)
	boss.landed.connect(func(_position: Vector2) -> void:
		landing_strengths.append(boss.get_landing_feedback_strength())
		var step := landing_strengths.size()
		target.global_position = Vector2(430.0 + step * 38.0, 220.0 + step * 34.0)
		target.velocity = Vector2(120.0 if step % 2 == 0 else 0.0, 120.0 if step % 2 == 1 else 0.0)
	)
	boss.state_changed.connect(func(next_state: Stage5Boss.State, duration: float) -> void:
		if next_state == Stage5Boss.State.ROOT_WIND_UP:
			root_wind_up_durations.append(duration)
	)

	# Exactly 30% enters the repeatable 3/4/5 tier and forces its first chain
	# at the next legal chase boundary.
	boss.health_component.set_current_health(boss.health_component.maximum_health * 0.30)
	await _wait_for_root_handoff(root_wind_up_durations, 1)
	if desperation_events[0] != 1 or locks.size() != 3 or landing_strengths.size() != 3:
		_fail("First 30%-health pursuit was not a three-jump chain (events=%d locks=%d landings=%d)." % [desperation_events[0], locks.size(), landing_strengths.size()])
		return
	if locks[0].distance_to(target_positions[0]) > 0.1 or locks[1].distance_to(target_positions[1]) < 40.0 or locks[2].distance_to(target_positions[2]) > 0.1:
		_fail("Three-jump pursuit lost its direct, predicted, direct-finisher target grammar.")
		return
	if not (landing_strengths[0] < landing_strengths[1] and landing_strengths[1] < landing_strengths[2]):
		_fail("Low-health landing feedback did not escalate toward its finisher: %s" % [landing_strengths])
		return
	if not is_equal_approx(jump_damages[2], boss.jump_damage * boss.desperation_final_damage_multiplier):
		_fail("Low-health final slam lost its 150% jump damage.")
		return
	if root_wind_up_durations != [boss.desperation_root_wind_up_seconds]:
		_fail("Low-health pursuit did not hand off into the faster prison.")
		return

	# Bypass the prison duration only inside the test. A far-away target must
	# trigger the next chain without first donating a melee contact to the boss.
	locks.clear()
	target_positions.clear()
	landing_strengths.clear()
	jump_damages.clear()
	root_wind_up_durations.clear()
	boss.state = Stage5Boss.State.CHASE
	boss._root_ready = false
	boss._jump_cooldown = 0.0
	boss._attacks_since_jump = 0
	boss.global_position = Vector2(120.0, 120.0)
	target.global_position = Vector2(720.0, 420.0)
	await _wait_for_root_handoff(root_wind_up_durations, 1)
	if desperation_events[0] != 2 or locks.size() != 4:
		_fail("Low-health anti-kite pursuit did not recur without a melee gate (events=%d locks=%d)." % [desperation_events[0], locks.size()])
		return
	if boss._next_jump_chain_count(Stage5Boss.JumpTier.DESPERATION) != 5:
		_fail("Low-health pursuit cycle did not advance from 3/4 into 5 jumps.")
		return
	if not is_equal_approx(boss._jump_reuse_seconds(), boss.desperation_jump_reuse_seconds):
		_fail("Low-health pursuit did not retain its explicit post-prison reuse cooldown.")
		return

	print("Stage 5 health-tier jump cadence, recurring 3/4/5 pursuit, varied locks, and prison handoff passed.")
	quit(0)


func _wait_for_root_handoff(events: Array[float], expected_count: int) -> void:
	var deadline := Time.get_ticks_msec() + 3500
	while events.size() < expected_count and Time.get_ticks_msec() < deadline:
		await physics_frame


func _build_target() -> CharacterBody2D:
	var target := CharacterBody2D.new()
	var health := HealthComponent.new()
	health.name = "HealthComponent"
	health.maximum_health = 600.0
	target.add_child(health)
	var hurtbox := HurtboxComponent.new()
	hurtbox.collision_layer = 64
	hurtbox.collision_mask = 32
	hurtbox.health_component = health
	target.add_child(hurtbox)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	hurtbox.add_child(shape)
	return target


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
