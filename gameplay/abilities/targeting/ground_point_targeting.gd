class_name GroundPointTargeting
extends Node2D

signal targeting_started(component: AbilityComponent)
signal targeting_cancelled
signal targeting_confirmed(component: AbilityComponent, target_global_position: Vector2)

var _component: AbilityComponent
var _target_local := Vector2.DOWN * 80.0
var _range := 220.0
var _radius := 52.0
var _lane_preview: Dictionary = {}
var _last_pointer := Vector2.INF
var _last_origin := Vector2.INF
var _last_stick := Vector2.INF


func _ready() -> void:
	visible = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(false)


func _process(_delta: float) -> void:
	var actor := _component.owner as Player if _component != null else null
	if actor != null:
		update_aim(get_global_mouse_position(), actor.input_source.get_aim_direction())


func _exit_tree() -> void:
	_set_cursor_targeting(false)


func is_targeting() -> bool:
	return _component != null


func get_target_component() -> AbilityComponent:
	return _component


func begin_targeting(component: AbilityComponent, initial_direction: Vector2) -> bool:
	if component == null or not component.supports_ground_targeting() or not component.is_ready():
		return false
	_component = component
	_range = component.get_target_range_pixels()
	_radius = component.get_target_radius_pixels()
	_target_local = (initial_direction.normalized() if not initial_direction.is_zero_approx() else Vector2.DOWN) * minf(96.0, _range)
	if component.is_fixed_length_line_targeted():
		_target_local = _target_local.normalized() * _range
	_target_local = component.resolve_ground_target(_aim_origin()+_target_local) - _aim_origin()
	_update_lane_preview()
	visible = true
	_last_pointer = Vector2.INF
	set_process(true)
	_set_cursor_targeting(true)
	queue_redraw()
	targeting_started.emit(component)
	return true


func update_aim(pointer_global_position: Vector2, stick_direction: Vector2) -> void:
	if not is_targeting():
		return
	var origin := _aim_origin()
	if pointer_global_position == _last_pointer and origin == _last_origin and stick_direction == _last_stick:
		return
	_last_pointer = pointer_global_position
	_last_origin = origin
	_last_stick = stick_direction
	var next_local := pointer_global_position - _aim_origin()
	if stick_direction.length_squared() > 0.16:
		next_local = stick_direction.normalized() * _range
	if next_local.length() > _range:
		next_local = next_local.normalized() * _range
	if _component.is_fixed_length_line_targeted():
		# Keep the last useful direction when the cursor crosses King's center.
		next_local = next_local.normalized() * _range if next_local.length_squared() >= .01 else _target_local
	_target_local = _component.resolve_ground_target(_aim_origin()+next_local) - _aim_origin()
	_update_lane_preview()
	queue_redraw()


func confirm_targeting() -> bool:
	if not is_targeting():
		return false
	var component := _component
	var target := _aim_origin() + _target_local
	_clear()
	targeting_confirmed.emit(component, target)
	return true


func cancel_targeting() -> bool:
	if not is_targeting():
		return false
	_clear()
	targeting_cancelled.emit()
	return true


func _clear() -> void:
	_component = null
	_lane_preview.clear()
	visible = false
	set_process(false)
	_set_cursor_targeting(false)
	queue_redraw()


func _draw() -> void:
	if not is_targeting():
		return
	if _component.is_fixed_length_line_targeted():
		_draw_lane()
		return
	var origin := to_local(_aim_origin())
	var center := to_local(_aim_origin() + _target_local + _component.get_target_center_offset())
	draw_dashed_line(origin, center, Color("afb7c8", .12), 1.0, 6.0, false)
	# Short, quiet range arcs keep the large cast range from framing the screen.
	var near_limit := _target_local.length() >= _range*.9
	for index in 4:
		var angle := index*PI*.5
		draw_arc(origin, _range, angle-.14, angle+.14, 12, Color("aea7c4", .15 if near_limit else .07), 1.0, false)
	draw_circle(center, _radius, Color("655386", .06))
	# One clear boundary follows the hit radius without a decorative outer frame.
	draw_arc(center, _radius, 0.0, TAU, 96, Color("bac2d2", .62), 2.0, false)
	for index in 4:
		var direction := Vector2.from_angle(index*PI*.5)
		draw_line(center+direction*(_radius-2.0), center+direction*(_radius+2.0), Color("c3c9da", .62), 2.0)
	var core := _component.get_target_core_radius_pixels()
	# Foundation Worldsplitter's core equals the outer radius. Drawing it again
	# previously compounded opacity and made the same boundary too bright.
	if core>0.0 and core<_radius-1.0:
		for index in 8:
			var angle := index*TAU/8.0
			draw_arc(center,core,angle+.08,angle+TAU/8.0-.08,8,Color("afa4c7",.16),1.0,false)
	_draw_target_mark(center)


func _draw_target_mark(center: Vector2) -> void:
	for direction in [Vector2.UP,Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT]:
		draw_line(center+direction*2.0, center+direction*5.0, Color("c3c9da",.60),1.0)


func _update_lane_preview() -> void:
	_lane_preview = _component.get_target_lane_preview(_aim_origin() + _target_local) if _component != null and _component.is_fixed_length_line_targeted() else {}


func _aim_origin() -> Vector2:
	# Every preview measures from the same physical feet as its committed cast.
	if _component != null and _component.owner is Node2D:
		return (_component.owner as Node2D).global_position
	return global_position


func _draw_lane() -> void:
	if _lane_preview.is_empty():
		return
	var waves: Array = _lane_preview.get("waves",[])
	for index in maxi(0,waves.size()-1):
		_draw_lane_shape(waves[index],false)
	_draw_lane_shape(_lane_preview,true)


func _draw_lane_shape(path: Dictionary, primary: bool) -> void:
	var lane_radius: float = path.radius
	var start: Vector2 = to_local(path.contact)
	var end: Vector2 = to_local(path.end)
	var forward: Vector2 = path.direction
	var side := forward.orthogonal()
	var color := Color("c3c9da")
	var points := PackedVector2Array()
	# Capsule caps match the swept front radius used by combat authority.
	for index in 13:
		points.append(end + forward.rotated(-PI*.5 + PI*index/12.0) * lane_radius)
	for index in 13:
		points.append(start + forward.rotated(PI*.5 + PI*index/12.0) * lane_radius)
	draw_colored_polygon(points, Color(color, .035 if primary else .008))
	points.append(points[0])
	draw_polyline(points, Color(color,.40 if primary else .16), 1.0)
	if not primary:
		draw_line(end-side*lane_radius,end+side*lane_radius,Color(color,.18),1.0)
	if primary:
		draw_line(start,end,Color(color,.14),1.0)
	if primary and start.distance_to(end) > 12.0:
		var tip := start.lerp(end,.6)
		draw_polyline(PackedVector2Array([tip-forward*3.0+side*2.0,tip,tip-forward*3.0-side*2.0]),Color(color,.38),1.0)
		_draw_target_mark(end)
	if path.blocked:
		draw_line(end-side*lane_radius,end+side*lane_radius,Color("bea9de"),2.0)


func _set_cursor_targeting(active: bool) -> void:
	var cursor_service := get_node_or_null("/root/CursorService")
	if cursor_service != null:
		cursor_service.set_targeting_active(active)
