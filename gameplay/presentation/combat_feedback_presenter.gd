class_name CombatFeedbackPresenter
extends Node

## Presents accepted hits without owning combat state, damage, or timing.

const PLAYER_HIT_TINT := Color("ece5d5")
const MAGIC_HIT_TINT := Color("83c9f4")
const PURE_HIT_TINT := Color("ded1ff")
const CRITICAL_BURST = preload("res://gameplay/presentation/critical_hit_burst.gd")
const CRITICAL_HIT_TINT := Color(1.0, 0.28, 0.30, 1.0)
const PLAYER_DAMAGED_TINT := Color(1.0, 0.42, 0.42, 1.0)
const HIT_FLASH_SHADER := preload("res://gameplay/presentation/hit_flash.gdshader")
const HIT_FLASH_SECONDS := 0.1
const LIGHT_HITSTOP_SECONDS := 0.024
const MEDIUM_HITSTOP_SECONDS := 0.03
const HEAVY_HITSTOP_SECONDS := 0.045
const DEVASTATING_HITSTOP_SECONDS := 0.065

@export var player: Player
@export var effects_parent: Node2D
@export var camera: Camera2D
@export var damage_number_scene: PackedScene
@export var hit_burst_scene: PackedScene
@export var sword_hit_sound: AudioStream
@export var ability_hit_sound: AudioStream
@export var player_hurt_sound: AudioStream
## Opt out for isolated motion reviews; production keeps its current hitstop.
@export var hitstop_enabled := true

var _camera_base_offset := Vector2.ZERO
var _camera_tween: Tween
var _hitstop_active := false
var _melee_shared_feedback_consumed := false
var _last_ability_impact_physics_frame := -1
var _weapon_impact_index := 0
var _hit_flash_material: ShaderMaterial


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player == null or effects_parent == null or camera == null:
		push_error("CombatFeedbackPresenter requires player, effects parent, and camera references.")
		return
	if damage_number_scene == null or hit_burst_scene == null:
		push_error("CombatFeedbackPresenter requires damage-number and hit-burst scenes.")
		return
	_camera_base_offset = camera.offset
	add_to_group(&"combat_feedback")
	_hit_flash_material = ShaderMaterial.new()
	_hit_flash_material.shader = HIT_FLASH_SHADER
	_hit_flash_material.set_shader_parameter("flash_amount", 1.0)
	player.attack_component.hit_landed.connect(_on_player_hit_landed)
	player.attack_component.attack_started.connect(_on_player_attack_started)
	for ability in player.get_all_ability_components():
		ability.hit_landed.connect(_on_player_ability_hit_landed.bind(ability))
	player.health_component.damaged.connect(_on_player_damaged)


static func find_for_player(actor: Player) -> CombatFeedbackPresenter:
	if not is_instance_valid(actor) or not actor.is_inside_tree():
		return null
	for candidate: Node in actor.get_tree().get_nodes_in_group(&"combat_feedback"):
		if candidate is CombatFeedbackPresenter and candidate.player == actor:
			return candidate
	return null


func _on_player_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	var owns_shared_feedback := not _melee_shared_feedback_consumed
	_melee_shared_feedback_consumed = true
	_show_hit(
		target.global_position + Vector2(0.0, -22.0),
		info,
		PLAYER_HIT_TINT,
		1.5 if owns_shared_feedback else 0.0
	)
	_flash_target(target)
	if owns_shared_feedback:
		_request_hitstop(_resolve_basic_hitstop(info.amount))
		_play_basic_impact(target.global_position)


func _play_basic_impact(position: Vector2) -> void:
	var attack := player.attack_component
	var audio := attack.weapon.get_hit_audio_for_step(attack.combo_step)
	if audio == null or audio.variations.is_empty():
		_play_sound_at(sword_hit_sound, position, 1.0)
		return
	_play_sound_at(audio.stream_for(_weapon_impact_index), position, audio.pitch_for(_weapon_impact_index), 0.0, audio.volume_db)
	_weapon_impact_index += 1


func _resolve_basic_hitstop(accepted_damage: float) -> float:
	## Basic attacks feel heavier as their accepted damage rises, but remain well
	## below ability tiers. This is presentation only and cannot reset enemy AI.
	return clampf(0.018 + accepted_damage * 0.0008, LIGHT_HITSTOP_SECONDS, 0.034)


func _on_player_attack_started() -> void:
	## A broad cleave keeps local feedback on every struck target, while camera,
	## hitstop, and impact audio run once for the complete swing. This prevents a
	## clustered contact from feeling like several frame stalls stacked together.
	_melee_shared_feedback_consumed = false


func _on_player_ability_hit_landed(
	target: HurtboxComponent,
	info: DamageInfo,
	active_ability: AbilityComponent
) -> void:
	## A travelling wave lands across multiple ticks. Its authored sequence owns
	## bounded shared impacts; per-target global pauses would freeze that travel.
	var owns_sequence_feedback := active_ability != null and active_ability.owns_contact_feedback()
	var is_first_impact_this_frame := not owns_sequence_feedback and Engine.get_physics_frames() != _last_ability_impact_physics_frame
	if is_first_impact_this_frame:
		_last_ability_impact_physics_frame = Engine.get_physics_frames()
	_show_hit(
		target.global_position + Vector2(0.0, -22.0),
		info,
		PLAYER_HIT_TINT,
		2.5 if is_first_impact_this_frame else 0.0
	)
	_flash_target(target)
	if is_first_impact_this_frame:
		_request_hitstop(_resolve_ability_hitstop(active_ability))
		_play_sound_at(ability_hit_sound if ability_hit_sound != null else sword_hit_sound, target.global_position, 0.96)


func _resolve_ability_hitstop(component: AbilityComponent) -> float:
	if component == null or component.definition == null:
		return MEDIUM_HITSTOP_SECONDS
	if (
		component.definition.ability_id == &"king_skill_4"
		and component.is_current_strike_final()
	):
		return DEVASTATING_HITSTOP_SECONDS
	match component.definition.impact_weight:
		AbilityDefinition.ImpactWeight.LIGHT:
			return LIGHT_HITSTOP_SECONDS
		AbilityDefinition.ImpactWeight.HEAVY:
			return HEAVY_HITSTOP_SECONDS
		AbilityDefinition.ImpactWeight.DEVASTATING:
			return DEVASTATING_HITSTOP_SECONDS
	return MEDIUM_HITSTOP_SECONDS


func _on_player_damaged(info: DamageInfo) -> void:
	_show_hit(player.global_position + Vector2(0.0, -26.0), info, PLAYER_DAMAGED_TINT, 2.0)
	_request_hitstop(_resolve_incoming_hitstop(info.amount))
	_play_sound_at(player_hurt_sound, player.global_position, 1.0)


func _resolve_incoming_hitstop(damage_amount: float) -> float:
	## Incoming enemy definitions currently span 8-22 damage. Keep ordinary
	## contacts brief, let heavy enemies read clearly, and reserve the longest
	## tier for future boss-scale blows without coupling feedback to enemy types.
	if damage_amount >= 30.0:
		return DEVASTATING_HITSTOP_SECONDS
	if damage_amount >= 18.0:
		return HEAVY_HITSTOP_SECONDS
	if damage_amount >= 12.0:
		return MEDIUM_HITSTOP_SECONDS
	return LIGHT_HITSTOP_SECONDS


func _show_hit(position: Vector2, info: DamageInfo, tint: Color, camera_strength: float) -> void:
	var resolved_tint := CRITICAL_HIT_TINT if info.is_critical else tint
	if not info.is_critical and tint != PLAYER_DAMAGED_TINT:
		if info.damage_type == DamageInfo.DamageType.MAGIC: resolved_tint = MAGIC_HIT_TINT
		elif info.damage_type == DamageInfo.DamageType.PURE: resolved_tint = PURE_HIT_TINT
	var number := damage_number_scene.instantiate() as DamageNumber
	number.global_position = position
	number.configure(
		info.amount,
		resolved_tint,
		24.0 if info.is_critical else 18.0,
		info.is_critical
	)
	effects_parent.add_child(number)

	var burst: HitBurst = CRITICAL_BURST.new() if info.is_critical else hit_burst_scene.instantiate()
	burst.global_position = position + info.direction * 3.0
	burst.configure(info.direction, resolved_tint)
	effects_parent.add_child(burst)
	if camera_strength > 0.0:
		_pulse_camera(camera_strength)


func _pulse_camera(strength: float) -> void:
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	camera.offset = _camera_base_offset
	_camera_tween = create_tween()
	_camera_tween.tween_property(camera, "offset", _camera_base_offset + Vector2(strength, 0.0), 0.025)
	_camera_tween.tween_property(camera, "offset", _camera_base_offset + Vector2(-strength, 0.0), 0.04)
	_camera_tween.tween_property(camera, "offset", _camera_base_offset, 0.045)


func request_camera_pulse(strength: float) -> void:
	## Shared presentation entry point for authored world impacts. Keeping the
	## active tween here prevents independent enemies from fighting camera offset.
	if camera == null or DisplayServer.get_name() == "headless":
		return
	_pulse_camera(maxf(strength, 0.0))


func _flash_target(target: HurtboxComponent) -> void:
	var actor := target.get_parent()
	if actor == null:
		return
	var body := actor.find_child("Body", true, false) as CanvasItem
	if body == null:
		return
	var original_material := body.material
	body.material = _hit_flash_material
	var timer := get_tree().create_timer(HIT_FLASH_SECONDS, true, false, true)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(body) and body.material == _hit_flash_material:
			body.material = original_material
	)


func _request_hitstop(duration_seconds: float) -> void:
	if not hitstop_enabled: return
	if _hitstop_active or get_tree().paused:
		return
	_hitstop_active = true
	get_tree().paused = true
	var timer := get_tree().create_timer(maxf(duration_seconds, 0.001), true, false, true)
	timer.timeout.connect(_finish_hitstop)


func _finish_hitstop() -> void:
	if not _hitstop_active:
		return
	_hitstop_active = false
	get_tree().paused = false


func _play_sound_at(
	stream: AudioStream,
	position: Vector2,
	pitch: float,
	from_position_seconds: float = 0.0,
	volume_db: float = 0.0
) -> void:
	if stream == null or DisplayServer.get_name() == "headless":
		return
	var player_2d := AudioStreamPlayer2D.new()
	player_2d.stream = stream
	player_2d.bus = AudioDirector.SFX_BUS
	player_2d.pitch_scale = pitch
	player_2d.volume_db = volume_db
	effects_parent.add_child(player_2d)
	player_2d.global_position = position
	player_2d.finished.connect(player_2d.queue_free)
	player_2d.play(from_position_seconds)
