extends "res://tools/launch_stage_4_renewal.gd"

const DEAD_EVIDENCE := "res://tmp/review/environment/stage_5_renewal_2026_10_03/"

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	_open_dead_forest()
	if "--capture" in OS.get_cmdline_user_args():
		root.size = Vector2i(960,540)
		await create_timer(0.6).timeout
		await _capture("review_controls.png")
		toolbar.hide()
		await _capture("arrival.png")
		_visit(Vector2(768,700))
		await _capture("approach.png")
		_toggle_overview()
		await _capture("overview.png")
		quit()

func _open_dead_forest() -> void:
	stage = load("res://levels/stage_5/stage_5.tscn").instantiate()
	stage.review_hold_approach = true
	root.add_child(stage)
	current_scene = stage
	stage.player.health_component.is_damage_immune = true
	stage.player.health_component.set_current_health(stage.player.health_component.maximum_health)
	root.title = "Battle of Gods — Stage V Dead Forest & Sentries (NO SAVES)"
	var column := _column("STAGE V · NO SAVES\nWASD · attack / skills")
	var row := HBoxContainer.new()
	column.add_child(row)
	var left := VBoxContainer.new()
	var right := VBoxContainer.new()
	row.add_child(left)
	row.add_child(right)
	_button(left,"Arrival gateway",func() -> void: _visit(Vector2(768,1020)))
	_button(left,"Sentry approach",func() -> void: _visit(Vector2(768,850)))
	_button(left,"Northern basin",func() -> void: _visit(Vector2(768,575)))
	_button(left,"Overview / gameplay",_toggle_overview)
	var combat := _button(left,"Start six sentries",func() -> void: stage.approach_encounter.start_encounter())
	combat.pressed.connect(func() -> void: combat.disabled = true)
	var safety := _button(right,"King safe: ON",func() -> void: stage.player.health_component.is_damage_immune = not stage.player.health_component.is_damage_immune)
	safety.pressed.connect(func() -> void: safety.text = "King safe: ON" if stage.player.health_component.is_damage_immune else "King safe: OFF")
	_button(right,"Reset Stage V",_reset_dead_forest)
	_button(right,"Stage IV / Rotcaller",_switch.bind(false))
	var ambience := _button(right,"Outdoor sound: ON",func() -> void: stage.outdoor_audio.set_enabled(not stage.outdoor_audio._enabled))
	ambience.pressed.connect(func() -> void: ambience.text = "Outdoor sound: ON" if stage.outdoor_audio._enabled else "Outdoor sound: OFF")
	_button(right,"Local dead wood creak",func() -> void: stage.outdoor_audio._play_cue())

func _reset_dead_forest() -> void:
	paused = false
	stage.queue_free()
	await process_frame
	_overview = false
	_open_dead_forest()

func _toggle_overview() -> void:
	if not "approach_encounter" in stage:
		super._toggle_overview()
		return
	_overview = not _overview
	var camera: Camera2D = stage.player.get_node("Camera2D")
	camera.zoom = Vector2(0.45,0.45) if _overview else Vector2.ONE
	_visit(Vector2(768,576) if _overview else Vector2(768,850))

func _capture(name: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEAD_EVIDENCE))
	root.get_texture().get_image().save_png(DEAD_EVIDENCE+name)
