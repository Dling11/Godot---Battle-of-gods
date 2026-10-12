extends Node

## Opt-in physical attack steps. Presentation never writes the player's position.
## Mounted by opt-in weapon profiles and the isolated greatsword review.
var actor: Player
var attack: MeleeAttackComponent
var step_distances := PackedFloat32Array([8,10,12,8])
var _duration := 0.0
var _elapsed := 0.0
var _distance := 0.0
var _issued := 0.0
var _direction := Vector2.RIGHT
var actual_distance := 0.0
var blocked := false

func _ready() -> void:
	assert(actor!=null and attack!=null)
	attack.phase_changed.connect(_phase)
	attack.attack_finished.connect(_stop)
	set_physics_process(false)

func _phase(phase: int,duration: float) -> void:
	if phase==MeleeAttackComponent.Phase.WIND_UP:
		_elapsed = 0
		_duration = maxf(duration,0.0001)
		_distance = maxf(step_distances[attack.combo_step],0) if attack.combo_step<step_distances.size() else 0.0
		_issued = 0
		actual_distance = 0
		blocked = false
		_direction = attack.get_attack_direction()
		set_physics_process(_distance>0)
	elif phase==MeleeAttackComponent.Phase.ACTIVE:
		if not blocked: _advance(1.0)
		_stop()
	else: _stop()

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf((_elapsed/_duration-0.35)/0.65,0,1)
	_advance(progress*progress*(3.0-2.0*progress))

func _advance(progress: float) -> void:
	var wanted := _distance*progress
	var motion := _direction*maxf(wanted-_issued,0)
	_issued = wanted
	var origin := actor.global_position
	var bounded := (origin+motion).clamp(actor.movement_bounds.position,actor.movement_bounds.end)
	var collision := actor.move_and_collide(bounded-origin)
	actual_distance += actor.global_position.distance_to(origin)
	if collision!=null or not bounded.is_equal_approx(origin+motion):
		blocked = true
		_stop()

func _stop() -> void:
	set_physics_process(false)

func _exit_tree() -> void:
	_stop()
	if is_instance_valid(attack):
		if attack.phase_changed.is_connected(_phase): attack.phase_changed.disconnect(_phase)
		if attack.attack_finished.is_connected(_stop): attack.attack_finished.disconnect(_stop)
