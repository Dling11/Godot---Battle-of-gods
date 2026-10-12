class_name NavigationCutout
extends Node

@export var local_outline: PackedVector2Array
@export var derive_from_collision_shapes := false


func get_global_outline() -> PackedVector2Array:
	var result := PackedVector2Array()
	var parent_2d := get_parent() as Node2D
	if parent_2d == null:
		return result
	for point in local_outline:
		result.append(parent_2d.to_global(point))
	return result


func get_global_outlines() -> Array[PackedVector2Array]:
	var outlines: Array[PackedVector2Array] = []
	var parent_body := get_parent() as CollisionObject2D
	if derive_from_collision_shapes and parent_body != null:
		var combined_points := PackedVector2Array()
		for child in parent_body.get_children():
			var collision := child as CollisionShape2D
			if collision == null or collision.disabled or collision.shape == null:
				continue
			var outline := _shape_outline(collision)
			if outline.size() >= 3:
				combined_points.append_array(outline)
		if combined_points.size() >= 3:
			outlines.append(Geometry2D.convex_hull(combined_points))
	if outlines.is_empty():
		var fallback := get_global_outline()
		if fallback.size() >= 3:
			outlines.append(fallback)
	return outlines


func _shape_outline(collision: CollisionShape2D) -> PackedVector2Array:
	var local_points := PackedVector2Array()
	if collision.shape is RectangleShape2D:
		var half_size: Vector2 = (collision.shape as RectangleShape2D).size * 0.5
		local_points = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
		])
	elif collision.shape is CircleShape2D:
		var radius: float = (collision.shape as CircleShape2D).radius
		for index in range(12):
			local_points.append(Vector2.RIGHT.rotated(TAU * float(index) / 12.0) * radius)
	elif collision.shape is ConvexPolygonShape2D:
		local_points = (collision.shape as ConvexPolygonShape2D).points
	else:
		return local_points

	var global_points := PackedVector2Array()
	for point in local_points:
		global_points.append(collision.to_global(point))
	return global_points
