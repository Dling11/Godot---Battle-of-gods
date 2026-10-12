extends Area2D

var hub: Node
var town_map: CanvasLayer
var player_inside := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var trigger := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 32
	trigger.shape = shape
	trigger.position.y = 12
	add_child(trigger)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body is Player or not town_map.enabled: return
	player_inside = true
	hub.combat_hud.show_interaction_prompt(true,"PRESS F · TOWN MAP",null)

func _on_body_exited(body: Node2D) -> void:
	if not body is Player or not player_inside: return
	player_inside = false
	hub.combat_hud.show_interaction_prompt(false,"",null)

func _unhandled_input(event: InputEvent) -> void:
	if town_map.enabled and player_inside and event.is_action_pressed("player_interact") and not hub.dialogue_panel.visible:
		town_map.toggle()
		get_viewport().set_input_as_handled()
