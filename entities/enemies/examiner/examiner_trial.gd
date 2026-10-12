class_name ExaminerTrial
extends Node

## Separate defensive seal. Absorbs mitigated hits before HP, never after it.
signal progressed(damage: float, required: float, seconds_left: float)
signal completed(success: bool)
signal cut_released

const LaneScene = preload("res://entities/enemies/examiner/examiner_axiom_lane.tscn")
var actor: Node2D
var target: Node2D
var definition: ExaminerDefinition
var active := false
var damage := 0.0
var remaining := 0.0
var required := 240.0
var warns_cuts := true
var _cut_clock := 0.0
var _hud_clock := 0.0
var _cut_index := 0
var _pending: Array[Dictionary] = []
var _visuals: Array[Node] = []


func _ready() -> void:
	set_physics_process(false)


func begin(owner_actor: Node2D, player: Node2D, tuning: ExaminerDefinition, orb := false, firmament := false) -> void:
	cancel()
	actor = owner_actor
	target = player
	definition = tuning
	damage = 0.0
	remaining = definition.trial_duration_seconds
	required = definition.trial_damage_required
	warns_cuts = not orb
	if orb:
		remaining = definition.orb_charge_seconds
		required = definition.orb_guard_health
	if firmament:
		warns_cuts = false
		remaining = definition.firmament_charge_seconds
		required = definition.firmament_guard_health
	_cut_clock = 1.0
	_hud_clock = 0.0
	_cut_index = 0
	active = true
	set_physics_process(true)
	progressed.emit(damage, required, remaining)


func absorb_damage(info: DamageInfo) -> bool:
	if not active:
		return false
	record_damage(info)
	# No overflow: breaking the seal earns the following attacks a HP window.
	return true


func record_damage(info: DamageInfo) -> void:
	if not active or (actor.get_node("HealthComponent") as HealthComponent).current_health <= 0.0:
		return
	damage += info.amount
	progressed.emit(damage, required, remaining)
	if damage >= required:
		_finish(true)


func _physics_process(delta: float) -> void:
	if not active:
		return
	remaining = maxf(remaining - delta, 0.0)
	_cut_clock -= delta
	_hud_clock -= delta
	for index in range(_pending.size() - 1, -1, -1):
		_pending[index].remaining -= delta
		if _pending[index].remaining <= 0.0:
			_resolve_cut(_pending[index])
			_pending.remove_at(index)
	if remaining <= 0.0:
		_finish(false)
		return
	if warns_cuts and _cut_clock <= 0.0 and remaining > 1.0:
		_warn_cut()
		_cut_clock = 1.5
	if _hud_clock <= 0.0:
		_hud_clock = 0.1
		progressed.emit(damage, required, remaining)


func _warn_cut() -> void:
	if not is_instance_valid(target) or not is_instance_valid(actor):
		return
	var direction := Vector2.RIGHT if _cut_index % 2 == 0 else Vector2.DOWN
	_cut_index += 1
	var center := target.global_position
	var visual := LaneScene.instantiate() as ExaminerAxiomLane
	var effects := get_tree().get_first_node_in_group("boss_effects") as Node2D
	(effects if effects != null else actor.get_parent()).add_child(visual)
	_visuals.append(visual)
	visual.configure(center, direction, 210.0, 26.0, 0.85, 0.85)
	_pending.append({"center": center, "direction": direction, "remaining": 0.85, "visual": visual})


func _resolve_cut(cut: Dictionary) -> void:
	cut_released.emit()
	if not is_instance_valid(target):
		return
	var center: Vector2 = cut.center
	var direction: Vector2 = cut.direction
	var relative := target.global_position - center
	var along := clampf(relative.dot(direction), -105.0, 105.0)
	if relative.distance_to(direction * along) > 13.0:
		return
	var health := target.find_child("HealthComponent", true, false) as HealthComponent
	if health != null:
		health.apply_damage(DamageInfo.new(definition.trial_cut_damage, actor, direction, 70.0, 0.10))


func _finish(success: bool) -> void:
	cancel()
	completed.emit(success)


func cancel() -> void:
	active = false
	set_physics_process(false)
	for visual in _visuals:
		if is_instance_valid(visual):
			visual.queue_free()
	_visuals.clear()
	_pending.clear()


func _exit_tree() -> void:
	cancel()
