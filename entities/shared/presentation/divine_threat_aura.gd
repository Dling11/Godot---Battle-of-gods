class_name DivineThreatAura
extends Node2D

## Reusable ground-language component for Disciples, divine bosses, and gods.
## It is presentation only: gameplay collision and targeting never read it.

@export var ring_radius := Vector2(25.0, 10.5)
@export var color := Color(1.0, 0.82, 0.32, 1.0)
@export_range(0.0, 2.0, 0.01) var idle_intensity := 0.16
@export_range(0.0, 3.0, 0.01) var empowered_intensity := 0.34
@export_range(-2.0, 2.0, 0.01) var rotation_speed := 0.18

var empowered := false


func _ready() -> void:
	z_index = -2
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func set_empowered(value: bool) -> void:
	empowered = value
	queue_redraw()


func _draw() -> void:
	var ticks := Time.get_ticks_msec()
	var pulse := 0.5 + 0.5 * sin(float(ticks) * 0.0031)
	var intensity := empowered_intensity if empowered else idle_intensity
	var alpha := intensity * (0.68 + pulse * 0.32)
	var beat := 1.0 + pulse * (0.055 if empowered else 0.025)
	for layer in 3:
		var radius := ring_radius * beat + Vector2(float(layer) * 3.0, float(layer) * 1.2)
		var points := PackedVector2Array()
		for index in 49:
			var angle := float(index) * TAU / 48.0
			points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
		var layer_alpha := alpha * (0.34 if layer == 2 else (0.58 if layer == 1 else 1.0))
		draw_polyline(points, Color(color.r, color.g, color.b, layer_alpha), 1.0 + float(2 - layer), false)
	var orbit := float(ticks) * 0.001 * rotation_speed
	for rune_index in 8:
		var angle := float(rune_index) * TAU / 8.0 + orbit
		var rune := Vector2(cos(angle) * (ring_radius.x + 7.0) * beat, sin(angle) * (ring_radius.y + 3.0) * beat)
		var tangent := Vector2(-sin(angle), cos(angle)).normalized()
		var outward := Vector2(cos(angle), sin(angle)).normalized()
		var size := 3.8 if empowered else 2.8
		var rune_color := Color(color.r, color.g, color.b, minf(alpha * 1.65, 0.92))
		draw_colored_polygon(PackedVector2Array([
			rune + outward * size,
			rune + tangent * size * 0.7,
			rune - outward * size,
			rune - tangent * size * 0.7,
		]), rune_color)
		if rune_index % 2 == 0:
			draw_line(rune - tangent * 4.5, rune + tangent * 4.5, rune_color, 1.0)
	# A counter-rotating inner measure stops the aura reading as one flat wheel.
	var counter := -orbit * 1.45
	for mark_index in 6:
		var angle := counter + float(mark_index) * TAU / 6.0
		var start := Vector2(cos(angle) * ring_radius.x * 0.56, sin(angle) * ring_radius.y * 0.56)
		var finish := Vector2(cos(angle) * ring_radius.x * 0.78, sin(angle) * ring_radius.y * 0.78)
		draw_line(start, finish, Color(color.r, color.g, color.b, alpha * 0.88), 1.0)
