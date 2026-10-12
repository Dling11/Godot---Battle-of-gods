extends Node2D

## Optional NPC identity presentation. Interaction stays with DialogueNpc.
@export var npc_name := ""
@export var role_name := ""
var _name_label: Label
var _role_label: Label

func _ready() -> void:
	z_index = 3
	_name_label = _label(npc_name,0,11)
	_role_label = _label(role_name,14,9)
	set_near(false)

func set_near(value: bool) -> void:
	if not is_instance_valid(_name_label): return
	_name_label.modulate = Color(1,.87,.58) if value else Color(.91,.83,.65)
	_role_label.modulate = Color(.82,.94,.96) if value else Color(.69,.78,.8)

func _label(text: String, top: float, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = Vector2(-60,top)
	label.size = Vector2(120,14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_constant_override("outline_size",3)
	label.add_theme_color_override("font_outline_color",Color(.035,.035,.055,.95))
	add_child(label)
	return label
