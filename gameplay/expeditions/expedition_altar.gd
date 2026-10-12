class_name ExpeditionAltar
extends Area2D

signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)
signal selection_requested

@export var interaction_icon: Texture2D
@export var portal_structure: CanvasItem
@export var front_depth_area: Area2D
var _player_inside := false
var _portal_structure_default_z_index := 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if front_depth_area != null:
		front_depth_area.body_entered.connect(_on_front_depth_body_entered)
		front_depth_area.body_exited.connect(_on_front_depth_body_exited)
	if portal_structure != null:
		_portal_structure_default_z_index = portal_structure.z_index


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or not event.is_action_pressed("player_interact"):
		return
	get_viewport().set_input_as_handled()
	proximity_changed.emit(false, "", null)
	selection_requested.emit()


func restore_prompt() -> void:
	if _player_inside:
		proximity_changed.emit(true, "PRESS F TO CHOOSE EXPEDITION", interaction_icon)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = true
	proximity_changed.emit(true, "PRESS F TO CHOOSE EXPEDITION", interaction_icon)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = false
	proximity_changed.emit(false, "", null)


func _on_front_depth_body_entered(body: Node2D) -> void:
	if body is Player:
		_set_player_in_front(true)


func _on_front_depth_body_exited(body: Node2D) -> void:
	if body is Player:
		_set_player_in_front(false)


func _set_player_in_front(is_in_front: bool) -> void:
	if portal_structure == null:
		return
	portal_structure.z_index = (
		_portal_structure_default_z_index - 1
		if is_in_front
		else _portal_structure_default_z_index
	)
