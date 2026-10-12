extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame

	var attack_component := player.attack_component
	var observed := {"started": 0, "finished": 0}
	attack_component.attack_started.connect(func() -> void: observed.started += 1)
	attack_component.attack_finished.connect(func() -> void: observed.finished += 1)

	if not player.request_primary_attack():
		_fail("Ready player rejected the first basic attack.")
		return
	while attack_component.phase != attack_component.Phase.RECOVERY:
		player.request_primary_attack()
		await physics_frame

	for frame in range(3):
		if not player.request_primary_attack():
			_fail("Repeated primary input was not retained as one buffered attack.")
			return
		await physics_frame
	if observed.started != 1 or observed.finished != 0:
		_fail("Primary spam cancelled recovery and restarted the attack early.")
		return

	while observed.started < 2:
		await physics_frame
	if observed.finished != 1:
		_fail("Buffered primary did not wait for the first attack to finish.")
		return
	if attack_component.phase != attack_component.Phase.WIND_UP:
		_fail("Buffered primary did not begin as a fresh wind-up.")
		return

	print("Basic attack repeat cadence smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
