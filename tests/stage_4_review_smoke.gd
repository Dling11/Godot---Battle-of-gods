extends "res://tools/launch_stage_4_renewal.gd"

var checks := 0
var failures := 0

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/characters/rotcaller_2026_10_03/"))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	_open_stage()
	await create_timer(.35).timeout
	await _click_button("Try Rotcaller")
	_check(_trial and not stage.player.health_component.is_damage_immune,"Try Rotcaller does not enter a vulnerable trial")
	_check(stage.player.health_component.current_health == stage.player.health_component.maximum_health,"Trial does not start with full health")
	await _click_button("Start trial")
	await create_timer(.7).timeout
	_check(stage.encounter_controller.get_progress().total == 3,"Start trial does not start the selected encounter")
	stage.player.health_component.apply_damage(DamageInfo.new(99999,stage.encounter_controller,Vector2.ZERO))
	await process_frame
	_check(stage.player.is_defeated and _trial_status.text.contains("Reset trial"),"Defeated trial does not explain its reset")
	await _click_button("Reset trial")
	_check(not stage.player.is_defeated and stage.player.health_component.current_health == stage.player.health_component.maximum_health,"Reset retains defeated state or depleted HP")
	await _click_button("Spitter: OFF")
	_check(_with_spitter and stage.encounter_controller.waves[0].total_enemy_count() == 4,"Spitter button does not rebuild the four-slot trial")
	await _click_button("King safe: OFF")
	_check(stage.player.health_component.is_damage_immune,"Safety button does not affect actual damage authority")
	# Tab uses the real bag/pause boundary inside the trial.
	await _key(KEY_TAB)
	_check(stage.character_menu.visible and paused and not toolbar.visible,"Trial bag cannot own pause and hide review controls")
	await _key(KEY_ESCAPE)
	_check(not paused and not stage.character_menu.visible,"Trial bag cannot release pause")
	await _capture_trial()
	await _click_button("Stage IV environment")
	_check(not _trial and stage.encounter_controller.waves.size() == 5 and stage.encounter_controller.max_active_enemies == 8,"Return to environment loses canonical Stage IV encounters")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Review controls re-enable normal saving")
	print("STAGE_4_REVIEW: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _click_button(text: String) -> void:
	await process_frame
	await process_frame
	var button: Button
	for candidate: Node in toolbar.find_children("*","Button",true,false):
		if candidate.text == text: button = candidate
	_check(button != null,"Review button missing: "+text)
	if button == null: return
	var point := button.get_global_rect().get_center()
	Input.warp_mouse(point)
	await process_frame
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = true
	root.push_input(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame
	await create_timer(.08).timeout

func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func _capture_trial() -> void:
	await RenderingServer.frame_post_draw
	var path := "res://tmp/review/characters/rotcaller_2026_10_03/trial_controls.png"
	_check(root.get_texture().get_image().save_png(path) == OK,"Trial control capture failed")

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
