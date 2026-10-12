extends Node2D

@export var bird_origin := Vector2(384,160)
@export var flight_bounds := Rect2(48,260,1052,290)

## Reuse the accepted two-bird flight, with its Timer/Tween cadence, in the glade.
func _ready() -> void:
	var birds := preload("res://levels/sanctuary/town/garden_birds.gd").new()
	birds.name = "GroveBirds"
	birds.position = bird_origin
	birds.flight_bounds = flight_bounds
	add_child(birds)
	birds.set_enabled(true)
