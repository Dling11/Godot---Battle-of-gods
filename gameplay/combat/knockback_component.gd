class_name KnockbackComponent
extends Node

signal knockback_started(velocity: Vector2)

@export var health_component: HealthComponent
@export_range(0.05, 1.0, 0.01, "suffix:s") var duration_seconds := 0.16

var velocity := Vector2.ZERO
var _deceleration := 0.0
var _strength_multiplier := 1.0


func _ready() -> void:
	set_physics_process(false)
	if health_component == null:
		push_error("KnockbackComponent requires a HealthComponent reference.")
		return
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(clear)


func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, _deceleration * delta)
	if velocity.is_zero_approx():
		clear()


func clear() -> void:
	velocity = Vector2.ZERO
	_deceleration = 0.0
	set_physics_process(false)


func configure(enemy_definition: EnemyDefinition) -> void:
	_strength_multiplier = enemy_definition.knockback_multiplier() if enemy_definition != null else 1.0


func accepts_light_pressure() -> bool:
	return _strength_multiplier >= 1.0


func apply_pressure(direction: Vector2, strength: float) -> void:
	if accepts_light_pressure():
		_on_damaged(DamageInfo.new(0.0, null, direction, strength))


func _on_damaged(info: DamageInfo) -> void:
	var resolved_strength := info.knockback_strength * _strength_multiplier
	if resolved_strength <= 0.0 or info.direction.is_zero_approx():
		return
	velocity = info.direction * resolved_strength
	_deceleration = resolved_strength / duration_seconds
	set_physics_process(true)
	knockback_started.emit(velocity)
