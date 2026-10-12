extends Node

## Owns the project's hardware cursor vocabulary. Gameplay systems request a
## semantic cursor state; no world Sprite2D follows the pointer with added lag.

const DEFAULT_CURSOR = preload(
	"res://assets/ui/targeting/pointer.png"
)
const INTERACT_CURSOR = preload(
	"res://assets/ui/targeting/interact.png"
)
const TARGET_CURSOR = preload(
	"res://assets/ui/targeting/selected.png"
)
const AIM_CURSOR = preload("res://assets/ui/targeting/aim_cursor.png")

var targeting_active := false
var combat_target_selected := false


func _ready() -> void:
	_install_cursor_vocabulary()
	_apply_arrow_cursor()


func _exit_tree() -> void:
	if DisplayServer.get_name() == "headless":
		return
	# Release the two hardware bindings before the renderer is torn down.
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)


func set_targeting_active(active: bool) -> void:
	if targeting_active == active:
		return
	targeting_active = active
	_apply_arrow_cursor()


func set_combat_target_selected(selected: bool) -> void:
	if combat_target_selected == selected:
		return
	combat_target_selected = selected
	_apply_arrow_cursor()


func _install_cursor_vocabulary() -> void:
	if DisplayServer.get_name() == "headless":
		return
	Input.set_custom_mouse_cursor(
		INTERACT_CURSOR,
		Input.CURSOR_POINTING_HAND,
		Vector2(7.0, 6.0)
	)


func _apply_arrow_cursor() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if targeting_active:
		Input.set_custom_mouse_cursor(AIM_CURSOR, Input.CURSOR_ARROW, Vector2(12,12))
		return
	if combat_target_selected:
		Input.set_custom_mouse_cursor(
			TARGET_CURSOR,
			Input.CURSOR_ARROW,
			Vector2(2.0, 2.0)
		)
		return
	Input.set_custom_mouse_cursor(
		DEFAULT_CURSOR,
		Input.CURSOR_ARROW,
		Vector2(2.0, 2.0)
	)
