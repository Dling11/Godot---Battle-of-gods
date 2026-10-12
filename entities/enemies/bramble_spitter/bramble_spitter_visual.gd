extends Node2D

@export var body: AnimatedSprite2D
@export var target_marker: Node2D
@export var target_ring: Line2D
@export var muzzle_flash: Polygon2D
@export var muzzle_sparks: CPUParticles2D

var _direction := "down"
var _state := BrambleSpitter.State.SPAWNING
var _telegraph_tween: Tween
var _frame_tween: Tween
var _flash_tween: Tween


func _ready() -> void:
	target_marker.top_level = true
	target_marker.hide()
	muzzle_flash.hide()


func set_facing(direction: Vector2) -> void:
	var next_direction := ("right" if direction.x > 0.0 else "left") if absf(direction.x) > absf(direction.y) else ("down" if direction.y > 0.0 else "up")
	if next_direction == _direction:
		return
	_direction = next_direction
	_restore_state_animation()


func play_state(state: BrambleSpitter.State, duration: float) -> void:
	_state = state
	_kill_frame_tween()
	body.position = Vector2(0.0, -22.0)
	body.scale = Vector2.ONE
	body.modulate = Color.WHITE
	match state:
		BrambleSpitter.State.SPAWNING:
			body.play("idle_down")
			body.modulate.a = 0.0
			body.scale = Vector2(0.35, 0.15)
			var tween := create_tween().set_parallel(true)
			tween.tween_property(body, "modulate:a", 1.0, duration)
			tween.tween_property(body, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK)
		BrambleSpitter.State.POSITIONING:
			_hide_telegraph()
			body.play("walk_" + _direction)
		BrambleSpitter.State.WIND_UP:
			body.position = Vector2(0.0, -26.0)
			_play_attack_span(0, 5, duration)
		BrambleSpitter.State.RECOVERY:
			_hide_telegraph()
			body.position = Vector2(0.0, -26.0)
			_play_attack_span(5, 3, duration)
		BrambleSpitter.State.STAGGER:
			_hide_telegraph()
			body.play("hurt_" + _direction)
		BrambleSpitter.State.DEAD:
			_hide_telegraph()
			body.play("dead_" + _direction)
			create_tween().tween_property(body, "modulate:a", 0.0, duration)


func show_shot_telegraph(global_target: Vector2, duration: float) -> void:
	if _telegraph_tween != null and _telegraph_tween.is_valid():
		_telegraph_tween.kill()
	target_marker.global_position = global_target
	target_marker.scale = Vector2(0.65, 0.65)
	target_marker.modulate.a = 0.35
	target_ring.width = 1.0
	target_marker.show()
	_telegraph_tween = create_tween().set_parallel(true)
	_telegraph_tween.tween_property(target_marker, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_telegraph_tween.tween_property(target_marker, "modulate:a", 1.0, duration)
	_telegraph_tween.tween_property(target_ring, "width", 3.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func play_firing_feedback(direction: Vector2) -> void:
	_hide_telegraph()
	var muzzle_position := Vector2(0.0, -13.0) + direction * 12.0
	muzzle_flash.position = muzzle_position
	muzzle_flash.rotation = direction.angle()
	muzzle_flash.scale = Vector2(0.35, 0.35)
	muzzle_flash.modulate.a = 1.0
	muzzle_flash.show()
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween().set_parallel(true)
	_flash_tween.tween_property(muzzle_flash, "scale", Vector2(1.5, 1.5), 0.12)
	_flash_tween.tween_property(muzzle_flash, "modulate:a", 0.0, 0.12)
	_flash_tween.chain().tween_callback(muzzle_flash.hide)
	muzzle_sparks.position = muzzle_position
	muzzle_sparks.rotation = direction.angle()
	muzzle_sparks.restart()


func _hide_telegraph() -> void:
	target_marker.hide()


func _play_attack_span(first_frame: int, frame_count: int, duration: float) -> void:
	body.animation = "attack_" + _direction
	body.pause()
	body.frame = first_frame
	if frame_count <= 1:
		return
	_frame_tween = create_tween()
	var frame_seconds := duration / float(frame_count)
	for offset in range(1, frame_count):
		_frame_tween.tween_interval(frame_seconds)
		_frame_tween.tween_callback(body.set_frame.bind(first_frame + offset))


func _restore_state_animation() -> void:
	body.position = Vector2(0.0, -22.0)
	match _state:
		BrambleSpitter.State.POSITIONING:
			body.play("walk_" + _direction)
		BrambleSpitter.State.WIND_UP, BrambleSpitter.State.RECOVERY:
			body.position = Vector2(0.0, -26.0)
			body.play("attack_" + _direction)
		BrambleSpitter.State.STAGGER:
			body.play("hurt_" + _direction)
		BrambleSpitter.State.DEAD:
			body.play("dead_" + _direction)
		_:
			body.play("idle_" + _direction)


func _kill_frame_tween() -> void:
	if _frame_tween != null and _frame_tween.is_valid():
		_frame_tween.kill()
