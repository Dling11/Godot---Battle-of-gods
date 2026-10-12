class_name ExaminerAxiomLane
extends Node2D

var _length := 500.0
var _width := 28.0
var _active := false
var _alpha := 0.0
var _elapsed := 0.0
var _resolve_elapsed := 0.0
var _resolve_delay := 1.0


func _ready() -> void:
	# Floor danger remains visible while the actor's mask and pose stay clear.
	z_index = -1


func configure(
	center: Vector2,
	direction: Vector2,
	length: float,
	width: float,
	warning_seconds: float,
	resolve_delay: float
) -> void:
	global_position = center
	rotation = direction.angle()
	_length = length
	_width = width
	_resolve_delay = maxf(resolve_delay, 0.01)
	queue_redraw()
	var tween := create_tween()
	tween.tween_property(self, "_alpha", 0.5, maxf(warning_seconds * 0.45, 0.05))
	tween.tween_property(self, "_alpha", 0.18, maxf(resolve_delay - warning_seconds * 0.45, 0.05))
	tween.tween_callback(_resolve)
	tween.tween_interval(0.08)
	tween.tween_property(self, "_alpha", 0.0, 0.20)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_elapsed += delta
	if _active:
		_resolve_elapsed += delta
	queue_redraw()


func _resolve() -> void:
	_active = true
	_alpha = 0.95
	queue_redraw()


func _draw() -> void:
	var half := Vector2(_length * 0.5, _width * 0.5)
	if _active:
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.AxiomBeam, ExaminerEffectAtlas.frame_at(_resolve_elapsed, 0.28), Rect2(Vector2(-half.x, -half.y * 1.6), Vector2(_length, _width * 1.6)), Color(1, 1, 1, _alpha))
	else:
		var progress := clampf(_elapsed / _resolve_delay, 0, 1)
		# Segment-distance damage includes semicircular caps at both endpoints.
		ExaminerEffectAtlas.danger_circle(self, Vector2(-half.x, 0), half.y, progress)
		ExaminerEffectAtlas.danger_circle(self, Vector2(half.x, 0), half.y, progress)
		ExaminerEffectAtlas.danger_lane(self, Rect2(-half, half * 2), clampf(_elapsed / _resolve_delay, 0, 1))
