extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const DamageInfoScript = preload("res://gameplay/combat/damage_info.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	root.add_child(player)
	player.global_position = Vector2(200.0, 200.0)

	var evade_component = player.get_node("EvadeComponent")
	var health_component = player.get_node("HealthComponent")
	var start_position: Vector2 = player.global_position

	if not player.request_evade(Vector2.RIGHT):
		_fail("Ready player rejected evade.")
		return
	if not evade_component.is_dashing() or not health_component.is_invulnerable:
		_fail("Dash did not enter its invulnerable phase immediately.")
		return
	var damage := DamageInfoScript.new(25.0, player, Vector2.LEFT)
	if health_component.apply_damage(damage):
		_fail("Damage was accepted during invulnerability.")
		return

	while evade_component.is_dashing():
		await physics_frame

	var distance: float = player.global_position.distance_to(start_position)
	var expected_distance: float = evade_component.definition.get_distance()
	if absf(distance - expected_distance) > 8.0:
		_fail("Expected dash distance near %s, received %s." % [expected_distance, distance])
		return
	if health_component.is_invulnerable:
		_fail("Invulnerability remained active during recovery.")
		return
	if player.request_evade(Vector2.RIGHT):
		_fail("Evade was accepted during recovery.")
		return

	while not evade_component.is_ready():
		await physics_frame
	if player.request_evade(Vector2.RIGHT):
		_fail("Evade ignored its post-recovery cooldown.")
		return
	while not evade_component.is_evade_available():
		await physics_frame

	if not player.request_primary_attack():
		_fail("Attack was not restored after evade recovery.")
		return

	print("Player evade smoke test passed. Distance: %.2f px" % distance)
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
