class_name DialogueNpc
extends Area2D

signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)
signal dialogue_requested(speaker: String, lines: Array[String], portrait: Texture2D)

@export var interaction_icon: Texture2D
@export var dialogue_portrait: Texture2D
@export var prompt_text := "PRESS F TO SPEAK"
@export var speaker_name := "TRAVELER"
@export_multiline var dialogue_lines: Array[String] = []
@export var idle_aura: Node2D

var _player_inside := false
var _nearby_player: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if idle_aura == null:
		return
	var rotation_tween := create_tween().set_loops()
	rotation_tween.tween_property(idle_aura, "rotation", TAU, 6.0).from(0.0)
	var pulse_tween := create_tween().set_loops()
	pulse_tween.tween_property(idle_aura, "modulate:a", 0.42, 1.1).from(0.9).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(idle_aura, "modulate:a", 0.9, 1.3).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or not event.is_action_pressed("player_interact"):
		return
	get_viewport().set_input_as_handled()
	if is_instance_valid(_nearby_player):
		_nearby_player.begin_interaction(global_position)
	proximity_changed.emit(false, "", null)
	dialogue_requested.emit(speaker_name, dialogue_lines, dialogue_portrait)


func restore_prompt() -> void:
	if is_instance_valid(_nearby_player):
		_nearby_player.finish_interaction()
	if _player_inside:
		proximity_changed.emit(true, prompt_text, interaction_icon)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	_player_inside = true
	_nearby_player = body as Player
	proximity_changed.emit(true, prompt_text, interaction_icon)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	_player_inside = false
	if body == _nearby_player:
		_nearby_player.finish_interaction()
		_nearby_player = null
	proximity_changed.emit(false, "", null)
