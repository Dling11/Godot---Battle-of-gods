extends RefCounted

## Shared preview/commit geometry. Pointer distance never shortens the lane.
static func resolve(actor: Player, point: Vector2, tuning: AbilityDefinition, start := Vector2.INF, reach := -1.0, contact_offset := -1.0) -> Dictionary:
	var origin := actor.global_position if start == Vector2.INF else start
	var direction := point - origin
	if direction.length_squared() < .01:
		direction = actor.facing_direction
	direction = direction.normalized()
	var distance: float = tuning.range_pixels if reach < 0.0 else reach
	# The supernatural ground wave keeps its authored reach through scenery.
	# Movement collision remains separate from this preview/contact geometry.
	return {
		"origin": origin,
		"direction": direction,
		"contact": origin + direction * minf(tuning.contact_offset if contact_offset < 0.0 else contact_offset, distance),
		"end": origin + direction * distance,
		"radius": tuning.lane_radius,
		"blocked": false,
	}

