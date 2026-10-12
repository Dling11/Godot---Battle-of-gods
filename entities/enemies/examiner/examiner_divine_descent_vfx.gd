class_name ExaminerDivineDescentVfx
extends Node2D

const LIFETIME := 1.75
var elapsed := 0.0

func _ready() -> void:
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= LIFETIME:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var frame := ExaminerEffectAtlas.frame_at(elapsed, 0.95)
	var fade := 1.0 - clampf((elapsed - 1.10) / 0.65, 0, 1)
	# Crater remains world-locked; the larger plume is cosmetic, never damage authority.
	ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Impact, frame, Rect2(-210, -315, 420, 420), Color(1, 1, 1, fade))
	if elapsed < 0.32:
		draw_set_transform(Vector2(0, -140), PI * 0.5)
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Energy, ExaminerEffectAtlas.frame_at(elapsed, 0.32), Rect2(-150, -35, 300, 70), Color(1, 1, 1, 0.85))
		draw_set_transform(Vector2.ZERO)
