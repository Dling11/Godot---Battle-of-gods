extends SceneTree

const PauseMenuScene = preload("res://ui/pause_menu.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var menu := PauseMenuScene.instantiate() as PauseMenu
	root.add_child(menu)
	await process_frame
	if menu.visible or paused:
		_fail("Pause menu was visible or paused before being opened.")
		return
	menu.open_menu()
	if not menu.visible or not paused:
		_fail("Pause menu did not open and pause the stage.")
		return
	var sfx_index := AudioServer.get_bus_index(AudioDirector.SFX_BUS)
	if sfx_index < 0:
		_fail("Pause menu could not access the SFX bus.")
		return
	var was_muted := AudioServer.is_bus_mute(sfx_index)
	menu.toggle_sfx()
	if AudioServer.is_bus_mute(sfx_index) == was_muted:
		_fail("Pause menu SFX toggle did not update the shared audio bus.")
		return
	menu.toggle_sfx()
	menu.close_menu()
	if menu.visible or paused:
		_fail("Pause menu did not resume the stage cleanly.")
		return
	if menu.sanctuary_scene.is_empty() or not ResourceLoader.exists(menu.sanctuary_scene):
		_fail("Pause menu has no valid Sanctuary return destination.")
		return
	print("In-stage pause menu smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
