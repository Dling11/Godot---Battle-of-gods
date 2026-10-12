extends CanvasLayer

const MapDrawing = preload("res://levels/sanctuary/town/town_map_drawing.gd")
const ThemeKit = preload("res://ui/themes/sanctuary_theme.gd")
## Owner requested temporary map withdrawal during layout iteration.
const PRESENTATION_ENABLED := false
var entries: Array[Dictionary] = []
var player: Node2D
var hub: Node
var panel: PanelContainer
var mini: PanelContainer
var mini_drawing: Control
var drawing: Control
var guidance: Label
var selected_id := ""
var enabled := false
var suspended := false
var _timer: Timer
var _modals: Array[Control] = []

func configure(owner_hub: Node, service_entries: Array[Dictionary], path_routes: Array[PackedVector2Array]) -> void:
	hub = owner_hub
	player = hub.get_node("World/Actors/Player")
	entries = service_entries
	layer = 16
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(292, 0)
	panel.theme = ThemeKit.build()
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.add_theme_stylebox_override("panel",ThemeKit.frame(12))
	add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",4)
	panel.add_child(stack)
	var heading := HBoxContainer.new()
	stack.add_child(heading)
	var title := Label.new()
	title.text = "SANCTUARY  ·  M"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size",13)
	heading.add_child(title)
	var close := Button.new()
	close.text = "×"
	close.custom_minimum_size = Vector2(22,22)
	close.pressed.connect(func() -> void:
		panel.hide()
		_refresh())
	heading.add_child(close)
	drawing = MapDrawing.new()
	drawing.custom_minimum_size = Vector2(268,156)
	drawing.interactive = true
	drawing.destination_selected.connect(select_destination)
	drawing.player = player
	drawing.entries = entries
	drawing.routes = path_routes
	stack.add_child(drawing)
	for entry in entries:
		var button := Button.new()
		button.text = str(entry.name) + " · " + str(entry.role)
		button.custom_minimum_size.y = 20
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size",12)
		button.add_theme_color_override("font_color",entry.color)
		button.pressed.connect(select_destination.bind(str(entry.id)))
		stack.add_child(button)
	var clear := Button.new()
	clear.text = "Clear destination"
	clear.custom_minimum_size.y = 20
	clear.add_theme_font_size_override("font_size",11)
	clear.pressed.connect(clear_destination)
	stack.add_child(clear)
	guidance = Label.new()
	guidance.position = Vector2(348,108)
	guidance.size = Vector2(300,24)
	guidance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guidance.add_theme_font_size_override("font_size",13)
	guidance.add_theme_constant_override("outline_size",5)
	guidance.add_theme_color_override("font_outline_color",Color(.025,.035,.045,.95))
	add_child(guidance)
	_timer = Timer.new()
	_timer.wait_time = .15
	_timer.timeout.connect(_refresh)
	add_child(_timer)
	_build_mini(path_routes)
	get_viewport().size_changed.connect(_layout)
	_layout()
	panel.hide()
	guidance.hide()
	_modals.assign([hub.dialogue_panel,hub.character_menu,hub.rootforge_menu,hub.umi_exchange_menu,hub.expedition_menu,hub.get_node("UI/PauseMenu")])
	for modal in _modals:
		modal.visibility_changed.connect(_on_modal_visibility_changed.bind(modal))

func _on_modal_visibility_changed(modal: Control) -> void:
	if modal.visible:
		hide_for_modal()

func hide_for_modal() -> void:
	panel.hide()
	mini.hide()
	guidance.hide()

func set_enabled(value: bool) -> void:
	enabled = value and PRESENTATION_ENABLED
	set_process_unhandled_key_input(enabled)
	if enabled:
		_timer.start()
		_refresh()
	else:
		_timer.stop()
		panel.hide()
		mini.hide()
		clear_destination()

func toggle() -> void:
	if enabled and not suspended and not get_tree().paused and not hub.dialogue_panel.visible:
		panel.visible = not panel.visible
		_refresh()

func select_destination(service_id: String) -> void:
	if not enabled or suspended: return
	selected_id = service_id
	for entry in entries:
		if entry.has("beacon"): entry.beacon.set_selected(str(entry.id) == selected_id)
	panel.hide()
	_refresh()

func clear_destination() -> void:
	selected_id = ""
	for entry in entries:
		if entry.has("beacon"): entry.beacon.set_selected(false)
	guidance.hide()
	if is_instance_valid(drawing):
		drawing.selected_id = ""
		drawing.queue_redraw()
		mini_drawing.selected_id = ""
		mini_drawing.queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M and enabled and not suspended and not hub.dialogue_panel.visible:
		toggle()
		get_viewport().set_input_as_handled()

func _refresh() -> void:
	if not enabled: return
	var modal_open := get_tree().paused or suspended
	for modal in _modals: modal_open = modal_open or modal.visible
	if modal_open:
		panel.hide()
		mini.hide()
		guidance.hide()
		return

	drawing.selected_id = selected_id
	mini.visible = not panel.visible
	mini_drawing.selected_id = selected_id
	if mini.visible: mini_drawing.queue_redraw()
	if panel.visible: drawing.queue_redraw()
	guidance.visible = not selected_id.is_empty()
	for entry in entries:
		if str(entry.id) != selected_id: continue
		var target: Node2D = entry.node
		var offset := target.global_position - player.global_position
		var direction := "→" if offset.x >= 0 else "←"
		if absf(offset.y) > absf(offset.x): direction = "↓" if offset.y >= 0 else "↑"
		if offset.length() < 50: direction = "[F]"
		guidance.text = direction + "  " + str(entry.name) + " · " + str(entry.role)
		guidance.modulate = entry.color
		return

func set_suspended(value: bool) -> void:
	suspended = value
	_refresh()

func _layout() -> void:
	var width := get_viewport().get_visible_rect().size.x
	panel.position = Vector2(width-304,48)
	mini.position = Vector2(width-212,48)
	guidance.position.x = (width-guidance.size.x)/2

func _build_mini(routes: Array[PackedVector2Array]) -> void:
	mini = PanelContainer.new()
	mini.custom_minimum_size.x = 200
	mini.theme = panel.theme
	mini.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mini.add_theme_stylebox_override("panel",ThemeKit.frame(12))
	mini.tooltip_text = "Town directory · Click or press M"
	add_child(mini)
	var stack := VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.add_child(stack)
	var heading := Label.new()
	heading.text = "SANCTUARY · [M]"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size",11)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(heading)
	mini_drawing = MapDrawing.new()
	mini_drawing.custom_minimum_size = Vector2(176,114)
	mini_drawing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini_drawing.player = player
	mini_drawing.entries = entries
	mini_drawing.routes = routes
	stack.add_child(mini_drawing)
	mini.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			mini.accept_event()
			toggle())
	mini.hide()
