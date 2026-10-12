class_name ExpeditionMenu
extends Control

signal menu_closed

@export var expeditions: Array[ExpeditionDefinition] = []
@export var progression_definition: ProgressionDefinition

@onready var route_list: VBoxContainer = %RouteList
@onready var close_button: Button = %CloseButton

var first_expedition_button: Button
var route_buttons: Array[Button] = []
var _route_definitions: Array[ExpeditionDefinition] = []
var _owns_pause := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_route_buttons()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()


func open_menu() -> void:
	if visible:
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	_refresh_route_buttons()
	show()
	if first_expedition_button != null and not first_expedition_button.disabled:
		first_expedition_button.grab_focus()
	else:
		close_button.grab_focus()


func close_menu() -> void:
	if not visible:
		return
	hide()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	menu_closed.emit()


func begin_first_expedition() -> void:
	if not _route_definitions.is_empty():
		_begin_expedition(_route_definitions[0])


func _build_route_buttons() -> void:
	for definition: ExpeditionDefinition in expeditions:
		if definition == null or not definition.is_valid_definition():
			continue
		var button := Button.new()
		button.name = "%sButton" % String(definition.expedition_id).to_pascal_case()
		button.custom_minimum_size = Vector2(0, 44)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(_begin_expedition.bind(definition))
		route_list.add_child(button)
		route_buttons.append(button)
		_route_definitions.append(definition)
	if not route_buttons.is_empty():
		first_expedition_button = route_buttons[0]
	_refresh_route_buttons()


func _refresh_route_buttons() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	var player_level := _current_player_level()
	for index in mini(route_buttons.size(), _route_definitions.size()):
		var button := route_buttons[index]
		var definition := _route_definitions[index]
		var unmet := definition.get_unmet_requirements(story_state, player_level)
		var available := definition.is_available(story_state, player_level)
		button.disabled = not available
		button.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND if available else Control.CURSOR_FORBIDDEN
		)
		var status := "AVAILABLE"
		if (
			(definition.destination_scene.is_empty() or not ResourceLoader.exists(definition.destination_scene))
			and unmet.is_empty()
		):
			status = "SEALED  •  EXPEDITION NOT YET FORMED"
		elif not unmet.is_empty():
			status = "SEALED  •  %s" % unmet[0]
		button.text = "%s  •  %s\n%s  •  %s" % [
			definition.route_label,
			definition.display_name,
			definition.difficulty_label,
			status,
		]
		button.tooltip_text = definition.description
		if not unmet.is_empty():
			button.tooltip_text += "\n\nREQUIREMENTS\n%s" % "\n".join(unmet)
	_update_focus_loop()


func _update_focus_loop() -> void:
	var enabled_buttons: Array[Button] = []
	for button: Button in route_buttons:
		if not button.disabled:
			enabled_buttons.append(button)
	if enabled_buttons.is_empty():
		close_button.focus_neighbor_top = close_button.get_path()
		close_button.focus_neighbor_bottom = close_button.get_path()
		return
	for index in enabled_buttons.size():
		var button := enabled_buttons[index]
		var previous: Control = close_button if index == 0 else enabled_buttons[index - 1]
		var next: Control = close_button if index == enabled_buttons.size() - 1 else enabled_buttons[index + 1]
		button.focus_neighbor_top = button.get_path_to(previous)
		button.focus_neighbor_bottom = button.get_path_to(next)
	close_button.focus_neighbor_top = close_button.get_path_to(enabled_buttons[-1])
	close_button.focus_neighbor_bottom = close_button.get_path_to(enabled_buttons[0])


func _begin_expedition(definition: ExpeditionDefinition) -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if definition == null or not definition.is_available(story_state, _current_player_level()):
		return
	if not ResourceLoader.exists(definition.destination_scene):
		return
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service != null:
		transition_service.transition_to(definition.destination_scene)


func _current_player_level() -> int:
	if progression_definition == null:
		return 1
	var run_session := get_node_or_null("/root/RunSession")
	var total_experience: int = run_session.total_experience if run_session != null else 0
	return progression_definition.get_level_for_total_experience(total_experience)
