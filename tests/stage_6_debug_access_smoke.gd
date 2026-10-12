extends SceneTree

const SanctuaryScene = preload("res://levels/sanctuary/sanctuary.tscn")
const STAGE_6_SCENE := "res://levels/stage_6/stage_6.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var sanctuary := SanctuaryScene.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	await process_frame

	var player := sanctuary.get_node("World/Actors/Player") as Player
	var admin_panel := sanctuary.get_node("UI/AdminPanel") as Control
	var stage_6_button := sanctuary.get_node(
		"UI/AdminPanel/Margin/Stack/OpenStage6"
	) as Button
	if player == null or admin_panel == null or stage_6_button == null:
		_fail("Sanctuary is missing the Stage VI debug access controls.")
		return

	var admin_state := root.get_node_or_null("DebugAdminState")
	if admin_state == null:
		_fail("DebugAdminState is unavailable.")
		return
	admin_state.call("set_enabled", false)
	if admin_panel.visible:
		_fail("Admin Tools were visible before the F9 preset.")
		return

	player.apply_debug_testing_preset()
	await process_frame
	if not bool(admin_state.get("enabled")) or not admin_panel.visible:
		_fail("F9 did not reveal Admin Tools in Sanctuary.")
		return

	var requested_target := [""]
	var transition := root.get_node_or_null("SceneTransition")
	transition.transition_started.connect(
		func(target_scene: String) -> void: requested_target[0] = target_scene,
		CONNECT_ONE_SHOT
	)
	stage_6_button.pressed.emit()
	await process_frame
	if requested_target[0] != STAGE_6_SCENE:
		_fail("The visible Stage VI button did not request the preview scene.")
		return

	# Let the threaded scene request finish before quitting the test process.
	await transition.transition_finished
	if current_scene == null or current_scene.scene_file_path != STAGE_6_SCENE:
		_fail("The Stage VI debug request did not finish loading its scene.")
		return
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("STAGE_6_DEBUG_ACCESS_SMOKE_PASSED")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
