class_name ExaminerEffectAtlas
extends RefCounted

const Energy = preload("res://assets/vfx/divine_order/examiner/energy.png")
const Sun = preload("res://assets/vfx/divine_order/examiner/sun.png")
const SunLoop = preload("res://assets/vfx/divine_order/examiner/sun_loop.png")


static func draw_sun(canvas: CanvasItem, elapsed: float, center: Vector2, extent: float, tint := Color.WHITE, turn := 0.0, hot_core := false) -> void:
	var frame := posmod(int(elapsed * 18.0), 16)
	var cell := SunLoop.get_size() / 4.0
	canvas.draw_set_transform(center, turn)
	canvas.draw_texture_rect_region(SunLoop, Rect2(-Vector2.ONE * extent, Vector2.ONE * extent * 2), Rect2(Vector2(frame % 4, frame / 4) * cell, cell), tint)
	if hot_core:
		var core_extent := extent * 0.43
		canvas.draw_texture_rect_region(SunLoop, Rect2(-Vector2.ONE * core_extent, Vector2.ONE * core_extent * 2), Rect2(Vector2(frame % 4, frame / 4) * cell, cell), Color(1,0.86,0.64,0.95))
	canvas.draw_set_transform(Vector2.ZERO)
const AxiomBeam = preload("res://assets/vfx/divine_order/examiner/axiom_beam.png")
const Sweep = preload("res://assets/vfx/divine_order/examiner/sweep.png")
const Impact = preload("res://assets/vfx/divine_order/examiner/impact.png")
const Circle = preload("res://assets/vfx/divine_order/examiner/danger_circle.png")
const Lane = preload("res://assets/vfx/divine_order/examiner/danger_lane.png")


static func draw_frame(canvas: CanvasItem, texture: Texture2D, index: int, destination: Rect2, tint := Color.WHITE) -> void:
	var cell := texture.get_size() / Vector2(4, 2)
	var frame := clampi(index, 0, 7)
	canvas.draw_texture_rect_region(texture, destination, Rect2(Vector2(frame % 4, floori(float(frame) / 4.0)) * cell, cell), tint)


static func frame_at(elapsed: float, duration: float) -> int:
	return clampi(int(elapsed / maxf(duration, 0.001) * 8.0), 0, 7)


static func danger_circle(canvas: CanvasItem, center: Vector2, radius: float, progress: float) -> void:
	# Fixed outer extent is the damage radius. Only the interior fills with time.
	canvas.draw_circle(center, radius, Color(0.65, 0.015, 0.025, 0.12))
	canvas.draw_circle(center, radius * sqrt(clampf(progress, 0, 1)), Color(0.95, 0.035, 0.06, 0.13))
	canvas.draw_texture_rect(Circle, Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2), false, Color(1, 1, 1, 0.65 + progress * 0.35))


static func danger_lane(canvas: CanvasItem, rect: Rect2, progress: float) -> void:
	canvas.draw_texture_rect(Lane, rect, false, Color(1, 1, 1, 0.55 + progress * 0.45))
	canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(progress, 0, 1), rect.size.y)), Color(1, 0.04, 0.08, 0.10))
