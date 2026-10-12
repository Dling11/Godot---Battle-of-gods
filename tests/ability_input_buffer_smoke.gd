extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	var attack := player.attack_component
	var ability := player.ability_2_component
	var observed := {"unsafe_overlap": false}
	attack.phase_changed.connect(func(phase: int, _duration_seconds: float) -> void:
		if phase == MeleeAttackComponent.Phase.ACTIVE and ability.is_casting():
			observed.unsafe_overlap = true
	)

	if not player.request_primary_attack():
		_fail("The normal attack needed for ability-buffer coverage was rejected.")
		return
	if not player.request_ability(2):
		_fail("A ready skill was not buffered during a normal attack.")
		return
	if ability.is_casting():
		_fail("Buffered skill interrupted the live normal attack instead of waiting safely.")
		return
	while not ability.is_casting():
		await physics_frame
	if observed.unsafe_overlap:
		_fail("Buffered skill overlapped the normal attack's damage window.")
		return
	if attack.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Buffered skill did not replace only the normal attack recovery.")
		return
	ability.cancel_cast()
	ability._physics_process(ability.cooldown_remaining + 0.1)

	if not player.request_evade(Vector2.RIGHT):
		_fail("Ready player rejected the dash needed for ability-buffer coverage.")
		return
	if not player.request_ability(2):
		_fail("A ready skill was not buffered during the active dash.")
		return
	if ability.is_casting():
		_fail("Buffered skill began before dash invulnerability ended.")
		return
	while evade_is_dashing(player):
		await physics_frame
	if not ability.is_casting() or player.health_component.is_invulnerable:
		_fail("Dash-buffered skill did not begin at the safe vulnerable boundary.")
		return
	if player.request_evade(Vector2.RIGHT):
		_fail("Buffer accepted a dash that was still unavailable on cooldown.")
		return
	ability.cancel_cast()
	player.queue_free()
	await process_frame

	var king := PlayerScene.instantiate() as Player
	root.add_child(king)
	king.global_position = Vector2(200.0, 200.0)
	await physics_frame
	var pursuit := king.ability_3_component as SovereignPursuitComponent
	var molten_crash := king.ability_2_component as MoltenCrashComponent
	if not pursuit.request_cast_at(Vector2(300.0, 200.0), 25.0):
		_fail("Sovereign Pursuit did not start for the Skill 3-to-2 buffer proof.")
		return
	if not king.request_ability(2):
		_fail("Molten Crash was not retained while Sovereign Pursuit was committed.")
		return
	if molten_crash.is_casting():
		_fail("Buffered Molten Crash overlapped Sovereign Pursuit.")
		return
	while pursuit.is_casting():
		await physics_frame
	if not molten_crash.is_casting():
		_fail("Buffered Molten Crash did not execute when Sovereign Pursuit finished.")
		return
	molten_crash.cancel_cast()
	king.queue_free()
	await process_frame

	var expiry_king := PlayerScene.instantiate() as Player
	root.add_child(expiry_king)
	await physics_frame
	var long_pursuit := expiry_king.ability_3_component as SovereignPursuitComponent
	long_pursuit.definition = long_pursuit.definition.duplicate(true)
	long_pursuit.definition.wind_up_seconds = 0.1
	long_pursuit.definition.active_seconds = 1.0
	long_pursuit.definition.recovery_seconds = 0.4
	if not long_pursuit.request_cast_at(Vector2(100.0, 0.0), 25.0):
		_fail("Long pursuit did not start for buffer-expiry coverage.")
		return
	if not expiry_king.request_primary_attack():
		_fail("Attack intent was not accepted for short-buffer expiry coverage.")
		return
	for frame_index in range(55):
		await physics_frame
	if expiry_king.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Buffered attack began before the long committed ability ended.")
		return
	while long_pursuit.is_casting():
		await physics_frame
	await physics_frame
	if expiry_king.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Expired action lingered and executed after its 0.8-second window.")
		return

	print("Short latest-intent combat buffer smoke test passed.")
	quit(0)


func evade_is_dashing(player: Player) -> bool:
	return player.evade_component.is_dashing()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
