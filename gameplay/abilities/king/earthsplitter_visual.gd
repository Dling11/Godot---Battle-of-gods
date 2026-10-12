extends Node2D

## Authored sprites observe the committed cast and its advancing damage front.
const Sword = preload("res://assets/vfx/abilities/king/earthsplitter/sword.png")
const GroundVisual = preload("res://gameplay/abilities/king/earthsplitter_ground_visual.gd")
const Swing = preload("res://assets/audio/sfx/player/greatsword/cleave.wav")
const Impact = preload("res://assets/audio/sfx/abilities/king/riftbreak_ground_slam.wav")
var source: Player
var component: AbilityComponent
var contact := Vector2.ZERO
var direction := Vector2.RIGHT
var _sword: Sprite2D
var _released := false
var _age := 0.0
var _after := 0.0
var _ground: Node2D
var _played_swing := false
var _feedback: CombatFeedbackPresenter
var wave_count := 1
var is_fan := false
var _grounds: Array[Node2D] = []
var _wave_fronts: Array[Vector2] = []
var _wave_contacts: Array[Vector2] = []
var _finished_after := -1.0

func _ready() -> void:
	_feedback = CombatFeedbackPresenter.find_for_player(source)
	add_to_group("earthsplitter_effects")
	global_position = contact
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 3
	_sword = Sprite2D.new()
	_sword.texture = Sword
	_sword.region_enabled = true
	_sword.region_filter_clip_enabled = true
	_set_sword_frame(0)
	_sword.scale = Vector2.ONE * .42
	# Keep screen-up gravity in the overhead swing. Rotating the complete
	# side-view drawing by 180 degrees turns a left cast into an uppercut.
	var vertical := absf(direction.y) > absf(direction.x)
	_sword.rotation = PI * .25 if vertical else 0.0
	_sword.flip_h = direction.x < 0.0 and not vertical
	add_child(_sword)

func release() -> void:
	_released = true
	_after = 0.0
	_set_sword_frame(7)
	_sound(Impact, -13.5, .94)
	if is_instance_valid(_feedback):
		_feedback.request_camera_pulse(2.2)

func start_wave(index: int, plan: Dictionary) -> void:
	_ground = GroundVisual.new()
	_ground.direction = plan.path.direction
	_ground.radius = plan.tuning.lane_radius
	_ground.strength_scale = plan.strength
	_ground.aftermath_speed = plan.aftermath_speed
	if plan.get("accent",false):
		_ground.terminal_scale = 1.45
	elif wave_count > 1 and not is_fan:
		_ground.terminal_scale = 1.38 if index==wave_count-1 else .95
	_ground.z_index = -1
	add_child(_ground)
	_ground.global_position = plan.path.contact
	_grounds.append(_ground)
	_wave_contacts.append(plan.path.contact)
	_wave_fronts.append(plan.path.contact)
	if index > 0 and (not is_fan or plan.get("accent",false)):
		var final := index == wave_count-1
		_sound(Impact,-14.5 if final else -23.0,.84 if final else 1.14,to_local(plan.path.contact))
		if final and is_instance_valid(_feedback):
			_feedback.request_camera_pulse(2.8)

func advance_wave(index: int, point: Vector2) -> void:
	_wave_fronts[index] = point
	if is_instance_valid(_grounds[index]):
		_grounds[index].advance_front(point)

func finish_wave(index: int) -> void:
	if not is_instance_valid(source) or source.is_defeated:
		return
	if is_instance_valid(_grounds[index]):
		_grounds[index].finish()
	if index == wave_count-1 and _wave_contacts[index].distance_to(_wave_fronts[index])>16.0:
		_sound(Impact,-18.0 if wave_count>1 else -20.0,1.08 if wave_count>1 else 1.23,to_local(_wave_fronts[index]))
		if is_instance_valid(_feedback):
			_feedback.request_camera_pulse(1.8 if wave_count>1 else 1.4)

func finish_sequence() -> void:
	_finished_after = _after

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated:
		queue_free()
		return
	_age += delta
	if not _released:
		var progress := clampf(_age / component.definition.wind_up_seconds, 0.0, 1.0)
		_set_sword_frame(mini(6, int(progress * 7.0)))
		if progress > .45 and not _played_swing:
			_played_swing = true
			_sound(Swing, -14.0, 1.16)
	else:
		_after += delta
		_set_sword_frame(mini(15, 7 + int(_after / .032)))
		_sword.visible = _after < .29
	if _released and ((_finished_after >= 0.0 and _after-_finished_after >= .8) or _after >= 2.0):
		queue_free()

func _set_sword_frame(index: int) -> void:
	# Pixel-snapped rotated quads can sample the next atlas row at their edge.
	# An explicit clipped cell preserves the drawing and its 512px registration.
	_sword.region_rect = Rect2(Vector2(index % 4, index / 4) * 512.0, Vector2(512, 512))


func _sound(stream: AudioStream, volume: float, pitch: float, local_point := Vector2.ZERO) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var sound := AudioStreamPlayer2D.new()
	sound.position = local_point
	sound.stream = stream
	sound.volume_db = volume
	sound.pitch_scale = pitch
	sound.bus = &"SFX"
	add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()
