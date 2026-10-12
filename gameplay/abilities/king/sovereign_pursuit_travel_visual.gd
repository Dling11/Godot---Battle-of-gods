class_name SovereignPursuitTravelVisual
extends Node2D

## Character-following power sheath for Sovereign Pursuit's traversal only.
## The separate top-level SovereignPursuitVisual owns takeoff and landing ground VFX.

@export var ability_component: SovereignPursuitComponent
@export var effect_sprite: AnimatedSprite2D

func _ready() -> void:
	hide_visual()


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		hide_visual()
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"travel")
		_emit_wake()
	elif phase == AbilityComponent.Phase.RECOVERY:
		hide_visual()


func hide_visual() -> void:
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _is_pursuit() -> bool:
	return (
		ability_component != null
		and ability_component.definition != null
		and ability_component.definition.ability_id == &"sovereign_pursuit"
	)


func _emit_wake() -> void:
	# Four short-lived snapshots make the fast leap read as travel, while the
	# actual actor and ability component remain the only movement authority.
	for stamp in 4:
		await get_tree().create_timer(0.065, false).timeout
		if not _is_pursuit() or ability_component.phase != AbilityComponent.Phase.ACTIVE:
			return
		var ghost := Sprite2D.new()
		ghost.texture = effect_sprite.sprite_frames.get_frame_texture(&"travel", effect_sprite.frame)
		ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ghost.z_index = -2
		ghost.modulate = Color(0.58, 0.82, 1.0, 0.3)
		ability_component.owner.get_parent().add_child(ghost)
		ghost.global_position = effect_sprite.global_position
		var fade := ghost.create_tween()
		fade.tween_property(ghost, "modulate:a", 0.0, 0.18)
		fade.tween_callback(ghost.queue_free)
