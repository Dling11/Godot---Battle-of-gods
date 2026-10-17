class_name EquipmentDetailPanel
extends PanelContainer

## Bounded inspection. Inventory/Player still own all acquisition and equips.
signal equip_requested(definition: EquipmentDefinition)
const Readout = preload("res://ui/equipment/equipment_inspection_readout.gd")
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
const IconPresenter = preload("res://ui/equipment/equipment_icon_presenter.gd")
@onready var aura_back: Panel = %AuraBack
@onready var item_icon: TextureRect = %ItemIcon
@onready var fallback_glyph: Label = %FallbackGlyph
@onready var rarity_label: Label = %RarityLabel
@onready var name_label: Label = %NameLabel
@onready var power_label: RichTextLabel = %PowerLabel
@onready var comparison_label: RichTextLabel = %ComparisonLabel
@onready var lore_label: Label = %LoreLabel
@onready var synergy_title: Label = %SynergyTitle
@onready var synergy_body: RichTextLabel = %SynergyBody
@onready var body_scroll: ScrollContainer = %BodyScroll
@onready var state_label: Label = %StateLabel
@onready var equip_button: Button = %EquipButton
var current_definition: EquipmentDefinition
var current_material_definition: MaterialDefinition
var _aura_tween: Tween

func _ready() -> void:
	for label: Label in [name_label,synergy_title]: label.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	for label: RichTextLabel in [power_label,comparison_label,synergy_body]:
		label.add_theme_font_override("normal_font",VeilStyle.BODY_FONT)
		label.add_theme_font_override("bold_font",VeilStyle.DISPLAY_FONT)
	item_icon.get_parent().resized.connect(_fit_icon)
	visibility_changed.connect(_refresh_aura_activity)

func configure_empty(message: String) -> void:
	current_definition = null
	current_material_definition = null
	_stop_aura()
	item_icon.hide()
	fallback_glyph.hide()
	rarity_label.text = "INVENTORY"
	name_label.text = message
	power_label.text = ""
	comparison_label.hide()
	lore_label.text = "Choose a category to browse your owned equipment and materials."
	synergy_title.text = ""
	synergy_body.text = "Select an item to inspect it."
	state_label.text = "No item selected"
	equip_button.hide()
	body_scroll.scroll_vertical = 0
	_apply_aura_style(Color("657185"))

func configure(item: EquipmentDefinition, equipped: bool, class_compatible: bool = true, comparison_item: EquipmentDefinition = null) -> void:
	current_definition = item
	current_material_definition = null
	_show_icon(item.icon, item.display_name.left(1))
	var color := item.get_rarity_color()
	rarity_label.text = "%s · %s" % [item.get_rarity_name(),item.weapon_definition.family_display_name if item.weapon_definition != null else item.get_slot_name().capitalize()]
	rarity_label.add_theme_color_override("font_color",color)
	name_label.text = item.display_name
	name_label.add_theme_color_override("font_color",color.lightened(.12))
	power_label.text = Readout.stats(item)
	power_label.tooltip_text = "Base weapon values before attack-speed gear, buffs, criticals, defenses or missed contacts. Skill power feeds King's abilities separately."
	comparison_label.show()
	comparison_label.text = Readout.comparison(item,comparison_item)
	lore_label.text = item.lore
	synergy_title.text = item.synergy_name
	synergy_title.add_theme_color_override("font_color",color.lightened(.18))
	synergy_body.text = Readout.mechanics(item)
	state_label.text = "Equipped" if equipped else ("Ready to equip" if class_compatible else "Class restricted")
	state_label.add_theme_color_override("font_color",VeilStyle.CYAN if equipped else Color("a5d0af") if class_compatible else Color("ed9693"))
	equip_button.show()
	equip_button.disabled = equipped or not class_compatible
	equip_button.text = "EQUIPPED" if equipped else "EQUIP ITEM" if class_compatible else "CLASS LOCKED"
	_apply_aura_style(color)
	body_scroll.scroll_vertical = 0
	_refresh_aura_activity()

func configure_material(item: MaterialDefinition, quantity: int) -> void:
	current_definition = null
	current_material_definition = item
	_show_icon(item.icon,item.get_family_glyph())
	var color := item.get_rarity_color()
	rarity_label.text = "%s · %s" % [item.get_rarity_name(),item.get_family_name()]
	rarity_label.add_theme_color_override("font_color",color)
	name_label.text = item.display_name
	name_label.add_theme_color_override("font_color",color.lightened(.12))
	power_label.text = "[color=#91d4ec]Crafting material[/color]   ×%s" % str(quantity)
	power_label.tooltip_text = ""
	comparison_label.hide()
	lore_label.text = item.description
	synergy_title.text = "Known source"
	synergy_title.add_theme_color_override("font_color",color)
	synergy_body.text = item.source_lore
	state_label.text = "Material pouch · no equipment space used"
	state_label.add_theme_color_override("font_color",Color("a5d0af"))
	equip_button.hide()
	_apply_aura_style(color)
	body_scroll.scroll_vertical = 0
	_refresh_aura_activity()

func _show_icon(texture: Texture2D, fallback: String) -> void:
	item_icon.texture = IconPresenter.texture(texture)
	item_icon.visible = texture != null
	fallback_glyph.visible = texture == null
	fallback_glyph.text = fallback.to_upper()
	_fit_icon.call_deferred()

func _fit_icon() -> void:
	if not is_instance_valid(item_icon) or item_icon.texture == null: return
	IconPresenter.fit(item_icon,Rect2((item_icon.get_parent().size-Vector2(72,72))*.5,Vector2(72,72)))

func _apply_aura_style(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color.darkened(.94)
	style.border_color = color.darkened(.12)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(color,.24)
	style.shadow_size = 8
	aura_back.add_theme_stylebox_override("panel",style)

func _refresh_aura_activity() -> void:
	_stop_aura()
	if not is_visible_in_tree() or (current_definition == null and current_material_definition == null): return
	var strong := current_definition != null and current_definition.get_rarity_rank() >= 4
	if not strong:
		aura_back.modulate.a = .72
		return
	_aura_tween = create_tween().set_loops()
	_aura_tween.tween_property(aura_back,"modulate:a",.95,.95).set_trans(Tween.TRANS_SINE)
	_aura_tween.tween_property(aura_back,"modulate:a",.5,1.25).set_trans(Tween.TRANS_SINE)

func _stop_aura() -> void:
	if is_instance_valid(_aura_tween): _aura_tween.kill()
	_aura_tween = null
	aura_back.modulate.a = .72

func _on_equip_button_pressed() -> void:
	if current_definition != null and not equip_button.disabled: equip_requested.emit(current_definition)
