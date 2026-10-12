class_name ExaminerActionVfx
extends Node2D

var kind: StringName = &"precision_thrust"
var direction := Vector2.RIGHT
var elapsed := 0.0
var lifetime := 0.28

func configure(action_kind: StringName, action_direction: Vector2) -> void:
	kind = action_kind
	direction = action_direction.normalized() if not action_direction.is_zero_approx() else Vector2.RIGHT
	rotation = direction.angle()
	lifetime = 0.24 if kind == &"precision_thrust" else 0.34

func _ready() -> void:
	z_index = 12
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var frame := ExaminerEffectAtlas.frame_at(elapsed, lifetime)
	if kind == &"divine_sweep":
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Sweep, frame, Rect2(-58, -58, 116, 116))
	elif kind == &"precision_thrust":
		# Spawn is 58 px forward; its complete bright tip remains within 86 px.
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Energy, frame, Rect2(-32, -12, 60, 24))
	else:
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Energy, frame, Rect2(-64, -20, 80, 40))
