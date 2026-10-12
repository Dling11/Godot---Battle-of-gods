class_name Stage5BossAudio
extends Node

@export var boss: Stage5Boss
@export var step: AudioStreamPlayer
@export var lunge: AudioStreamPlayer
@export var slap: AudioStreamPlayer
@export var jump_launch: AudioStreamPlayer
@export var jump_air: AudioStreamPlayer
@export var jump_impact: AudioStreamPlayer
@export var prison: AudioStreamPlayer
@export var prison_lock: AudioStreamPlayer
@export var execution_rumble: AudioStreamPlayer
@export var execution_impact: AudioStreamPlayer
@export var hurt: AudioStreamPlayer
@export var phase: AudioStreamPlayer
@export var defeat: AudioStreamPlayer

var _moving := false
var _step_timer := 0.0
var _phase_played := false

func _ready() -> void:
	if boss == null: return
	boss.movement_changed.connect(func(moving: bool): _moving = moving)
	boss.state_changed.connect(_on_state_changed)
	boss.slap_landed.connect(func(_p): slap.play())
	boss.landed.connect(_on_landed)
	boss.root_locked.connect(_on_root_locked)
	boss.root_executed.connect(_on_root_executed)
	var health := boss.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.damaged.connect(_on_health_damaged)
		health.died.connect(func(): defeat.play())

func _process(delta: float) -> void:
	if not _moving or boss.state == Stage5Boss.State.DEAD: return
	_step_timer -= delta
	if _step_timer <= 0.0:
		step.play(); _step_timer = 0.34

func _on_state_changed(state: Stage5Boss.State, _duration: float) -> void:
	if state == Stage5Boss.State.LUNGE_WIND_UP: lunge.play()
	elif state == Stage5Boss.State.JUMP_WIND_UP: jump_launch.play()
	elif state == Stage5Boss.State.JUMP_TRAVEL: jump_air.play()
	elif state == Stage5Boss.State.ROOT_WIND_UP: prison.play()

func _on_landed(_position: Vector2) -> void:
	jump_air.stop()
	jump_impact.play()


func _on_root_locked(_position: Vector2, _captured_player: bool) -> void:
	prison_lock.play()


func _on_root_executed(_position: Vector2, _hit_player: bool) -> void:
	execution_rumble.play()
	execution_impact.play()


func _on_health_damaged(_info: DamageInfo) -> void:
	hurt.play()
	var health := boss.get_node_or_null("HealthComponent") as HealthComponent
	if health != null and not _phase_played and health.current_health <= health.maximum_health * 0.30:
		_phase_played = true
		phase.play()
