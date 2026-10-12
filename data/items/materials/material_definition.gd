class_name MaterialDefinition
extends Resource

## Immutable identity and presentation metadata for one crafting material.

enum MaterialFamily {
	VIAL,
	HIDE,
	FIBER_BUNDLE,
	PLATE_CHITIN,
	ORE_FITTING,
	SEED_CRYSTAL,
	CORE,
	RELIC,
	ORGANIC_TISSUE,
	HEARTWOOD,
}

enum MaterialRarity {
	COMMON,
	UNCOMMON,
	RARE,
	BOSS,
}

@export var material_id: StringName
@export var display_name := ""
@export_multiline var description := ""
@export var region_id: StringName
@export var material_family := MaterialFamily.ORGANIC_TISSUE
@export var rarity := MaterialRarity.COMMON
@export var icon: Texture2D
@export var crafting_tags := PackedStringArray()
@export_multiline var source_lore := ""
@export_group("Umi Exchange Metadata")
@export var source_enemy_id: StringName
@export var source_enemy_display_name := ""
@export_range(-1, 999999, 1) var sell_value_override := -1
@export_range(-1, 999999, 1) var meld_value_override := -1
@export_range(-1, 999999, 1) var transmutation_point_cost_override := -1
@export_range(-1, 999999, 1) var transmutation_gold_cost_override := -1
@export_range(-1, 9999, 1) var required_source_defeats_override := -1
@export_range(-1, 999, 1) var same_region_rare_catalysts_override := -1
@export var can_be_sold := true
@export var can_be_melded := true
@export var can_be_transmuted := true
@export_group("")


func is_valid() -> bool:
	if (
		material_id.is_empty()
		or display_name.strip_edges().is_empty()
		or description.strip_edges().is_empty()
		or region_id.is_empty()
		or material_family < MaterialFamily.VIAL
		or material_family > MaterialFamily.HEARTWOOD
		or rarity < MaterialRarity.COMMON
		or rarity > MaterialRarity.BOSS
		or (is_reconstruction_target() and source_enemy_id.is_empty())
	):
		return false
	var seen_tags := {}
	for raw_tag: String in crafting_tags:
		var tag := StringName(raw_tag.strip_edges())
		if tag.is_empty() or seen_tags.has(tag):
			return false
		seen_tags[tag] = true
	return true


func is_reconstruction_target() -> bool:
	## Common drops remain sellable/fuel resources; Umi exists to relieve
	## low-drop RNG rather than manufacture ordinary campaign materials.
	return can_be_transmuted and rarity >= MaterialRarity.UNCOMMON


func get_sell_value() -> int:
	if not can_be_sold:
		return 0
	if sell_value_override >= 0:
		return sell_value_override
	return [1, 5, 18, 0][rarity]


func get_meld_value() -> int:
	if not can_be_melded:
		return 0
	if meld_value_override >= 0:
		return meld_value_override
	return [1, 10, 35, 0][rarity]


func get_transmutation_point_cost() -> int:
	if transmutation_point_cost_override >= 0:
		return transmutation_point_cost_override
	return [25, 100, 400, 1500][rarity]


func get_transmutation_gold_cost() -> int:
	if transmutation_gold_cost_override >= 0:
		return transmutation_gold_cost_override
	return [10, 75, 200, 1000][rarity]


func get_required_source_defeats() -> int:
	if required_source_defeats_override >= 0:
		return required_source_defeats_override
	return [1, 10, 20, 10][rarity]


func get_same_region_rare_catalyst_count() -> int:
	if same_region_rare_catalysts_override >= 0:
		return same_region_rare_catalysts_override
	return 4 if rarity == MaterialRarity.BOSS else 0


func get_family_name() -> String:
	return MaterialFamily.keys()[material_family].capitalize().replace("_", " ")


func get_family_glyph() -> String:
	match material_family:
		MaterialFamily.VIAL:
			return "V"
		MaterialFamily.HIDE:
			return "H"
		MaterialFamily.FIBER_BUNDLE:
			return "F"
		MaterialFamily.PLATE_CHITIN:
			return "P"
		MaterialFamily.ORE_FITTING:
			return "O"
		MaterialFamily.SEED_CRYSTAL:
			return "S"
		MaterialFamily.CORE:
			return "C"
		MaterialFamily.RELIC:
			return "R"
		MaterialFamily.ORGANIC_TISSUE:
			return "T"
		MaterialFamily.HEARTWOOD:
			return "W"
	return "?"


func get_rarity_name() -> String:
	return MaterialRarity.keys()[rarity].capitalize()


func get_rarity_color() -> Color:
	match rarity:
		MaterialRarity.COMMON:
			return Color("87927f")
		MaterialRarity.UNCOMMON:
			return Color("81aa68")
		MaterialRarity.RARE:
			return Color("6ba3ce")
		MaterialRarity.BOSS:
			return Color("c58bd8")
	return Color.WHITE
