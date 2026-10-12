extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not InputMap.has_action("debug_max_progression"):
		_fail("Debug maximum-progression action is missing.")
		return
	var has_f9 := false
	for event: InputEvent in InputMap.action_get_events("debug_max_progression"):
		if event is InputEventKey and event.physical_keycode == KEY_F9:
			has_f9 = true
			break
	if not has_f9:
		_fail("Debug maximum-progression action is not physically bound to F9.")
		return

	var has_right_click := false
	var has_left_click := false
	for event: InputEvent in InputMap.action_get_events("player_attack_primary"):
		if event is InputEventMouseButton:
			has_right_click = has_right_click or event.button_index == MOUSE_BUTTON_RIGHT
			has_left_click = has_left_click or event.button_index == MOUSE_BUTTON_LEFT
	if not has_left_click or has_right_click:
		_fail("Manual primary attack must use left-click without binding right-click to the attack action.")
		return
	var expected_number_keys := {
		"player_skill_1": KEY_1,
		"player_skill_2": KEY_2,
		"player_skill_3": KEY_3,
		"player_skill_4": KEY_4,
	}
	for action: String in expected_number_keys:
		var found_key := false
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventKey and event.physical_keycode == expected_number_keys[action]:
				found_key = true
				break
		if not found_key:
			_fail("%s is not bound to its intended numbered action key." % action)
			return

	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(player)
	root.add_child(hud)
	hud.bind_player(player)
	await process_frame
	player.global_position = Vector2(100.0, 100.0)
	if not player.request_directional_primary_attack(Vector2(20.0, 100.0)):
		_fail("Directional left-click attack request was rejected while idle.")
		return
	if player.facing_direction != Vector2.LEFT:
		_fail("Clicking left of King did not face the manual sword attack left.")
		return
	player.attack_component.cancel_attack()
	if not player.request_directional_primary_attack(Vector2(100.0, 180.0)):
		_fail("Second directional click attack request was rejected while idle.")
		return
	if player.facing_direction != Vector2.DOWN:
		_fail("Clicking below King did not face the manual sword attack down.")
		return
	player.attack_component.cancel_attack()

	var input_source := player.input_source
	if input_source.resolve_cardinal_facing(Vector2.RIGHT, Vector2.DOWN) != Vector2.RIGHT:
		_fail("Horizontal movement did not resolve to horizontal combat facing.")
		return
	if input_source.resolve_cardinal_facing(Vector2(1.0, -1.0), Vector2.RIGHT) != Vector2.RIGHT:
		_fail("Diagonal movement did not retain its matching horizontal facing axis.")
		return
	if input_source.resolve_cardinal_facing(Vector2(1.0, -1.0), Vector2.UP) != Vector2.UP:
		_fail("Diagonal movement did not retain its matching vertical facing axis.")
		return
	if input_source.resolve_cardinal_facing(Vector2.ZERO, Vector2.LEFT) != Vector2.LEFT:
		_fail("Standing still did not retain the last movement-facing direction.")
		return

	Input.action_press("player_move_left")
	await process_frame
	await physics_frame
	Input.action_release("player_move_left")
	await physics_frame
	if player.facing_direction != Vector2.LEFT:
		_fail("Live WASD movement did not become Player combat-facing authority.")
		return
	await physics_frame
	if player.facing_direction != Vector2.LEFT:
		_fail("Player facing changed while standing without movement input.")
		return

	var debug_event := InputEventAction.new()
	debug_event.action = "debug_max_progression"
	debug_event.pressed = true
	player._unhandled_input(debug_event)
	var run_session := root.get_node("RunSession")
	if (
		player.progression_component.level != 10
		or player.progression_component.coins != 999
		or run_session.total_experience != 4950
		or run_session.coins != 999
	):
		_fail("F9 testing preset did not synchronize level 10 and 999 coins.")
		return
	if not hud.stage_label.text.contains("DEBUG TEST"):
		_fail("F9 testing preset did not provide visible HUD confirmation.")
		return

	print("Player control scheme and debug testing preset smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	Input.action_release("player_move_left")
	push_error(message)
	quit(1)
