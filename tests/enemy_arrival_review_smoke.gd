extends "res://tools/launch_enemy_arrival_review.gd"

var checks := 0
var failures := 0

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	_check(root.get_node("SaveService").get_profile_path() == "user://enemy_arrival_review.json", "Review uses ordinary profile")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(), "Review can save progression")
	for label in ["One Rootling", "Three: roots + caster", "Eight-live crowd"]:
		await click(label)
		await create_timer(.45).timeout
		var encounter: EncounterController = stage.encounter_controller
		var count := 1 if label.begins_with("One") else (3 if label.begins_with("Three") else 8)
		_check(encounter._active_enemies == count, "Review button did not spawn its labelled count")
		_check(encounter._pending_enemies.is_empty(), "Review silently queued extra enemies")
		_check(_batch_buttons.all(func(b: Button) -> bool: return b.disabled), "Review permits mixing batches without reset")
		for actor in encounter.actors.get_children():
			if actor.get("health_component") != null and actor != stage.player:
				_check(actor.get_node_or_null("EnemyRewardComponent") == null, "Review enemy can grant campaign rewards")
		await click("Reset review")
		await create_timer(.35).timeout
		_check(stage.encounter_controller._active_enemies == 0, "Reset leaves old warnings/enemies")
	await click("King safe: ON")
	_check(not stage.player.health_component.is_damage_immune, "Safety button does not allow vulnerable play")
	await key(KEY_TAB)
	_check(stage.character_menu.visible and not toolbar.visible, "Bag does not hide review controls")
	await key(KEY_ESCAPE)
	_check(not stage.character_menu.visible and toolbar.visible, "Closing bag does not restore review controls")
	await click("Normal Stage IV")
	await create_timer(.3).timeout
	_check(stage.scene_file_path == "res://levels/stage_4/stage_4.tscn" and stage.encounter_controller.waves.size() == 5, "Normal Stage IV button lost real waves")
	stage.queue_free()
	await process_frame
	print("ENEMY_ARRIVAL_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func click(label: String) -> void:
	for button in toolbar.find_children("*","Button",true,false):
		if button.text == label:
			var point: Vector2 = button.get_global_rect().get_center()
			for pressed in [true,false]:
				var event := InputEventMouseButton.new()
				event.position = point
				event.button_index = MOUSE_BUTTON_LEFT
				event.pressed = pressed
				Input.parse_input_event(event)
				await process_frame
			return
	_check(false,"Missing review button: "+label)

func key(code: Key) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
