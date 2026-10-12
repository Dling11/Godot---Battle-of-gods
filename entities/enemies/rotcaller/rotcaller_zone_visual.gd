extends Node2D

## Pixel-aligned ground warning. Contact remains in the sibling hitbox.
var progress := 0.0
var active := false
var _animation: Tween

func _ready() -> void:
	get_parent().warning_started.connect(_warn)
	get_parent().erupted.connect(_erupt)

func _warn(seconds: float) -> void:
	if DisplayServer.get_name() != "headless": $WarningSfx.play()
	_animation = create_tween()
	_animation.tween_method(_set_progress,0.0,1.0,seconds)

func _erupt(seconds: float) -> void:
	if DisplayServer.get_name() != "headless": $ReleaseSfx.play()
	if _animation != null: _animation.kill()
	active = true
	_animation = create_tween()
	_animation.tween_method(_set_progress,1.0,0.0,seconds)

func _set_progress(value: float) -> void:
	progress = value
	queue_redraw()

func _draw() -> void:
	var radius: float = get_parent().radius
	draw_circle(Vector2.ZERO,radius,Color(.22,.06,.16,.25))
	draw_arc(Vector2.ZERO,radius,0,TAU,32,Color(.12,.04,.12,.95),4,false)
	draw_arc(Vector2.ZERO,radius,0,TAU,32,Color(.85,.57,.75,.9),2,false)
	draw_arc(Vector2.ZERO,radius-4,-PI*.5,-PI*.5+TAU*maxf(progress,.01),32,Color(1,.81,.52),2,false)
	for i in 6:
		var direction := Vector2.RIGHT.rotated(TAU*i/6)
		var tip := direction*(radius-6)
		draw_line(direction*4,tip,Color(.6,.34,.45,.8),2,false)
		if active:
			var root := tip+Vector2(0,-16*progress)
			draw_line(tip,root,Color(.15,.08,.11),6,false)
			draw_line(tip,root,Color(.72,.55,.4),3,false)
