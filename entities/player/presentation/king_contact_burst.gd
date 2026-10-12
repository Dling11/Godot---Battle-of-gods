extends Node2D

## Finite generated raster contact, clipped to the real area of effect.
var _texture: Texture2D
var _points := PackedVector2Array()
var _uvs := PackedVector2Array()
var _frame := 0
var _color := Color.WHITE

func show_radial(texture: Texture2D, radius: float, duration: float, empowered: bool) -> void:
	_texture = texture
	for index in 48:
		var point := Vector2.from_angle(index*TAU/48.0)*radius
		_points.append(point)
		_uvs.append(point/(radius*2)+Vector2(.5,.5))
	_color = Color(1.15,1.15,1.2,1) if empowered else Color.WHITE
	_animate(duration,0,7)

func show_cleave(texture: Texture2D, shape: Shape2D, duration: float, echo: bool) -> void:
	_texture = texture
	if shape is ConvexPolygonShape2D:
		_points = shape.points
	else:
		queue_free()
		return
	var bounds := Rect2(_points[0],Vector2.ZERO)
	for p in _points:
		bounds = bounds.expand(p)
	for p in _points:
		_uvs.append((p-bounds.position)/bounds.size)
	_color = Color(.65,.84,1,.9) if echo else Color.WHITE
	_animate(duration,0,3)

func _animate(duration: float, first: int, last: int) -> void:
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_method(func(value: float) -> void: _frame=roundi(value); queue_redraw(),float(first),float(last),maxf(duration,.06))
	tween.tween_callback(queue_free)

func _draw() -> void:
	if _texture == null or _points.is_empty():
		return
	var uvs := PackedVector2Array()
	for uv in _uvs:
		uvs.append((uv+Vector2(_frame%4,_frame/4))/Vector2(4,2))
	draw_polygon(_points,PackedColorArray([_color]),uvs,_texture)
