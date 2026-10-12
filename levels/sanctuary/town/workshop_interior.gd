extends Node2D

## One composed room. Physics and navigation share measured furniture footprints.
const ART := "res://assets/environment/sanctuary/interiors/orren/v2/"
const FLOOR := Rect2(38,72,404,90)
const CENTER := Vector2(240,96)
const SPAWN := Vector2(240,150)
const EXIT := Vector2(240,162)
const FURNITURE := [
	["forge",Vector2(396,123),Vector2(42,19)],
	["workbench",Vector2(240,114),Vector2(48,12)],
	["rack",Vector2(93,102),Vector2(40,8)],
]
const INSPECTIONS := {"workbench":Vector2(240,132),"forge":Vector2(396,139),"rack":Vector2(93,121)}
var navigation: NavigationRegion2D
var embers: CPUParticles2D

func _ready() -> void:
	y_sort_enabled = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var surround := Polygon2D.new()
	surround.polygon = _outline(Rect2(-1000,-600,2640,1424))
	surround.color = Color(.025,.032,.042)
	surround.z_index = -20
	add_child(surround)
	var shell := Sprite2D.new()
	shell.name = "Shell"
	shell.centered = false
	shell.texture = load(ART+"shell.png")
	shell.z_index = -10
	add_child(shell)
	_solid("NorthWall",Rect2(0,0,480,72))
	_solid("WestWall",Rect2(0,72,38,105))
	_solid("EastWall",Rect2(442,72,38,105))
	_solid("SouthWall",Rect2(0,168,480,15))
	var geometry := NavigationMeshSourceGeometryData2D.new()
	geometry.add_traversable_outline(_outline(FLOOR))
	for rectangle in [Rect2(0,147,96,21),Rect2(384,147,96,21)]:
		_solid("FrontWall",rectangle)
		geometry.add_obstruction_outline(_outline(rectangle))
	for recipe in FURNITURE:
		var footprint := Rect2(recipe[1]-Vector2(recipe[2].x/2,recipe[2].y),recipe[2])
		var body := _solid(str(recipe[0]).to_pascal_case(),footprint)
		var sprite := Sprite2D.new()
		sprite.name = "Art"
		sprite.texture = load(ART+recipe[0]+".png")
		sprite.position = recipe[1]-body.position-Vector2(0,sprite.texture.get_height()/2.0)
		body.add_child(sprite)
		geometry.add_obstruction_outline(_outline(footprint))
	var polygon := NavigationPolygon.new()
	polygon.agent_radius = 8
	NavigationServer2D.bake_from_source_geometry_data(polygon,geometry)
	navigation = NavigationRegion2D.new()
	navigation.navigation_polygon = polygon
	navigation.enabled = false
	add_child(navigation)
	embers = CPUParticles2D.new()
	embers.position = Vector2(396,109)
	embers.amount = 6
	embers.lifetime = 1.1
	embers.direction = Vector2.UP
	embers.spread = 15
	embers.gravity = Vector2(0,-3)
	embers.initial_velocity_min = 4
	embers.initial_velocity_max = 9
	embers.scale_amount_min = .6
	embers.scale_amount_max = 1
	embers.color = Color(1,.49,.12,.7)
	add_child(embers)
	set_active(false)

func _solid(node_name: String, rectangle: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = Vector2(rectangle.get_center().x,rectangle.end.y)
	add_child(body)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rectangle.size
	collision.shape = shape
	collision.position = Vector2(0,-rectangle.size.y/2)
	body.add_child(collision)
	return body

func set_active(value: bool) -> void:
	visible = value
	navigation.enabled = value
	embers.emitting = value
	process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED

static func _outline(rectangle: Rect2) -> PackedVector2Array:
	return PackedVector2Array([rectangle.position,Vector2(rectangle.end.x,rectangle.position.y),rectangle.end,Vector2(rectangle.position.x,rectangle.end.y)])
