class_name ExaminerActionSfx
extends Node

const Thrust = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_thrust.wav")
const SunCharge = preload("res://assets/audio/sfx/characters/disciples/examiner/firmament/sun_gather.wav")
const CrimsonCharge = preload("res://assets/audio/sfx/characters/disciples/examiner/firmament/crimson_gather.wav")
const CrimsonRelease = preload("res://assets/audio/sfx/characters/disciples/examiner/firmament/crimson_release.wav")
const SealCharge = preload("res://assets/audio/sfx/characters/disciples/examiner/ascendant/seal_charge.wav")
const SunRelease = preload("res://assets/audio/sfx/characters/disciples/examiner/ascendant/sun_release.wav")
const GuardBreak = preload("res://assets/audio/sfx/characters/disciples/examiner/ascendant/guard_break.wav")
const Awakening = preload("res://assets/audio/sfx/characters/disciples/examiner/ascendant/awakening.wav")
const Sweep = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_sweep.wav")
const ChargePrepare = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_charge_prepare.wav")
const ChargeDash = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_charge_dash.wav")
const ChargeImpact = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_charge_impact.wav")
const SlamPrepare = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_slam_prepare.wav")
const SlamImpact = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_slam_impact.wav")
const Refutation = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_refutation.wav")
const AxiomPrepare = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_axiom_prepare.wav")
const AxiomCut = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_axiom_cut.wav")
const DescentChime = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_descent_chime.wav")
const DescentLaunch = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_descent_launch.wav")
const DescentCharge = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_descent_charge.wav")
const DescentFall = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_descent_fall.wav")
const DescentImpact = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_descent_impact.wav")

@export var action_player: AudioStreamPlayer2D
@export var impact_player: AudioStreamPlayer2D

const Step = preload("res://assets/audio/sfx/characters/disciples/examiner/rework/examiner_step.wav")
var _body: AnimatedSprite2D
var _foot_player: AudioStreamPlayer2D


func _ready() -> void:
	_body = get_parent().get_node("Visual/Body") as AnimatedSprite2D
	_foot_player = AudioStreamPlayer2D.new()
	_foot_player.bus = &"SFX"
	_foot_player.max_distance = 700.0
	add_child(_foot_player)
	_body.frame_changed.connect(_on_body_frame_changed)


func _on_body_frame_changed() -> void:
	if String(_body.animation).begins_with("walk_") and _body.frame in [0, 2]:
		_play(_foot_player, Step, -18.0)


func _exit_tree() -> void:
	for player in [action_player, impact_player, _foot_player]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null


func play_state(state: Examiner.State, _duration_seconds: float) -> void:
	match state:
		Examiner.State.THRUST_ACTIVE:
			_play(action_player, Thrust, -4.0)
		Examiner.State.SWEEP_ACTIVE:
			_play(action_player, Sweep, -3.0)
		Examiner.State.CHARGE_WIND_UP, Examiner.State.PURSUIT_WIND_UP:
			_play(action_player, ChargePrepare, -5.0)
		Examiner.State.CHARGE_TRAVEL, Examiner.State.PURSUIT_TRAVEL:
			_play(action_player, ChargeDash, -2.0)
		Examiner.State.SLAM_WIND_UP, Examiner.State.HELD_JUDGMENT:
			_play(action_player, SlamPrepare, -5.0)
		Examiner.State.REFUTATION_ACTIVE:
			_play(action_player, Refutation, -4.0)
		Examiner.State.AXIOM_WIND_UP:
			_play(action_player, AxiomPrepare, -4.0)
		Examiner.State.TRIAL_CHANNEL:
			_play(action_player, SealCharge, -8.0)
		Examiner.State.ORB_CHARGE:
			_play(action_player, SunCharge, -7.0)
		Examiner.State.FIRMAMENT_CHARGE:
			_play(action_player, CrimsonCharge, -7.0)
		Examiner.State.FIRMAMENT_BARRAGE:
			_play(action_player, CrimsonRelease, -5.0)
		Examiner.State.ORB_RELEASE:
			_play(action_player, SunRelease, -3.0)
		Examiner.State.GUARD_BROKEN:
			action_player.stop()
			_play(impact_player, GuardBreak, -3.0)
		Examiner.State.BERSERK_AWAKEN:
			_play(action_player, Awakening, -3.0)
		Examiner.State.CROWNFALL:
			_play(action_player, DescentChime, -4.0)
		Examiner.State.AXIOM_CUT_ONE:
			_play(action_player, AxiomCut, -3.0)
			action_player.pitch_scale = 0.92
		Examiner.State.AXIOM_CUT_TWO:
			_play(action_player, AxiomCut, -2.0)
			action_player.pitch_scale = 1.12
		Examiner.State.AXIOM_DASH:
			_play(action_player, ChargeDash, -3.0)
		Examiner.State.PHASE_STANCE:
			_play(action_player, DescentChime, -2.0)
		Examiner.State.DESCENT_LAUNCH:
			_play(action_player, DescentLaunch, -1.0)
		Examiner.State.DESCENT_ABSENT:
			_play(action_player, DescentCharge, -5.0)
		Examiner.State.DESCENT_FALL:
			_play(action_player, DescentFall, -1.0)
		Examiner.State.WITHDRAWAL:
			action_player.stop()
		Examiner.State.VICTORY_KNEEL:
			action_player.stop()
			_play(impact_player, GuardBreak, -7.0)
		Examiner.State.VICTORY_RISE:
			_play(action_player, DescentChime, -9.0)


func play_impact(kind: StringName, _world_position: Vector2, _direction: Vector2) -> void:
	if kind == &"ground_judgment":
		_play(impact_player, SlamImpact, -1.0)
	elif kind == &"judgment_charge":
		_play(impact_player, ChargeImpact, -2.0)
	elif kind == &"divine_descent":
		_play(impact_player, DescentImpact, 0.0)


func _play(player: AudioStreamPlayer2D, stream: AudioStream, volume_db: float) -> void:
	if player == null:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.97, 1.03)
	if DisplayServer.get_name() != "headless":
		player.play()


func play_trial_cut() -> void:
	_play(impact_player, AxiomCut, -5.0)
