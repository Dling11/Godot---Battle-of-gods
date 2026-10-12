extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await create_timer(.8).timeout
	var boss := lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	var dummy := CharacterBody2D.new()
	var health := HealthComponent.new()
	health.name = "HealthComponent"
	health.maximum_health = 10000
	dummy.add_child(health)
	root.add_child(dummy)
	boss.target = dummy
	var totals := [0.0, 0.0]
	var failures := 0
	for seed_value in 30:
		for moving in 2:
			dummy.global_position = Vector2(365, 280) if seed_value % 2 == 0 else boss.arena_bounds.position + Vector2(30,30)
			health.set_current_health(10000)
			boss.firmament.begin(boss, seed_value)
			boss.firmament.set_physics_process(false)
			for step in 370:
				boss.firmament._physics_process(1.0 / 60)
				if moving:
					dummy.global_position = dummy.global_position.move_toward(boss.firmament.escape_point, 120.0 / 60)
				var armed := 0
				for node in boss._owned_suns:
					if is_instance_valid(node):
						node.set_physics_process(false)
						node._physics_process(1.0 / 60)
						if not node.resolved:
							armed += 1
				if armed > 6:
					failures += 1
			if boss.firmament.points.size() != 24:
				failures += 1
			totals[moving] += 10000 - health.current_health
			boss._cancel_suns()
			boss.firmament.cancel()
			await process_frame
	if totals[1] >= totals[0]:
		failures += 1
	print("Rain movement simulation: 30 seeds, center/corner starts, 24 meteors, at most 6 armed; stationary/moving damage=", totals, "; failures=", failures)
	dummy.queue_free()
	lab.clear_simulation()
	lab.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
