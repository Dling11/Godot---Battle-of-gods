class_name ChestSpawnEffect
extends Node2D

## Short presentation-only arrival burst for stage reward chests.

@export var rune: Line2D
@export var core: Polygon2D
@export var sparks_root: Node2D

var _played := false


func play(accent_color: Color, is_reliquary: bool) -> void:
	if _played or rune == null or core == null or sparks_root == null:
		return
	_played = true
	var bright := accent_color.lerp(Color.WHITE, 0.3)
	rune.default_color = accent_color
	rune.width = 3.0 if is_reliquary else 2.0
	core.color = bright
	_create_sparks(bright, 10 if is_reliquary else 7)

	modulate.a = 0.0
	scale = Vector2(0.38, 0.38)
	rotation = -0.18
	var reveal := create_tween().set_parallel()
	reveal.tween_property(self, "modulate:a", 1.0, 0.08)
	reveal.tween_property(self, "scale", Vector2(1.22, 1.22), 0.38).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	reveal.tween_property(self, "rotation", 0.1, 0.38).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	reveal.chain().tween_property(self, "modulate:a", 0.0, 0.28)
	reveal.tween_callback(queue_free)


func _create_sparks(color: Color, count: int) -> void:
	for index in count:
		var angle := (float(index) / float(count)) * TAU
		var direction := Vector2.RIGHT.rotated(angle)
		var spark := Polygon2D.new()
		spark.polygon = PackedVector2Array([
			Vector2(0.0, -2.0),
			Vector2(2.0, 0.0),
			Vector2(0.0, 2.0),
			Vector2(-2.0, 0.0),
		])
		spark.color = color
		spark.position = direction * 11.0
		sparks_root.add_child(spark)
		var travel := spark.create_tween().set_parallel()
		travel.tween_property(
			spark,
			"position",
			direction * (42.0 if count >= 10 else 34.0),
			0.46
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		travel.tween_property(spark, "modulate:a", 0.0, 0.46).set_delay(0.1)
