extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_session := root.get_node("RunSession")
	run_session.reset_run()

	var first_player := PlayerScene.instantiate() as Player
	root.add_child(first_player)
	first_player.set_physics_process(false)
	first_player.progression_component.grant_rewards(50, 4)
	first_player.health_component.apply_damage(
		DamageInfo.new(37.0, first_player, Vector2.LEFT)
	)
	var expected_level := first_player.progression_component.level
	var expected_health := first_player.health_component.current_health
	first_player.queue_free()
	await process_frame

	var transitioned_player := PlayerScene.instantiate() as Player
	root.add_child(transitioned_player)
	transitioned_player.set_physics_process(false)
	var progression := transitioned_player.progression_component
	if progression.total_experience != 50 or progression.coins != 4:
		_fail("A replacement player did not inherit the active run's XP and coins.")
		return
	if progression.level != expected_level:
		_fail("A replacement player did not reconstruct the active run's level.")
		return
	if (
		not is_equal_approx(transitioned_player.health_component.maximum_health, 140.0)
		or not is_equal_approx(transitioned_player.health_component.current_health, expected_health)
	):
		_fail("A replacement player did not preserve current HP across the stage boundary.")
		return

	var regeneration := transitioned_player.health_regeneration_component
	var fast_regeneration := regeneration.vitality_definition.duplicate(true) as PlayerVitalityDefinition
	fast_regeneration.base_health_regeneration_per_second = 10.0
	fast_regeneration.regeneration_delay_seconds = 0.05
	fast_regeneration.regeneration_tick_seconds = 0.05
	regeneration.vitality_definition = fast_regeneration
	transitioned_player.health_component.apply_damage(
		DamageInfo.new(1.0, transitioned_player, Vector2.LEFT)
	)
	var health_before_regeneration := transitioned_player.health_component.current_health
	await create_timer(0.2).timeout
	if transitioned_player.health_component.current_health <= health_before_regeneration:
		_fail("Baseline health regeneration did not begin after its damage-free delay.")
		return
	if not is_equal_approx(
		run_session.player_current_health,
		transitioned_player.health_component.current_health
	):
		_fail("Regenerated health was not synchronized back into the active run.")
		return

	transitioned_player.queue_free()
	await process_frame
	run_session.reset_run()
	var restarted_player := PlayerScene.instantiate() as Player
	root.add_child(restarted_player)
	restarted_player.set_physics_process(false)
	if (
		restarted_player.progression_component.total_experience != 0
		or restarted_player.progression_component.coins != 0
		or not is_equal_approx(restarted_player.health_component.current_health, 140.0)
	):
		_fail("Resetting the run did not restore level-one progression and full vitality.")
		return

	print("Run session progression smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
