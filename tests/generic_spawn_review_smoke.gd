extends "res://tools/launch_generic_spawn_review.gd"

var checks := 0
var failures := 0
var shared_frames: SpriteFrames

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	await process_frame
	await process_frame
	_check(root.get_node("SaveService").get_profile_path() == "user://generic_spawn_review.json", "Review uses normal saves")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(), "Review can autosave")
	var image := Image.load_from_file(ProjectSettings.globalize_path("res://assets/vfx/generic_enemy_arrival/ground.png"))
	var binary := true
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x,y).a
			if alpha != 0.0 and alpha != 1.0: binary = false
	_check(binary and image.get_size() == Vector2i(256,64), "Shared atlas is not four binary-alpha cells")
	for index in FOES.size():
		if index == 0: await click("Spawn selected foe")
		else: await pick_foe(index)
		var encounter: EncounterController = stage.encounter_controller
		_check(_foe_index == index and encounter._arrivals.size() == 1 and encounter._active_enemies == 1, "Enemy picker lost the real reservation")
		if encounter._arrivals.is_empty():
			print("PICK_DEBUG expected=",index," chosen=",_foe_index," selected=",foe_picker.selected," rebuilding=",_rebuilding," active=",encounter._active_enemies," queued=",encounter._pending_enemies.size())
			quit(1)
			return
		var pending: Node = encounter._arrivals.keys()[0]
		var effect: SummonEffect = encounter._arrivals[pending].effect
		_check(pending.scene_file_path == FOES[index].scene.resource_path, "Picker spawned the wrong actor")
		if index == 0: shared_frames = effect.sprite.sprite_frames
		_check(is_same(effect.sprite.sprite_frames,shared_frames), "Another enemy size loads separate drawings")
		_check(effect.sprite.scale == Vector2.ONE and effect.scale == Vector2.ONE and effect.sprite.position == Vector2(0,-14), "Shared cue scales or changes floor origin for another body")
		_check(shared_frames.get_frame_count(&"warning") == 1 and shared_frames.get_frame_count(&"release") == 3, "Shared effect needs more than four drawings")
		var point: Vector2 = effect.global_position
		paused = true
		await create_timer(.25,true).timeout
		_check(not effect.released and encounter._arrivals.size() == 1 and effect.sprite.frame == 0, "Pause advances warning/actor arrival")
		paused = false
		await create_timer(.36,false).timeout
		_check(effect.released and effect.sprite.animation == &"release" and effect.global_position == point, "Real release does not drive the planted effect")
		_check(encounter._arrivals.is_empty() and pending.is_inside_tree(), "Actor did not materialize through normal authority")
		_check(pending.get_node_or_null("EnemyRewardComponent") == null, "Comparison actor has rewards")
		await create_timer(.60,false).timeout
		_check(not is_instance_valid(effect), "Shared effect leaks after fading")
	await click("Ground: grass")
	_check(_dark_ground and stage.encounter_controller._active_enemies == 1, "Dark ground loses the selected foe")
	await create_timer(.4,false).timeout
	await click("Reset review")
	await click("Three: roots + caster")
	await create_timer(.4,false).timeout
	_check(stage.encounter_controller._active_enemies == 3, "Mixed batch lost real actors")
	await click("Reset review")
	await click("Eight-live crowd")
	await create_timer(.4,false).timeout
	_check(stage.encounter_controller._active_enemies == 8 and stage.encounter_controller._pending_enemies.is_empty(), "Shared cue changes crowd caps/queues")
	await click("Replay same batch")
	_check(stage.encounter_controller._active_enemies == 8, "Replay changes crowd count")
	await key(KEY_TAB)
	_check(stage.character_menu.visible and not toolbar.visible, "Bag overlaps review controls")
	await key(KEY_ESCAPE)
	_check(not stage.character_menu.visible and toolbar.visible, "Bag does not restore controls")
	for button: Button in toolbar.find_children("*","Button",true,false):
		_check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(button.get_global_rect()), "Button outside native viewport")
	stage.queue_free()
	await process_frame
	print("GENERIC_SPAWN_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func pick_foe(index: int) -> void:
	await mouse_click(foe_picker.get_global_rect().get_center())
	_check(foe_picker.get_popup().visible,"Enemy picker did not open")
	var popup := foe_picker.get_popup()
	# Native popups have a separate input window. Exercise their selection
	# signal after opening with the real mouse, without stealing OS input.
	popup.index_pressed.emit(index)
	popup.hide()
	await process_frame
	while _rebuilding: await process_frame

func click(label: String) -> void:
	for button: Button in toolbar.find_children("*","Button",true,false):
		if button.text == label:
			await mouse_click(button.get_global_rect().get_center())
			return
	_check(false,"Missing button: "+label)

func mouse_click(point: Vector2) -> void:
	for pressed in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
	await process_frame
	while _rebuilding: await process_frame

func key(code: Key) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
