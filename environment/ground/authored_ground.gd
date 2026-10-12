@tool
extends TileMapLayer

@export var map_size := Vector2i(15, 9)
@export var layout: AuthoredGroundLayout:
	set(value):
		layout = value
		if layout != null:
			map_size = layout.map_size
		_queue_rebuild()

var _rebuild_queued := false


func _ready() -> void:
	if get_used_cells().is_empty():
		rebuild_from_layout()


func _queue_rebuild() -> void:
	if not is_inside_tree() or _rebuild_queued:
		return
	_rebuild_queued = true
	call_deferred("rebuild_from_layout")


func rebuild_from_layout() -> void:
	_rebuild_queued = false
	if layout == null or tile_set == null:
		return
	map_size = layout.map_size
	clear()
	for y in range(map_size.y):
		var row := layout.rows[y] if y < layout.rows.size() else ""
		for x in range(map_size.x):
			var key := row.substr(x, 1) if x < row.length() else ""
			if not key.is_empty() and layout.empty_tile_keys.contains(key):
				continue
			var tile_spec: Variant = layout.tile_legend.get(key, layout.default_tile)
			var source_id := layout.default_source_id
			var atlas_coordinates := layout.default_tile
			if typeof(tile_spec) == TYPE_VECTOR3I:
				source_id = tile_spec.z
				atlas_coordinates = Vector2i(tile_spec.x, tile_spec.y)
			elif typeof(tile_spec) == TYPE_VECTOR2I:
				atlas_coordinates = tile_spec
			set_cell(Vector2i(x, y), source_id, atlas_coordinates)
