extends Node

## Opt-in review mechanic: a real early-dash evade earns one brief pure counter.
## Not installed on the production Player; the combat review owns this component.
signal counter_ready_changed(ready: bool)
signal counter_landed

@export var timing_window_seconds := .12
@export var opportunity_seconds := .75
@export var damage_bonus_ratio := .25
var actor: Player
var _window: Timer
var _opportunity: Timer
var _swing_consumed := false

func _ready() -> void:
	actor = get_parent() as Player
	assert(actor != null)
	_window = _timer(timing_window_seconds)
	_opportunity = _timer(opportunity_seconds)
	_opportunity.timeout.connect(func() -> void: counter_ready_changed.emit(false))
	if actor.is_node_ready(): _bind()
	else: actor.ready.connect(_bind)

func _timer(seconds: float) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(timer)
	return timer

func _bind() -> void:
	actor.evade_component.evade_started.connect(_on_evade_started)
	actor.health_component.damage_blocked.connect(_on_blocked)
	actor.health_component.damaged.connect(_on_damaged)
	actor.attack_component.attack_started.connect(_on_attack_started)
	actor.attack_component.hit_landed.connect(_on_hit_landed)
	actor.defeated.connect(clear)

func is_counter_ready() -> bool:
	return not _opportunity.is_stopped()

func _on_evade_started(_direction: Vector2) -> void:
	_window.start()

func _on_blocked(info: DamageInfo) -> void:
	if _window.is_stopped() or not actor.evade_component.is_dashing() or actor.health_component.is_damage_immune:
		return
	if not actor.health_component.is_invulnerable or not is_instance_valid(info.source) or info.source == actor:
		return
	if not (info.source.get("definition") is EnemyDefinition or info.source.is_in_group(&"enemies")):
		return
	_window.stop() # A crowd cannot repeatedly refresh the same dodge opportunity.
	_opportunity.start()
	counter_ready_changed.emit(true)

func _on_attack_started() -> void:
	_swing_consumed = false
	if not is_counter_ready(): return
	actor.attack_component.committed_damage_type = DamageInfo.DamageType.PURE
	actor.attack_component.committed_perfect_counter = true
	actor.attack_component.committed_damage_multiplier += damage_bonus_ratio

func _on_hit_landed(_target: HurtboxComponent, info: DamageInfo) -> void:
	if _swing_consumed or not actor.attack_component.committed_perfect_counter or info.amount <= 0.0:
		return
	_swing_consumed = true
	_opportunity.stop()
	counter_ready_changed.emit(false)
	counter_landed.emit()

func _on_damaged(_info: DamageInfo) -> void:
	clear()

func clear() -> void:
	_window.stop()
	_opportunity.stop()
	counter_ready_changed.emit(false)
