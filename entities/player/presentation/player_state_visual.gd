extends Node

@export var visual_root: CanvasItem

var _visual_tween: Tween


func flash_damaged(_info: DamageInfo) -> void:
	_flash(Color(2.0, 0.55, 0.55, 1.0), 0.14)


func flash_blocked(_info: DamageInfo) -> void:
	_flash(Color(0.65, 1.25, 2.0, 1.0), 0.12)


func play_defeat() -> void:
	if visual_root == null:
		return
	_kill_visual_tween()
	_visual_tween = create_tween()
	_visual_tween.tween_interval(0.58)
	_visual_tween.tween_property(visual_root, "modulate", Color(0.28, 0.25, 0.35, 0.0), 0.42)


func _flash(color: Color, duration_seconds: float) -> void:
	if visual_root == null:
		return
	_kill_visual_tween()
	visual_root.modulate = color
	_visual_tween = create_tween()
	_visual_tween.tween_property(visual_root, "modulate", Color.WHITE, duration_seconds)


func _kill_visual_tween() -> void:
	if _visual_tween != null and _visual_tween.is_valid():
		_visual_tween.kill()
