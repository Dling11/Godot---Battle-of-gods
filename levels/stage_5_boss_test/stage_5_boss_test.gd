extends Node

@export var player: Player
@export var boss: Stage5Boss
@export var combat_hud: CombatHUD
@export var boss_hud: BossHealthHUD
@export var state_label: Label


func _ready() -> void:
	if player == null or boss == null or combat_hud == null or boss_hud == null or state_label == null:
		push_error("Stage5BossTest is missing a required dependency.")
		return
	combat_hud.bind_player(player)
	boss.target = player
	boss_hud.bind_boss(boss.health_component, "STAGE 5 BOSS", "COMBAT PROOF")
	boss.health_component.died.connect(_on_boss_died)
	boss.state_changed.connect(_on_boss_state_changed)
	player.defeated.connect(_on_player_defeated)
	_on_boss_state_changed(boss.state, 0.0)
	combat_hud.show_story_message("STAGE 5 BOSS PROOF  |  F9 SKILLS  |  R RESTART  |  F8 EXIT", 4.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("arena_restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()
	elif event.is_action_pressed("debug_stage_5_boss_arena"):
		get_viewport().set_input_as_handled()
		var transition := get_node_or_null("/root/SceneTransition")
		if transition != null:
			transition.call("transition_to", "res://levels/sanctuary/sanctuary.tscn")


func _on_boss_state_changed(state: Stage5Boss.State, _duration_seconds: float) -> void:
	state_label.text = "STATE: " + Stage5Boss.State.keys()[state].replace("_", " ")


func _on_boss_died() -> void:
	state_label.text = "BOSS PROOF CLEARED  |  R TO RESTART"


func _on_player_defeated() -> void:
	combat_hud.show_defeat()
	state_label.text = "KING DEFEATED  |  R TO RESTART"
