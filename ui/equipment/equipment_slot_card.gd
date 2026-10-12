class_name EquipmentSlotCard
extends PanelContainer

## Small reusable loadout slot. Empty slots are honest presentation, not items.

signal equipment_dropped(item: EquipmentDefinition)
signal equipment_inspected(item: EquipmentDefinition)

@onready var slot_icon: TextureRect = %SlotIcon
@onready var slot_label: Label = %SlotLabel
@onready var item_label: Label = %ItemLabel

var accepted_slot := EquipmentDefinition.Slot.WEAPON
var _item: EquipmentDefinition


func configure(
	slot_name: String,
	slot: EquipmentDefinition.Slot,
	item: EquipmentDefinition = null,
	empty_icon: Texture2D = null
) -> void:
	accepted_slot = slot
	_item = item
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if item != null else Control.CURSOR_ARROW
	slot_label.text = slot_name.to_upper()
	if item != null:
		slot_icon.texture = item.icon
		item_label.text = item.display_name.to_upper()
		item_label.add_theme_color_override("font_color", item.get_rarity_color())
		tooltip_text = "%s — %s\n%s" % [
			item.display_name,
			item.get_rarity_name(),
			item.get_stat_summary(),
		]
	else:
		slot_icon.texture = empty_icon
		item_label.text = "EMPTY"
		item_label.add_theme_color_override("font_color", Color("74806b"))
		tooltip_text = "%s slot — no item equipped" % slot_name.capitalize()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return (
		data is Dictionary
		and data.get("equipment") is EquipmentDefinition
		and (data.get("equipment") as EquipmentDefinition).slot == accepted_slot
	)


func _gui_input(event: InputEvent) -> void:
	if _item != null and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		equipment_inspected.emit(_item)
		accept_event()


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(Vector2.ZERO, data):
		equipment_dropped.emit(data["equipment"] as EquipmentDefinition)
