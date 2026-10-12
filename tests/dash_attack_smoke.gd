extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.global_position = Vector2(200.0, 200.0)
	await process_frame

	var attack_component := player.attack_component
	var evade_component := player.evade_component
	var observed := {"attack_count": 0, "unsafe_overlap": false}
	attack_component.attack_started.connect(func() -> void:
		observed.attack_count += 1
		observed.unsafe_overlap = (
			observed.unsafe_overlap or player.health_component.is_invulnerable
		)
	)

	var start_position := player.global_position
	if not player.request_evade(Vector2.RIGHT):
		_fail("Ready player rejected the dash for a buffered attack.")
		return
	if not player.request_primary_attack():
		_fail("Basic attack was not buffered during the active dash.")
		return
	if attack_component.phase != attack_component.Phase.IDLE:
		_fail("Buffered attack began before the active dash completed.")
		return

	while evade_component.is_dashing():
		if attack_component.phase != attack_component.Phase.IDLE:
			_fail("Sword attack overlapped the invulnerable dash movement.")
			return
		await physics_frame

	if not evade_component.is_ready():
		_fail("Buffered attack did not cancel only the dash recovery window.")
		return
	if attack_component.phase == attack_component.Phase.IDLE or observed.attack_count != 1:
		_fail(
			"Buffered dash attack did not begin when dash movement ended (phase %d, count %d)."
			% [attack_component.phase, observed.attack_count]
		)
		return
	if observed.unsafe_overlap:
		_fail("Dash attack began while player invulnerability was still active.")
		return
	var dash_distance := player.global_position.distance_to(start_position)
	if absf(dash_distance - evade_component.definition.get_distance()) > 8.0:
		_fail("Buffered attack changed the authored dash distance.")
		return

	while attack_component.phase != attack_component.Phase.IDLE:
		await physics_frame
	while not evade_component.is_evade_available():
		await physics_frame

	if not player.request_evade(Vector2.DOWN):
		_fail("Second dash was rejected after the first attack completed.")
		return
	while evade_component.is_dashing():
		await physics_frame
	if not evade_component.is_recovering():
		_fail("Second dash did not enter its normal vulnerable recovery.")
		return
	if not player.request_primary_attack():
		_fail("Attack did not cancel an already-started dash recovery.")
		return
	if not evade_component.is_ready() or attack_component.phase == attack_component.Phase.IDLE:
		_fail("Recovery cancel did not start the normal sword attack immediately.")
		return
	if observed.attack_count != 2 or observed.unsafe_overlap:
		_fail("Dash-to-attack chaining emitted duplicate or unsafe attacks.")
		return

	print("Buffered dash-to-basic-attack smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
