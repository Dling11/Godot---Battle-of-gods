class_name InventorySlotButton
extends Button

## Compact focusable slot used by the Character & Bag grid. It presents
## authoritative ownership data but never mutates inventory state itself.

enum Kind {
	EMPTY,
	EQUIPMENT,
	MATERIAL,
}

signal equipment_selected(definition: EquipmentDefinition)
signal material_selected(definition: MaterialDefinition)

@onready var item_icon: TextureRect = %ItemIcon
@onready var fallback_glyph: Label = %FallbackGlyph
@onready var quantity_label: Label = %QuantityLabel
@onready var state_label: Label = %StateLabel

var kind := Kind.EMPTY
var equipment_definition: EquipmentDefinition
var material_definition: MaterialDefinition
var quantity := 0


func _ready() -> void:
	pressed.connect(_on_pressed)


func configure_equipment(
	item: EquipmentDefinition,
	equipped: bool,
	class_compatible: bool = true
) -> void:
	_reset_content()
	kind = Kind.EQUIPMENT
	equipment_definition = item
	name = String(item.item_id)
	disabled = false
	item_icon.texture = item.icon
	item_icon.visible = item.icon != null
	fallback_glyph.visible = item.icon == null
	fallback_glyph.text = item.display_name.left(1).to_upper()
	state_label.visible = equipped or not class_compatible
	state_label.text = "E" if equipped else "!"
	state_label.add_theme_color_override(
		"font_color",
		Color("e6ce73") if equipped else Color("d06459")
	)
	tooltip_text = "%s\n%s • %s\n%s" % [
		item.display_name,
		item.get_rarity_name(),
		"EQUIPPED" if equipped else (
			"READY TO EQUIP" if class_compatible else "CLASS LOCKED"
		),
		item.get_stat_summary(),
	]
	_apply_slot_style(item.get_rarity_color(), equipped)


func configure_material(item: MaterialDefinition, owned_quantity: int) -> void:
	_reset_content()
	kind = Kind.MATERIAL
	material_definition = item
	quantity = owned_quantity
	name = String(item.material_id)
	disabled = false
	item_icon.texture = item.icon
	item_icon.visible = item.icon != null
	fallback_glyph.visible = item.icon == null
	fallback_glyph.text = item.get_family_glyph()
	fallback_glyph.add_theme_color_override("font_color", item.get_rarity_color())
	quantity_label.visible = true
	quantity_label.text = "MAX" if owned_quantity >= 9999 else "×%d" % owned_quantity
	tooltip_text = "%s\n%s • %s\nOWNED %d\n%s" % [
		item.display_name,
		item.get_rarity_name(),
		item.get_family_name(),
		owned_quantity,
		item.description,
	]
	_apply_slot_style(item.get_rarity_color(), false)


func configure_empty() -> void:
	_reset_content()
	kind = Kind.EMPTY
	disabled = true
	focus_mode = Control.FOCUS_NONE
	tooltip_text = "Empty bag slot"
	_apply_slot_style(Color("343b46"), false, true)


func _reset_content() -> void:
	kind = Kind.EMPTY
	equipment_definition = null
	material_definition = null
	quantity = 0
	disabled = false
	focus_mode = Control.FOCUS_ALL
	button_pressed = false
	item_icon.texture = null
	item_icon.visible = false
	fallback_glyph.text = ""
	fallback_glyph.visible = false
	fallback_glyph.remove_theme_color_override("font_color")
	quantity_label.text = ""
	quantity_label.visible = false
	state_label.text = ""
	state_label.visible = false


func _apply_slot_style(color: Color, selected_item: bool, empty := false) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("090e16") if not empty else Color("080c12")
	normal.border_color = color.darkened(0.48) if not empty else color.darkened(0.25)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = color.darkened(0.82)
	hover.border_color = color.lightened(0.12)
	var pressed_style := normal.duplicate() as StyleBoxFlat
	pressed_style.bg_color = color.darkened(0.72)
	pressed_style.border_color = Color("e6ce73") if selected_item else color.lightened(0.2)
	pressed_style.set_border_width_all(2)
	var focus := pressed_style.duplicate() as StyleBoxFlat
	focus.border_color = Color("d9c9f4")
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", focus)
	add_theme_stylebox_override("disabled", normal)


func _on_pressed() -> void:
	match kind:
		Kind.EQUIPMENT:
			equipment_selected.emit(equipment_definition)
		Kind.MATERIAL:
			material_selected.emit(material_definition)


func _get_drag_data(at_position: Vector2) -> Variant:
	if kind != Kind.EQUIPMENT or equipment_definition == null:
		return null
	set_drag_preview(_create_drag_preview(at_position))
	return {"equipment": equipment_definition}


func _create_drag_preview(at_position: Vector2) -> TextureRect:
	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(48, 48)
	preview.size = Vector2(48, 48)
	preview.position = -at_position.clamp(Vector2.ZERO, size)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.texture = equipment_definition.icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return preview
