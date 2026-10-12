extends "res://tools/launch_stage_5_renewal.gd"

var checks := 0
var failures := 0

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	_open_dead_forest()
	await create_timer(0.4).timeout
	await _capture("review_controls.png")
	_check(stage.review_hold_approach and not stage.approach_encounter._started,"Review does not wait for an explicit start")
	_check(stage.player.health_component.is_damage_immune,"Peaceful review has no labelled safety")
	for candidate: Node in toolbar.find_children("*","Button",true,false):
		_check(candidate.get_global_rect().end.y < 411,"Review control covers the normal action bar")
	await _click("Overview / gameplay")
	_check(_overview and stage.player.get_node("Camera2D").zoom == Vector2(0.45,0.45),"Overview does not frame Stage V")
	await _click("Overview / gameplay")
	_check(not _overview and stage.player.get_node("Camera2D").zoom == Vector2.ONE,"Gameplay zoom was not restored")
	await _click("Start six sentries")
	await create_timer(1.8).timeout
	_check(stage.approach_encounter._active_enemies == 5 and stage.approach_encounter.get_progress().total == 6,"Real start button does not start the finite encounter")
	await _click("King safe: ON")
	_check(not stage.player.health_component.is_damage_immune,"Safety toggle does not permit real damage")
	stage.player.health_component.apply_damage(DamageInfo.new(99999,stage.approach_encounter,Vector2.ZERO))
	await process_frame
	_check(stage.player.is_defeated,"Fixture did not create a real defeat")
	var old_player: int = stage.player.get_instance_id()
	await _click("Reset Stage V")
	_check(stage.player.get_instance_id() != old_player and not stage.player.is_defeated and stage.player.health_component.current_health == stage.player.health_component.maximum_health,"Reset did not create a fresh full-health Player")
	await _key(KEY_TAB)
	_check(stage.character_menu.visible and not toolbar.visible,"Bag modal does not hide review controls")
	await _key(KEY_ESCAPE)
	_check(not stage.character_menu.visible and toolbar.visible,"Bag close does not restore review controls")
	await _key(KEY_ESCAPE)
	_check(paused and not toolbar.visible,"Pause does not own input and hide review controls")
	await _key(KEY_ESCAPE)
	_check(not paused and toolbar.visible,"Pause close does not restore gameplay")
	await _click("Outdoor sound: ON")
	_check(not stage.outdoor_audio._enabled,"Outdoor sound button does not change playback")
	await _click("Stage IV / Rotcaller")
	_check(stage.scene_file_path == "res://levels/stage_4/stage_4.tscn","Stage IV shortcut does not load its normal renewed scene")
	await _click("Try Rotcaller")
	_check(_trial and stage.encounter_controller.waves[0].total_enemy_count() == 3,"Caster trial shortcut no longer works")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Review lost save suppression")
	print("STAGE_5_REVIEW: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _click(text: String) -> void:
	await process_frame
	await process_frame
	var button: Button
	for candidate: Node in toolbar.find_children("*","Button",true,false):
		if candidate.text == text: button = candidate
	_check(button != null,"Missing button: "+text)
	if button == null: return
	var point := button.get_global_rect().get_center()
	var pressed := [false]
	button.pressed.connect(func() -> void: pressed[0] = true,CONNECT_ONE_SHOT)
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
	await create_timer(0.08).timeout
	_check(pressed[0],"Mouse did not activate: "+text)

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

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
