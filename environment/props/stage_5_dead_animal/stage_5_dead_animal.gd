extends StaticBody2D

@export var flies_root: Node2D


func _ready() -> void:
	if flies_root == null:
		return
	var routes := [
		[Vector2(-8, -5), Vector2(5, -9), Vector2(10, 2), Vector2(-3, 7)],
		[Vector2(6, 4), Vector2(12, -4), Vector2(1, -10), Vector2(-9, -2)],
		[Vector2(-4, 8), Vector2(-12, 1), Vector2(-5, -8), Vector2(8, -5)],
		[Vector2(10, -2), Vector2(3, 8), Vector2(-10, 5), Vector2(-7, -6)],
	]
	for index in mini(flies_root.get_child_count(), routes.size()):
		var fly := flies_root.get_child(index) as Polygon2D
		if fly == null:
			continue
		var origin := fly.position
		var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_interval(index * 0.07)
		for offset: Vector2 in routes[index]:
			tween.tween_property(fly, "position", origin + offset, 0.22 + index * 0.015)
