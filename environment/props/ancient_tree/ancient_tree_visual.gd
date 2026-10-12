extends Node2D

@export var canopy: Sprite2D


func _ready() -> void:
	_schedule_sway()


func _schedule_sway() -> void:
	if canopy == null:
		return
	var sway_tween := create_tween()
	sway_tween.tween_interval(randf_range(1.6, 3.2))
	sway_tween.tween_property(canopy, "rotation", deg_to_rad(randf_range(-0.7, 0.7)), 0.9).set_trans(Tween.TRANS_SINE)
	sway_tween.tween_property(canopy, "rotation", 0.0, 1.1).set_trans(Tween.TRANS_SINE)
	sway_tween.tween_callback(_schedule_sway)
