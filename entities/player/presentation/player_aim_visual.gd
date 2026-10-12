extends Node2D

## Applies actor-owned facing snapshots to an action pivot without deciding
## player intent, attack timing, contacts, or damage.

@export var attack_component: MeleeAttackComponent
@export var ability_component: AbilityComponent
@export var ability_2_component: AbilityComponent
@export var ability_3_component: AbilityComponent
@export var ability_4_component: AbilityComponent
@export var lock_during_attack := false
@export var lock_during_ability_cast := false

var _action_facing_locked := false
var _pending_facing_direction := Vector2.ZERO


func _ready() -> void:
	if lock_during_attack:
		if attack_component == null:
			push_error("PlayerAimVisual requires a melee attack component when attack locking is enabled.")
		else:
			attack_component.attack_started.connect(_lock_attack_facing)
			attack_component.attack_finished.connect(_release_action_facing)
	if lock_during_ability_cast:
		for component in [ability_component, ability_2_component, ability_3_component, ability_4_component]:
			if component == null:
				continue
			component.ability_started.connect(_lock_cast_facing.bind(component))
			component.ability_finished.connect(_release_action_facing)


func set_facing_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	if _action_facing_locked:
		_pending_facing_direction = direction.normalized()
		return
	rotation = direction.angle()


func _lock_attack_facing() -> void:
	if attack_component == null:
		return
	var attack_direction := attack_component.get_attack_direction()
	if attack_direction.is_zero_approx():
		return
	_action_facing_locked = true
	_pending_facing_direction = Vector2.ZERO
	rotation = attack_direction.angle()


func _lock_cast_facing(source_component: AbilityComponent) -> void:
	if source_component == null:
		return
	var cast_direction := source_component.get_cast_direction()
	if cast_direction.is_zero_approx():
		return
	_action_facing_locked = true
	_pending_facing_direction = Vector2.ZERO
	rotation = cast_direction.angle()


func _release_action_facing() -> void:
	_action_facing_locked = false
	if _pending_facing_direction.is_zero_approx():
		return
	rotation = _pending_facing_direction.angle()
	_pending_facing_direction = Vector2.ZERO
