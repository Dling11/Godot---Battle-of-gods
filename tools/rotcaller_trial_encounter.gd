extends EncounterController

## Uses normal waves/navigation/slot accounting, excludes campaign grants.
var _spawn_number := 0

func _prepare_enemy(enemy: Node) -> void:
	var rewards := enemy.get_node_or_null("EnemyRewardComponent")
	if rewards != null:
		enemy.remove_child(rewards)
		rewards.free()

func _choose_spawn_position() -> Vector2:
	var points := [Vector2(768,392),Vector2(664,368),Vector2(872,368),Vector2(904,296)]
	var requested: Vector2 = points[mini(_spawn_number,points.size()-1)]
	_spawn_number += 1
	return NavigationServer2D.map_get_closest_point(player.get_world_2d().get_navigation_map(),requested)

func _complete_encounter() -> void:
	if _completion_spawned: return
	_completion_spawned = true
	_portal_opened = true
	stage_cleared.emit()
	_emit_progress()
