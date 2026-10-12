class_name ExaminerEnergyPresentation
extends RefCounted

## Animated layers only. All timing and hazard geometry remain actor-owned.
const CRIMSON := Color(1.0, 0.19, 0.12)


static func charge(canvas: CanvasItem, elapsed: float, duration: float, berserk: bool, red := false) -> void:
	var progress := clampf(elapsed / maxf(duration, 0.01), 0, 1)
	var center := Vector2(sin(elapsed * 4.1) * progress * 2, -100 - progress * 8)
	var tint := CRIMSON if red else Color.WHITE
	var extent := lerpf(15.0, 96.0 if berserk else 78.0, pow(progress, 0.66))
	# A gathering pulse accelerates as the charge approaches release.
	extent *= 1.0 + sin(elapsed * 9 + progress * progress * 15) * (0.025 + progress * 0.03)
	ExaminerEffectAtlas.draw_sun(canvas, elapsed, center, extent, tint, elapsed * (0.28 + progress * 0.45), red)
	# Counter-rotating seal gives parallax around the independent churning core.
	canvas.draw_set_transform(center, -elapsed * 0.72)
	canvas.draw_texture_rect(CourtOfFirstMeasure.DescentCircle, Rect2(-Vector2.ONE * extent * 1.12, Vector2.ONE * extent * 2.24), false, Color(tint, 0.20 + progress * 0.16))
	canvas.draw_set_transform(Vector2.ZERO)
	for index in 28:
		var phase := fmod(elapsed * (0.55 + progress * 0.4) + float(index) / 28, 1.0)
		var angle := index * 2.4 + phase * 2.6
		var distance := lerpf(110, extent * 0.3, phase)
		var point := center + Vector2(cos(angle), sin(angle) * 0.75) * distance
		var color := Color(tint, sin(phase * PI) * 0.9)
		canvas.draw_rect(Rect2(point, Vector2.ONE * (3 if index % 4 == 0 else 2)), color)
	# Short textured streams contract toward the core, with separate frame phases.
	for index in 4:
		var angle := index * PI * 0.5 - elapsed * 0.65
		canvas.draw_set_transform(center, angle)
		ExaminerEffectAtlas.draw_frame(canvas, ExaminerEffectAtlas.Energy, posmod(int(elapsed * 18) + index * 2, 8), Rect2(extent * 0.45, -6, 45 + progress * 22, 12), Color(tint, 0.5))
	canvas.draw_set_transform(Vector2.ZERO)
	if red:
		# Orbiting embers hint at the twelve-part barrage, without warning false damage.
		for index in 5:
			var angle := elapsed * 1.0 + index * TAU / 5
			var point := center + Vector2(cos(angle) * 92, sin(angle) * 34)
			ExaminerEffectAtlas.draw_sun(canvas, elapsed + index * 0.11, point, 11 + progress * 9, Color(CRIMSON, 0.85), -angle, true)


static func enrage(canvas: CanvasItem, elapsed: float, intensity: float) -> void:
	# Behind-body flame ribbons preserve the ivory armor and readable silhouette.
	for index in 7:
		var phase := fmod(elapsed * 0.8 + index * 0.143, 1.0)
		var x := (index - 3) * 10.0
		canvas.draw_set_transform(Vector2(x, -8 - phase * 23), -PI * 0.5)
		ExaminerEffectAtlas.draw_frame(canvas, ExaminerEffectAtlas.Energy, posmod(int(elapsed * 16) + index, 8), Rect2(0, -8, 50 + phase * 23, 16), Color(1, 0.28 + phase * 0.3, 0.12, (1 - phase) * 0.42 * intensity))
	canvas.draw_set_transform(Vector2(0,-2), -elapsed * 0.38, Vector2(1,0.48))
	canvas.draw_texture_rect(CourtOfFirstMeasure.DescentCircle, Rect2(-43,-43,86,86), false, Color(1,0.33,0.17,0.5 * intensity))
	canvas.draw_set_transform(Vector2.ZERO)
	for index in 20:
		var phase := fmod(elapsed * 0.65 + index * 0.05, 1.0)
		var point := Vector2(sin(index * 2.4 + elapsed) * (25 + phase * 15), -phase * 95)
		canvas.draw_rect(Rect2(point,Vector2(2,3)), Color(1,0.36 + phase * 0.4,0.17,(1-phase) * intensity))
