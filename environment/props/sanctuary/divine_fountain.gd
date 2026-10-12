class_name DivineFountain
extends StaticBody2D

## Presentation-only fountain motion. Collision remains stationary while the
## glint and low glow make the landmark feel alive.

@export var water_glint: Node2D
@export var fountain_glow: CanvasItem


func _ready() -> void:
	if water_glint != null:
		var water_tween := create_tween().set_loops()
		water_tween.tween_property(water_glint, "position:x", 3.0, 0.85).from(-3.0).set_trans(Tween.TRANS_SINE)
		water_tween.tween_property(water_glint, "position:x", -3.0, 0.95).set_trans(Tween.TRANS_SINE)
	if fountain_glow != null:
		var glow_tween := create_tween().set_loops()
		glow_tween.tween_property(fountain_glow, "modulate:a", 0.32, 1.3).from(0.62).set_trans(Tween.TRANS_SINE)
		glow_tween.tween_property(fountain_glow, "modulate:a", 0.62, 1.5).set_trans(Tween.TRANS_SINE)
