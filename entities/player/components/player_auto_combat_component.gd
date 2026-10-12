class_name PlayerAutoCombatComponent
extends Node

## Optional player-authorized automation. It reuses normal targeting, attack,
## ability, cooldown, and navigation authority rather than dealing damage itself.

signal mode_changed(auto_farm_enabled: bool, auto_skills_enabled: bool)

@export var player: Player
@export var targeting_component: PlayerCombatTargetingComponent
@export_range(0.1, 1.0, 0.05, "suffix:s") var skill_check_interval := 0.25

var auto_farm_enabled := false
var auto_skills_enabled := false
var _skill_check_remaining := 0.0


func update_auto_combat(delta: float) -> void:
	if not auto_farm_enabled or player == null or player.is_defeated or player.is_restrained():
		return
	if not targeting_component.has_valid_target():
		targeting_component.engage_next_roster_target()
	if not auto_skills_enabled or not targeting_component.has_valid_target():
		return
	_skill_check_remaining = maxf(_skill_check_remaining - delta, 0.0)
	if _skill_check_remaining > 0.0:
		return
	_skill_check_remaining = skill_check_interval
	_try_ready_skill()


func set_auto_farm_enabled(enabled: bool) -> void:
	if auto_farm_enabled == enabled and (enabled or not auto_skills_enabled):
		return
	auto_farm_enabled = enabled
	if not enabled:
		auto_skills_enabled = false
		targeting_component.suspend_auto_attack()
	else:
		targeting_component.engage_next_roster_target()
	_skill_check_remaining = 0.0
	mode_changed.emit(auto_farm_enabled, auto_skills_enabled)


func set_auto_skills_enabled(enabled: bool) -> void:
	if enabled and not auto_farm_enabled:
		auto_farm_enabled = true
	if auto_skills_enabled == enabled:
		mode_changed.emit(auto_farm_enabled, auto_skills_enabled)
		return
	auto_skills_enabled = enabled
	_skill_check_remaining = 0.0
	mode_changed.emit(auto_farm_enabled, auto_skills_enabled)


func _try_ready_skill() -> bool:
	if (
		player.attack_component.phase != MeleeAttackComponent.Phase.IDLE
		or player.evade_component.is_dashing()
		or player.is_any_ability_casting()
		or player.is_targeting_any_ability()
		or not targeting_component.is_target_in_attack_range()
	):
		return false
	var target_position := targeting_component.target_actor.global_position
	var target_direction := target_position - player.global_position
	for slot_number in range(1, SkillLoadoutDefinition.SLOT_COUNT + 1):
		var component := player.get_ability_component_for_slot(slot_number)
		if component == null or component.definition == null or not component.is_ready():
			continue
		# Pursuit is King's manual mobility choice, not a routine auto-cast.
		if component == player.ability_3_component:
			continue
		if not player.request_ability(slot_number):
			continue
		match component.definition.activation_mode:
			AbilityDefinition.ActivationMode.DIRECTIONAL_WEDGE_TARGETED:
				player.directional_wedge_targeting.update_aim(target_direction, Vector2.ZERO)
				player.directional_wedge_targeting.confirm_targeting()
			AbilityDefinition.ActivationMode.GROUND_TARGETED:
				player.ground_point_targeting.update_aim(target_position, Vector2.ZERO)
				player.ground_point_targeting.confirm_targeting()
		return true
	return false
