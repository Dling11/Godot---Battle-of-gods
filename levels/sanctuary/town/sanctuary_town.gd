extends Node

## Current Sanctuary composition; service, progression and save authorities remain on the hub.
const Ground = preload("res://levels/sanctuary/town/town_ground.gd")
const OrrenReview = preload("res://levels/sanctuary/town/orren_workshop.gd")
const EiraReview = preload("res://levels/sanctuary/town/eira_presentation.gd")
const ArtisanReview = preload("res://levels/sanctuary/town/artisan_presentation.gd")
const Birds = preload("res://levels/sanctuary/town/garden_birds.gd")
const InterfaceReview = preload("res://levels/sanctuary/town/sanctuary_interface.gd")
const WorkshopVisit = preload("res://levels/sanctuary/town/workshop_visit.gd")
const TownDressing = preload("res://levels/sanctuary/town/town_dressing.gd")
const Beacon = preload("res://entities/npcs/presentation/service_beacon.gd")
const TownMap = preload("res://levels/sanctuary/town/town_map.gd")
const Courier = preload("res://entities/npcs/courier/sanctuary_courier.gd")
const Noticeboard = preload("res://levels/sanctuary/town/town_noticeboard.gd")
const ART := "res://assets/environment/sanctuary/refuge_review/"
var hub: Node
var ground: TileMapLayer
var props: Node2D
var lodge: StaticBody2D
var orren_review: Node
var eira_review: Node
var nema_review: Node
var umi_review: Node
var birds: Node2D
var interface_review: Node
var workshop_visit: Node
var dressing: Node
var town_map: CanvasLayer
var courier: CharacterBody2D
var noticeboard: Area2D
var beacons: Array[Node2D] = []
var test_controls_enabled := false
var overview := false
var _panel: PanelContainer

func _ready() -> void:
	name = "SanctuaryTown"
	ground = Ground.new()
	ground.name = "SanctuaryGround32"
	hub.get_node("World/Level").add_child(ground)
	props = Node2D.new()
	props.name = "TownProps"
	props.y_sort_enabled = true
	hub.get_node("World/Actors").add_child(props)
	_build_lodge()
	orren_review = OrrenReview.new()
	add_child(orren_review)
	orren_review.configure(hub,props)
	eira_review = EiraReview.new()
	add_child(eira_review)
	eira_review.configure(hub)
	nema_review = ArtisanReview.new()
	add_child(nema_review)
	nema_review.configure(hub,"Rootweaver","Nema","Grove Smith")
	umi_review = ArtisanReview.new()
	add_child(umi_review)
	umi_review.configure(hub,"Umi","Umi","Echo Melder")
	for position in [Vector2(168,448),Vector2(456,432),Vector2(464,388),Vector2(688,388),Vector2(464,564),Vector2(672,584),Vector2(512,720),Vector2(624,720)]:
		_prop("lantern",position,Vector2(18,12))
	for position in [Vector2(440,336),Vector2(752,408),Vector2(400,584),Vector2(720,584)]:
		_prop("planter",position,Vector2(54,18))
	for position in [Vector2(408,352),Vector2(752,352)]:
		_prop("bench",position,Vector2(56,14))
	dressing = TownDressing.new()
	add_child(dressing)
	dressing.configure(hub, props)
	birds = Birds.new()
	props.add_child(birds)
	_build_town_life()
	_build_controls()
	interface_review = InterfaceReview.new()
	add_child(interface_review)
	interface_review.configure(hub,_panel)
	workshop_visit = WorkshopVisit.new()
	add_child(workshop_visit)
	workshop_visit.configure(self)
	_panel.hide()
	workshop_visit.set_enabled(true)
	for beacon in beacons: beacon.set_enabled(true)
	town_map.set_enabled(true)
	courier.set_enabled(true)
	birds.set_enabled(true)

func _build_lodge() -> void:
	lodge = StaticBody2D.new()
	lodge.name = "TrainerLodge"
	lodge.position = Vector2(224,390)
	lodge.collision_layer = 1
	lodge.collision_mask = 0
	props.add_child(lodge)
	var sprite := Sprite2D.new()
	sprite.texture = load(ART+"trainer_lodge.png")
	sprite.position = Vector2(0,-96)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lodge.add_child(sprite)
	_collision(lodge,Vector2(176,52),Vector2(16,-34))
	for marker_name in ["Doorway","Approach","ReturnPoint"]:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position = Vector2(0,0 if marker_name == "Doorway" else (36 if marker_name == "Approach" else 48))
		lodge.add_child(marker)
	lodge.set_meta("service_id",&"skillkeeper")
	lodge.set_meta("interior_status",&"planned")
	# Footprint remains fixed. Only the roof/body visibility fades behind it.
	var rear := Area2D.new()
	rear.collision_layer = 0
	rear.collision_mask = 2
	lodge.add_child(rear)
	_collision(rear,Vector2(168,112),Vector2(16,-116))
	rear.body_entered.connect(func(body: Node) -> void:
		if body is Player: sprite.modulate.a = .48)
	rear.body_exited.connect(func(body: Node) -> void:
		if body is Player: sprite.modulate.a = 1.0)

func _prop(kind: String, position: Vector2, footprint: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = kind.capitalize()+str(props.get_child_count())
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 0
	props.add_child(body)
	var sprite := Sprite2D.new()
	sprite.texture = load(ART+kind+".png")
	sprite.position = Vector2(0,-32)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(sprite)
	_collision(body,footprint,Vector2(0,-footprint.y/2))
	if kind == "lantern":
		var glow := Sprite2D.new()
		var gradient := Gradient.new()
		gradient.set_color(0,Color(1.0,.67,.25,.24))
		gradient.set_color(1,Color(1.0,.67,.25,0.0))
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.width = 28
		texture.height = 28
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(.5,.5)
		texture.fill_to = Vector2(1,.5)
		glow.texture = texture
		glow.position = Vector2(0,-46)
		body.add_child(glow)
		var tween := glow.create_tween().set_loops()
		tween.tween_property(glow,"modulate:a",.45,1.3)
		tween.tween_property(glow,"modulate:a",1.0,1.7)

func _collision(parent: CollisionObject2D, size: Vector2, offset: Vector2) -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = offset
	parent.add_child(collision)

func _build_controls() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 15
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.position = Vector2(324,8)
	layer.add_child(_panel)
	var column := VBoxContainer.new()
	_panel.add_child(column)
	var title := Label.new()
	title.text = "SANCTUARY · TEST SESSION"
	title.add_theme_font_size_override("font_size",12)
	column.add_child(title)
	var caption := Label.new()
	caption.text = "NO SAVES · F to talk · Follow the courier"
	caption.add_theme_font_size_override("font_size",11)
	column.add_child(caption)
	var row := HBoxContainer.new()
	column.add_child(row)
	_action(row,"Visit Orren",visit_orren)
	_action(row,"Visit Eira",visit_eira)
	_action(row,"Visit Nema",visit_nema)
	_action(row,"Visit Umi",visit_umi)
	var navigation := HBoxContainer.new()
	column.add_child(navigation)
	_action(navigation,"Overview / walk",func() -> void: set_overview(not overview))
	if TownMap.PRESENTATION_ENABLED:
		_action(navigation,"Town map [M]",town_map.toggle)
	_action(navigation,"Find Rowan",visit_courier)
	_action(navigation,"Workshop door",visit_workshop)

func _action(row: HBoxContainer, title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.add_theme_font_size_override("font_size",12)
	button.pressed.connect(action)
	row.add_child(button)
	return button

func enable_test_controls() -> void:
	test_controls_enabled = true
	interface_review._sync_review_controls()

func _build_town_life() -> void:
	var entries: Array[Dictionary] = []
	var recipes := [
		["orren","WeaponMerchant","Orren","Armskeeper",Color(.96,.75,.4),"Keeping that edge true, King?",orren_review],
		["eira","Skillkeeper","Eira","Skills",Color(.8,.69,.98),"Ready to practice, King?",eira_review],
		["nema","Rootweaver","Nema","Crafting",Color(.66,.86,.51),"Bring your finds. We'll make use of them.",nema_review],
		["umi","Umi","Umi","Exchange",Color(.49,.82,.95),"Every fragment holds a memory.",umi_review],
	]
	for recipe in recipes:
		var npc: DialogueNpc = hub.get_node("World/Actors/" + str(recipe[1]))
		var beacon := Beacon.new()
		beacon.name = "ServiceBeacon"
		beacon.configure(npc,recipe[4],recipe[5],recipe[6])
		beacons.append(beacon)
		entries.append({"id":recipe[0],"node":npc,"name":recipe[2],"role":recipe[3],"color":recipe[4],"beacon":beacon})
	entries.append({"id":"gate","node":hub.get_node("World/Actors/ExpeditionAltar"),"name":"Veil Gate","role":"Expeditions","color":Color(.85,.77,.97)})
	town_map = TownMap.new()
	add_child(town_map)
	town_map.configure(hub,entries,ground.routes)
	noticeboard = Noticeboard.new()
	noticeboard.hub = hub
	noticeboard.town_map = town_map
	dressing.stations[2].add_child(noticeboard)
	courier = Courier.new()
	courier.name = "TownCourier"
	courier.player = hub.get_node("World/Actors/Player")
	courier.hub = hub
	courier.route = PackedVector2Array([Vector2(720,496),Vector2(928,496),Vector2(968,484),Vector2(928,496),Vector2(704,496),Vector2(704,552),Vector2(576,552),Vector2(416,520),Vector2(288,492),Vector2(416,520),Vector2(576,552),Vector2(704,552)])
	courier.stop_indices.assign([2,8])
	hub.get_node("World/Actors").add_child(courier)

func visit_orren() -> void:
	set_overview(false)
	hub.get_node("World/Actors/Player").global_position = Vector2(984,474)
	hub.get_node("World/Actors/Player/Camera2D").reset_smoothing()

func visit_workshop() -> void:
	_visit(orren_review.workshop.get_node("Approach").global_position)

func visit_eira() -> void:
	set_overview(false)
	hub.get_node("World/Actors/Player").global_position = EiraReview.APPROACH
	hub.get_node("World/Actors/Player/Camera2D").reset_smoothing()

func visit_nema() -> void:
	_visit(Vector2(366,658))

func visit_umi() -> void:
	_visit(Vector2(784,686))

func visit_courier() -> void:
	# Use an authored open delivery stop; avoid teleporting King into a nearby prop.
	courier.position = Vector2(704,552)
	courier.destination_index = 6
	courier._stop_remaining = 0
	_visit(Vector2(724,552))

func _visit(point: Vector2) -> void:
	set_overview(false)
	hub.get_node("World/Actors/Player").global_position = point
	hub.get_node("World/Actors/Player/Camera2D").reset_smoothing()

func set_overview(value: bool) -> void:
	if workshop_visit != null and workshop_visit.inside: workshop_visit.leave()
	overview = value
	var camera := hub.get_node("World/Actors/Player/Camera2D") as Camera2D
	camera.position_smoothing_enabled = false
	camera.set_as_top_level(value)
	camera.position = Vector2(576,384) if value else Vector2(0,-8)
	camera.zoom = Vector2(.68,.68) if value else Vector2.ONE
	camera.limit_left = -10000 if value else 0
	camera.limit_top = -10000 if value else 0
	camera.limit_right = 10000 if value else 1152
	camera.limit_bottom = 10000 if value else 768
	camera.reset_smoothing()
