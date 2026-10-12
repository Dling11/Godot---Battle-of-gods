extends Node

const ART := "res://assets/environment/sanctuary/inhabited/"
const Wind = preload("res://levels/sanctuary/town/foliage_wind.gdshader")
var trees: Array[StaticBody2D] = []
var walls: Array[StaticBody2D] = []
var stations: Array[StaticBody2D] = []
var buildings: Array[StaticBody2D] = []
var _props: Node2D

func configure(hub: Node, props: Node2D) -> void:
	_props = props
	for recipe in [
		["linden", Vector2(104, 232)], ["cedar", Vector2(1056, 232)],
		["cedar", Vector2(88, 526)], ["linden", Vector2(1080, 622)],
		["linden", Vector2(104, 716)], ["cedar", Vector2(1048, 720)],
	]:
		var tree := _prop(recipe[0], recipe[1], Vector2(32, 16), 9)
		trees.append(tree)
		var reveal := Area2D.new()
		reveal.name = "CanopyReveal"
		reveal.collision_layer = 0
		reveal.collision_mask = 2
		tree.add_child(reveal)
		_collision(reveal, Vector2(100, 120), Vector2(0, -75))
		var art: Sprite2D = tree.get_node("Art")
		var wind := ShaderMaterial.new()
		wind.shader = Wind
		wind.set_shader_parameter("phase", trees.size()*1.7)
		art.material = wind
		reveal.body_entered.connect(func(body: Node) -> void:
			if body is Player: art.modulate.a = .45)
		reveal.body_exited.connect(func(body: Node) -> void:
			if body is Player: art.modulate.a = 1.0)
	stations.append(_prop("anvil_station", Vector2(1038, 430), Vector2(60, 16), 4))
	stations.append(_prop("lectern", Vector2(344, 410), Vector2(24, 14), 3))
	stations.append(_prop("noticeboard", Vector2(438, 658), Vector2(48, 14), 4))
	for start in [Vector2(136, 224), Vector2(704, 224)]:
		_wall_run(start, 3, false)
	for start in [Vector2(136, 704), Vector2(880, 736)]:
		_wall_run(start, 2, false)
	_wall_run(Vector2(136, 224), 2, true)
	_wall_run(Vector2(992, 224), 1, true)
	for point in [Vector2(136,224),Vector2(424,224),Vector2(704,224),Vector2(992,224),Vector2(136,416),Vector2(992,320),Vector2(136,704),Vector2(328,704),Vector2(880,736),Vector2(1072,736)]:
		walls.append(_prop("pillar", point, Vector2(20,16), 4))
	_building("nema",Vector2(232,648),Vector2(132,46),Vector2(-12,-27),Vector2(-38,-3))
	_building("umi",Vector2(904,668),Vector2(132,42),Vector2(5,-25),Vector2(-18,-3))

func _building(kind: String, point: Vector2, footprint: Vector2, body_offset: Vector2, door: Vector2) -> void:
	var body := _prop("../orthographic/"+kind,point,footprint,0)
	body.name = kind.to_pascal_case()
	body.get_node("CollisionShape2D").position = body_offset
	if kind == "nema":
		_collision(body,Vector2(46,28),Vector2(64,-17))
	else:
		_collision(body,Vector2(44,20),Vector2(-57,-20))
	buildings.append(body)
	body.set_meta("interior_status", &"planned")
	for marker_name in ["Doorway","Approach","ReturnPoint"]:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position = door + (Vector2.ZERO if marker_name == "Doorway" else Vector2(0,28))
		body.add_child(marker)
	var reveal := Area2D.new()
	reveal.collision_layer = 0
	reveal.collision_mask = 2
	body.add_child(reveal)
	_collision(reveal,Vector2(140,110),Vector2(0,-100))
	var art: Sprite2D = body.get_node("Art")
	reveal.body_entered.connect(func(actor: Node) -> void:
		if actor is Player: art.modulate.a = .45)
	reveal.body_exited.connect(func(actor: Node) -> void:
		if actor is Player: art.modulate.a = 1.0)

func _wall_run(start: Vector2, count: int, vertical: bool) -> void:
	for index in count:
		var point := start + (Vector2(0, (index + 1) * 96) if vertical else Vector2(index * 96 + 48, 0))
		walls.append(_prop("wall_vertical" if vertical else "wall_horizontal", point,
			Vector2(22, 96) if vertical else Vector2(96, 14), 0))

func _prop(kind: String, point: Vector2, footprint: Vector2, bottom_padding: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = kind.get_file().to_pascal_case() + str(_props.get_child_count())
	body.position = point
	body.collision_layer = 1
	body.collision_mask = 0
	_props.add_child(body)
	var art := Sprite2D.new()
	art.name = "Art"
	art.texture = load(ART + kind + ".png")
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.position = Vector2(0, bottom_padding - art.texture.get_height() / 2.0)
	body.add_child(art)
	_collision(body, footprint, Vector2(0, bottom_padding - footprint.y / 2.0))
	return body

func _collision(parent: CollisionObject2D, size: Vector2, offset: Vector2) -> void:
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = offset
	parent.add_child(collision)
