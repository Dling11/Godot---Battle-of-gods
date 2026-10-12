extends Node2D

## Bounded occasional flights, driven by Tween/Timer; no collision or gameplay authority.
const SHEET = preload("res://assets/environment/sanctuary/courtyards/swallow.png")
@export var flight_bounds := Rect2(48,260,1052,290)
var birds: Array[AnimatedSprite2D] = []
var _timer: Timer
var _flight: Tween
var _enabled := false
var _pass := 0

func _ready() -> void:
	z_index = 12
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"fly")
	frames.set_animation_speed(&"fly",7)
	for index in 4:
		var frame := AtlasTexture.new()
		frame.atlas = SHEET
		frame.region = Rect2(index*40,0,40,40)
		frame.filter_clip = true
		frames.add_frame(&"fly",frame)
	for index in 2:
		var bird := AnimatedSprite2D.new()
		bird.sprite_frames = frames
		bird.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bird.scale = Vector2(.5,.5)
		add_child(bird)
		birds.append(bird)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_begin_flight)
	add_child(_timer)

func set_enabled(value: bool) -> void:
	_enabled = value
	_timer.stop()
	if _flight != null: _flight.kill()
	for bird in birds:
		bird.hide()
		bird.stop()
	if value: _timer.start(2)

func _begin_flight() -> void:
	if not _enabled: return
	var east := _pass%2 == 0
	var start := flight_bounds.position if east else flight_bounds.end
	var finish := Vector2(flight_bounds.end.x,flight_bounds.position.y+80) if east else Vector2(flight_bounds.position.x,flight_bounds.end.y-150)
	_flight = create_tween().set_parallel(true)
	for index in birds.size():
		var bird := birds[index]
		var offset := Vector2(-24,16)*index
		bird.position = start+offset
		bird.flip_h = not east
		bird.show()
		bird.play(&"fly")
		bird.frame = index*2
		_flight.tween_property(bird,"position",finish+offset,12.0)
	_flight.chain().tween_callback(func() -> void:
		for bird in birds:
			bird.hide()
			bird.stop()
		_pass += 1
		if _enabled: _timer.start(10.0))
