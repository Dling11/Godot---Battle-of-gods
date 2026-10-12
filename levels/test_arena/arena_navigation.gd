extends NavigationRegion2D

@export var navigation_bounds := Rect2(48.0, 48.0, 864.0, 444.0)
@export_range(1.0, 64.0, 1.0, "suffix:px") var navigation_agent_radius := 6.0


func _ready() -> void:
	call_deferred("rebuild_navigation")


func rebuild_navigation() -> void:
	var polygon := NavigationPolygon.new()
	polygon.agent_radius = navigation_agent_radius
	var source_geometry := NavigationMeshSourceGeometryData2D.new()
	var outer := PackedVector2Array([
		navigation_bounds.position,
		Vector2(navigation_bounds.end.x, navigation_bounds.position.y),
		navigation_bounds.end,
		Vector2(navigation_bounds.position.x, navigation_bounds.end.y),
	])
	if not Geometry2D.is_polygon_clockwise(outer):
		outer.reverse()
	source_geometry.add_traversable_outline(outer)

	for node in get_tree().get_nodes_in_group("navigation_cutout"):
		if not node is NavigationCutout:
			continue
		for global_outline in node.get_global_outlines():
			var local_outline := PackedVector2Array()
			for point in global_outline:
				local_outline.append(to_local(point))
			source_geometry.add_projected_obstruction(local_outline, false)

	NavigationServer2D.bake_from_source_geometry_data(polygon, source_geometry)
	navigation_polygon = polygon
	NavigationServer2D.region_set_navigation_polygon(get_rid(), polygon)
	NavigationServer2D.map_force_update(get_navigation_map())
