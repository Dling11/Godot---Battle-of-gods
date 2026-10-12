extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame

	## Reach the old idempotence edge case first: F9 must still activate its
	## combat helpers when level and coins already match the preset.
	player.progression_component.apply_debug_testing_preset()
	if not player.request_ability(2):
		_fail("Riftbreak was unavailable before enabling the debug helper.")
		return
	player.ability_2_component.cancel_cast()
	if player.ability_2_component.cooldown_remaining <= 0.0:
		_fail("The authored Riftbreak cooldown was not active before F9.")
		return

	var f9_event := InputEventAction.new()
	f9_event.action = "debug_max_progression"
	f9_event.pressed = true
	player._unhandled_input(f9_event)
	var admin_state := root.get_node_or_null("DebugAdminState")
	if admin_state == null or not bool(admin_state.get("enabled")):
		_fail("F9 did not enable the debug review destinations.")
		return
	if player.ability_2_component.cooldown_remaining > 0.0:
		_fail("F9 did not clear an existing skill cooldown.")
		return
	if not player.request_ability(2):
		_fail("Riftbreak could not be reused after F9 cleared its cooldown.")
		return
	while player.ability_2_component.is_casting():
		await physics_frame
	if player.ability_2_component.cooldown_remaining > 0.0 or not player.ability_2_component.is_ready():
		_fail("F9 did not clear Riftbreak automatically when its cast finished.")
		return
	if not player.request_ability(2):
		_fail("An unlimited debug skill could not be cast consecutively.")
		return

	print("F9 unlimited-skills debug smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
