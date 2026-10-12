extends SceneTree

## Actual five-skill kit. Paused enemies let the owner inspect before enabling AI.
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
	lab.enemy_selector.select(0)
	lab._on_roster_selected(0)
	lab.set_enemy_ai_enabled(false)
	lab.set_player_invincible(false)
	lab.spawn_selected(4)
	lab.get_node("KingCombatReview").open_review()
	lab.get_node("KingCombatReview").set_worldsplitter_rank(2)
	root.title = "Battle of Gods — Worldsplitter Summoned Swords Review"
