class_name SkillLoadoutDefinition
extends Resource

## Ordered skill-slot configuration shared by gameplay and presentation.

const SLOT_COUNT := 10
@export var slots: Array[Resource] = []


func get_slot(slot_number: int) -> SkillSlotDefinition:
	for resource: Resource in slots:
		var slot := resource as SkillSlotDefinition
		if slot != null and slot.slot_number == slot_number:
			return slot
	return null


func get_ordered_slots() -> Array[SkillSlotDefinition]:
	var ordered: Array[SkillSlotDefinition] = []
	for slot_number in range(1, SLOT_COUNT + 1):
		var slot := get_slot(slot_number)
		if slot != null:
			ordered.append(slot)
	return ordered


func has_complete_layout() -> bool:
	return get_ordered_slots().size() == SLOT_COUNT
