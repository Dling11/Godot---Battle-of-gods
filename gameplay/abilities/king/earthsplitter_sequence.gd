extends Node2D

## Owns a released cast after Player recovery. All paths and stats are snapshots.
signal hit_landed(target: HurtboxComponent, info: DamageInfo)
signal wave_started(index: int, plan: Dictionary)
signal front_advanced(index: int, point: Vector2)
signal wave_finished(index: int)
signal sequence_finished
const GroundAttack = preload("res://gameplay/abilities/king/earthsplitter_ground_attack.gd")
var source: Player
var plans: Array[Dictionary] = []
var weapon_damage := 0.0
var critical_chance := 0.0
var critical_multiplier := 1.5
var _age := 0.0
var _next := 0
var _active := 0
var _cancelled := false
var _shared_targets: Dictionary = {}

func _ready() -> void:
	add_to_group("earthsplitter_sequences")
	_launch_due()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated:
		_cancel()
		return
	_age += delta
	_launch_due()

func _launch_due() -> void:
	while _next < plans.size() and _age + .00001 >= float(plans[_next].delay):
		var index := _next
		var plan: Dictionary = plans[index]
		_next += 1
		_active += 1
		var wave := GroundAttack.new()
		wave.source = source
		if plan.get("share_hits", false):
			wave.shared_targets = _shared_targets
		wave.origin = plan.path.contact
		wave.target = plan.path.end
		wave.tuning = plan.tuning
		wave.damage = wave.tuning.resolve_damage(weapon_damage)
		wave.critical_chance = critical_chance
		wave.critical_multiplier = critical_multiplier
		wave.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void: hit_landed.emit(target,info))
		wave.front_advanced.connect(func(point: Vector2) -> void: front_advanced.emit(index,point))
		wave.travel_finished.connect(_on_wave_finished.bind(index))
		wave_started.emit(index,plan)
		add_child(wave)

func _on_wave_finished(index: int) -> void:
	if _cancelled:
		return
	_active -= 1
	wave_finished.emit(index)
	if _next == plans.size() and _active == 0:
		sequence_finished.emit()
		set_physics_process(false)
		queue_free()

func _cancel() -> void:
	if _cancelled:
		return
	_cancelled = true
	set_physics_process(false)
	for wave in get_children():
		wave._cancel()
	queue_free()
