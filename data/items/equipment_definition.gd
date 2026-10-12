class_name EquipmentDefinition
extends Resource

## Immutable identity, ownership, compatibility, and presentation contract for
## one equipment item. Weapon combat authority remains in WeaponDefinition.

enum Slot {
	WEAPON,
	HEAD,
	PLATE,
	GLOVES,
	LEGGINGS,
	BOOTS,
	BRACER,
	AMULET,
	RING,
	TALISMAN,
}

enum Rarity {
	A_GRADE = 0,
	S_GRADE = 1,
	LEGENDARY = 2,
	MYTHIC = 3,
	WOOD = 4,
	STONE = 5,
	IRON = 6,
	RARE = 7,
}

@export var item_id: StringName
@export var display_name := "Equipment"
@export var slot := Slot.WEAPON
@export var rarity := Rarity.A_GRADE
@export var icon: Texture2D
## Opt-in closure pass; unselected families retain their existing Bag display.
@export var show_combo_details := false
@export var compatible_classes: PackedStringArray = []
@export_range(0, 9999, 1, "suffix: coins") var purchase_price := 0
@export var weapon_definition: WeaponDefinition
@export_range(0, 999, 1) var preview_power := 0
@export_range(0.0, 9999.0, 1.0) var flat_health_bonus := 0.0
@export_range(0.0, 9999.0, 1.0) var armor_bonus := 0.0
@export_range(0.0, 9999.0, 1.0) var magic_resistance_bonus := 0.0
@export_range(0.0, 99.0, 0.05, "suffix:/s") var regeneration_bonus := 0.0
@export_range(0.0, 0.75, 0.01, "suffix:%") var ward_reduction_ratio := 0.0
@export_range(0.0, 2.0, 0.01, "suffix:%") var attack_speed_bonus_ratio := 0.0
@export_range(0.0, 2.0, 0.01, "suffix:%") var movement_speed_bonus_ratio := 0.0
@export_multiline var lore := ""
@export var synergy_name := "Skill Synergy"
@export_multiline var synergy_description := ""


func get_slot_name() -> String:
	return Slot.keys()[slot].capitalize()


func get_rarity_name() -> String:
	match rarity:
		Rarity.A_GRADE:
			return "A GRADE"
		Rarity.S_GRADE:
			return "S GRADE"
		Rarity.LEGENDARY:
			return "LEGENDARY"
		Rarity.MYTHIC:
			return "MYTHIC"
		Rarity.WOOD:
			return "WOOD"
		Rarity.STONE:
			return "STONEBOUND"
		Rarity.IRON:
			return "IRON"
		Rarity.RARE:
			return "RARE"
	return "UNKNOWN"


func get_rarity_color() -> Color:
	match rarity:
		Rarity.A_GRADE:
			return Color("66a4d8")
		Rarity.S_GRADE:
			return Color("9b71d0")
		Rarity.LEGENDARY:
			return Color("d6c171")
		Rarity.MYTHIC:
			return Color("f0e5d2")
		Rarity.WOOD:
			return Color("b97a36")
		Rarity.STONE:
			return Color("858b86")
		Rarity.IRON:
			return Color("b5bdc2")
		Rarity.RARE:
			return Color("66a4d8")
	return Color.WHITE


func get_stat_summary() -> String:
	if weapon_definition != null:
		if show_combo_details:
			return WeaponCombatReadout.summary(weapon_definition)
		var weapon_summary := "BASIC HIT %d-%d  •  SKILL POWER %d" % [
			roundi(weapon_definition.basic_damage_minimum),
			roundi(weapon_definition.basic_damage_maximum),
			roundi(weapon_definition.damage),
		]
		if weapon_definition.critical_chance_ratio > 0.0:
			weapon_summary += "  •  CRIT %d%%" % roundi(
				weapon_definition.critical_chance_ratio * 100.0
			)
		return weapon_summary+"  •  "+DamageInfo.type_name(weapon_definition.damage_type)
	var parts := PackedStringArray()
	if flat_health_bonus > 0.0:
		parts.append("HP +%d" % roundi(flat_health_bonus))
	if armor_bonus > 0.0:
		parts.append("ARMOR +%d" % roundi(armor_bonus))
	if magic_resistance_bonus > 0.0:
		parts.append("MAGIC RESIST +%d" % roundi(magic_resistance_bonus))
	if regeneration_bonus > 0.0:
		parts.append("REGEN +%.2f/s" % regeneration_bonus)
	if ward_reduction_ratio > 0.0:
		parts.append("WARD +%d%%" % roundi(ward_reduction_ratio * 100.0))
	if attack_speed_bonus_ratio > 0.0:
		parts.append("ATTACK SPEED +%d%%" % roundi(attack_speed_bonus_ratio * 100.0))
	if movement_speed_bonus_ratio > 0.0:
		parts.append("MOVE SPEED +%d%%" % roundi(movement_speed_bonus_ratio * 100.0))
	return "  •  ".join(parts) if not parts.is_empty() else "NO ACTIVE STATS"


func get_comparison_summary(reference: EquipmentDefinition) -> String:
	if reference == self:
		return "CURRENTLY EQUIPPED"
	var parts := PackedStringArray()
	if weapon_definition != null:
		var reference_weapon := reference.weapon_definition if reference != null else null
		var reference_minimum := reference_weapon.basic_damage_minimum if reference_weapon != null else 0.0
		var reference_maximum := reference_weapon.basic_damage_maximum if reference_weapon != null else 0.0
		var reference_skill_power := reference_weapon.damage if reference_weapon != null else 0.0
		var reference_critical := reference_weapon.critical_chance_ratio if reference_weapon != null else 0.0
		_append_signed_stat(parts, weapon_definition.basic_damage_minimum - reference_minimum, "MIN HIT")
		_append_signed_stat(parts, weapon_definition.basic_damage_maximum - reference_maximum, "MAX HIT")
		_append_signed_stat(parts, weapon_definition.damage - reference_skill_power, "SKILL POWER")
		_append_signed_percent(
			parts,
			weapon_definition.critical_chance_ratio - reference_critical,
			"CRIT"
		)
	else:
		_append_signed_stat(parts, flat_health_bonus - _reference_stat(reference, "flat_health_bonus"), "HP")
		_append_signed_stat(parts, armor_bonus - _reference_stat(reference, "armor_bonus"), "ARMOR")
		_append_signed_stat(parts, magic_resistance_bonus - _reference_stat(reference, "magic_resistance_bonus"), "MAGIC RESIST")
		_append_signed_stat(
			parts,
			regeneration_bonus - _reference_stat(reference, "regeneration_bonus"),
			"REGEN/S"
		)
		_append_signed_percent(
			parts,
			attack_speed_bonus_ratio - _reference_stat(reference, "attack_speed_bonus_ratio"),
			"ATTACK SPEED"
		)
		_append_signed_percent(
			parts,
			movement_speed_bonus_ratio - _reference_stat(reference, "movement_speed_bonus_ratio"),
			"MOVE SPEED"
		)
	return "  •  ".join(parts) if not parts.is_empty() else "NO STAT CHANGE"


func _reference_stat(reference: EquipmentDefinition, property_name: StringName) -> float:
	return float(reference.get(property_name)) if reference != null else 0.0


func _append_signed_stat(parts: PackedStringArray, difference: float, label: String) -> void:
	if is_zero_approx(difference):
		return
	parts.append("%+d %s" % [roundi(difference), label])


func _append_signed_percent(parts: PackedStringArray, difference: float, label: String) -> void:
	if is_zero_approx(difference):
		return
	parts.append("%+d%% %s" % [roundi(difference * 100.0), label])


func is_compatible_with(character_class_id: StringName) -> bool:
	return compatible_classes.has(String(character_class_id))


func get_class_requirement_text() -> String:
	if compatible_classes.is_empty():
		return "NO CLASS"
	var labels: PackedStringArray = []
	for class_id in compatible_classes:
		labels.append(class_id.capitalize())
	return " / ".join(labels)


func is_equippable_weapon() -> bool:
	return (
		is_valid_definition()
		and slot == Slot.WEAPON
		and not compatible_classes.is_empty()
		and weapon_definition != null
		and weapon_definition.weapon_id == item_id
		and (
			weapon_definition.world_texture != null
			or weapon_definition.uses_integrated_visual
		)
	)


func is_equippable_gear() -> bool:
	return (
		is_valid_definition()
		and slot != Slot.WEAPON
		and not compatible_classes.is_empty()
		and weapon_definition == null
	)


func is_valid_definition() -> bool:
	return not item_id.is_empty() and not display_name.is_empty() and icon != null
