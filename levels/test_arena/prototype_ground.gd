extends TileMapLayer

@export var map_size := Vector2i(15, 9)


func _ready() -> void:
	if tile_set == null or get_used_cells().size() > 0:
		return
	var random := RandomNumberGenerator.new()
	random.seed = 20260712
	for y in range(map_size.y):
		for x in range(map_size.x):
			var roll := random.randi_range(0, 15)
			var atlas_coordinate := Vector2i.ZERO
			if roll >= 10:
				atlas_coordinate = Vector2i(1, 0)
			if roll >= 13:
				atlas_coordinate = Vector2i(0, 1)
			if roll == 15:
				atlas_coordinate = Vector2i(1, 1)
			set_cell(Vector2i(x, y), 0, atlas_coordinate)
