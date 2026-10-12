class_name KingSkill4Visual
extends Node2D

@export var ability_component: KingSkill4Component
@export var sword_sprite: AnimatedSprite2D
@export var ground_sprite: AnimatedSprite2D

## The point sits two pixels inside the crater so its hard ground-plane clip is
## hidden by the authored impact core instead of reading as a severed tip.
const SWORD_REST_POSITION := Vector2(0.0, -90.0)
const SWORD_START_POSITION := Vector2(0.0, -260.0)
const SWORD_TEXTURE_HEIGHT := 192.0
const SWORD_POINT_Y := 188.0
const SWORD_DRIVE_DEPTH := 20.0

var _sword_tween: Tween
var _residue_tween: Tween
var _shockwave_tween: Tween
var _preserve_crater := false
var _shockwave_radius := 0.0
var _shockwave_alpha := 0.0


func _ready() -> void:
	set_as_top_level(true)
	_clear_visual()


func play_phase(phase: int, duration_seconds: float) -> void:
	if not _is_skill_4() or phase != AbilityComponent.Phase.WIND_UP:
		return
	_begin_descent(duration_seconds)


func play_strike(strike_index: int, strike_count: int, duration_seconds: float) -> void:
	if not _is_skill_4() or ground_sprite == null or sword_sprite == null:
		return
	_snap_to_target()
	if strike_index < strike_count - 1:
		sword_sprite.position = SWORD_REST_POSITION
		_set_sword_sink_depth(0.0)
		sword_sprite.play(&"embedded")
		ground_sprite.visible = true
		ground_sprite.play(&"build_up")
		_play_ground_resistance(duration_seconds)
		_play_shockwave(18.0, 62.0, 0.28, 0.82)
		return
	ground_sprite.visible = true
	ground_sprite.play(&"explosion")
	_play_shockwave(34.0, 118.0, 0.42, 1.0)
	_dissolve_sword()
	_begin_crater_residue()


func hide_visual() -> void:
	if _preserve_crater:
		return
	_clear_visual()


func _begin_descent(duration_seconds: float) -> void:
	_reset_tweens()
	_preserve_crater = false
	_snap_to_target()
	z_index = 8
	visible = true
	ground_sprite.visible = false
	sword_sprite.visible = true
	sword_sprite.play(&"formation")
	_set_sword_sink_depth(0.0)
	sword_sprite.position = SWORD_START_POSITION
	sword_sprite.rotation = 0.0
	sword_sprite.scale = Vector2(0.82, 0.82)
	sword_sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var formation := minf(0.18, duration_seconds * 0.42)
	var descent := minf(0.18, duration_seconds * 0.42)
	var hold := maxf(duration_seconds - formation - descent, 0.0)
	_sword_tween = create_tween()
	_sword_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_sword_tween.set_parallel(true)
	_sword_tween.tween_property(sword_sprite, "modulate:a", 1.0, formation)
	_sword_tween.tween_property(sword_sprite, "scale", Vector2.ONE, formation).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sword_tween.set_parallel(false)
	_sword_tween.tween_interval(hold)
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION, descent).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)


func _play_ground_resistance(seconds_until_explosion: float) -> void:
	if _sword_tween != null and _sword_tween.is_valid():
		_sword_tween.kill()
	_sword_tween = create_tween()
	_sword_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	## The normalized sword frames share one point baseline. These short, uneven
	## beats make the ground visibly resist before the decisive accelerated burial.
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION + Vector2(0, -5), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_sword_tween.parallel().tween_property(sword_sprite, "rotation", -0.026, 0.05)
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION + Vector2(0, -1), 0.055).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_sword_tween.parallel().tween_property(sword_sprite, "rotation", 0.021, 0.055)
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION + Vector2(0, -3), 0.045)
	_sword_tween.parallel().tween_property(sword_sprite, "rotation", -0.017, 0.045)
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION, 0.045)
	_sword_tween.parallel().tween_property(sword_sprite, "rotation", 0.012, 0.045)
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION + Vector2(0, -2), 0.04)
	_sword_tween.parallel().tween_property(sword_sprite, "rotation", 0.0, 0.04)
	var resistance_seconds := 0.235
	var drive_seconds := 0.125
	_sword_tween.tween_interval(maxf(seconds_until_explosion - resistance_seconds - drive_seconds, 0.0))
	_sword_tween.tween_property(sword_sprite, "position", SWORD_REST_POSITION + Vector2(0, SWORD_DRIVE_DEPTH), drive_seconds).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_sword_tween.parallel().tween_method(_set_sword_sink_depth, 0.0, SWORD_DRIVE_DEPTH, drive_seconds).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)


func _dissolve_sword() -> void:
	if _sword_tween != null and _sword_tween.is_valid():
		_sword_tween.kill()
	sword_sprite.play(&"dissolve")
	_sword_tween = create_tween().set_parallel(true)
	_sword_tween.tween_property(sword_sprite, "modulate:a", 0.0, 0.22)
	_sword_tween.tween_property(sword_sprite, "scale", Vector2(1.08, 1.16), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_sword_tween.chain().tween_callback(func() -> void: sword_sprite.visible = false)


func _begin_crater_residue() -> void:
	_preserve_crater = true
	if _residue_tween != null and _residue_tween.is_valid():
		_residue_tween.kill()
	_residue_tween = create_tween()
	_residue_tween.tween_interval(0.22)
	_residue_tween.tween_callback(_show_crater)
	_residue_tween.tween_interval(1.2)
	_residue_tween.tween_property(ground_sprite, "modulate:a", 0.0, 0.8)
	_residue_tween.tween_callback(_finish_crater)


func _show_crater() -> void:
	if ground_sprite == null:
		return
	z_index = -1
	ground_sprite.modulate.a = 1.0
	ground_sprite.play(&"crater")


func _set_sword_sink_depth(depth_pixels: float) -> void:
	if sword_sprite == null or sword_sprite.material == null:
		return
	var cutoff := (SWORD_POINT_Y - clampf(depth_pixels, 0.0, SWORD_DRIVE_DEPTH)) / SWORD_TEXTURE_HEIGHT
	sword_sprite.material.set_shader_parameter("visible_cutoff_uv", cutoff)


func _snap_to_target() -> void:
	if ability_component == null:
		return
	global_position = ability_component.get_target_global_position()
	global_rotation = 0.0


func _play_shockwave(start_radius: float, end_radius: float, duration: float, alpha: float) -> void:
	if _shockwave_tween != null and _shockwave_tween.is_valid():
		_shockwave_tween.kill()
	_shockwave_radius = start_radius
	_shockwave_alpha = alpha
	queue_redraw()
	_shockwave_tween = create_tween().set_parallel(true)
	_shockwave_tween.tween_method(_set_shockwave_radius, start_radius, end_radius, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_shockwave_tween.tween_method(_set_shockwave_alpha, alpha, 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _set_shockwave_radius(value: float) -> void:
	_shockwave_radius = value
	queue_redraw()


func _set_shockwave_alpha(value: float) -> void:
	_shockwave_alpha = value
	queue_redraw()


func _draw() -> void:
	if _shockwave_alpha <= 0.0:
		return
	draw_circle(Vector2.ZERO, maxf(_shockwave_radius - 7.0, 1.0), Color(0.18, 0.42, 0.92, 0.09 * _shockwave_alpha))
	draw_arc(Vector2.ZERO, _shockwave_radius, 0.0, TAU, 64, Color(0.9, 0.97, 1.0, 0.94 * _shockwave_alpha), 2.0, false)
	draw_arc(Vector2.ZERO, maxf(_shockwave_radius - 7.0, 1.0), 0.0, TAU, 56, Color(0.28, 0.58, 1.0, 0.7 * _shockwave_alpha), 1.0, false)


func _reset_tweens() -> void:
	for tween in [_sword_tween, _residue_tween, _shockwave_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
	_sword_tween = null
	_residue_tween = null
	_shockwave_tween = null


func _clear_visual() -> void:
	_reset_tweens()
	_preserve_crater = false
	_shockwave_radius = 0.0
	_shockwave_alpha = 0.0
	queue_redraw()
	if sword_sprite != null:
		_set_sword_sink_depth(0.0)
		sword_sprite.stop()
		sword_sprite.animation = &"formation"
		sword_sprite.frame = 0
		sword_sprite.visible = false
		sword_sprite.modulate = Color.WHITE
		sword_sprite.scale = Vector2.ONE
		sword_sprite.rotation = 0.0
	if ground_sprite != null:
		ground_sprite.stop()
		ground_sprite.visible = false
		ground_sprite.modulate = Color.WHITE
	visible = false


func _finish_crater() -> void:
	_preserve_crater = false
	_clear_visual()


func _is_skill_4() -> bool:
	return ability_component != null and ability_component.definition != null and ability_component.definition.ability_id == &"king_skill_4"
