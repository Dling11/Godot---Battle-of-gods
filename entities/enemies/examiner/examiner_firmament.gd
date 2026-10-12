class_name ExaminerFirmament
extends Node

## Each wave snapshots the target and scatters around a local escape opening.
## Seed injection supports reproducible checks; runtime casts use a live RNG.
var actor: Examiner
var active := false
var wave := 0
var remaining := 0.0
var points: Array[Vector2] = []
var escape_point := Vector2.ZERO
var _random := RandomNumberGenerator.new()
var _meteors: Array[ExaminerSun] = []


func _ready() -> void:
	_random.randomize()
	set_physics_process(false)


func begin(owner_actor: Examiner, test_seed := -1) -> void:
	cancel()
	actor = owner_actor
	if test_seed >= 0:
		_random.seed = test_seed
	wave = 0
	points.clear()
	_meteors.clear()
	active = true
	set_physics_process(true)
	_release_wave()


func _physics_process(delta: float) -> void:
	if not active or not is_instance_valid(actor):
		return
	remaining -= delta
	if remaining <= 0.0:
		_release_wave()


func _release_wave() -> void:
	if wave >= actor.definition.firmament_wave_count:
		cancel()
		return
	var center := actor.target.global_position if is_instance_valid(actor.target) else actor.arena_bounds.get_center()
	var radius := actor.definition.firmament_radius
	escape_point = _choose_escape(center, radius)
	var chosen: Array[Vector2] = [center.clamp(actor.arena_bounds.position + Vector2.ONE * 16, actor.arena_bounds.end - Vector2.ONE * 16)]
	var inset := actor.arena_bounds.grow(-radius)
	for index in range(1, actor.definition.firmament_meteors_per_wave):
		for attempt in 64:
			var point := Vector2(_random.randf_range(inset.position.x, inset.end.x), _random.randf_range(inset.position.y, inset.end.y))
			if point.distance_to(escape_point) < radius + 26:
				continue
			var spaced := true
			for other in chosen:
				if point.distance_to(other) < radius * 2 + 12:
					spaced = false
					break
			if spaced:
				chosen.append(point)
				break
	for point in chosen:
		points.append(point)
		var sun := actor._spawn_sun(point, radius, actor.scaled_damage(actor.definition.firmament_damage), actor.definition.firmament_warning_seconds, true)
		sun.crimson = true
		sun.presentation_gain = 0.45
		_meteors.append(sun)
	wave += 1
	remaining = actor.definition.firmament_wave_interval


func _choose_escape(center: Vector2, radius: float) -> Vector2:
	var inset := actor.arena_bounds.grow(-18)
	var best := center
	var best_clearance := -INF
	var start_angle := _random.randf_range(0, TAU)
	for index in 24:
		var candidate := (center + Vector2.from_angle(start_angle + index * TAU / 24) * 78).clamp(inset.position, inset.end)
		if candidate.distance_to(center) < radius + 20:
			continue
		var clearance := 200.0
		for meteor in _meteors:
			if is_instance_valid(meteor) and not meteor.resolved:
				clearance = minf(clearance, candidate.distance_to(meteor.destination) - meteor.radius)
		if clearance > best_clearance:
			best = candidate
			best_clearance = clearance
	return best


func cancel() -> void:
	active = false
	set_physics_process(false)
