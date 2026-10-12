extends Node

## Doorway and room visit; same Player, inventory and service authorities.
const Room = preload("res://levels/sanctuary/town/workshop_interior.gd")
const ThemeKit = preload("res://ui/themes/sanctuary_theme.gd")
const ROOM_ORIGIN := Vector2(2400,1920)
const ENTRY_APRON := Rect2(-28,-4,56,76)
var study: Node
var hub: Node
var player: Player
var room: Node2D
var inside := false
var enabled := false
var title: PanelContainer
var door_label: Label
var _timer: Timer
var _prompt := ""
var _target := ""
var _old: Dictionary

func configure(owner_study: Node) -> void:
	study = owner_study
	hub = study.hub
	player = hub.player
	room = Room.new()
	room.name = "OrrenWorkshopInterior"
	room.position = ROOM_ORIGIN
	hub.get_node("World/Actors").add_child(room)
	study.orren_review.workshop.set_meta("interior_status",&"playable")
	door_label = Label.new()
	door_label.text = "WORKSHOP · [F]"
	door_label.position = Vector2(-72,14)
	door_label.add_theme_font_size_override("font_size",10)
	door_label.add_theme_color_override("font_color",Color(.98,.8,.46))
	door_label.add_theme_color_override("font_outline_color",Color(.04,.04,.05))
	door_label.add_theme_constant_override("outline_size",3)
	door_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	study.orren_review.workshop.add_child(door_label)
	var layer := CanvasLayer.new()
	layer.layer = 15
	add_child(layer)
	title = PanelContainer.new()
	title.position = Vector2(312,12)
	title.custom_minimum_size.x = 336
	title.theme = ThemeKit.build()
	title.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	title.add_theme_stylebox_override("panel",ThemeKit.frame(12))
	layer.add_child(title)
	var stack := VBoxContainer.new()
	title.add_child(stack)
	var heading := Label.new()
	heading.text = "ORREN'S WORKSHOP"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size",14)
	stack.add_child(heading)
	var hint := Label.new()
	hint.text = "F · INSPECT / LEAVE    WASD · WALK"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size",10)
	stack.add_child(hint)
	title.hide()
	_timer = Timer.new()
	_timer.wait_time = .1
	_timer.timeout.connect(_refresh)
	add_child(_timer)
	hub.dialogue_panel.visibility_changed.connect(_on_modal_changed)
	for modal: Control in [hub.character_menu,hub.rootforge_menu,hub.umi_exchange_menu,hub.expedition_menu,hub.get_node("UI/PauseMenu")]:
		modal.visibility_changed.connect(_on_modal_changed)
	get_viewport().size_changed.connect(func() -> void: title.position.x = (get_viewport().get_visible_rect().size.x-title.size.x)/2)

func set_enabled(value: bool) -> void:
	if not value and inside: leave()
	enabled = value
	door_label.visible = value
	if value: _timer.start()
	else:
		_timer.stop()
		_set_prompt("","")

func _can_transfer() -> bool:
	return enabled and not get_tree().paused and not player.is_cinematic_locked() and not player.is_defeated and not player.is_any_ability_casting() and not player.is_targeting_any_ability() and not player.evade_component.is_dashing() and player.attack_component.phase == 0 and not player.is_in_hit_recovery()

func enter() -> bool:
	if inside or not _can_transfer() or not _at_door(): return false
	var camera: Camera2D = player.get_node("Camera2D")
	_old = {"bounds":player.movement_bounds,"overview":study.overview,
		"path_tolerance":player.combat_targeting.navigation_agent.path_desired_distance,
		"top_level":camera.is_set_as_top_level(),"position":camera.position,"zoom":camera.zoom,
		"limits":Vector4(camera.limit_left,camera.limit_top,camera.limit_right,camera.limit_bottom),
		"smoothing":camera.position_smoothing_enabled}
	_reset_movement()
	inside = true
	room.set_active(true)
	player.movement_bounds = Rect2(ROOM_ORIGIN+Room.FLOOR.position,Room.FLOOR.size)
	player.combat_targeting.navigation_agent.path_desired_distance = 3
	player.global_position = ROOM_ORIGIN+Room.SPAWN
	player.facing_direction = Vector2.UP
	player.facing_changed.emit(Vector2.UP)
	camera.set_as_top_level(true)
	camera.position = ROOM_ORIGIN+Room.CENTER
	camera.zoom = Vector2.ONE
	camera.position_smoothing_enabled = false
	camera.limit_left = -10000
	camera.limit_top = -10000
	camera.limit_right = 10000
	camera.limit_bottom = 10000
	camera.reset_smoothing()
	study.town_map.set_suspended(true)
	study._panel.hide()
	title.show()
	_refresh()
	return true

func leave() -> void:
	if not inside: return
	_reset_movement()
	inside = false
	room.set_active(false)
	player.movement_bounds = _old.bounds
	player.combat_targeting.navigation_agent.path_desired_distance = _old.path_tolerance
	player.global_position = study.orren_review.workshop.get_node("ReturnPoint").global_position
	player.facing_direction = Vector2.DOWN
	player.facing_changed.emit(Vector2.DOWN)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.set_as_top_level(_old.top_level)
	camera.position = _old.position
	camera.zoom = _old.zoom
	camera.limit_left = int(_old.limits.x)
	camera.limit_top = int(_old.limits.y)
	camera.limit_right = int(_old.limits.z)
	camera.limit_bottom = int(_old.limits.w)
	camera.position_smoothing_enabled = _old.smoothing
	camera.reset_smoothing()
	title.hide()
	study.town_map.set_suspended(false)
	study.interface_review._sync_review_controls()
	_set_prompt("","")

func _reset_movement() -> void:
	player.combat_targeting.cancel_click_move()
	player.combat_targeting.clear_target()
	player.auto_combat.set_auto_farm_enabled(false)
	player.velocity = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("player_interact") or event.is_echo() or not _can_transfer(): return
	_refresh()
	if _target.is_empty(): return
	get_viewport().set_input_as_handled()
	match _target:
		"enter": enter()
		"exit": leave()
		"workbench": _inspect("THE WORKBENCH",["An unfinished blade rests beside worn tongs. Orren has laid each tool within easy reach.","The work here takes patience. Orren is keeping watch over his tools in the courtyard."])
		"forge": _inspect("THE FORGE",["Warm coals glow beneath the stone hood. The hearth keeps a steady heat for the next blade."])
		"rack": _inspect("THE WEAPON RACK",["Finished blades hang above a battered shield. These are the armskeeper's working pieces."])

func _inspect(speaker: String, lines: Array[String]) -> void:
	hub.dialogue_panel.show_dialogue(speaker,lines)

func _at_door(rectangle: Rect2 = ENTRY_APRON) -> bool:
	var workshop: Node2D = study.orren_review.workshop
	var doorway: Marker2D = workshop.get_node("Doorway")
	return rectangle.has_point(workshop.to_local(player.global_position)-doorway.position)

func _refresh() -> void:
	if not enabled: return
	if get_tree().paused:
		_set_prompt("","")
		return
	if not inside:
		var approach: Vector2 = study.orren_review.workshop.get_node("Approach").global_position
		door_label.visible = player.global_position.distance_to(approach) < 180
		for npc: DialogueNpc in [hub.skillkeeper,hub.weapon_merchant,hub.rootweaver,hub.echo_melder]:
			if npc._player_inside:
				_prompt = ""
				_target = ""
				return
		if _at_door():
			_set_prompt("enter","PRESS F · ENTER WORKSHOP")
		else: _set_prompt("","")
		return
	var point := player.global_position-ROOM_ORIGIN
	if point.distance_to(Room.EXIT) < 18:
		_set_prompt("exit","PRESS F · RETURN TO THE COURTYARD")
	elif point.distance_to(Room.INSPECTIONS.workbench) < 18:
		_set_prompt("workbench","PRESS F · INSPECT THE WORKBENCH")
	elif point.distance_to(Room.INSPECTIONS.forge) < 18:
		_set_prompt("forge","PRESS F · INSPECT THE FORGE")
	elif point.distance_to(Room.INSPECTIONS.rack) < 18:
		_set_prompt("rack","PRESS F · INSPECT THE WEAPON RACK")
	else: _set_prompt("","")

func _set_prompt(target: String, text: String) -> void:
	if _prompt == text and _target == target: return
	var had_prompt := not _prompt.is_empty()
	_prompt = text
	_target = target
	if had_prompt or not text.is_empty(): hub.combat_hud.show_interaction_prompt(not text.is_empty(),text,null)

func _on_modal_changed() -> void:
	# The interface adapter already observes all modal visibility, including dynamic collection.
	study.interface_review._sync_review_controls()
	if hub.dialogue_panel.visible or get_tree().paused: _set_prompt("","")

func set_modal_open(value: bool) -> void:
	title.visible = inside and not value

func _exit_tree() -> void:
	if is_instance_valid(room): room.queue_free()
