extends "res://tools/launch_stage_1_renewal.gd"

const THORN_EVIDENCE := "res://tmp/review/environment/stage_2_renewal_2026_10_03/"
var _music_enabled := true
var _ambience_enabled := true

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/environment/stage_2_renewal_2026_10_03/"))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	stage = load("res://levels/stage_2/stage_2.tscn").instantiate()
	stage.review_hold_encounter = true
	root.add_child(stage)
	current_scene = stage
	root.title = "Battle of Gods — Stage 2 Bramble & Sound Review (NO SAVES)"
	stage.player.health_component.is_damage_immune = true
	toolbar = CanvasLayer.new()
	toolbar.layer = 4
	stage.add_child(toolbar)
	var column := VBoxContainer.new()
	column.position = Vector2(12,170)
	column.theme = preload("res://ui/themes/sanctuary_theme.gd").build()
	toolbar.add_child(column)
	var label := Label.new()
	label.text = "STAGE II · NO SAVES\nKing safe · WASD / skills"
	label.add_theme_font_size_override("font_size",10)
	column.add_child(label)
	_button(column,"Arrival",func() -> void: _visit(Vector2(768,736)))
	_button(column,"Broken Heart",func() -> void: _visit(Vector2(768,520)))
	_button(column,"North threshold",func() -> void: _visit(Vector2(768,180)))
	_button(column,"Overview / gameplay",_toggle_overview)
	var combat := _button(column,"Start normal waves",func() -> void:
		stage.encounter_controller.start_encounter())
	combat.pressed.connect(func() -> void: combat.disabled = true)
	var music_button := _button(column,"Music: ON",func() -> void:
		_music_enabled = not _music_enabled
		root.get_node("AudioDirector").music_player.stream_paused = not _music_enabled)
	music_button.pressed.connect(func() -> void: music_button.text = "Music: ON" if _music_enabled else "Music: OFF")
	var ambience_button := _button(column,"Outdoor sound: ON",func() -> void:
		_ambience_enabled = not _ambience_enabled
		stage.get_node("World/OutdoorAudio").set_enabled(_ambience_enabled))
	ambience_button.pressed.connect(func() -> void: ambience_button.text = "Outdoor sound: ON" if _ambience_enabled else "Outdoor sound: OFF")
	_button(column,"Local bird call",func() -> void: stage.get_node("World/OutdoorAudio")._play_cue())
	_button(column,"Music handoff demo",func() -> void:
		var director := root.get_node("AudioDirector")
		director.play_music(preload("res://assets/audio/music/boss/varkuun_battle_rpg_theme_loop.ogg"), -13.0)
		await create_timer(4.0).timeout
		if is_instance_valid(stage):
			director.play_music(stage.get_node("StageMusic").music_stream, -13.0))
	if "--capture" in OS.get_cmdline_user_args():
		root.size = Vector2i(960,540)
		await create_timer(1.0).timeout
		toolbar.hide()
		for spec in [["arrival.png",Vector2(768,736)],["ruin.png",Vector2(768,520)],["threshold.png",Vector2(768,180)]]:
			_visit(spec[1])
			await _capture(spec[0])
		_visit(Vector2(505,640))
		await create_timer(.4).timeout
		await _capture("canopy_readability.png")
		stage.get_node("UI").hide()
		stage.expedition_feedback.view.hide()
		_toggle_overview()
		await _capture("overview.png")
		stage.get_node("UI").show()
		stage.expedition_feedback.view.show()
		_toggle_overview()
		_visit(Vector2(768,520))
		stage.encounter_controller.start_encounter()
		await create_timer(2.2).timeout
		await _capture("combat.png")
		quit()

func _toggle_overview() -> void:
	_overview = not _overview
	var camera: Camera2D = stage.player.get_node("Camera2D")
	camera.zoom = Vector2(.59,.59) if _overview else Vector2.ONE
	_visit(Vector2(768,448) if _overview else Vector2(768,520))

func _capture(file: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(THORN_EVIDENCE+file) == OK)

