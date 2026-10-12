extends TileMapLayer

## Current 32px Sanctuary ground and service routes.
const ATLAS = preload("res://assets/environment/sanctuary/refuge_review/ground_32.png")
const MAP_SIZE := Vector2i(36,24)
var routes: Array[PackedVector2Array] = [
	PackedVector2Array([Vector2(576,752),Vector2(560,608),Vector2(576,520),Vector2(576,304)]),
	PackedVector2Array([Vector2(224,400),Vector2(224,464),Vector2(352,496),Vector2(480,488),Vector2(576,480),Vector2(688,488),Vector2(864,472),Vector2(928,400)]),
	PackedVector2Array([Vector2(194,672),Vector2(368,672),Vector2(464,592),Vector2(560,608),Vector2(704,688),Vector2(800,688),Vector2(800,584),Vector2(928,472)]),
	PackedVector2Array([Vector2(800,688),Vector2(886,688)]),
	PackedVector2Array([Vector2(352,496),Vector2(352,464)]),
	PackedVector2Array([Vector2(912,472),Vector2(992,464),Vector2(992,416)]),
]
var path_cells: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -10
	tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(32,32)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ATLAS
	atlas.texture_region_size = Vector2i(32,32)
	for y in 8:
		for x in 4: atlas.create_tile(Vector2i(x,y))
	tile_set.add_source(atlas,0)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var cell := Vector2i(x,y)
			var p := Vector2(cell*32)+Vector2(16,16)
			if _route_distance(p) <= 32.0 or p.distance_to(Vector2(576,452)) < 100.0:
				path_cells[cell] = true
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var cell := Vector2i(x,y)
			var p := Vector2(cell*32)+Vector2(16,16)
			var variant := posmod(x*17+y*29+x*y,4)
			var coordinate := Vector2i(variant,0)
			if path_cells.has(cell):
				var mask := 0
				for index in 4:
					if path_cells.has(cell+[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT][index]): mask |= 1<<index
				coordinate = Vector2i(mask%4,4+mask/4) if mask != 15 else Vector2i(variant,3 if (x+y)%7 == 0 else 2)
			elif Rect2(320,384,96,80).has_point(p) or Rect2(304,592,80,64).has_point(p) or Rect2(744,600,80,64).has_point(p):
				coordinate = Vector2i(variant,1)
			set_cell(cell,0,coordinate)

func _route_distance(point: Vector2) -> float:
	var best := INF
	for route: PackedVector2Array in routes:
		for index in range(route.size()-1):
			best = minf(best,point.distance_to(Geometry2D.get_closest_point_to_segment(point,route[index],route[index+1])))
	return best
