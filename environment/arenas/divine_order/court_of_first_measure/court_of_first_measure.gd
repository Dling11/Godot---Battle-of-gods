class_name CourtOfFirstMeasure
extends Node2D

const DescentCircle = preload("res://assets/environment/arenas/divine_order/court_of_first_measure/examiner_divine_descent_circle_512.png")
const Floor = preload("res://assets/environment/arenas/divine_order/court_of_first_measure/court_slate_floor.png")
const FLOOR_BOUNDS := Rect2(40, 92, 650, 390)
const CENTER := Vector2(365.0, 287.0)
const PYLON_POINTS := [Vector2(126, 118), Vector2(604, 118), Vector2(126, 456), Vector2(604, 456)]
const PROTECTION_RADIUS := 54.0

var active_wards: Array[Vector2] = []

var _measure_energy := 0.0
var _descent_energy := 0.0
var _descent_progress := 0.0
var _impact_energy := 0.0
var _pulse_tween: Tween
var _descent_tween: Tween
var _seal: Sprite2D
var _seal_counter: Sprite2D
var _danger_material: ShaderMaterial


func _ready() -> void:
	# Positive child layers render above this node's procedural floor while the
	# arena itself remains below actors and combat effects.
	_seal = _make_seal(0.62, 1)
	_seal_counter = _make_seal(0.43, 2)
	var danger := ColorRect.new()
	danger.position = FLOOR_BOUNDS.position
	danger.size = FLOOR_BOUNDS.size
	danger.mouse_filter = Control.MOUSE_FILTER_IGNORE
	danger.z_index = 3
	_danger_material = ShaderMaterial.new()
	_danger_material.shader = preload("res://assets/vfx/divine_order/examiner/court_danger.gdshader")
	var local_wards := PackedVector2Array()
	for point: Vector2 in PYLON_POINTS:
		local_wards.append(point - FLOOR_BOUNDS.position)
	_danger_material.set_shader_parameter("ward_points", local_wards)
	_danger_material.set_shader_parameter("ward_radius", PROTECTION_RADIUS)
	danger.material = _danger_material
	add_child(danger)
	queue_redraw()


func _make_seal(scale_value: float, layer: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = DescentCircle
	sprite.position = CENTER
	sprite.scale = Vector2.ONE * scale_value
	sprite.z_index = layer
	sprite.modulate = Color(1.0, 0.9, 0.56, 0.0)
	add_child(sprite)
	return sprite


func pulse_measure(duration_seconds := 2.2) -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_measure_energy = 0.0
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(self, "_measure_energy", 1.0, 0.28)
	_pulse_tween.tween_interval(maxf(duration_seconds - 0.7, 0.1))
	_pulse_tween.tween_property(self, "_measure_energy", 0.0, 0.42)


func begin_divine_descent_charge(duration_seconds: float) -> void:
	if _descent_tween != null and _descent_tween.is_valid():
		_descent_tween.kill()
	_descent_energy = 1.0
	_descent_progress = 0.0
	_impact_energy = 0.0
	_descent_tween = create_tween()
	_descent_tween.tween_property(self, "_descent_progress", 1.0, maxf(duration_seconds, 0.1))


func resolve_divine_descent(player: Node2D, raw_damage := 800.0, source: Node = null) -> bool:
	var protected := is_position_protected(player.global_position)
	_impact_energy = 1.0
	_descent_energy = 0.0
	_descent_progress = 1.0
	create_tween().tween_property(self, "_impact_energy", 0.0, 0.72)
	if protected:
		return true
	var health := player.find_child("HealthComponent", true, false) as HealthComponent
	if health != null:
		var direction := (player.global_position - CENTER).normalized()
		if direction.is_zero_approx():
			direction = Vector2.DOWN
		var verdict := DamageInfo.new(raw_damage, source, direction, 260.0, 0.32)
		verdict.ignores_invulnerability = true
		health.apply_damage(verdict)
	return false


func is_position_protected(world_position: Vector2) -> bool:
	for point: Vector2 in active_wards:
		if world_position.distance_to(point) <= PROTECTION_RADIUS:
			return true
	return false


func protection_points() -> Array[Vector2]:
	var result: Array[Vector2] = []
	result.assign(PYLON_POINTS)
	return result


func _process(delta: float) -> void:
	if _danger_material != null:
		_danger_material.set_shader_parameter("progress", _descent_progress)
		_danger_material.set_shader_parameter("strength", _descent_energy)
	if _seal != null:
		_seal.rotation += delta * (0.18 + _descent_progress * 0.34)
		_seal_counter.rotation -= delta * (0.31 + _descent_progress * 0.45)
		var pulse := 0.82 + 0.18 * sin(Time.get_ticks_msec() * 0.008)
		_seal.modulate.a = _descent_energy * (0.18 + _descent_progress * 0.30) * pulse
		_seal_counter.modulate.a = _descent_energy * (0.06 + _descent_progress * 0.12)
	queue_redraw()


func _draw() -> void:
	draw_texture_rect(Floor, FLOOR_BOUNDS, false)
	# This outer boundary is also the lab's physical movement/navigation edge.
	draw_rect(FLOOR_BOUNDS, Color("82744e"), false, 2.0)
	var dormant := Color(0.55, 0.62, 0.55, 0.0)
	var active := Color(1.0, 0.82, 0.34, 0.10 + _measure_energy * 0.16)
	for radius in [68.0, 112.0, 151.0, 184.0]:
		draw_arc(CENTER, radius, 0.0, TAU, 96, dormant.lerp(active, _measure_energy), 2.0)
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		draw_line(CENTER + Vector2.RIGHT.rotated(angle) * 78.0, CENTER + Vector2.RIGHT.rotated(angle) * 181.0, dormant.lerp(active, _measure_energy), 1.0)
	for point: Vector2 in PYLON_POINTS:
		_draw_pylon(point)
		if point in active_wards:
			_draw_protection_zone(point)
	if _descent_energy > 0.0:
		_draw_descent_charge_motes()


func _draw_protection_zone(point: Vector2) -> void:
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.009 + point.x)
	var alpha := (0.30 + _descent_progress * 0.42) * (0.82 + pulse * 0.18)
	draw_circle(point, PROTECTION_RADIUS, Color(0.35, 0.92, 1.0, alpha * 0.15), true)
	draw_arc(point, PROTECTION_RADIUS, 0.0, TAU, 48, Color(0.66, 0.96, 1.0, alpha), 3.0)
	for index in 4:
		var angle := float(index) * TAU / 4.0 - Time.get_ticks_msec() * 0.0008
		draw_circle(point + Vector2.from_angle(angle) * PROTECTION_RADIUS, 3.0, Color(0.84, 1.0, 1.0, alpha), true)


func _draw_descent_charge_motes() -> void:
	var time := Time.get_ticks_msec() * 0.001
	for index in 28:
		var angle := float(index) * 2.399 + time * (0.10 + float(index % 3) * 0.03)
		var radius := 42.0 + float((index * 31) % 145)
		var rise := fmod(time * (16.0 + float(index % 5) * 4.0) + float(index * 19), 72.0)
		var point := CENTER + Vector2(cos(angle) * radius, sin(angle) * radius * 0.55 - rise * 0.22)
		var alpha := (0.18 + _descent_progress * 0.58) * (1.0 - rise / 94.0)
		draw_rect(Rect2(point - Vector2.ONE, Vector2(2, 2)), Color(1.0, 0.91, 0.55, alpha), true)


func _draw_pylon(point: Vector2) -> void:
	# Recessed ward plates are deliberately traversable; no painted solid
	# pillar falsely suggests a collision obstacle inside a protection zone.
	draw_circle(point, 17.0, Color("172b34"))
	draw_arc(point, 17.0, 0, TAU, 32, Color("8e815d"), 2.0)
	draw_arc(point, 12.0, 0, TAU, 24, Color("4e8490"), 1.0)
	var light := Color(0.48, 0.94, 1.0, 0.72 + _descent_energy * 0.28) if point in active_wards else Color("746957")
	draw_colored_polygon(PackedVector2Array([point + Vector2(0,-8),point + Vector2(5,0),point + Vector2(0,8),point + Vector2(-5,0)]), light)


func set_sanctuary(enabled: bool, point := Vector2.ZERO) -> void:
	active_wards.clear()
	if enabled and point in PYLON_POINTS:
		active_wards.append(point)
	var flags := PackedFloat32Array()
	for candidate: Vector2 in PYLON_POINTS:
		flags.append(1.0 if candidate in active_wards else 0.0)
	if _danger_material != null:
		_danger_material.set_shader_parameter("ward_enabled", flags)
	queue_redraw()


func reset_trial() -> void:
	if _descent_tween != null and _descent_tween.is_valid():
		_descent_tween.kill()
	_descent_energy = 0.0
	_descent_progress = 0.0
	_impact_energy = 0.0
	set_sanctuary(false)
