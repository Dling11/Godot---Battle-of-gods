extends "res://entities/npcs/presentation/service_work_animation.gd"

const BUILDING = preload("res://assets/environment/sanctuary/refuge_review/orren_workshop.png")
const ORREN_POSITION := Vector2(992,438)
var workshop: StaticBody2D

func configure(hub: Node, props: Node2D) -> void:
	setup(hub,"WeaponMerchant","Orren","Armskeeper",Vector2(0,-62))
	npc.position = ORREN_POSITION
	_build_workshop(props)

func _build_workshop(props: Node2D) -> void:
	workshop = StaticBody2D.new()
	workshop.name = "OrrenWorkshop"
	workshop.position = Vector2(928,390)
	workshop.collision_layer = 1
	workshop.collision_mask = 0
	props.add_child(workshop)
	var art := Sprite2D.new()
	art.name = "Art"
	art.texture = BUILDING
	art.position = Vector2(0,-96)
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	workshop.add_child(art)
	_collision(workshop,Vector2(142,42),Vector2(-5,-25))
	_collision(workshop,Vector2(82,34),Vector2(103,-21))
	for marker_name in ["Doorway","Approach","ReturnPoint"]:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position.y = 0 if marker_name == "Doorway" else (36 if marker_name == "Approach" else 48)
		workshop.add_child(marker)
	workshop.set_meta("service_id",&"armskeeper")
	workshop.set_meta("interior_status",&"planned")
	var rear := Area2D.new()
	rear.collision_layer = 0
	rear.collision_mask = 2
	workshop.add_child(rear)
	_collision(rear,Vector2(222,120),Vector2(28,-106))
	rear.body_entered.connect(func(body: Node) -> void:
		if body is Player: art.modulate.a = .48)
	rear.body_exited.connect(func(body: Node) -> void:
		if body is Player: art.modulate.a = 1.0)
	var embers := CPUParticles2D.new()
	embers.name = "ForgeEmbers"
	embers.position = Vector2(80,-37)
	embers.amount = 5
	embers.lifetime = 1.4
	embers.direction = Vector2.UP
	embers.spread = 18
	embers.gravity = Vector2(0,-3)
	embers.initial_velocity_min = 4
	embers.initial_velocity_max = 7
	embers.color = Color(1,.44,.14,.7)
	embers.scale_amount_min = .7
	embers.scale_amount_max = 1.0
	var gradient := Gradient.new()
	gradient.set_color(0,Color(1,.65,.25,0))
	gradient.set_color(1,Color(1,.2,.06,0))
	gradient.add_point(.2,Color(1,.45,.12,.75))
	embers.color_ramp = gradient
	workshop.add_child(embers)

func _collision(parent: CollisionObject2D, size: Vector2, offset: Vector2) -> void:
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	collider.position = offset
	parent.add_child(collider)
