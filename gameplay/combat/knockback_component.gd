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


func remaining_after_slide(actor: CharacterBody2D, applied: Vector2) -> Vector2:
	## move_and_slide removes blocked normal velocity. Subtracting that old
	## impulse next frame creates a false velocity in the opposite direction.
	if applied.is_zero_approx(): return Vector2.ZERO
	for index in actor.get_slide_collision_count():
		applied = applied.slide(actor.get_slide_collision(index).get_normal())
	return applied


func apply_pressure(direction: Vector2, strength: float) -> void:
	if accepts_light_pressure():
		_on_damaged(DamageInfo.new(0.0, null, direction, strength))


func _on_damaged(info: DamageInfo) -> void:
	var resolved_strength := info.knockback_strength * _strength_multiplier
	var direction := info.direction
	if info.light_pull_distance > 0.0 and accepts_light_pressure() and is_instance_valid(info.source) and info.source is Node2D and health_component.get_parent() is Node2D:
		var actor := health_component.get_parent() as Node2D
		var inward := (info.source as Node2D).global_position - actor.global_position
		var distance := minf(info.light_pull_distance, maxf(inward.length() - info.pull_standoff_distance, 0.0))
		# Include one full physics tick in the bound: parent movement can sample
		# the impulse before this child's decay. Continuous-time integration alone
		# would overshoot distance/stand-off by a few pixels at 60Hz.
		var tick := 1.0 / Engine.physics_ticks_per_second
		resolved_strength = distance / (duration_seconds * 0.5 + tick)
		direction = inward.normalized()
	if resolved_strength <= 0.0 or direction.is_zero_approx():
		return
	velocity = direction * resolved_strength
	_deceleration = resolved_strength / duration_seconds
	set_physics_process(true)
	knockback_started.emit(velocity)
