extends Control

signal destination_selected(service_id: String)
const PAPER = preload("res://assets/ui/sanctuary_theme/map_paper.png")
const LANDMARKS := [
	[preload("res://assets/environment/sanctuary/refuge_review/trainer_lodge.png"),Rect2(96,180,256,224)],
	[preload("res://assets/environment/sanctuary/refuge_review/orren_workshop.png"),Rect2(768,182,320,224)],
	[preload("res://assets/environment/sanctuary/orthographic/nema.png"),Rect2(132,500,200,148)],
	[preload("res://assets/environment/sanctuary/orthographic/umi.png"),Rect2(816,533,176,135)],
]
var interactive := false

var entries: Array[Dictionary] = []
var routes: Array[PackedVector2Array] = []
var player: Node2D
var selected_id := ""

func _draw() -> void:
	var map_scale := Vector2.ONE * minf(size.x / 1152.0,size.y / 768.0)
	var offset := (size - Vector2(1152,768) * map_scale) / 2
	draw_texture_rect(PAPER,Rect2(Vector2.ZERO,size),false)
	for route in routes:
		var points := PackedVector2Array()
		for point in route: points.append(point*map_scale+offset)
		draw_polyline(points,Color(.25,.23,.18,.8),maxf(2,38*map_scale.x))
		draw_polyline(points,Color(.76,.68,.46),maxf(1,21*map_scale.x))
	for landmark in LANDMARKS:
		var rectangle: Rect2 = landmark[1]
		draw_texture_rect(landmark[0],Rect2(rectangle.position*map_scale+offset,rectangle.size*map_scale),false,Color(.85,.80,.67))
	draw_circle(Vector2(576,452)*map_scale+offset,maxf(3,35*map_scale.x),Color(.24,.45,.46))
	for entry in entries:
		var point: Vector2 = entry.node.global_position*map_scale+offset
		if str(entry.id) == selected_id: draw_circle(point,7,Color(.95,.88,.55),false,1)
		draw_circle(point,4.5,Color(.10,.09,.09))
		draw_circle(point,3,entry.color)
	if is_instance_valid(player):
		var point := player.global_position*map_scale+offset
		draw_circle(point,5,Color(.10,.09,.09,.85))
		draw_colored_polygon(PackedVector2Array([point+Vector2(0,-5),point+Vector2(4,4),point+Vector2(-4,4)]),Color.WHITE)

func map_point(world_point: Vector2) -> Vector2:
	var factor := minf(size.x/1152.0,size.y/768.0)
	return (size-Vector2(1152,768)*factor)/2+world_point*factor

func _gui_input(event: InputEvent) -> void:
	if not interactive or not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT or not event.pressed: return
	var best := 13.0
	var picked := ""
	for entry in entries:
		var distance: float = event.position.distance_to(map_point(entry.node.global_position))
		if distance < best:
			best = distance
			picked = str(entry.id)
	if not picked.is_empty():
		accept_event()
		destination_selected.emit(picked)
