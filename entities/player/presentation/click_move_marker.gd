class_name ClickMoveMarker
extends Node2D

## Presentation-only four-arrow destination mark. Navigation and movement stay
## in PlayerCombatTargetingComponent and Player respectively.

@export var targeting_component: PlayerCombatTargetingComponent

const MoveFrame1 = preload("res://assets/ui/icons/actions/icon_action_move_arrows_1_24.svg")
const MoveFrame2 = preload("res://assets/ui/icons/actions/icon_action_move_arrows_2_24.svg")
const MARKER_SIZE := Vector2(20.0, 20.0)

var _pulse_time := 0.0
var _frame_index := 0


func _ready() -> void:
	top_level = true
	z_index = 28
	visible = false
	if targeting_component == null:
		push_error("ClickMoveMarker requires a targeting component.")
		return
	targeting_component.click_move_changed.connect(_on_click_move_changed)
	set_process(false)


func _process(delta: float) -> void:
	_pulse_time += delta
	_frame_index = int(_pulse_time / 0.13) % 2
	queue_redraw()


func _draw() -> void:
	var texture: Texture2D = MoveFrame1 if _frame_index == 0 else MoveFrame2
	var alpha := 0.88 + sin(_pulse_time * 7.0) * 0.08
	draw_texture_rect(
		texture,
		Rect2(-MARKER_SIZE * 0.5, MARKER_SIZE),
		false,
		Color(1.0, 1.0, 1.0, alpha)
	)


func _on_click_move_changed(world_position: Vector2, active: bool) -> void:
	visible = active
	set_process(active)
	if active:
		global_position = world_position
		_pulse_time = 0.0
		_frame_index = 0
		queue_redraw()
