class_name KingSkill4Component
extends AbilityComponent

## Releases rank-authored plunges at a fixed target independently of recovery.

const Visual = preload("res://gameplay/abilities/king/worldsplitter_visual.gd")
const Sequence = preload("res://gameplay/abilities/king/worldsplitter_sequence.gd")
var _visual: Node2D
var _target_global_position := Vector2.ZERO


func request_cast_at(target_global_position: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if not is_ready(): return false
	var skill := definition as KingSkill4Definition
	var actor := owner as Node2D
	if skill == null or actor == null:
		return false
	var offset := target_global_position - actor.global_position
	if offset.length() > skill.target_range_pixels:
		offset = offset.normalized() * skill.target_range_pixels
	_target_global_position = resolve_ground_target(target_global_position)
	if not request_cast(offset, equipped_weapon_damage): return false
	_visual = Visual.new()
	_visual.source = actor
	_visual.component = self
	_visual.radius = skill.first_impact_radius_pixels
	_visual.tuning = skill.duplicate(true)
	actor.get_parent().add_child(_visual)
	_visual.global_position = get_target_global_position()
	return true


func supports_ground_targeting() -> bool:
	return true


func get_target_range_pixels() -> float:
	var skill := definition as KingSkill4Definition
	return skill.target_range_pixels if skill != null else 0.0


func get_target_radius_pixels() -> float:
	var skill := definition as KingSkill4Definition
	return skill.explosion_radius_pixels if skill != null else 0.0


func get_target_global_position() -> Vector2:
	var skill := definition as KingSkill4Definition
	return _target_global_position + Vector2(0.0, skill.ground_center_offset_y if skill != null else 0.0)


func cancel_cast() -> void:
	if phase == Phase.WIND_UP and is_instance_valid(_visual): _visual.queue_free()
	_reset_hitbox_position()
	super.cancel_cast()


func _start_current_strike() -> void:
	if is_instance_valid(_visual): _visual.release()
	var sequence := Sequence.new()
	sequence.source = owner
	sequence.component = self
	sequence.tuning = definition.duplicate(true) as KingSkill4Definition
	sequence.visual = _visual
	sequence.damage = definition.resolve_damage(_equipped_weapon_damage)
	sequence.critical_chance = _critical_chance_ratio
	sequence.critical_multiplier = _critical_damage_multiplier
	owner.get_parent().add_child(sequence)
	sequence.global_position = get_target_global_position()
	strike_started.emit(0, 1, definition.active_seconds)


func _advance_active_strikes(_delta: float) -> void:
	pass # Released sequence owns all plunge contacts after the short cast.


func _advance_phase() -> void:
	var previous_phase := phase
	super._advance_phase()
	if previous_phase == Phase.RECOVERY:
		_reset_hitbox_position()


func _reset_hitbox_position() -> void:
	if hitbox != null:
		hitbox.position = Vector2.ZERO

func resolve_ground_target(point: Vector2) -> Vector2:
	var actor := owner as Player
	if actor == null: return point
	var offset := (point-actor.global_position).limit_length(get_target_range_pixels())
	return actor.global_position+offset

func get_target_core_radius_pixels() -> float:
	return (definition as KingSkill4Definition).contact_radius(0)

func get_target_center_offset() -> Vector2:
	return Vector2(0.0, (definition as KingSkill4Definition).ground_center_offset_y)

func apply_rank(value: int) -> void:
	if is_casting(): return
	var next := definition.duplicate(true) as KingSkill4Definition
	next.configure_rank(value)
	definition = next
	collision_shape.shape = next.hitbox_shape
