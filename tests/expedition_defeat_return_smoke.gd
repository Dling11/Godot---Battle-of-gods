extends SceneTree

const DefeatReturnScript = preload(
	"res://gameplay/expeditions/expedition_defeat_return.gd"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_session := root.get_node("RunSession")
	var save_service := root.get_node("SaveService")
	save_service.suppress_autosave_for_debug_session()
	run_session.reset_run()
	run_session.update_progression(725, 113)
	var context := Node.new()
	root.add_child(context)
	if not DefeatReturnScript.request(context):
		_fail("Defeat return did not accept a valid Sanctuary transition.")
		return
	if run_session.total_experience != 725 or run_session.coins != 113:
		_fail("Defeat return reset progression before leaving the expedition.")
		return
	var transition := root.get_node("SceneTransition")
	await transition.transition_finished
	if run_session.total_experience != 725 or run_session.coins != 113:
		_fail("Returning to Sanctuary erased the player's level or coins.")
		return
	if current_scene == null or current_scene.scene_file_path != DefeatReturnScript.SANCTUARY_SCENE:
		_fail("Defeat did not finish in Sanctuary.")
		return
	print("Expedition defeat return preserves progression and reaches Sanctuary.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
