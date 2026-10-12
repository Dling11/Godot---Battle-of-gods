extends SceneTree

const Ground = preload("res://entities/enemies/examiner/examiner_ground_judgment_vfx.gd")
const Descent = preload("res://entities/enemies/examiner/examiner_divine_descent_vfx.gd")
const Lane = preload("res://entities/enemies/examiner/examiner_axiom_lane.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	# Every chronological effect frame must be reachable, including the decay row.
	for i in 8:
		if ExaminerEffectAtlas.frame_at((float(i) + 0.5) / 8.0, 1.0) != i:
			push_error("Effect timeline skipped an authored frame")
			quit(1)
			return
	var world := Node2D.new()
	root.add_child(world)
	var ground := Ground.new()
	var descent := Descent.new()
	var lane := Lane.new()
	world.add_child(ground)
	world.add_child(descent)
	world.add_child(lane)
	lane.configure(Vector2(30, 40), Vector2.LEFT, 300, 28, .1, .2)
	await create_timer(.10).timeout
	if lane._active:
		push_error("Axiom warning displayed contact before resolve")
		quit(1)
		return
	await create_timer(.16).timeout
	if not lane._active:
		push_error("Axiom contact missed its scheduled resolve")
		quit(1)
		return
	await create_timer(1.6).timeout
	if world.get_child_count() != 0:
		push_error("Transient effect survived its lifetime")
		quit(1)
		return
	world.queue_free()
	await process_frame
	print("Examiner VFX: all eight frames reachable, warning/contact timing and cleanup passed.")
	quit()
