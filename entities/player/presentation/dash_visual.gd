extends Node

@export var body_visual: AnimatedSprite2D
@export_range(0.01, 1.0, 0.01, "suffix:s") var afterimage_interval: float = 0.04

var _is_dashing := false
var _time_until_afterimage: float


func _ready() -> void:
	set_physics_process(false)


func play_dash(_direction: Vector2) -> void:
	_is_dashing = true
	_time_until_afterimage = 0.0
	if body_visual != null:
		body_visual.modulate = Color(1.35, 1.15, 1.75, 1.0)
	set_physics_process(true)


func set_invulnerable(is_invulnerable: bool) -> void:
	if is_invulnerable:
		return
	_is_dashing = false
	set_physics_process(false)
	if body_visual != null:
		body_visual.modulate = Color.WHITE


func _physics_process(delta: float) -> void:
	if not _is_dashing or body_visual == null:
		return
	_time_until_afterimage -= delta
	if _time_until_afterimage <= 0.0:
		_spawn_afterimage()
		_time_until_afterimage = afterimage_interval


func _spawn_afterimage() -> void:
	var afterimage := Sprite2D.new()
	afterimage.texture = body_visual.sprite_frames.get_frame_texture(
		body_visual.animation,
		body_visual.frame
	)
	afterimage.centered = body_visual.centered
	afterimage.offset = body_visual.offset
	afterimage.scale = body_visual.scale
	afterimage.modulate = Color(0.45, 0.25, 0.75, 0.45)
	afterimage.global_position = body_visual.global_position
	afterimage.global_rotation = body_visual.global_rotation
	afterimage.z_index = -1
	owner.get_parent().add_child(afterimage)
	var tween := afterimage.create_tween()
	tween.tween_property(afterimage, "modulate:a", 0.0, 0.18)
	tween.tween_callback(afterimage.queue_free)
