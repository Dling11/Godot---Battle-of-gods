extends ScrollContainer

## A normal catalog/equip surface for the real Lab Player, no separate rig.
var lab: Node
var buttons: Dictionary = {}
var status: Label
var detail: Label

func _ready() -> void:
	name = "Weapons"
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",6)
	add_child(column)
	var unlock := Button.new()
	unlock.text = "UNLOCK TEST WEAPONS · F9"
	unlock.focus_mode = Control.FOCUS_NONE
	unlock.pressed.connect(lab.player.apply_debug_testing_preset)
	column.add_child(unlock)
	status = _label(column,11)
	var items: Array[EquipmentDefinition] = lab.player.weapon_catalog.weapons.duplicate()
	# Keep variants beside their original so comparison needs no hunting.
	items.sort_custom(func(a: EquipmentDefinition,b: EquipmentDefinition) -> bool:
		return a.display_name.naturalnocasecmp_to(b.display_name)<0
	)
	for item: EquipmentDefinition in items:
		var row := HBoxContainer.new()
		column.add_child(row)
		var icon := TextureRect.new()
		icon.texture = item.icon
		icon.custom_minimum_size = Vector2(24,24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		var button := Button.new()
		button.text = item.display_name
		button.add_theme_font_size_override("font_size",10)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("18211f")
		style.border_color = Color("596354")
		style.set_border_width_all(1)
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		style.content_margin_left = 4
		style.content_margin_right = 4
		button.add_theme_stylebox_override("normal",style)
		var hover: StyleBoxFlat = style.duplicate()
		hover.bg_color = Color("283732")
		button.add_theme_stylebox_override("hover",hover)
		button.add_theme_stylebox_override("pressed",hover)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.tooltip_text = item.display_name+"\n"+item.synergy_description
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(equip.bind(item))
		row.add_child(button)
		buttons[item.item_id] = button
	detail = _label(column,10)
	var inventory := get_node("/root/WeaponInventory")
	inventory.weapon_acquired.connect(_acquired)
	for signal_name in ["weapon_definition_changed","testing_preset_applied"]:
		lab.player.connect(signal_name,_player_changed)
	lab.player.attack_component.attack_finished.connect(refresh)
	refresh()

func _label(column: VBoxContainer,size: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",size)
	column.add_child(label)
	return label

func _acquired(_id: StringName) -> void:
	refresh()

func _player_changed(_first: Variant=null,_second: Variant=null) -> void:
	refresh()

func refresh() -> void:
	var inventory := get_node("/root/WeaponInventory")
	var current: EquipmentDefinition = lab.player.get_equipped_weapon_item()
	status.text = "EQUIPPED: "+current.display_name
	for item: EquipmentDefinition in lab.player.weapon_catalog.weapons:
		var button: Button = buttons[item.item_id]
		button.disabled = not inventory.owns_weapon(item.item_id)
		button.text = ("✓ " if item==current else "")+item.display_name
		button.modulate = Color("b8d2c6") if item==current else Color.WHITE
	detail.text = current.synergy_description
	if current.show_combo_details: detail.text += "\n\n"+WeaponCombatReadout.summary(current.weapon_definition)

func equip(item: EquipmentDefinition) -> void:
	var actor: Player = lab.player
	if (
		actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE
		or actor.is_any_ability_casting()
		or actor.is_targeting_any_ability()
		or actor.evade_component.is_dashing()
		or actor.is_in_hit_recovery()
		or actor.is_cinematic_locked()
		or actor.is_restrained()
		or actor.is_defeated
	):
		status.text = "Finish the current action before switching."
		return
	if actor.equip_owned_weapon(item): refresh()
