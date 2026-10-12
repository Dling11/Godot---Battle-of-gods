extends SceneTree

const RootlingScene = preload("res://entities/enemies/rootling/rootling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var actors := Node2D.new()
	root.add_child(actors)
	var target := CharacterBody2D.new()
	actors.add_child(target)
	target.global_position = Vector2(0.0, 50.0)
	var rootling := RootlingScene.instantiate() as Rootling
	rootling.target = target
	actors.add_child(rootling)
	rootling.global_position = Vector2.ZERO
	var attack_record := {"direction": Vector2.ZERO, "erupted": false}
	rootling.root_jab_telegraphed.connect(func(direction: Vector2, _duration: float) -> void:
		attack_record.direction = direction
		# A player who sidesteps after the telegraph must not rotate the jab.
		target.global_position = rootling.global_position + Vector2.LEFT * 180.0
	)
	rootling.root_jab_erupted.connect(func(_direction: Vector2) -> void: attack_record.erupted = true)
	await create_timer(1.35).timeout
	if (
		rootling.definition.display_name != "Rootling"
		or rootling.definition.maximum_health != 35.0
		or not is_equal_approx(rootling.definition.attack_damage, 10.0)
	):
		_fail("Rootling must use its own compact Stage 1 definition.")
		return
	if (attack_record.direction as Vector2).is_zero_approx() or not attack_record.erupted:
		_fail("Rootling did not complete its anchor and root-jab sequence.")
		return
	var attack_pivot := rootling.get_node("AttackPivot") as Node2D
	if absf(angle_difference(attack_pivot.rotation, (attack_record.direction as Vector2).angle())) > 0.01:
		_fail("Rootling root jab rotated after its telegraph instead of staying locked.")
		return
	var body := rootling.get_node("Visual/Body") as Sprite2D
	if body.scale.y < 0.99:
		_fail("Rootling wind-up must keep its full body height in the down-facing jab.")
		return
	var walk_atlas := body.texture.get_image()
	var down_reference := _opaque_bounds(walk_atlas, 0)
	var unique_down_frames := 0
	for frame_index in range(1, 4):
		var frame_bounds := _opaque_bounds(walk_atlas, frame_index)
		if abs(frame_bounds.size.y - down_reference.size.y) > 1:
			_fail("Rootling down walk frames must keep a consistent body height.")
			return
		if not _cells_match(walk_atlas, 0, frame_index):
			unique_down_frames += 1
	if unique_down_frames < 2:
		_fail("Rootling down walk must contain real alternating step frames.")
		return
	var hitbox := rootling.get_node("AttackPivot/AttackHitbox") as MeleeHitbox
	var shape := hitbox.get_node("CollisionShape2D").shape as RectangleShape2D
	if shape.size.x != 40.0 or shape.size.y != 16.0:
		_fail("Rootling jab hitbox must remain the authored narrow 40x16 lane.")
		return
	var root_jab_audio := rootling.get_node("ActionSfx/RootJab") as AudioStreamPlayer2D
	if root_jab_audio.stream == null or root_jab_audio.stream.resource_path != "res://assets/audio/sfx/rootling_root_jab.wav":
		_fail("Rootling jab must use its dedicated wood-crack sound.")
		return
	print("Rootling behavior smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _opaque_bounds(image: Image, column: int) -> Rect2i:
	var left := 32
	var top := 32
	var right := -1
	var bottom := -1
	for y in range(32):
		for x in range(32):
			if image.get_pixel(column * 32 + x, y).a < 0.5:
				continue
			left = mini(left, x)
			top = mini(top, y)
			right = maxi(right, x)
			bottom = maxi(bottom, y)
	return Rect2i(left, top, right - left + 1, bottom - top + 1)


func _cells_match(image: Image, left_column: int, right_column: int) -> bool:
	for y in range(32):
		for x in range(32):
			if image.get_pixel(left_column * 32 + x, y) != image.get_pixel(right_column * 32 + x, y):
				return false
	return true
