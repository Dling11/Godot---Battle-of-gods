class_name ExaminerGroundJudgmentVfx
extends Node2D

const LIFETIME := 1.10
const RADIUS := 72.0
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
	var frame := ExaminerEffectAtlas.frame_at(elapsed, 0.65)
	var fade := 1.0 - clampf((elapsed - 0.7) / 0.4, 0, 1)
	ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Impact, frame, Rect2(-80, -120, 160, 160), Color(1, 1, 1, fade))
