class_name ExaminerDivineDescentLaunchVfx
extends Node2D

const LIFETIME := 0.58
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
	ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Impact, ExaminerEffectAtlas.frame_at(elapsed, LIFETIME), Rect2(-48, -72, 96, 96), Color(1, 1, 1, 1.0 - elapsed / LIFETIME))
