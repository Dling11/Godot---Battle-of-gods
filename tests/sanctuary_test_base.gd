extends SceneTree

const HUB = preload("res://levels/sanctuary/sanctuary.tscn")
const Study = preload("res://levels/sanctuary/town/sanctuary_town.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	quit()

func _blocked(space: PhysicsDirectSpaceState2D, point: Vector2) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0,point)
	query.collision_mask = 1
	query.collide_with_areas = false
	return not space.intersect_shape(query,1).is_empty()

func _reachable(space: PhysicsDirectSpaceState2D, start: Vector2i) -> Dictionary:
	var visited := {start:true}
	var blocked := {}
	var queue: Array[Vector2i] = [start]
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+offset
			if next.x < 0 or next.y < 0 or next.x >= 72 or next.y >= 48 or visited.has(next) or blocked.has(next): continue
			if _blocked(space,Vector2(next*16)+Vector2(8,8)):
				blocked[next] = true
			else:
				visited[next] = true
				queue.append(next)
	return visited

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
