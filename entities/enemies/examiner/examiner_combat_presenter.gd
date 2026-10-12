class_name ExaminerCombatPresenter
extends Node2D

const ActionVfx = preload("res://entities/enemies/examiner/examiner_action_vfx.gd")
const EnergyPresentation = preload("res://entities/enemies/examiner/examiner_energy_presentation.gd")
const GroundVfx = preload("res://entities/enemies/examiner/examiner_ground_judgment_vfx.gd")
const DescentVfx = preload("res://entities/enemies/examiner/examiner_divine_descent_vfx.gd")
const DescentLaunchVfx = preload("res://entities/enemies/examiner/examiner_divine_descent_launch_vfx.gd")

@export var examiner: Examiner
@export var body: AnimatedSprite2D
@export var divine_aura: DivineThreatAura
@export_range(0.01, 0.2, 0.01, "suffix:s") var afterimage_interval := 0.04

var state := Examiner.State.SPAWNING
var state_elapsed := 0.0
var state_duration := 0.0
var afterimage_remaining := 0.0
var presence_elapsed := 0.0
var impact_budget := 0.0


func _ready() -> void:
	z_index = -1
	queue_redraw()


func _process(delta: float) -> void:
	presence_elapsed += delta
	impact_budget = maxf(impact_budget - delta, 0)
	state_elapsed += delta
	afterimage_remaining -= delta
	if state in [Examiner.State.CHARGE_TRAVEL, Examiner.State.AXIOM_DASH, Examiner.State.PURSUIT_TRAVEL] and afterimage_remaining <= 0.0:
		_spawn_afterimage()
		afterimage_remaining = afterimage_interval
	queue_redraw()


func play_state(next_state: Examiner.State, duration_seconds: float) -> void:
	state = next_state
	state_elapsed = 0.0
	state_duration = maxf(duration_seconds, 0.01)
	if state == Examiner.State.VICTORY_KNEEL:
		_request_camera_pulse(2.0)
	if divine_aura != null:
		divine_aura.set_empowered(state in [Examiner.State.CHARGE_WIND_UP, Examiner.State.SLAM_WIND_UP, Examiner.State.AXIOM_WIND_UP, Examiner.State.PHASE_STANCE, Examiner.State.DESCENT_PREPARE, Examiner.State.DESCENT_LAUNCH, Examiner.State.DESCENT_FALL, Examiner.State.DESCENT_IMPACT])
	if state in [Examiner.State.CHARGE_TRAVEL, Examiner.State.AXIOM_DASH, Examiner.State.PURSUIT_TRAVEL]:
		afterimage_remaining = 0.0
	if state == Examiner.State.DESCENT_LAUNCH and examiner != null:
		var launch := DescentLaunchVfx.new() as Node2D
		_effects_parent().add_child(launch)
		launch.global_position = examiner.global_position + Vector2(0.0, -3.0)
		_request_camera_pulse(2.6)
	queue_redraw()


func play_impact(kind: StringName, world_position: Vector2, direction: Vector2) -> void:
	if kind == &"meteor_impact":
		if impact_budget <= 0:
			_request_camera_pulse(4.0)
			impact_budget = 0.15
		return
	if kind == &"sun_impact":
		_request_camera_pulse(5.5)
		return
	if kind == &"guard_break":
		_request_camera_pulse(4.0)
		var shards := ActionVfx.new() as ExaminerActionVfx
		shards.configure(&"divine_sweep", Vector2.RIGHT)
		_effects_parent().add_child(shards)
		shards.global_position = world_position
		return
	if kind == &"divine_descent":
		var descent := DescentVfx.new() as Node2D
		_effects_parent().add_child(descent)
		descent.global_position = world_position
		_request_camera_pulse(8.0)
		return
	if kind == &"ground_judgment":
		var ground := GroundVfx.new() as Node2D
		_effects_parent().add_child(ground)
		ground.global_position = world_position
		_request_camera_pulse(3.5)
		return
	var effect := ActionVfx.new() as ExaminerActionVfx
	effect.configure(kind, direction)
	_effects_parent().add_child(effect)
	effect.global_position = world_position
	if kind == &"judgment_charge":
		_request_camera_pulse(1.8)


func _draw() -> void:
	_draw_body_presence()
	if examiner == null:
		return
	if state in [Examiner.State.CHARGE_WIND_UP, Examiner.State.PURSUIT_WIND_UP]:
		_draw_charge_warning()
	elif state in [Examiner.State.TRIAL_CHANNEL, Examiner.State.ORB_CHARGE, Examiner.State.BERSERK_AWAKEN, Examiner.State.CROWNFALL, Examiner.State.FIRMAMENT_CHARGE, Examiner.State.FIRMAMENT_BARRAGE]:
		_draw_channel()
	elif state == Examiner.State.GUARD_BROKEN:
		for i in 5:
			var angle := state_elapsed * 3.2 + i * TAU / 5
			var point := Vector2(cos(angle) * 17, -43 + sin(angle) * 5)
			draw_rect(Rect2(point, Vector2(3, 2)), Color(1, 0.86, 0.42, 0.9))
	elif state == Examiner.State.ORB_RELEASE:
		var progress := clampf(state_elapsed / state_duration, 0, 1)
		var extent := (96.0 if examiner.is_berserk() else 78.0) * (1.0 - 0.2 * progress)
		ExaminerEffectAtlas.draw_sun(self, state_elapsed, Vector2(0,-108).lerp(Vector2(0,-100), progress), extent, Color.WHITE, state_elapsed * 2.2)
		var radius := examiner.definition.berserk_orb_radius if examiner.is_berserk() else examiner.definition.orb_radius
		ExaminerEffectAtlas.danger_circle(self, to_local(examiner._sun_target), radius, progress * 0.25)
	elif state == Examiner.State.COMBO_WIND_UP:
		draw_set_transform(Vector2.ZERO, examiner.facing_direction.angle())
		ExaminerEffectAtlas.danger_lane(self, Rect2(16, -12, 108, 24), clampf(state_elapsed / state_duration, 0, 1))
		draw_set_transform(Vector2.ZERO)
	elif state in [Examiner.State.SLAM_WIND_UP, Examiner.State.HELD_JUDGMENT]:
		_draw_slam_warning()
	elif state == Examiner.State.DESCENT_FALL:
		_draw_descent_streak()


func _draw_body_presence() -> void:
	if examiner != null and examiner.is_berserk() and state not in [Examiner.State.VICTORY_KNEEL, Examiner.State.VICTORY_RISE, Examiner.State.VICTORY_HOLD, Examiner.State.WITHDRAWAL]:
		EnergyPresentation.enrage(self, presence_elapsed, 0.3 if state == Examiner.State.GUARD_BROKEN else 1.0)
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.0022)
	var empowered := (examiner != null and examiner.is_berserk()) or state in [Examiner.State.ORB_CHARGE, Examiner.State.TRIAL_CHANNEL, Examiner.State.CHARGE_WIND_UP, Examiner.State.SLAM_WIND_UP, Examiner.State.AXIOM_WIND_UP, Examiner.State.PHASE_STANCE, Examiner.State.DESCENT_PREPARE, Examiner.State.DESCENT_LAUNCH, Examiner.State.DESCENT_FALL]
	var alpha := (0.30 if empowered else 0.12) + pulse * (0.12 if empowered else 0.04)
	for mote_index in (7 if empowered else 4):
		var angle := float(mote_index) * 2.17 + Time.get_ticks_msec() * 0.00035
		var mote := Vector2(cos(angle) * (18.0 + float(mote_index % 3) * 5.0), -30.0 - float(mote_index % 4) * 13.0 + sin(angle) * 5.0)
		draw_rect(Rect2(mote - Vector2.ONE, Vector2(2, 2)), Color(1.0, 0.94, 0.62, alpha), true)


func _draw_charge_warning() -> void:
	var endpoint := to_local(examiner.judgment_charge_endpoint())
	var length := maxf(endpoint.length(), 48.0)
	var buildup := clampf(state_elapsed / state_duration, 0.0, 1.0)
	draw_set_transform(Vector2.ZERO, endpoint.angle())
	ExaminerEffectAtlas.danger_lane(self, Rect2(0, -22, length, 44), buildup)
	draw_set_transform(Vector2.ZERO)


func _draw_channel() -> void:
	var progress := clampf(state_elapsed / state_duration, 0, 1)
	var radius := 66.0 if examiner.is_berserk() else 53.0
	draw_set_transform(Vector2(0, -2), state_elapsed * 0.32)
	draw_texture_rect(CourtOfFirstMeasure.DescentCircle, Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2), false, Color(1, 0.82, 0.43, 0.45 + progress * 0.25))
	draw_set_transform(Vector2.ZERO)
	for index in 16:
		var phase := fmod(state_elapsed * 0.65 + index / 16.0, 1.0)
		var angle := index * 2.4
		var point := Vector2(cos(angle) * radius, sin(angle) * radius * 0.42 - phase * 65)
		draw_rect(Rect2(point, Vector2.ONE * 2), Color(1, 0.86, 0.4, 1.0 - phase))
	if state in [Examiner.State.ORB_CHARGE, Examiner.State.FIRMAMENT_CHARGE]:
		EnergyPresentation.charge(self, state_elapsed, state_duration, examiner.is_berserk(), state == Examiner.State.FIRMAMENT_CHARGE)


func _draw_slam_warning() -> void:
	ExaminerEffectAtlas.danger_circle(self, to_local(examiner.slam_hitbox.global_position), 72.0, clampf(state_elapsed / state_duration, 0, 1))


func _draw_descent_streak() -> void:
	draw_set_transform(Vector2(0, -90), PI * 0.5)
	ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Energy, ExaminerEffectAtlas.frame_at(state_elapsed, state_duration), Rect2(-100, -22, 200, 44))
	draw_set_transform(Vector2.ZERO)


func _spawn_afterimage() -> void:
	if body == null or body.sprite_frames == null:
		return
	var ghost := Sprite2D.new()
	ghost.texture = body.sprite_frames.get_frame_texture(body.animation, body.frame)
	ghost.centered = body.centered
	ghost.offset = body.offset
	ghost.global_position = body.global_position
	ghost.global_rotation = body.global_rotation
	ghost.scale = body.global_scale
	ghost.modulate = Color(1.0, 0.76, 0.22, 0.46)
	ghost.z_index = 7
	_effects_parent().add_child(ghost)
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.22)
	tween.tween_callback(ghost.queue_free)


func _effects_parent() -> Node2D:
	var effects := get_tree().get_first_node_in_group("boss_effects") as Node2D
	if effects != null:
		return effects
	return examiner.get_parent() as Node2D if examiner != null else self


func _request_camera_pulse(strength: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var current := get_tree().current_scene
	if current == null:
		return
	var feedback := current.find_child("CombatFeedback", true, false)
	if feedback != null and feedback.has_method("request_camera_pulse"):
		feedback.request_camera_pulse(strength)
