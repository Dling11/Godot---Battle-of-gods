class_name DirectionalWedgeTargeting
extends Node2D

## Player-owned targeting preview. It chooses intent only; the ability component
## remains the sole owner of cooldowns and damage.

signal targeting_started(component: AbilityComponent)
signal targeting_cancelled
signal targeting_confirmed(component: AbilityComponent, direction: Vector2)

var _target_component: AbilityComponent
var _direction := Vector2.DOWN
var _reach := 130.0
var _half_angle_radians := deg_to_rad(50.0)
var _pulse_on := false
var _direction_flash := 0.0:
	set(value):
		_direction_flash = value
		queue_redraw()
var _pulse_timer: Timer
var _direction_tween: Tween


func _ready() -> void:
	visible = false
	_pulse_timer = Timer.new()
	_pulse_timer.wait_time = 0.14
	_pulse_timer.timeout.connect(_on_pulse_timeout)
	add_child(_pulse_timer)


func _exit_tree() -> void:
	_set_cursor_targeting(false)


func is_targeting() -> bool:
	return _target_component != null


func get_target_component() -> AbilityComponent:
	return _target_component


func get_target_direction() -> Vector2:
	return _direction


func begin_targeting(component: AbilityComponent, initial_direction: Vector2) -> bool:
	if component == null or not component.is_ready():
		return false
	var echo_definition := component.definition as EchoingSeverDefinition
	if echo_definition == null:
		return false
	_target_component = component
	_reach = echo_definition.targeting_reach_pixels
	_half_angle_radians = deg_to_rad(echo_definition.targeting_half_angle_degrees)
	_direction = _normalized_direction(initial_direction, Vector2.DOWN)
	rotation = 0.0
	_pulse_on = false
	_play_direction_flash()
	_pulse_timer.start()
	_set_cursor_targeting(true)
	visible = true
	queue_redraw()
	targeting_started.emit(component)
	return true


func update_aim(pointer_direction: Vector2, stick_direction: Vector2) -> void:
	if not is_targeting():
		return
	var aim_direction := stick_direction if stick_direction.length_squared() > 0.16 else pointer_direction
	if aim_direction.length_squared() <= 0.01:
		return
	var next_direction := aim_direction.normalized()
	if next_direction.dot(_direction) > 0.99995:
		return
	_direction = next_direction
	queue_redraw()


func confirm_targeting() -> bool:
	if not is_targeting():
		return false
	var component := _target_component
	var direction := _direction
	_clear_targeting()
	targeting_confirmed.emit(component, direction)
	return true


func cancel_targeting() -> bool:
	if not is_targeting():
		return false
	_clear_targeting()
	targeting_cancelled.emit()
	return true


func _clear_targeting() -> void:
	_target_component = null
	_pulse_timer.stop()
	if _direction_tween != null:
		_direction_tween.kill()
	_direction_tween = null
	_direction_flash = 0.0
	_set_cursor_targeting(false)
	visible = false
	queue_redraw()


func _normalized_direction(direction: Vector2, fallback: Vector2) -> Vector2:
	if direction.is_zero_approx():
		return fallback
	return direction.normalized()


func _draw() -> void:
	if not is_targeting():
		return
	var scale_factor := _reach / 130.0
	var angle_scale := tan(_half_angle_radians) / tan(deg_to_rad(50.0))
	var wedge := PackedVector2Array()
	for point in [
		Vector2(14, -9), Vector2(30, -39), Vector2(54, -54),
		Vector2(84, -62), Vector2(110, -56), Vector2(128, -40),
		Vector2(138, -20), Vector2(140, 0), Vector2(138, 20),
		Vector2(128, 40), Vector2(110, 56), Vector2(84, 62),
		Vector2(54, 54), Vector2(30, 39), Vector2(14, 9)
	]:
		wedge.append(_orient(Vector2(point.x * scale_factor, point.y * scale_factor * angle_scale)))
	var pulse_alpha := 0.15 if _pulse_on else 0.11
	draw_colored_polygon(wedge, Color(0.055, 0.17, 0.29, pulse_alpha + _direction_flash * 0.08))
	draw_polyline(wedge, Color(0.30, 0.66, 0.87, 0.68 + _direction_flash * 0.28), 1.0, false)

	var far_edge := PackedVector2Array()
	for point in [
		Vector2(84, -62), Vector2(110, -56), Vector2(128, -40),
		Vector2(138, -20), Vector2(140, 0), Vector2(138, 20),
		Vector2(128, 40), Vector2(110, 56), Vector2(84, 62)
	]:
		far_edge.append(_orient(Vector2(point.x * scale_factor, point.y * scale_factor * angle_scale)))
	draw_polyline(far_edge, Color(0.72, 0.93, 1.0, 0.88 + _direction_flash * 0.12), 2.0, false)

	var blade_path := PackedVector2Array()
	for point in [Vector2(20, -7), Vector2(42, -25), Vector2(72, -35), Vector2(102, -30), Vector2(126, -14)]:
		blade_path.append(_orient(Vector2(point.x * scale_factor, point.y * scale_factor * angle_scale)))
	draw_polyline(blade_path, Color(0.92, 0.98, 1.0, 0.72 + _direction_flash * 0.28), 2.0, false)

	var center_start := _orient(Vector2(18, 0) * scale_factor)
	var center_end := _orient(Vector2(127, 0) * scale_factor)
	draw_dashed_line(center_start, center_end, Color(0.39, 0.73, 0.94, 0.62), 1.0, 8.0, false)
	_draw_rune(Vector2(82, 0) * scale_factor, scale_factor)
	_draw_rune(Vector2(112, 0) * scale_factor, scale_factor * 0.8)
	draw_arc(Vector2.ZERO, 13.0, 0.0, TAU, 16, Color(0.38, 0.70, 0.90, 0.56), 1.0, false)
	var tip := _orient(Vector2(140, 0) * scale_factor)
	var tangent := Vector2(-_direction.y, _direction.x)
	draw_colored_polygon(PackedVector2Array([
		tip + _direction * 4.0,
		tip + tangent * 3.0,
		tip - _direction * 4.0,
		tip - tangent * 3.0
	]), Color(0.96, 1.0, 1.0, 0.94))


func _orient(point: Vector2) -> Vector2:
	var tangent := Vector2(-_direction.y, _direction.x)
	return _direction * point.x + tangent * point.y


func _draw_rune(local_position: Vector2, rune_scale: float) -> void:
	var center := _orient(local_position)
	var forward := _direction * 4.0 * rune_scale
	var tangent := Vector2(-_direction.y, _direction.x) * 4.0 * rune_scale
	draw_polyline(PackedVector2Array([
		center - forward,
		center + tangent,
		center + forward,
		center - tangent,
		center - forward
	]), Color(0.58, 0.81, 0.96, 0.64), 1.0, false)


func _play_direction_flash() -> void:
	if _direction_tween != null:
		_direction_tween.kill()
	_direction_flash = 1.0
	_direction_tween = create_tween()
	_direction_tween.tween_property(self, "_direction_flash", 0.0, 0.08)


func _on_pulse_timeout() -> void:
	_pulse_on = not _pulse_on
	queue_redraw()


func _set_cursor_targeting(active: bool) -> void:
	var cursor_service := get_node_or_null("/root/CursorService")
	if cursor_service != null:
		cursor_service.set_targeting_active(active)
