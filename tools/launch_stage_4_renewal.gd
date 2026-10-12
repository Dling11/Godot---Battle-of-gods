extends "res://tools/launch_stage_1_renewal.gd"

const ROT_EVIDENCE := "res://tmp/review/environment/stage_4_renewal_2026_10_03/"
const Trial = preload("res://tools/rotcaller_trial_setup.gd")
var _trial := false
var _with_spitter := false
var _safe := false
var _trial_status: Label
var _interrupts := 0

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/environment/stage_4_renewal_2026_10_03/"))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	if "--trial" in OS.get_cmdline_user_args(): _open_trial()
	else: _open_stage()
	if "--capture" in OS.get_cmdline_user_args():
		root.size = Vector2i(960,540)
		await create_timer(1.0).timeout
		await _capture("review_controls.png")
		toolbar.hide()
		for spec in [["arrival.png",Vector2(768,736)],["living_west.png",Vector2(384,440)],["eastern_gateway.png",Vector2(1200,470)]]:
			_visit(spec[1])
			await _capture(spec[0])
		stage.get_node("UI").hide()
		stage.expedition_feedback.view.hide()
		_toggle_overview()
		await _capture("overview.png")
		_toggle_overview()
		stage.get_node("UI").show()
		stage.expedition_feedback.view.show()
		_visit(Vector2(768,500))
		stage.encounter_controller.start_encounter()
		await create_timer(3.0).timeout
		await _capture("hog_combat.png")
		quit()

func _open_stage() -> void:
	_trial = false
	stage = load("res://levels/stage_4/stage_4.tscn").instantiate()
	stage.review_hold_encounter = true
	root.add_child(stage)
	current_scene = stage
	stage.player.health_component.is_damage_immune = true
	stage.player.health_component.set_current_health(stage.player.health_component.maximum_health)
	root.title = "Battle of Gods — Eastern Rot & Rotcaller Trial (NO SAVES)"
	var column := _column("STAGE IV · NO SAVES\nKing safe · WASD / skills")
	_button(column,"Arrival",func() -> void: _visit(Vector2(768,736)))
	_button(column,"Living west",func() -> void: _visit(Vector2(384,440)))
	_button(column,"Eastern gateway",func() -> void: _visit(Vector2(1200,470)))
	_button(column,"Overview / gameplay",_toggle_overview)
	var combat := _button(column,"Start normal waves",func() -> void: stage.encounter_controller.start_encounter())
	combat.pressed.connect(func() -> void: combat.disabled = true)
	_button(column,"Try Rotcaller",_switch.bind(true))
	_audio_buttons(column)

func _open_trial() -> void:
	_trial = true
	_interrupts = 0
	stage = Trial.create(_with_spitter)
	root.add_child(stage)
	current_scene = stage
	stage.player.health_component.is_damage_immune = _safe
	stage.player.health_component.set_current_health(stage.player.health_component.maximum_health)
	_visit(Vector2(768,560))
	root.title = "Battle of Gods — Rotcaller Combat Trial (NO SAVES)"
	var column := _column("ROTCaller · NO SAVES\nWASD · attack / skills\nHit the caster during warning\nor leave the marked ground.")
	_trial_status = Label.new()
	_trial_status.add_theme_font_size_override("font_size",10)
	_trial_status.text = "1 caster + 2 Rootlings"+(" + Spitter" if _with_spitter else "")+"\nInterrupts: 0"
	column.add_child(_trial_status)
	stage.encounter_controller.enemy_spawned.connect(func(_point: Vector2) -> void:
		for enemy in stage.encounter_controller.actors.get_children():
			if enemy is Rotcaller and not enemy.cast_interrupted.is_connected(_interrupted): enemy.cast_interrupted.connect(_interrupted))
	stage.encounter_controller.stage_cleared.connect(func() -> void: _trial_status.text = "TRIAL CLEARED · Interrupts: %d\nReset to try again" % _interrupts)
	stage.player.defeated.connect(func() -> void: _trial_status.text = "KING DEFEATED\nReset trial to try again")
	var start := _button(column,"Start trial",func() -> void: stage.encounter_controller.start_encounter())
	start.pressed.connect(func() -> void: start.disabled = true)
	_button(column,"Reset trial",_switch.bind(true))
	var ranged := _button(column,"Spitter: ON" if _with_spitter else "Spitter: OFF",func() -> void:
		_with_spitter = not _with_spitter
		_switch(true))
	ranged.tooltip_text = "Starts a fresh trial with one additional ranged foe."
	var safe := _button(column,"King safe: ON" if _safe else "King safe: OFF",func() -> void:
		_safe = not _safe
		stage.player.health_component.is_damage_immune = _safe)
	safe.pressed.connect(func() -> void: safe.text = "King safe: ON" if _safe else "King safe: OFF")
	_button(column,"Stage IV environment",_switch.bind(false))

func _interrupted() -> void:
	_interrupts += 1
	_trial_status.text = "Interrupts: %d · cast cancelled\nCaster exposed for 0.8s" % _interrupts

func _switch(trial: bool) -> void:
	paused = false
	stage.queue_free()
	await process_frame
	_overview = false
	if trial: _open_trial()
	else: _open_stage()

func _column(text: String) -> VBoxContainer:
	toolbar = CanvasLayer.new()
	toolbar.layer = 4
	toolbar.process_mode = Node.PROCESS_MODE_ALWAYS
	stage.add_child(toolbar)
	var layer := toolbar
	var menu: CharacterMenu = stage.character_menu
	var pause_menu: Control = stage.get_node("UI/PauseMenu")
	var sync := func() -> void: layer.visible = not menu.visible and not pause_menu.visible
	menu.visibility_changed.connect(sync)
	pause_menu.visibility_changed.connect(sync)
	var column := VBoxContainer.new()
	column.position = Vector2(12,144)
	column.theme = preload("res://ui/themes/sanctuary_theme.gd").build()
	toolbar.add_child(column)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",10)
	column.add_child(label)
	return column

func _audio_buttons(column: VBoxContainer) -> void:
	var quiet := _button(column,"Outdoor sound: ON",func() -> void:
		var enabled: bool = not stage.get_node("World/LivingWestAudio")._enabled
		for name in ["LivingWestAudio","EasternRotAudio"]: stage.get_node("World/"+name).set_enabled(enabled))
	quiet.pressed.connect(func() -> void: quiet.text = "Outdoor sound: ON" if stage.get_node("World/LivingWestAudio")._enabled else "Outdoor sound: OFF")
	_button(column,"Local wood creak",func() -> void: stage.get_node("World/EasternRotAudio")._play_cue())

func _toggle_overview() -> void:
	_overview = not _overview
	stage.player.get_node("Camera2D").zoom = Vector2(.59,.59) if _overview else Vector2.ONE
	_visit(Vector2(768,448) if _overview else Vector2(768,500))

func _capture(file: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(ROT_EVIDENCE+file) == OK)
