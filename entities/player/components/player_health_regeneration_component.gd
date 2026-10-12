class_name PlayerHealthRegenerationComponent
extends Node

## Low baseline recovery for the active run. HealthComponent remains authority;
## this component only requests bounded healing after a damage-free delay.

@export var health_component: HealthComponent
@export var vitality_definition: PlayerVitalityDefinition
@export var delay_timer: Timer
@export var tick_timer: Timer

var flat_regeneration_bonus := 0.0


func _ready() -> void:
	if (
		health_component == null
		or vitality_definition == null
		or delay_timer == null
		or tick_timer == null
	):
		push_error("PlayerHealthRegenerationComponent requires health, vitality, and timer references.")
		return
	delay_timer.one_shot = true
	tick_timer.one_shot = false
	delay_timer.timeout.connect(_on_delay_finished)
	tick_timer.timeout.connect(_on_regeneration_tick)
	health_component.damaged.connect(_on_damaged)
	health_component.health_changed.connect(_on_health_changed)
	_refresh_timer_intervals()


func get_regeneration_per_second() -> float:
	return maxf(
		vitality_definition.base_health_regeneration_per_second
		+ flat_regeneration_bonus,
		0.0
	)


func set_flat_regeneration_bonus(flat_bonus: float) -> void:
	flat_regeneration_bonus = maxf(flat_bonus, 0.0)
	if get_regeneration_per_second() <= 0.0:
		delay_timer.stop()
		tick_timer.stop()


func _on_damaged(_info: DamageInfo) -> void:
	_start_delay()


func _on_health_changed(current: float, maximum: float) -> void:
	if current <= 0.0 or current >= maximum or get_regeneration_per_second() <= 0.0:
		delay_timer.stop()
		tick_timer.stop()
		return
	if delay_timer.is_stopped() and tick_timer.is_stopped():
		_start_delay()


func _start_delay() -> void:
	tick_timer.stop()
	_refresh_timer_intervals()
	if health_component.current_health > 0.0 and health_component.current_health < health_component.maximum_health:
		delay_timer.start()


func _on_delay_finished() -> void:
	if (
		health_component.current_health <= 0.0
		or health_component.current_health >= health_component.maximum_health
		or get_regeneration_per_second() <= 0.0
	):
		return
	_refresh_timer_intervals()
	tick_timer.start()


func _on_regeneration_tick() -> void:
	health_component.heal(
		get_regeneration_per_second()
		* vitality_definition.regeneration_tick_seconds
	)


func _refresh_timer_intervals() -> void:
	delay_timer.wait_time = maxf(vitality_definition.regeneration_delay_seconds, 0.01)
	tick_timer.wait_time = maxf(vitality_definition.regeneration_tick_seconds, 0.01)
