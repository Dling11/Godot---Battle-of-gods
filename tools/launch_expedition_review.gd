extends SceneTree

## Explicit no-save review. Helper defeats still use real health/reward authority.
var _stage: Node
var _finishing := false
var _timer: Timer

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").update_progression(100,250)
	root.get_node("StoryState").remember_story(&"awakened_in_sanctuary")
	root.get_node("StoryState").remember_story(&"forgotten_grove_completed")
	var path := "res://levels/stage_5/stage_5.tscn" if "--stage-5" in OS.get_cmdline_user_args() else "res://levels/stage_3/stage_3.tscn"
	_stage = load(path).instantiate()
	if "encounter_controller" in _stage:
		var encounter: EncounterController = _stage.encounter_controller
		encounter.inter_wave_delay = .4
		for index in encounter.waves.size():
			encounter.waves[index] = encounter.waves[index].duplicate(true)
			encounter.waves[index].spawn_interval = .15
			encounter.waves[index].reinforcement_delay = .3
	root.add_child(_stage)
	current_scene = _stage
	_stage.player.health_component.is_damage_immune = true
	root.title = "Battle of Gods — Expedition Objectives & Rewards (NO SAVES)"
	var layer := CanvasLayer.new()
	layer.layer = 4
	_stage.add_child(layer)
	var column := VBoxContainer.new()
	column.position = Vector2(12,230)
	column.add_theme_constant_override("separation",4)
	column.theme = preload("res://ui/themes/sanctuary_theme.gd").build()
	layer.add_child(column)
	var caption := Label.new()
	caption.text = "REVIEW · NO SAVES · KING SAFE"
	caption.add_theme_font_size_override("font_size",10)
	column.add_child(caption)
	_button(column,"Finish encounter", func() -> void: _finishing = true)
	_button(column,"Visit reward chest", _visit_chest)
	var hint := Label.new()
	hint.text = "Continue/skip dialogue · Chest [F]\nView rewards · Esc closes"
	hint.add_theme_font_size_override("font_size",10)
	column.add_child(hint)
	_timer = Timer.new()
	_timer.wait_time = .25
	_timer.timeout.connect(_finish_step)
	_stage.add_child(_timer)
	_timer.start()
	if "--finish" in OS.get_cmdline_user_args(): _finishing = true

func _button(parent: Control, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(190,26)
	button.add_theme_font_size_override("font_size",11)
	button.pressed.connect(action)
	parent.add_child(button)

func _finish_step() -> void:
	if not _finishing or not is_instance_valid(_stage): return
	if "encounter_controller" in _stage:
		for actor: Node in _stage.encounter_controller.actors.get_children():
			if actor != _stage.player and actor.get("health_component") != null: _defeat(actor)
	elif _stage.boss.visible and _stage.boss.target != null:
		_defeat(_stage.boss)

func _defeat(actor: Node) -> void:
	var health := actor.get("health_component") as HealthComponent
	if health.current_health <= 0: return
	var damage := DamageInfo.new(health.maximum_health*10,_stage.player,Vector2.ZERO)
	damage.ignores_invulnerability = true
	health.apply_damage(damage)

func _visit_chest() -> void:
	if not is_instance_valid(_stage): return
	var parent: Node = _stage.encounter_controller.actors if "encounter_controller" in _stage else _stage.reward_parent
	for node in parent.get_children():
		if node is StageRewardChest:
			_stage.player.combat_targeting.cancel_click_move()
			_stage.player.global_position = node.global_position+Vector2(0,-26)
			_stage.player.get_node("Camera2D").reset_smoothing()
			return
