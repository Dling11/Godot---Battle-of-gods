extends Node2D

var accent := Color(.9, .74, .38)
var greeting := ""
var selected := false
var near := false
var enabled := false
var npc: DialogueNpc
var adapter: Node
var speech: PanelContainer
var _speech_timer: Timer
var _last_greeting_ms := -30000

func configure(actor: DialogueNpc, color: Color, line: String, presenter: Node = null) -> void:
	npc = actor
	accent = color
	greeting = line
	adapter = presenter
	npc.add_child(self)
	z_index = -1
	npc.proximity_changed.connect(_on_proximity_changed)
	npc.dialogue_requested.connect(_on_dialogue_requested)
	speech = PanelContainer.new()
	speech.position = Vector2(-105, -96)
	speech.size = Vector2(210, 25)
	speech.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speech.z_index = 5
	var style := StyleBoxFlat.new()
	style.bg_color = Color(.055, .07, .085, .94)
	style.border_color = accent.darkened(.3)
	style.set_border_width_all(1)
	style.set_content_margin_all(5)
	speech.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = greeting
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 11)
	speech.add_child(label)
	add_child(speech)
	speech.hide()
	_speech_timer = Timer.new()
	_speech_timer.one_shot = true
	_speech_timer.wait_time = 3.2
	_speech_timer.timeout.connect(speech.hide)
	add_child(_speech_timer)

func set_enabled(value: bool) -> void:
	enabled = value
	visible = value
	_speech_timer.stop()
	speech.hide()
	near = npc._player_inside if value else false
	queue_redraw()

func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()

func _on_proximity_changed(value: bool, _prompt: String, _icon: Texture2D) -> void:
	near = value
	queue_redraw()
	if not value:
		speech.hide()
		_speech_timer.stop()
	if not enabled or not value or Time.get_ticks_msec() - _last_greeting_ms < 20000:
		return
	_last_greeting_ms = Time.get_ticks_msec()
	speech.show()
	_speech_timer.start()
	if is_instance_valid(adapter): adapter.greet()

func _on_dialogue_requested(_speaker: String, _lines: Array[String], _portrait: Texture2D) -> void:
	speech.hide()
	_speech_timer.stop()

func _draw() -> void:
	var color := accent
	color.a = .95 if near or selected else .38
	var points := PackedVector2Array()
	for index in 33:
		var angle := TAU * index / 32.0
		points.append(Vector2(cos(angle) * 17, sin(angle) * 7 + 1))
	draw_polyline(points, Color(.025,.035,.04,.7), 3)
	draw_polyline(points, color, 1)
	for side in [-1, 1]:
		draw_line(Vector2(side*19,1), Vector2(side*23,1), color, 2)
	if selected:
		draw_colored_polygon(PackedVector2Array([Vector2(-4,-72),Vector2(4,-72),Vector2(0,-67)]), accent)
