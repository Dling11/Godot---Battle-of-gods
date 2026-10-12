class_name EvadeComponent
extends Node

enum Phase { READY, DASHING, RECOVERY }

signal evade_started(direction: Vector2)
signal phase_changed(phase: Phase, duration_seconds: float)
signal invulnerability_changed(is_invulnerable: bool)
signal evade_finished
signal cooldown_started(duration_seconds: float)
signal cooldown_finished

@export var definition: EvadeDefinition

var phase := Phase.READY
var dash_direction := Vector2.DOWN
var _phase_time_remaining: float
var _cooldown_time_remaining := 0.0


func _ready() -> void:
	set_physics_process(false)


func request_evade(direction: Vector2) -> bool:
	if not is_evade_available() or definition == null or direction.is_zero_approx():
		return false
	dash_direction = direction.normalized()
	phase = Phase.DASHING
	_phase_time_remaining = definition.dash_seconds
	_cooldown_time_remaining = definition.cooldown_seconds
	evade_started.emit(dash_direction)
	phase_changed.emit(phase, definition.dash_seconds)
	invulnerability_changed.emit(true)
	cooldown_started.emit(definition.cooldown_seconds)
	set_physics_process(true)
	return true


func get_dash_velocity() -> Vector2:
	if phase != Phase.DASHING or definition == null:
		return Vector2.ZERO
	return dash_direction * definition.speed


func is_ready() -> bool:
	return phase == Phase.READY


func is_evade_available() -> bool:
	return phase == Phase.READY and _cooldown_time_remaining <= 0.0


func get_cooldown_remaining() -> float:
	return maxf(_cooldown_time_remaining, 0.0)


func is_dashing() -> bool:
	return phase == Phase.DASHING


func is_recovering() -> bool:
	return phase == Phase.RECOVERY


func cancel_recovery() -> bool:
	## Basic attacks may cancel only the vulnerable recovery window. Keeping
	## active-dash cancellation unavailable preserves distance and i-frame rules.
	if phase != Phase.RECOVERY:
		return false
	phase = Phase.READY
	_phase_time_remaining = 0.0
	set_physics_process(_cooldown_time_remaining > 0.0)
	evade_finished.emit()
	return true


func cancel_evade() -> void:
	var had_cooldown := _cooldown_time_remaining > 0.0
	if phase == Phase.DASHING:
		invulnerability_changed.emit(false)
	phase = Phase.READY
	_phase_time_remaining = 0.0
	_cooldown_time_remaining = 0.0
	set_physics_process(false)
	evade_finished.emit()
	if had_cooldown:
		cooldown_finished.emit()


func interrupt_recovery() -> void:
	## Accepted hits cannot reach the invulnerable dash phase, but may interrupt
	## its vulnerable recovery without refunding the already-spent cooldown.
	if phase != Phase.RECOVERY:
		return
	phase = Phase.READY
	_phase_time_remaining = 0.0
	set_physics_process(_cooldown_time_remaining > 0.0)
	evade_finished.emit()


func _physics_process(delta: float) -> void:
	var previous_cooldown := _cooldown_time_remaining
	_cooldown_time_remaining = maxf(_cooldown_time_remaining - delta, 0.0)
	if previous_cooldown > 0.0 and _cooldown_time_remaining <= 0.0:
		cooldown_finished.emit()
	_phase_time_remaining -= delta
	if _phase_time_remaining > 0.0:
		return

	if phase == Phase.DASHING:
		invulnerability_changed.emit(false)
		phase = Phase.RECOVERY
		_phase_time_remaining = definition.recovery_seconds
		phase_changed.emit(phase, definition.recovery_seconds)
	elif phase == Phase.RECOVERY:
		phase = Phase.READY
		evade_finished.emit()
	if phase == Phase.READY and _cooldown_time_remaining <= 0.0:
		set_physics_process(false)
