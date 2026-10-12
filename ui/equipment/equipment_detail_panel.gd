class_name EquipmentDetailPanel
extends PanelContainer

## Shared inspection surface for owned equipment and crafting materials.
## Equipment actions are forwarded to CharacterMenu; material inspection is
## read-only because MaterialInventory remains the ownership authority.

signal equip_requested(definition: EquipmentDefinition)

@onready var aura_back: Panel = %AuraBack
@onready var item_icon: TextureRect = %ItemIcon
@onready var fallback_glyph: Label = %FallbackGlyph
@onready var rarity_label: Label = %RarityLabel
@onready var name_label: Label = %NameLabel
@onready var power_label: Label = %PowerLabel
@onready var comparison_label: Label = %ComparisonLabel
@onready var lore_label: Label = %LoreLabel
@onready var synergy_title: Label = %SynergyTitle
@onready var synergy_body: Label = %SynergyBody
@onready var state_label: Label = %StateLabel
@onready var equip_button: Button = %EquipButton

var current_definition: EquipmentDefinition
var current_material_definition: MaterialDefinition
var _aura_tween: Tween

func configure_empty(message: String) -> void:
	current_definition = null
	current_material_definition = null
	if is_instance_valid(_aura_tween): _aura_tween.kill()
	item_icon.hide()
	fallback_glyph.hide()
	rarity_label.text = "INVENTORY"
	rarity_label.add_theme_color_override("font_color",Color("a3adbd"))
	name_label.text = message.to_upper()
	power_label.text = ""
	comparison_label.hide()
	lore_label.text = "Choose another category or clear the search to find an owned item."
	synergy_title.text = ""
	synergy_body.text = "Equipment can be inspected and equipped here. Materials stay in your separate pouch."
	state_label.text = "NO ITEM SELECTED"
	state_label.add_theme_color_override("font_color",Color("a3adbd"))
	_apply_aura_style(Color("657185"))
	equip_button.hide()


func configure(
	item: EquipmentDefinition,
	equipped: bool,
	class_compatible: bool = true,
	comparison_item: EquipmentDefinition = null
) -> void:
	current_definition = item
	current_material_definition = null
	var rarity_color := item.get_rarity_color()
	item_icon.texture = item.icon
	item_icon.visible = item.icon != null
	fallback_glyph.visible = item.icon == null
	fallback_glyph.text = item.display_name.left(1).to_upper()
	fallback_glyph.add_theme_color_override("font_color", rarity_color)
	rarity_label.text = "%s  •  %s" % [item.get_rarity_name(), item.get_slot_name().to_upper()]
	rarity_label.add_theme_color_override("font_color", rarity_color)
	name_label.text = item.display_name.to_upper()
	power_label.text = item.get_stat_summary()
	comparison_label.visible = true
	comparison_label.text = item.get_comparison_summary(comparison_item)
	comparison_label.add_theme_color_override(
		"font_color",
		Color("d6c171") if equipped else Color("8fca78")
	)
	lore_label.text = item.lore
	synergy_title.text = item.synergy_name.to_upper()
	synergy_title.add_theme_color_override("font_color", rarity_color)
	synergy_body.text = item.synergy_description
	if item.show_combo_details and item.weapon_definition != null:
		synergy_body.text += "\n" + WeaponCombatReadout.combo_description(item.weapon_definition)
		synergy_body.add_theme_font_size_override("font_size",8)
		power_label.tooltip_text = "Base roll is multiplied by each combo step. Base DPS is mean full-combo damage divided by wind-up + contact + recovery, per target. It excludes missed hits, defenses, criticals, buffs, hitstop and attack-speed gear. Skill Power feeds abilities separately."
	else:
		synergy_body.remove_theme_font_size_override("font_size")
		power_label.tooltip_text = ""
	# Only opted-in items receive a larger inspection; legacy families retain42px.
	var icon_edge := 64.0 if item.show_combo_details else 42.0
	item_icon.custom_minimum_size = Vector2.ONE * icon_edge
	item_icon.offset_left = -icon_edge * 0.5
	item_icon.offset_top = -icon_edge * 0.5
	item_icon.offset_right = icon_edge * 0.5
	item_icon.offset_bottom = icon_edge * 0.5
	item_icon.get_parent().custom_minimum_size.y = icon_edge
	state_label.text = (
		"EQUIPPED • ACTIVE EFFECTS APPLIED"
		if equipped
		else ("OWNED • READY TO EQUIP" if class_compatible else "OWNED • WRONG CLASS")
	)
	state_label.add_theme_color_override(
		"font_color",
		Color("d6c171") if equipped else (Color("9ab85d") if class_compatible else Color("c45b50"))
	)
	_apply_aura_style(rarity_color)
	_start_equipment_aura(item.rarity)
	equip_button.visible = true
	equip_button.disabled = equipped or not class_compatible
	equip_button.text = "EQUIPPED" if equipped else ("EQUIP ITEM" if class_compatible else "CLASS LOCKED")


func configure_material(item: MaterialDefinition, quantity: int) -> void:
	current_definition = null
	current_material_definition = item
	synergy_body.remove_theme_font_size_override("font_size")
	power_label.tooltip_text = ""
	var rarity_color := item.get_rarity_color()
	item_icon.texture = item.icon
	item_icon.custom_minimum_size = Vector2(42, 42)
	item_icon.offset_left = -21
	item_icon.offset_top = -21
	item_icon.offset_right = 21
	item_icon.offset_bottom = 21
	item_icon.get_parent().custom_minimum_size.y = 42
	item_icon.visible = item.icon != null
	fallback_glyph.visible = item.icon == null
	fallback_glyph.text = item.get_family_glyph()
	fallback_glyph.add_theme_color_override("font_color", rarity_color)
	rarity_label.text = "%s  •  %s" % [
		item.get_rarity_name().to_upper(),
		item.get_family_name().to_upper(),
	]
	rarity_label.add_theme_color_override("font_color", rarity_color)
	name_label.text = item.display_name.to_upper()
	power_label.text = "CRAFTING MATERIAL  ×%d" % quantity
	comparison_label.visible = false
	lore_label.text = item.description
	synergy_title.text = "KNOWN SOURCE"
	synergy_title.add_theme_color_override("font_color", rarity_color)
	synergy_body.text = item.source_lore
	state_label.text = "MATERIAL POUCH • NO BAG SPACE USED"
	state_label.add_theme_color_override("font_color", Color("8fb37b"))
	_apply_aura_style(rarity_color)
	_start_material_aura(item.rarity)
	equip_button.visible = false


func _on_equip_button_pressed() -> void:
	if current_definition != null and not equip_button.disabled:
		equip_requested.emit(current_definition)


func _apply_aura_style(color: Color) -> void:
	var aura_style := StyleBoxFlat.new()
	aura_style.bg_color = color.darkened(0.82)
	aura_style.border_color = color
	aura_style.set_border_width_all(2)
	aura_style.set_corner_radius_all(5)
	aura_back.add_theme_stylebox_override("panel", aura_style)


func _start_equipment_aura(rarity: EquipmentDefinition.Rarity) -> void:
	var is_high_rarity := rarity in [
		EquipmentDefinition.Rarity.LEGENDARY,
		EquipmentDefinition.Rarity.MYTHIC,
	]
	_start_aura(0.9 if is_high_rarity else 0.58, 1.075 if is_high_rarity else 1.035)


func _start_material_aura(rarity: MaterialDefinition.MaterialRarity) -> void:
	var is_high_rarity := rarity >= MaterialDefinition.MaterialRarity.RARE
	_start_aura(0.82 if is_high_rarity else 0.52, 1.055 if is_high_rarity else 1.025)


func _start_aura(maximum_alpha: float, scale_amount: float) -> void:
	if _aura_tween != null:
		_aura_tween.kill()
	aura_back.scale = Vector2.ONE
	aura_back.modulate.a = maximum_alpha
	_aura_tween = create_tween().set_loops()
	_aura_tween.tween_property(aura_back, "scale", Vector2.ONE * scale_amount, 0.9).set_trans(Tween.TRANS_SINE)
	_aura_tween.parallel().tween_property(aura_back, "modulate:a", 0.25, 0.9).set_trans(Tween.TRANS_SINE)
	_aura_tween.tween_property(aura_back, "scale", Vector2.ONE, 1.1).set_trans(Tween.TRANS_SINE)
	_aura_tween.parallel().tween_property(aura_back, "modulate:a", maximum_alpha, 1.1).set_trans(Tween.TRANS_SINE)
