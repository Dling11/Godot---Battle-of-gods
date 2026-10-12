class_name MaterialPickup
extends Area2D

## Presentation and contact collection for one already-resolved enemy drop.

@export var icon_sprite: Sprite2D
@export var quantity_label: Label
@export var glow: Polygon2D
@export var visual_root: Node2D
@export_range(0.0, 2.0, 0.05, "suffix:s") var auto_collect_delay := 0.5
@export_range(40.0, 800.0, 10.0, "suffix:px/s") var magnet_start_speed := 150.0
@export_range(100.0, 1600.0, 10.0, "suffix:px/s²") var magnet_acceleration := 900.0
@export_range(100.0, 1200.0, 10.0, "suffix:px/s") var magnet_max_speed := 620.0

var material_definition: MaterialDefinition
var quantity := 0
var _collecting := false
var _recipient: Player
var _homing := false
var _homing_speed := 0.0
var _hover_tween: Tween


func configure(
	definition: MaterialDefinition,
	amount: int,
	recipient: Player = null
) -> void:
	material_definition = definition
	quantity = amount
	_recipient = recipient


func _ready() -> void:
	if (
		material_definition == null
		or not material_definition.is_valid()
		or quantity <= 0
		or icon_sprite == null
		or quantity_label == null
		or glow == null
		or visual_root == null
	):
		push_error("MaterialPickup requires valid material data and presentation nodes.")
		queue_free()
		return
	set_physics_process(false)
	body_entered.connect(_on_body_entered)
	monitoring = false
	icon_sprite.texture = material_definition.icon
	quantity_label.text = "x%d" % quantity
	quantity_label.visible = quantity > 1
	glow.color = material_definition.get_rarity_color()
	glow.modulate.a = 0.22
	scale = Vector2(0.6, 0.6)


func begin_pop(direction: Vector2) -> void:
	if not is_inside_tree():
		return
	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = Vector2.UP
	var start := position
	var destination := start + launch_direction * 16.0
	var pop := create_tween().set_parallel()
	pop.tween_property(self, "position", destination, 0.28).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	pop.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)

	var jump := create_tween()
	jump.tween_property(visual_root, "position:y", -14.0, 0.13).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	jump.parallel().tween_property(visual_root, "rotation", -0.09, 0.13)
	jump.tween_property(visual_root, "position:y", -2.0, 0.15).set_trans(
		Tween.TRANS_BOUNCE
	).set_ease(Tween.EASE_OUT)
	jump.parallel().tween_property(visual_root, "rotation", 0.04, 0.1)
	jump.tween_callback(_enable_collection)

	var pulse := create_tween().set_loops()
	pulse.tween_property(glow, "scale", Vector2(1.18, 1.18), 0.65).set_trans(
		Tween.TRANS_SINE
	)
	pulse.tween_property(glow, "scale", Vector2.ONE, 0.65).set_trans(
		Tween.TRANS_SINE
	)


func _enable_collection() -> void:
	if not is_inside_tree():
		return
	monitoring = true
	_start_hover()
	await get_tree().physics_frame
	for body: Node2D in get_overlapping_bodies():
		if body is Player:
			_collect()
			return
	if auto_collect_delay <= 0.0:
		_begin_auto_collect()
		return
	get_tree().create_timer(auto_collect_delay).timeout.connect(
		_begin_auto_collect,
		CONNECT_ONE_SHOT
	)


func _start_hover() -> void:
	_hover_tween = create_tween().set_loops()
	_hover_tween.tween_property(visual_root, "position:y", -5.0, 0.55).set_trans(
		Tween.TRANS_SINE
	).set_ease(Tween.EASE_IN_OUT)
	_hover_tween.parallel().tween_property(visual_root, "rotation", -0.035, 0.55)
	_hover_tween.tween_property(visual_root, "position:y", -2.0, 0.55).set_trans(
		Tween.TRANS_SINE
	).set_ease(Tween.EASE_IN_OUT)
	_hover_tween.parallel().tween_property(visual_root, "rotation", 0.035, 0.55)


func _begin_auto_collect() -> void:
	if _collecting or _homing or not is_instance_valid(_recipient):
		return
	_homing = true
	_homing_speed = magnet_start_speed
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if not _homing:
		return
	if not is_instance_valid(_recipient):
		_homing = false
		set_physics_process(false)
		return
	_homing_speed = minf(
		magnet_max_speed,
		_homing_speed + magnet_acceleration * delta
	)
	var target_position := _recipient.global_position + Vector2(0.0, -8.0)
	global_position = global_position.move_toward(
		target_position,
		_homing_speed * delta
	)
	if global_position.distance_squared_to(target_position) <= 100.0:
		_collect()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_collect()


func _collect() -> void:
	if _collecting:
		return
	_collecting = true
	_homing = false
	set_physics_process(false)
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	set_deferred("monitoring", false)
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service == null or not loot_service.grant_material(
		material_definition,
		quantity,
		&"enemy_drop"
	):
		_collecting = false
		set_deferred("monitoring", true)
		return
	var collect := create_tween().set_parallel()
	collect.tween_property(self, "scale", Vector2(1.35, 1.35), 0.12)
	collect.tween_property(self, "modulate:a", 0.0, 0.12)
	collect.chain().tween_callback(queue_free)
