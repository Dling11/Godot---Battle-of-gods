class_name EarthsplitterComponent
extends EchoingSeverComponent

## Released lane authority; the Player and equipped slot retain their stable ID.
const Sequence = preload("res://gameplay/abilities/king/earthsplitter_sequence.gd")
const Visual = preload("res://gameplay/abilities/king/earthsplitter_visual.gd")
const Path = preload("res://gameplay/abilities/king/earthsplitter_path.gd")
var target_position := Vector2.ZERO
var cast_origin := Vector2.ZERO
var contact_position := Vector2.ZERO
var _visual: Node2D
var _plans: Array[Dictionary] = []
var _preview_definition: AbilityDefinition
var _wave_templates: Array[Dictionary] = []

func owns_contact_feedback() -> bool:
	return true

func supports_ground_targeting() -> bool:
	return true

func is_fixed_length_line_targeted() -> bool:
	return true

func get_target_lane_preview(point: Vector2) -> Dictionary:
	var plans := _resolve_plans(point)
	var preview: Dictionary = plans.back().path.duplicate()
	if plans.size() > 1:
		preview["waves"] = plans.map(func(plan: Dictionary) -> Dictionary: return plan.path)
	return preview

func _resolve_plans(point: Vector2) -> Array[Dictionary]:
	if _preview_definition != definition:
		_preview_definition = definition
		_wave_templates = definition.build_waves()
	var plans: Array[Dictionary] = []
	var center := Path.resolve(owner as Player,point,definition)
	for template in _wave_templates:
		var plan: Dictionary = template.duplicate()
		if definition.shares_lane_hits:
			var heading: Vector2 = center.direction.rotated(template.angle)
			var reach: float = maxf(0.0,template.tuning.range_pixels-center.origin.distance_to(center.contact))
			plan["path"] = Path.resolve(owner as Player,center.contact+heading*maxf(reach,1.0),template.tuning,center.contact,reach,0.0)
		else:
			plan["path"] = Path.resolve(owner as Player,point,template.tuning)
		plans.append(plan)
	return plans

func get_target_range_pixels() -> float:
	return definition.range_pixels

func get_target_radius_pixels() -> float:
	return definition.lane_radius

func get_target_global_position() -> Vector2:
	return target_position

func request_cast_at(point: Vector2, weapon_damage := 0.0) -> bool:
	if not is_ready() or not owner is Player:
		return false
	var actor := owner as Player
	cast_origin = actor.global_position
	_plans = _resolve_plans(point)
	for plan in _plans:
		plan.tuning = plan.tuning.duplicate(true)
	var path: Dictionary = _plans.back().path
	target_position = path.end
	var direction: Vector2 = path.direction
	contact_position = _plans.front().path.contact
	var accepted := super.request_cast(direction, weapon_damage)
	if accepted:
		_visual = Visual.new()
		_visual.source = actor
		_visual.component = self
		_visual.contact = contact_position
		_visual.direction = direction
		_visual.wave_count = _plans.size()
		_visual.is_fan = definition.shares_lane_hits
		actor.get_parent().add_child(_visual)
	return accepted

func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, definition.active_seconds)
			_current_strike_index = 0
			var attack := Sequence.new()
			attack.source = owner
			attack.plans = _plans
			attack.weapon_damage = _equipped_weapon_damage
			attack.critical_chance = _critical_chance_ratio
			attack.critical_multiplier = _critical_damage_multiplier
			attack.hit_landed.connect(_on_hit_landed)
			if is_instance_valid(_visual):
				attack.wave_started.connect(_visual.start_wave)
				attack.front_advanced.connect(_visual.advance_wave)
				attack.wave_finished.connect(_visual.finish_wave)
				attack.sequence_finished.connect(_visual.finish_sequence)
				_visual.release()
			(owner as Node).get_parent().add_child(attack)
			strike_started.emit(0, 1, definition.active_seconds)
		Phase.ACTIVE:
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			phase = Phase.IDLE
			ability_finished.emit()

func _advance_active_strikes(_delta: float) -> void:
	pass

func cancel_cast() -> void:
	if phase == Phase.WIND_UP and is_instance_valid(_visual):
		_visual.queue_free()
	super.cancel_cast()
