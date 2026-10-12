@tool
class_name EditorPreviewBackdrop
extends Node2D

## Draws contextual ground behind an isolated 2D asset while it is edited.
## It never draws during gameplay or when the asset is instanced in a level.

@export var preview_size := Vector2(384.0, 320.0):
	set(value):
		preview_size = Vector2(maxf(value.x, 32.0), maxf(value.y, 32.0))
		queue_redraw()
@export var preview_center := Vector2(0.0, -96.0):
	set(value):
		preview_center = value
		queue_redraw()
@export_range(8.0, 64.0, 1.0) var checker_size := 32.0:
	set(value):
		checker_size = maxf(value, 8.0)
		queue_redraw()
@export var ground_color := Color("557f3b"):
	set(value):
		ground_color = value
		queue_redraw()
@export var alternate_color := Color("4b7339"):
	set(value):
		alternate_color = value
		queue_redraw()
@export var border_color := Color("87a66b"):
	set(value):
		border_color = value
		queue_redraw()


func _enter_tree() -> void:
	queue_redraw()


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func _draw() -> void:
	if not is_editor_preview_active():
		return
	var preview_rect := Rect2(preview_center - preview_size * 0.5, preview_size)
	draw_rect(preview_rect, ground_color)
	var columns := ceili(preview_size.x / checker_size)
	var rows := ceili(preview_size.y / checker_size)
	for row in range(rows):
		for column in range(columns):
			if (row + column) % 2 == 0:
				continue
			var cell_position := preview_rect.position + Vector2(column, row) * checker_size
			var cell_size := Vector2(
				minf(checker_size, preview_rect.end.x - cell_position.x),
				minf(checker_size, preview_rect.end.y - cell_position.y)
			)
			draw_rect(Rect2(cell_position, cell_size), alternate_color)
	draw_rect(preview_rect, border_color, false, 1.0)


func is_editor_preview_active() -> bool:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return false
	return get_parent() == get_tree().edited_scene_root
