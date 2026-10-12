class_name SkillSlotDefinition
extends Resource

## Immutable presentation and input metadata for one equipped-skill slot.

@export_range(1, 10, 1) var slot_number := 1
@export var input_action: StringName = &"player_skill_1"
@export var ability: AbilityDefinition
@export var locked_icon: Texture2D
@export var locked_title := "Sealed Path"
@export_multiline var locked_description := "Ability not yet awakened."
@export var unlock_hint := "AWAKENING UNKNOWN"


func is_equipped() -> bool:
	return ability != null


func get_key_label() -> String:
	return str(slot_number % 10)


func get_display_name() -> String:
	return ability.display_name if is_equipped() else locked_title


func get_description() -> String:
	return ability.get_description_with_damage_type() if is_equipped() else locked_description


func get_icon() -> Texture2D:
	return ability.icon if is_equipped() else locked_icon


func get_status_text() -> String:
	return "EQUIPPED" if is_equipped() else unlock_hint
