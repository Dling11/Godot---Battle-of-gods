extends RefCounted

## All scenery may be crossed in flight; world bodies still block landing.

static func query_for(actor: Player, point: Vector2) -> PhysicsShapeQueryParameters2D:
	var footprint := actor.get_node("CollisionShape2D") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = footprint.shape
	query.transform = footprint.global_transform
	query.transform.origin += point - actor.global_position
	query.collision_mask = 1
	query.exclude = [actor.get_rid()]
	query.margin = .5
	return query

static func is_clear(actor: Player, point: Vector2) -> bool:
	var map := actor.get_world_2d().get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map) > 0:
		# Disabled offscreen rooms remain registered on Sanctuary's shared map.
		# Only enabled regions establish ground; outdoors uses physics and bounds.
		for region in NavigationServer2D.map_get_regions(map):
			if NavigationServer2D.region_get_enabled(region):
				if NavigationServer2D.map_get_closest_point(map, point).distance_to(point) > 1.0:
					return false
				break
	return actor.get_world_2d().direct_space_state.intersect_shape(query_for(actor, point), 1).is_empty()

static func resolve(actor: Player, point: Vector2, reach: float) -> Vector2:
	var origin := actor.global_position
	var target := (origin + (point-origin).limit_length(reach)).clamp(actor.movement_bounds.position, actor.movement_bounds.end)
	var query := query_for(actor, origin)
	var space := actor.get_world_2d().direct_space_state
	if is_clear(actor, target): return target
	# A trunk at the chosen destination should shorten the landing, not the whole leap.
	var back := (origin-target).normalized()
	for distance in range(4, 33, 4):
		var candidate := target + back * minf(distance, target.distance_to(origin))
		if is_clear(actor, candidate): return candidate
	# Large occupied landing: fall back to the first safe approach rather than embed.
	query.exclude = [actor.get_rid()]
	query.motion = target-origin
	var approach := origin + query.motion * space.cast_motion(query)[0]
	return approach if is_clear(actor, approach) else origin
