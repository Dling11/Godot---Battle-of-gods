class_name CragBearSlamImpactVfx
extends Node2D

## Short-lived, world-anchored normal-mob impact. All geometry is authored here
## so the radius, colors, and pixel density remain reusable and deterministic.

const LIFETIME_SECONDS := 0.72
const IMPACT_RADIUS := 44.0
var _cracks: Array[PackedVector2Array] = [
	PackedVector2Array([Vector2(3, -2), Vector2(13, -7), Vector2(20, -5), Vector2(31, -13), Vector2(39, -12)]),
	PackedVector2Array([Vector2(-2, -2), Vector2(-10, -11), Vector2(-18, -12), Vector2(-25, -23), Vector2(-34, -27)]),
	PackedVector2Array([Vector2(1, 3), Vector2(8, 12), Vector2(7, 20), Vector2(17, 29), Vector2(18, 38)]),
	PackedVector2Array([Vector2(-4, 2), Vector2(-15, 7), Vector2(-18, 16), Vector2(-31, 20), Vector2(-39, 27)]),
	PackedVector2Array([Vector2(3, 1), Vector2(16, 5), Vector2(23, 14), Vector2(35, 18)]),
	PackedVector2Array([Vector2(-1, 3), Vector2(-7, 15), Vector2(-5, 25), Vector2(-12, 36)]),
]
var _debris_directions: Array[Vector2] = [
	Vector2(0.92, -0.34),
	Vector2(0.63, -0.78),
	Vector2(0.18, -0.98),
	Vector2(-0.47, -0.86),
	Vector2(-0.91, -0.3),
	Vector2(-0.8, 0.5),
	Vector2(-0.25, 0.96),
	Vector2(0.38, 0.91),
	Vector2(0.82, 0.51),
]

var _elapsed := 0.0


func _ready() -> void:
	z_index = 9
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= LIFETIME_SECONDS:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(_elapsed / LIFETIME_SECONDS, 0.0, 1.0)
	_draw_contact_flash(progress)
	_draw_cracks(progress)
	_draw_shockwave(progress)
	_draw_dust(progress)
	_draw_debris(progress)


func _draw_contact_flash(progress: float) -> void:
	if progress > 0.22:
		return
	var alpha := (1.0 - progress / 0.22) * 0.48
	var radius := lerpf(15.0, 31.0, progress / 0.22)
	draw_circle(Vector2.ZERO, radius, Color(0.74, 0.82, 0.66, alpha), false, 3.0, false)
	draw_circle(Vector2(0, 2), radius * 0.58, Color(0.95, 0.82, 0.53, alpha * 0.55), false, 2.0, false)


func _draw_cracks(progress: float) -> void:
	var appear := clampf(progress / 0.1, 0.0, 1.0)
	var fade := 1.0 - clampf((progress - 0.55) / 0.45, 0.0, 1.0)
	var color := Color(0.09, 0.13, 0.12, appear * fade * 0.82)
	for crack in _cracks:
		var visible_points := maxi(2, ceili(crack.size() * appear))
		var partial := PackedVector2Array()
		for index in mini(visible_points, crack.size()):
			partial.append(crack[index])
		draw_polyline(partial, color, 2.0, false)


func _draw_shockwave(progress: float) -> void:
	var wave_progress := clampf(progress / 0.48, 0.0, 1.0)
	var radius := lerpf(17.0, IMPACT_RADIUS + 12.0, ease(wave_progress, 0.62))
	var alpha := (1.0 - wave_progress) * 0.72
	var pale_stone := Color(0.68, 0.79, 0.69, alpha)
	for arc_index in 4:
		var start := arc_index * TAU / 4.0 + 0.13
		draw_arc(Vector2.ZERO, radius, start, start + 1.18, 12, pale_stone, 3.0, false)
	var inner_alpha := (1.0 - wave_progress) * 0.34
	draw_arc(Vector2.ZERO, radius - 5.0, 0.35, TAU - 0.55, 30, Color(0.29, 0.49, 0.47, inner_alpha), 1.0, false)


func _draw_dust(progress: float) -> void:
	var dust_progress := clampf(progress / 0.78, 0.0, 1.0)
	var alpha := (1.0 - dust_progress) * 0.52
	for index in 12:
		var angle := index * TAU / 12.0 + 0.19
		var distance := lerpf(12.0, 48.0 + float(index % 3) * 3.0, dust_progress)
		var position := Vector2.from_angle(angle) * distance
		position.y *= 0.72
		var size := 2.0 + float(index % 3)
		draw_circle(position, size, Color(0.61, 0.64, 0.51, alpha), true, -1.0, false)


func _draw_debris(progress: float) -> void:
	var debris_progress := clampf(progress / 0.88, 0.0, 1.0)
	var alpha := 1.0 - clampf((debris_progress - 0.56) / 0.44, 0.0, 1.0)
	for index in _debris_directions.size():
		var direction := _debris_directions[index]
		var distance := (27.0 + float(index % 4) * 5.0) * debris_progress
		var lift := -sin(debris_progress * PI) * (9.0 + float(index % 3) * 2.0)
		var position := direction * distance + Vector2(0, lift)
		var side := 2.0 + float(index % 2)
		var tint := Color(0.31, 0.38, 0.32, alpha) if index % 2 == 0 else Color(0.54, 0.59, 0.47, alpha)
		draw_rect(Rect2(position - Vector2.ONE * side * 0.5, Vector2.ONE * side), tint, true)
