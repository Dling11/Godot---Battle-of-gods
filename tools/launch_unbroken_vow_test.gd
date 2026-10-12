extends SceneTree

## Direct entry to the same F7 -> Skills tab -> BUFF · ANIMATION TEST surface.
func _initialize() -> void:
	call_deferred("_launch")

func _launch() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab: Node = load("res://levels/combat_lab/combat_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.get_node("KingCombatReview").open_buff_test()
