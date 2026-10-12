extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const EnemyScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("Running Forsaken Thrall smoke test...")
	var player := PlayerScene.instantiate()
	var enemy := EnemyScene.instantiate()
	enemy.target = player
	root.add_child(player)
	root.add_child(enemy)
	player.global_position = Vector2(200.0, 200.0)
	enemy.global_position = Vector2(230.0, 200.0)
	player.set_physics_process(false)

	var player_health = player.get_node("HealthComponent")
	var enemy_health = enemy.get_node("HealthComponent")
	if (
		not is_equal_approx(enemy_health.maximum_health, 100.0)
		or not is_equal_approx(enemy.definition.attack_damage, 18.0)
	):
		_fail("Forsaken Thrall durability must remain at the early-stage 100 HP baseline.")
		return
	if enemy.state != enemy.State.SPAWNING:
		_fail("Forsaken Thrall did not begin in its materialization state.")
		return
	for frame in range(20):
		await physics_frame
	if player_health.current_health < player_health.maximum_health:
		_fail("Forsaken Thrall dealt damage before materialization completed.")
		return
	for frame in range(90):
		await physics_frame
	if player_health.current_health >= player_health.maximum_health:
		_fail("Forsaken Thrall did not damage the player.")
		return

	enemy.set_physics_process(false)
	enemy.global_position = Vector2(230.0, 200.0)
	player._set_facing_direction(Vector2.RIGHT)
	enemy_health.current_health = 10.0
	var death_result := {"died": false, "health": enemy_health.current_health}
	enemy_health.health_changed.connect(func(current: float, _maximum: float) -> void:
		death_result.health = current
	)
	enemy_health.died.connect(func() -> void:
		death_result.died = true
	)
	var enemy_hitbox := enemy.get_node("AttackPivot/AttackHitbox") as MeleeHitbox
	enemy_hitbox.activate(15.0, enemy, Vector2.LEFT)
	var health_before_sword: float = enemy_health.current_health
	if not player.request_primary_attack():
		_fail("Player sword request was rejected.")
		return
	for frame in range(40):
		await physics_frame
	var dealt_damage: float = health_before_sword - death_result.health
	if dealt_damage < 10.0 or dealt_damage > 12.0:
		_fail("King's Ashwood basic attack left its authored 10-12 damage range: %s." % [dealt_damage])
		return
	if not death_result.died:
		_fail("Sword lethal damage did not enter the enemy death state.")
		return

	print("Forsaken Thrall smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
