class_name NpcIdleBreath
extends Timer

## Applies a restrained, integer-pixel idle cadence to an NPC visual without
## moving its collision, interaction trigger, shadow, or gameplay authority.

@export var visual: Node2D
@export var vertical_steps := PackedInt32Array([0, -1, -1, 0, 0])
@export_range(0, 16, 1) var start_phase := 0

var _base_position := Vector2.ZERO
var _phase := 0


func _ready() -> void:
	if visual == null:
		push_warning("NpcIdleBreath requires a visual node.")
		stop()
		return
	_base_position = visual.position
	if vertical_steps.is_empty():
		vertical_steps = PackedInt32Array([0])
	_phase = posmod(start_phase, vertical_steps.size())
	timeout.connect(_advance_phase)
	_apply_phase()
	if is_stopped():
		start()


func reset_presentation() -> void:
	if visual != null:
		visual.position = _base_position
	_phase = posmod(start_phase, vertical_steps.size())


func _advance_phase() -> void:
	_phase = (_phase + 1) % vertical_steps.size()
	_apply_phase()


func _apply_phase() -> void:
	visual.position = _base_position + Vector2(0, vertical_steps[_phase])
