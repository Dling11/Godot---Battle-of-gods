class_name HitBurst
extends Node2D

## Lightweight pixel spark burst. It has no collision or damage authority.

@export var lifetime_seconds := 0.16

var _direction := Vector2.RIGHT
var _tint := Color.WHITE


func configure(direction: Vector2, tint: Color) -> void:
	_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	_tint = tint


func _ready() -> void:
	_create_white_core()
	for index in 3:
		_create_spark(index)
	get_tree().create_timer(lifetime_seconds).timeout.connect(queue_free)


func _create_white_core() -> void:
	var core := Polygon2D.new()
	core.color = Color.WHITE
	core.polygon = PackedVector2Array([
		Vector2(0, -4), Vector2(3, 0), Vector2(0, 4), Vector2(-3, 0)
	])
	add_child(core)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(core, "scale", Vector2(0.35, 0.35), 0.09)
	tween.tween_property(core, "modulate:a", 0.0, 0.09)


func _create_spark(index: int) -> void:
	var spark := Polygon2D.new()
	spark.color = _tint
	spark.polygon = PackedVector2Array([Vector2(-1, -2), Vector2(2, -1), Vector2(2, 1), Vector2(-1, 2)])
	var angle_offset := (-0.48 + index * 0.48)
	var travel := _direction.rotated(angle_offset) * (8.0 + index * 3.0)
	add_child(spark)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(spark, "position", travel, lifetime_seconds)
	tween.tween_property(spark, "scale", Vector2(0.45, 0.45), lifetime_seconds)
	tween.tween_property(spark, "modulate:a", 0.0, lifetime_seconds)
