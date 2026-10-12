class_name PlayerLevelUpVisual
extends Node2D

## Small world-space level-up glow and overhead label. Progression remains
## authoritative; this node only observes the event.

@export var progression_component: PlayerProgressionComponent

@onready var level_label: Label = %LevelLabel
@onready var chime_player: AudioStreamPlayer = %ChimePlayer

var _alpha := 0.0
var _radius := 7.0
var _ray_length := 3.0
var _effect_tween: Tween


func _ready() -> void:
	level_label.hide()
	if progression_component == null:
		push_error("PlayerLevelUpVisual requires a progression component.")
		return
	progression_component.leveled_up.connect(_play)


func _play(new_level: int) -> void:
	if _effect_tween != null and _effect_tween.is_valid():
		_effect_tween.kill()
	level_label.text = "LEVEL %d" % new_level
	level_label.position.y = -22.0
	level_label.scale = Vector2(0.9, 0.9)
	level_label.modulate.a = 0.0
	level_label.show()
	if chime_player.stream != null and DisplayServer.get_name() != "headless":
		chime_player.play()
	_alpha = 0.9
	_radius = 7.0
	_ray_length = 3.0
	queue_redraw()
	_effect_tween = create_tween().set_parallel(true)
	_effect_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_effect_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_effect_tween.tween_method(_set_alpha, 0.9, 0.0, 0.78)
	_effect_tween.tween_method(_set_radius, 7.0, 17.0, 0.62)
	_effect_tween.tween_method(_set_ray_length, 3.0, 7.0, 0.5)
	_effect_tween.tween_property(level_label, "modulate:a", 1.0, 0.1)
	_effect_tween.tween_property(level_label, "position:y", -29.0, 0.72)
	_effect_tween.tween_property(level_label, "scale", Vector2.ONE, 0.16)
	_effect_tween.chain().tween_property(level_label, "modulate:a", 0.0, 0.18)
	_effect_tween.chain().tween_callback(level_label.hide)


func _draw() -> void:
	if _alpha <= 0.001:
		return
	var gold := Color(1.0, 0.78, 0.28, 0.72 * _alpha)
	var spirit := Color(0.62, 0.88, 1.0, 0.52 * _alpha)
	draw_circle(Vector2(0.0, 7.0), _radius * 0.72, Color(1.0, 0.77, 0.3, 0.08 * _alpha))
	draw_arc(Vector2(0.0, 7.0), _radius, 0.0, TAU, 24, gold, 1.25)
	draw_arc(Vector2(0.0, 7.0), maxf(_radius - 4.0, 1.0), 0.0, TAU, 20, spirit, 1.0)
	for ray_index in 4:
		var direction := Vector2.UP.rotated(float(ray_index) * TAU / 4.0)
		draw_line(
			Vector2(0.0, 7.0) + direction * (_radius + 1.0),
			Vector2(0.0, 7.0) + direction * (_radius + _ray_length),
			gold,
			1.0
		)


func _set_alpha(value: float) -> void:
	_alpha = value
	queue_redraw()


func _set_radius(value: float) -> void:
	_radius = value
	queue_redraw()


func _set_ray_length(value: float) -> void:
	_ray_length = value
	queue_redraw()


func _exit_tree() -> void:
	if _effect_tween != null and _effect_tween.is_valid():
		_effect_tween.kill()
	if chime_player != null:
		chime_player.stop()
