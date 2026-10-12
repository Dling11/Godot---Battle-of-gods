extends Node2D

var _pulse := 0.0


func _process(delta: float) -> void:
	_pulse += delta
	queue_redraw()


func _draw() -> void:
	var wave := (sin(_pulse * 8.0) + 1.0) * 0.5
	draw_circle(Vector2.ZERO, 70.0, Color(0.22, 0.04, 0.08, 0.18))
	draw_arc(Vector2.ZERO, lerpf(54.0, 68.0, wave), 0.0, TAU, 48, Color(0.78, 0.22, 0.16, 0.72), 2.0)
	draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 32, Color(0.62, 0.86, 0.18, 0.8), 2.0)
	draw_line(Vector2(-10.0, 0.0), Vector2(10.0, 0.0), Color(0.86, 0.9, 0.6, 0.8), 1.0)
	draw_line(Vector2(0.0, -7.0), Vector2(0.0, 7.0), Color(0.86, 0.9, 0.6, 0.8), 1.0)

