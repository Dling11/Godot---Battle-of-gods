class_name StaggerComponent
extends Node

## Resolves temporary attack interruption from accepted damage. It observes
## health only; each enemy controller remains responsible for its own state,
## movement, and visuals while staggered.

signal stagger_started(duration_seconds: float)
signal stagger_finished
signal stagger_resistance_started(duration_seconds: float)
signal stagger_resistance_finished
signal stun_changed(active: bool)

@export var health_component: HealthComponent

var remaining_seconds := 0.0
var stun_remaining_seconds := 0.0
var _duration_multiplier := 1.0
var _interrupt_limit := 0
var _chain_window_seconds := 0.9
var _resistance_duration_seconds := 0.0
var _interrupt_count := 0
var _chain_remaining := 0.0
var _resistance_remaining := 0.0


func _ready() -> void:
	set_physics_process(false)
	if health_component == null:
		push_error("StaggerComponent requires a HealthComponent reference.")
		return
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(clear)


func configure(enemy_definition: EnemyDefinition) -> void:
	if enemy_definition == null:
		_duration_multiplier = 1.0
		_interrupt_limit = 0
		_chain_window_seconds = 0.9
		_resistance_duration_seconds = 0.0
		return
	_duration_multiplier = enemy_definition.stagger_multiplier()
	_interrupt_limit = enemy_definition.stagger_interrupt_limit
	_chain_window_seconds = enemy_definition.stagger_chain_window_seconds
	_resistance_duration_seconds = enemy_definition.stagger_resistance_seconds


func is_staggered() -> bool:
	return remaining_seconds > 0.0


func is_stunned() -> bool:
	return stun_remaining_seconds > 0.0 and is_staggered()


func is_resisting_stagger() -> bool:
	return _resistance_remaining > 0.0


func get_chain_interrupt_count() -> int:
	return _interrupt_count


func clear() -> void:
	var was_stunned := is_stunned()
	remaining_seconds = 0.0
	stun_remaining_seconds = 0.0
	_interrupt_count = 0
	_chain_remaining = 0.0
	_resistance_remaining = 0.0
	set_physics_process(false)
	if was_stunned:
		stun_changed.emit(false)


func _physics_process(delta: float) -> void:
	var was_staggered := is_staggered()
	var was_stunned := is_stunned()
	var was_resisting := is_resisting_stagger()
	remaining_seconds = maxf(remaining_seconds - delta, 0.0)
	stun_remaining_seconds = maxf(stun_remaining_seconds - delta, 0.0)
	_chain_remaining = maxf(_chain_remaining - delta, 0.0)
	_resistance_remaining = maxf(_resistance_remaining - delta, 0.0)
	if was_stunned and not is_stunned():
		stun_changed.emit(false)
	if was_staggered and not is_staggered():
		stagger_finished.emit()
	if was_resisting and not is_resisting_stagger():
		stagger_resistance_finished.emit()
	if _chain_remaining <= 0.0 and not is_resisting_stagger():
		_interrupt_count = 0
	_update_processing()


func _on_damaged(info: DamageInfo) -> void:
	var resolved_stun := info.stun_seconds * _duration_multiplier
	var resolved_duration := maxf(info.stagger_seconds * _duration_multiplier, resolved_stun)
	if resolved_duration <= 0.0:
		return
	if is_resisting_stagger():
		return
	if _interrupt_limit > 0 and _resistance_duration_seconds > 0.0:
		if _chain_remaining <= 0.0:
			_interrupt_count = 0
		_interrupt_count += 1
		_chain_remaining = _chain_window_seconds
		if _interrupt_count >= _interrupt_limit:
			var was_staggered := is_staggered()
			var was_stunned := is_stunned()
			remaining_seconds = 0.0
			stun_remaining_seconds = 0.0
			_interrupt_count = 0
			_chain_remaining = 0.0
			_resistance_remaining = _resistance_duration_seconds
			if was_stunned:
				stun_changed.emit(false)
			if was_staggered:
				stagger_finished.emit()
			stagger_resistance_started.emit(_resistance_duration_seconds)
			_update_processing()
			return
	var was_staggered := is_staggered()
	var was_stunned := is_stunned()
	remaining_seconds = maxf(remaining_seconds, resolved_duration)
	stun_remaining_seconds = maxf(stun_remaining_seconds, resolved_stun)
	_update_processing()
	if not was_staggered:
		stagger_started.emit(resolved_duration)
	# Controllers may synchronously reject this through super armor/clear().
	if was_stunned != is_stunned():
		stun_changed.emit(is_stunned())


func _update_processing() -> void:
	set_physics_process(
		is_staggered()
		or is_resisting_stagger()
		or _chain_remaining > 0.0
	)
