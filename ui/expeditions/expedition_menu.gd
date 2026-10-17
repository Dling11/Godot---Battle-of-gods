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
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
var selected_route := 0
var route_title: Label
var route_description: RichTextLabel
var route_state: Label
var enter_button: Button
var route_art: TextureRect
const ROUTE_ART := [
	preload("res://assets/environment/portals/threat_family/calm_frames.tres"),
	preload("res://assets/environment/portals/threat_family/grasp_frames.tres"),
	preload("res://assets/environment/portals/threat_family/maw_frames.tres"),
	preload("res://assets/environment/portals/threat_family/ominous_frames.tres"),
	preload("res://assets/environment/portals/threat_family/maw_frames.tres"),
	preload("res://assets/environment/portals/threat_family/unknowable_frames.tres"),
	preload("res://assets/environment/portals/threat_family/calm_frames.tres"),
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_route_details()
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
		button.custom_minimum_size = Vector2(242, 42)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(_select_route.bind(_route_definitions.size()))
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
		button.disabled = false # Locked routes can be inspected, never entered.
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
	_select_route(selected_route)

func _build_route_details() -> void:
	var panel := get_node("Panel") as Control
	panel.offset_left = -342
	panel.offset_right = 342
	panel.offset_top = -216
	panel.offset_bottom = 216
	get_node("Panel/Margin/Root/Title").text = "THE VEIL GATE"
	get_node("Panel/Margin/Root/Subtitle").text = "CHOOSE A PATH · PREPARE BEFORE CROSSING"
	var stack := get_node("Panel/Margin/Root") as VBoxContainer
	var scroll := stack.get_node("RouteScroll") as ScrollContainer
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",14)
	stack.add_child(row)
	stack.move_child(row,2)
	scroll.reparent(row)
	scroll.custom_minimum_size = Vector2(256,286)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation",6)
	row.add_child(details)
	route_art = TextureRect.new()
	route_art.custom_minimum_size = Vector2(0,86)
	route_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	route_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	route_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	details.add_child(route_art)
	route_title = Label.new()
	route_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_title.add_theme_font_size_override("font_size",15)
	route_title.add_theme_color_override("font_color",Color("dcd3f0"))
	details.add_child(route_title)
	route_state = Label.new()
	route_state.add_theme_font_size_override("font_size",10)
	details.add_child(route_state)
	route_description = RichTextLabel.new()
	route_description.bbcode_enabled = true
	route_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	route_description.custom_minimum_size = Vector2(0,100)
	route_description.add_theme_font_size_override("normal_font_size",11)
	details.add_child(route_description)
	enter_button = Button.new()
	enter_button.text = "ENTER EXPEDITION"
	enter_button.custom_minimum_size.y = 32
	enter_button.add_theme_font_size_override("font_size",12)
	enter_button.pressed.connect(func() -> void: _begin_expedition(_route_definitions[selected_route]))
	details.add_child(enter_button)

func _select_route(index: int) -> void:
	if _route_definitions.is_empty(): return
	selected_route = clampi(index,0,_route_definitions.size()-1)
	var definition := _route_definitions[selected_route]
	var story := get_node_or_null("/root/StoryState")
	var unmet := definition.get_unmet_requirements(story,_current_player_level())
	var available := definition.is_available(story,_current_player_level())
	route_title.text = definition.route_label+" · "+definition.display_name
	route_state.text = "PATH OPEN" if available else "SEALED PATH"
	route_state.add_theme_color_override("font_color",Color("a1d7c8") if available else Color("aa9cbf"))
	route_description.text = definition.description+"\n\n[color=#b4c9dd]"+definition.difficulty_label+"[/color]"
	if not unmet.is_empty(): route_description.text += "\n\n[color=#d3abc3]"+"\n".join(unmet)+"[/color]"
	elif not available: route_description.text += "\n\nThis expedition is not yet formed."
	enter_button.disabled = not available
	route_art.texture = ROUTE_ART[mini(selected_route,ROUTE_ART.size()-1)].get_frame_texture(&"active",0)
	for route_index in route_buttons.size():
		route_buttons[route_index].add_theme_stylebox_override("normal",VeilStyle.panel(Color("26354a") if route_index == selected_route else Color("101b2a"),Color("bda4dc") if route_index == selected_route else Color("4a5b70")))


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
