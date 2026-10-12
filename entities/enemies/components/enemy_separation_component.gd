class_name EnemySeparationComponent
extends Area2D

@export_range(0.0, 2.0, 0.05) var separation_weight := 0.85
@export_range(1.0, 100.0, 1.0, "suffix:px") var separation_radius := 30.0


func configure_radius(value: float) -> void:
	separation_radius = maxf(value, 1.0)
	var detection_shape := get_node_or_null("DetectionShape") as CollisionShape2D
	if detection_shape == null or not detection_shape.shape is CircleShape2D:
		push_error("EnemySeparationComponent requires a circular DetectionShape.")
		return
	var runtime_shape := detection_shape.shape.duplicate() as CircleShape2D
	runtime_shape.radius = separation_radius
	detection_shape.shape = runtime_shape


func blend_direction(actor: CharacterBody2D, desired_direction: Vector2) -> Vector2:
	var repulsion := Vector2.ZERO
	for body in get_overlapping_bodies():
		if body == actor or not body is CharacterBody2D:
			continue
		var away := actor.global_position - body.global_position
		var distance := away.length()
		if distance >= separation_radius:
			continue
		if distance <= 0.01:
			var seed_angle := float(actor.get_instance_id() % 16) * TAU / 16.0
			away = Vector2.RIGHT.rotated(seed_angle)
			distance = 0.01
		var proximity := 1.0 - distance / separation_radius
		repulsion += away.normalized() * proximity

	if repulsion.is_zero_approx():
		return desired_direction.normalized()
	if desired_direction.is_zero_approx():
		return repulsion.normalized()
	return (desired_direction.normalized() + repulsion * separation_weight).normalized()
