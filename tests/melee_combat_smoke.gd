extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TrainingTargetScene = preload("res://entities/training/training_target.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	var center_target := TrainingTargetScene.instantiate()
	var edge_target := TrainingTargetScene.instantiate()
	var former_wide_edge_target := TrainingTargetScene.instantiate()
	var opposite_target := TrainingTargetScene.instantiate()
	root.add_child(player)
	root.add_child(center_target)
	root.add_child(edge_target)
	root.add_child(former_wide_edge_target)
	root.add_child(opposite_target)
	player.global_position = Vector2(100.0, 100.0)
	center_target.global_position = Vector2(100.0, 118.0)
	# This target sits inside King's greatsword 36-reach by 44-wide contact fan.
	edge_target.global_position = Vector2(125.0, 120.0)
	# This lane was covered by the old inherited 96-wide contact fan.
	former_wide_edge_target.global_position = Vector2(143.0, 104.0)
	opposite_target.global_position = Vector2(100.0, 60.0)
	player.set_physics_process(false)
	player._set_facing_direction(Vector2.DOWN)

	var attack_component = player.get_node("MeleeAttackComponent")
	var center_health = center_target.get_node("HealthComponent")
	var edge_health = edge_target.get_node("HealthComponent")
	var former_wide_edge_health = former_wide_edge_target.get_node("HealthComponent")
	var opposite_health = opposite_target.get_node("HealthComponent")
	var received_knockback := {"strength": 0.0}
	center_health.damaged.connect(func(info: DamageInfo) -> void:
		received_knockback.strength = info.knockback_strength
	)
	if not attack_component.request_attack(Vector2.DOWN):
		_fail("The first sword attack request was rejected.")
		return
	# Reproduce a fast opposite movement input after the attack is accepted.
	# The visible attack and real SwordPivot must remain on the captured lane.
	player._set_facing_direction(Vector2.UP)
	var sword_pivot := player.get_node("SwordPivot") as Node2D
	if not is_equal_approx(sword_pivot.rotation, Vector2.DOWN.angle()):
		_fail("Movement input redirected the real sword pivot during wind-up.")
		return

	for frame in range(40):
		await physics_frame

	var center_damage: float = 100.0 - center_health.current_health
	var edge_damage: float = 100.0 - edge_health.current_health
	if center_damage < 10.0 or center_damage > 12.0 or not is_equal_approx(edge_damage, center_damage):
		_fail(
			"Expected one shared 10-12 damage roll at the tightened center and edge; health was %s / %s."
			% [center_health.current_health, edge_health.current_health]
		)
		return
	if not is_equal_approx(former_wide_edge_health.current_health, 100.0):
		_fail("King's basic slash still contacted the old inherited wide edge.")
		return
	if not is_equal_approx(opposite_health.current_health, 100.0):
		_fail("The accepted down-facing attack incorrectly hit the later up-facing lane.")
		return
	if not is_equal_approx(received_knockback.strength, 48.0):
		_fail("Ashwood Blade did not deliver its configured light knockback.")
		return
	if attack_component.phase != attack_component.Phase.IDLE:
		_fail("Sword attack did not return to IDLE.")
		return
	if not is_equal_approx(sword_pivot.rotation, Vector2.UP.angle()):
		_fail("Sword pivot did not adopt the latest movement facing after recovery.")
		return

	print("Melee combat smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
