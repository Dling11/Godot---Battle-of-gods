extends EncounterController

var _spawn_cursor := 0

func _choose_spawn_position() -> Vector2:
	var point := _spawn_points[_spawn_cursor%_spawn_points.size()]
	_spawn_cursor += 1
	return NavigationServer2D.map_get_closest_point(player.get_world_2d().get_navigation_map(),point.global_position)

## A finite encounter inside a boss stage. Boss flow retains bank/chest authority.
func _complete_encounter() -> void:
	if _completion_spawned: return
	_completion_spawned = true
	_portal_opened = true
	_emit_progress()
	stage_cleared.emit()
