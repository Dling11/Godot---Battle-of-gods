extends SceneTree

const EVIDENCE := "res://tmp/review/environment/stage_1_renewal_2026_10_02/"
var stage: Node
var toolbar: CanvasLayer
var _overview := false

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/environment/stage_1_renewal_2026_10_02/"))
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	stage = load("res://levels/test_arena/test_arena.tscn").instantiate()
	stage.encounter_controller.auto_start = false
	root.add_child(stage)
	current_scene = stage
	root.title = "Battle of Gods — Stage 1 Woodland Renewal (NO SAVES)"
	stage.player.health_component.is_damage_immune = true
	toolbar = CanvasLayer.new()
	toolbar.layer = 4
	stage.add_child(toolbar)
	var column := VBoxContainer.new()
	column.position = Vector2(12,180)
	column.theme = preload("res://ui/themes/sanctuary_theme.gd").build()
	toolbar.add_child(column)
	var label := Label.new()
	label.text = "STAGE 1 REVIEW · NO SAVES\nKing safe · WASD to explore"
	label.add_theme_font_size_override("font_size",10)
	column.add_child(label)
	_button(column,"Entrance",func() -> void: _visit(Vector2(960,880)))
	_button(column,"Glade",func() -> void: _visit(Vector2(960,620)))
	_button(column,"Old shrine",func() -> void: _visit(Vector2(960,416)))
	_button(column,"Overview / gameplay",_toggle_overview)
	var combat := _button(column,"Start normal waves",func() -> void:
		stage.encounter_controller.start_encounter())
	combat.pressed.connect(func() -> void: combat.disabled = true)
	if "--capture" in OS.get_cmdline_user_args():
		root.size = Vector2i(960,540)
		await create_timer(.3).timeout
		toolbar.hide()
		for spec in [["entrance.png",Vector2(960,880)],["glade.png",Vector2(960,620)],["shrine.png",Vector2(960,416)]]:
			_visit(spec[1])
			await _capture(spec[0])
		_visit(Vector2(390,770))
		await create_timer(.4).timeout
		await _capture("canopy_readability.png")
		_visit(Vector2(960,620))
		await create_timer(2.2).timeout
		await _capture("ambient_flight_a.png")
		await create_timer(.5).timeout
		await _capture("ambient_flight_b.png")
		stage.get_node("UI").hide()
		stage.expedition_feedback.view.hide()
		_toggle_overview()
		await _capture("overview.png")
		quit()

func _button(parent: Node,text: String,action: Callable) -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.text = text
	button.custom_minimum_size = Vector2(164,25)
	button.add_theme_font_size_override("font_size",11)
	parent.add_child(button)
	button.pressed.connect(action)
	return button

func _visit(point: Vector2) -> void:
	stage.player.combat_targeting.cancel_click_move()
	stage.player.global_position = point
	stage.player.get_node("Camera2D").reset_smoothing()

func _toggle_overview() -> void:
	_overview = not _overview
	var camera: Camera2D = stage.player.get_node("Camera2D")
	camera.zoom = Vector2(.47,.47) if _overview else Vector2.ONE
	_visit(Vector2(960,576) if _overview else Vector2(960,620))

func _capture(file: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(EVIDENCE+file) == OK)
