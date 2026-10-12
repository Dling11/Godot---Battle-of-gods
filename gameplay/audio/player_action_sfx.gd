class_name PlayerActionSfx
extends Node2D

## Presents local player action sounds; combat components remain authoritative.

@export var sword_swing_player: AudioStreamPlayer2D
@export var dash_player: AudioStreamPlayer2D
@export var ability_component: AbilityComponent
@export var ability_2_component: AbilityComponent
@export var ability_3_component: AbilityComponent
@export var ability_4_component: AbilityComponent
@export var sovereign_pursuit_landing_player: AudioStreamPlayer2D
@export var sovereign_pursuit_launch_player: AudioStreamPlayer2D
@export var skill_4_formation_player: AudioStreamPlayer2D
@export var skill_4_first_impact_player: AudioStreamPlayer2D
@export var skill_4_explosion_player: AudioStreamPlayer2D
@export var action_denied_player: AudioStreamPlayer2D

func play_attack_phase(phase: int, _duration_seconds: float) -> void:
	var actor := get_parent() as Player
	if actor != null and actor.attack_component.weapon.combo != null:
		return # Greatsword presentation owns the three distinct weight cues.
	if phase == MeleeAttackComponent.Phase.ACTIVE:
		_play(sword_swing_player, 1.0)


func play_ability_phase(phase: int, _duration_seconds: float) -> void:
	var active_ability := _get_casting_ability()
	if active_ability is EarthsplitterComponent or active_ability is MoltenCrashComponent:
		return
	if _is_sovereign_pursuit(active_ability):
		if phase == AbilityComponent.Phase.ACTIVE:
			_play(sovereign_pursuit_launch_player, 1.0)
		return
	if _is_skill_4(active_ability):
		if phase == AbilityComponent.Phase.WIND_UP:
			_play(skill_4_formation_player, 0.96)
		return


func play_ability_strike(strike_index: int, strike_count: int, _duration_seconds: float) -> void:
	if _get_casting_ability() is EarthsplitterComponent or _get_casting_ability() is MoltenCrashComponent:
		return
	if _is_sovereign_pursuit(_get_casting_ability()):
		_play(sovereign_pursuit_landing_player, 1.0)
		return
	if _is_skill_4(_get_casting_ability()):
		_play(skill_4_explosion_player if strike_index >= strike_count - 1 else skill_4_first_impact_player, 0.96)
		return


func play_dash(_direction: Vector2) -> void:
	_play(dash_player, 0.96)


func play_action_denied(_action: StringName) -> void:
	_play(action_denied_player, 0.94)


func _play(player: AudioStreamPlayer2D, pitch: float, from_position_seconds: float = 0.0) -> void:
	if player == null or player.stream == null or DisplayServer.get_name() == "headless":
		return
	player.pitch_scale = pitch
	player.play(from_position_seconds)


func _get_casting_ability() -> AbilityComponent:
	for component in [ability_component, ability_2_component, ability_3_component, ability_4_component]:
		if component != null and component.is_casting():
			return component
	return null


func _is_sovereign_pursuit(component: AbilityComponent) -> bool:
	return component != null and component.definition != null and component.definition.ability_id == &"sovereign_pursuit"


func _is_skill_4(component: AbilityComponent) -> bool:
	return component != null and component.definition != null and component.definition.ability_id == &"king_skill_4"
