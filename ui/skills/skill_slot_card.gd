class_name SkillSlotCard
extends Button

## Reusable, focusable character-menu presentation for one skill slot.

signal slot_selected(definition: SkillSlotDefinition)

var slot_definition: SkillSlotDefinition


func _ready() -> void:
	pressed.connect(_on_pressed)


func configure(definition: SkillSlotDefinition) -> void:
	disabled = false
	slot_definition = definition
	name = "Skill%d" % definition.slot_number
	icon = definition.get_icon()
	text = "[%s]  %s\n%s" % [
		definition.get_key_label(),
		definition.get_display_name().to_upper(),
		definition.get_status_text(),
	]
	tooltip_text = "%s — %s\n%s" % [
		definition.get_display_name(),
		definition.get_status_text(),
		definition.get_description(),
	]
	modulate = Color.WHITE if definition.is_equipped() else Color(0.66, 0.66, 0.72, 0.9)


func configure_locked_preview(
	card_name: String,
	display_name: String,
	description: String
) -> void:
	name = card_name
	slot_definition = null
	disabled = true
	icon = preload("res://assets/ui/icons/states/icon_slot_locked_16x16.png")
	text = "[LOCKED]  %s\nFUTURE TIER" % display_name.to_upper()
	tooltip_text = "%s — LOCKED\n%s" % [display_name, description]
	add_theme_color_override("font_disabled_color", Color(0.58, 0.58, 0.68, 1.0))
	add_theme_color_override("icon_disabled_color", Color(0.58, 0.58, 0.68, 1.0))
	modulate = Color.WHITE


func _on_pressed() -> void:
	if slot_definition != null:
		slot_selected.emit(slot_definition)
