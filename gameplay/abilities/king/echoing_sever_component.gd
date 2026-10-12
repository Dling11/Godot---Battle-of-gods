class_name EchoingSeverComponent
extends AbilityComponent

## Runs two intentionally separated damage windows. The rift pause is inactive,
## so standing in the preview cannot receive hidden continuous damage.

enum ActiveBeat { PRIMARY_WINDOW, ECHO_DELAY, ECHO_WINDOW, COMPLETE }

var _active_beat := ActiveBeat.COMPLETE
var _beat_time_remaining := 0.0


func _advance_phase() -> void:
	var echo_definition := definition as EchoingSeverDefinition
	if echo_definition == null:
		super._advance_phase()
		return
	match phase:
		Phase.WIND_UP:
			var total_active_seconds := (
				echo_definition.strike_window_seconds * 2.0
				+ echo_definition.echo_delay_seconds
			)
			_enter_phase(Phase.ACTIVE, total_active_seconds)
			_current_strike_index = 0
			_active_beat = ActiveBeat.PRIMARY_WINDOW
			_beat_time_remaining = echo_definition.strike_window_seconds
			_activate_echo_strike(0, echo_definition.strike_window_seconds)
		Phase.ACTIVE:
			hitbox.deactivate()
			_active_beat = ActiveBeat.COMPLETE
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			phase = Phase.IDLE
			ability_finished.emit()


func _advance_active_strikes(delta: float) -> void:
	var echo_definition := definition as EchoingSeverDefinition
	if echo_definition == null:
		super._advance_active_strikes(delta)
		return
	_beat_time_remaining -= delta
	while _beat_time_remaining <= 0.0 and _active_beat != ActiveBeat.COMPLETE:
		var overflow := -_beat_time_remaining
		match _active_beat:
			ActiveBeat.PRIMARY_WINDOW:
				hitbox.deactivate()
				_active_beat = ActiveBeat.ECHO_DELAY
				_beat_time_remaining = echo_definition.echo_delay_seconds - overflow
			ActiveBeat.ECHO_DELAY:
				_current_strike_index = 1
				_active_beat = ActiveBeat.ECHO_WINDOW
				_beat_time_remaining = echo_definition.strike_window_seconds - overflow
				_activate_echo_strike(1, echo_definition.strike_window_seconds)
			ActiveBeat.ECHO_WINDOW:
				hitbox.deactivate()
				_active_beat = ActiveBeat.COMPLETE
				_beat_time_remaining = 0.0


func cancel_cast() -> void:
	_active_beat = ActiveBeat.COMPLETE
	_beat_time_remaining = 0.0
	super.cancel_cast()


func _activate_echo_strike(strike_index: int, duration_seconds: float) -> void:
	hitbox.activate(
		definition.resolve_strike_damage(_equipped_weapon_damage, strike_index),
		owner,
		_cast_direction,
		definition.resolve_strike_knockback(strike_index),
		definition.resolve_strike_stagger(strike_index),
		_critical_chance_ratio,
		_critical_damage_multiplier,
		definition.resolve_strike_stun(strike_index),
		definition.damage_type
	)
	strike_started.emit(strike_index, definition.strike_count(), duration_seconds)
