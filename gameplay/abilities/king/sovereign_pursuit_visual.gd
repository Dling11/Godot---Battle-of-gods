class_name SovereignPursuitVisual
extends Node2D

@export var ability_component: SovereignPursuitComponent
@export var effect_sprite: AnimatedSprite2D

var _fade_tween: Tween
var _preserve_residue := false
var _impact_released := false
var _feedback: CombatFeedbackPresenter


func _ready() -> void:
	set_as_top_level(true)
	_clear_visual()
	if effect_sprite != null and not effect_sprite.animation_finished.is_connected(_on_animation_finished):
		effect_sprite.animation_finished.connect(_on_animation_finished)
	if ability_component != null and ability_component.owner is Player:
		var actor := ability_component.owner as Player
		if not actor.defeated.is_connected(_clear_visual):
			actor.defeated.connect(_clear_visual)


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not is_instance_valid(_feedback) and ability_component != null:
		_feedback = CombatFeedbackPresenter.find_for_player(ability_component.owner as Player)
	if not _is_pursuit() or effect_sprite == null:
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		_reset_fade()
		_impact_released = false
		_follow_landing_origin()
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"launch")


func play_strike(_strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		return
	_follow_landing_origin()
	global_position = ability_component.hitbox.global_position
	_reset_fade()
	visible = true
	effect_sprite.visible = true
	effect_sprite.play(&"impact")
	_impact_released = true
	if is_instance_valid(_feedback):
		_feedback.request_camera_pulse(1.7)


func hide_visual() -> void:
	# Let the blade-cut landing finish after player control returns.
	if _preserve_residue or (_impact_released and effect_sprite != null and effect_sprite.animation == &"impact"):
		return
	_clear_visual()


func _clear_visual() -> void:
	_reset_fade()
	_impact_released = false
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _on_animation_finished() -> void:
	if effect_sprite != null and effect_sprite.animation == &"impact":
		_preserve_residue = true
		effect_sprite.play(&"afterglow")
		_fade_tween = create_tween()
		_fade_tween.tween_interval(0.12)
		_fade_tween.tween_property(effect_sprite, "modulate:a", 0.0, 0.32)
		_fade_tween.tween_callback(_finish_residue)


func _is_pursuit() -> bool:
	return ability_component != null and ability_component.definition != null and ability_component.definition.ability_id == &"sovereign_pursuit"


func _follow_landing_origin() -> void:
	if ability_component != null and ability_component.owner is Node2D:
		global_position = (ability_component.owner as Node2D).global_position
		global_rotation = 0.0


func _reset_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
	_preserve_residue = false
	if effect_sprite != null:
		effect_sprite.modulate.a = 1.0


func _finish_residue() -> void:
	_preserve_residue = false
	_clear_visual()
