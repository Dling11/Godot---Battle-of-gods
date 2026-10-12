extends CanvasLayer

## Presents training and loadout intent; KingSkillLibrary owns validation and saving.
var library: KingSkillLibrary
var trainer_access := false
var _selected := ""
var _detail: RichTextLabel
var _upgrade_button: Button
var _list: VBoxContainer
var _slots: GridContainer
var _notice: Label
var _status: Label
var _clear_button: Button
var _core_button: Button
var _panel: PanelContainer
var _last_slot := 0
var _owns_pause := false
var return_menu: CharacterMenu
var _closing := false
var _training_mode := false
var _training_tab: Button
var _loadout_tab: Button
var _rank_path: HBoxContainer
var _slot_header: HBoxContainer

func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	_owns_pause = not get_tree().paused
	get_tree().paused = true
	var veil := ColorRect.new()
	veil.color = Color(0.02,.03,.045,.86)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	_panel = PanelContainer.new()
	_panel.theme = preload("res://assets/ui/themes/battle_of_gods_theme.tres")
	_panel.size = Vector2(860,480)
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var style := StyleBoxFlat.new()
	style.bg_color = Color("111d29")
	style.border_color = Color("80734f")
	style.set_border_width_all(2)
	style.set_content_margin_all(18)
	_panel.add_theme_stylebox_override("panel",style)
	_panel.add_theme_font_size_override("font_size",12)
	add_child(_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",8)
	_panel.add_child(stack)
	var header := HBoxContainer.new()
	stack.add_child(header)
	if trainer_access:
		var portrait := TextureRect.new()
		portrait.texture = preload("res://assets/characters/npcs/skillkeeper/renewal/portrait.png")
		portrait.custom_minimum_size = Vector2(48,48)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		header.add_child(portrait)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(identity)
	var title := Label.new()
	title.text = "EIRA · SKILL MENTOR" if trainer_access and not library.is_lab() else "KING · COMBAT LOADOUT"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size",16)
	identity.add_child(title)
	var purpose := Label.new()
	purpose.text = "Train stronger techniques as King grows. No coin or material cost." if trainer_access else "Choose which learned skill belongs on each combat key."
	purpose.add_theme_font_size_override("font_size",11)
	identity.add_child(purpose)
	_core_button = Button.new()
	_core_button.text = "Restore core layout"
	_core_button.tooltip_text = "Place learned core skills in 1–5. This changes your current arrangement."
	_core_button.pressed.connect(_restore_core)
	header.add_child(_core_button)
	var close := Button.new()
	close.text = "Back [Esc]"
	close.pressed.connect(_close)
	header.add_child(close)
	var tabs := HBoxContainer.new()
	stack.add_child(tabs)
	_training_tab = Button.new()
	_training_tab.text = "TRAINING"
	_training_tab.toggle_mode = true
	_training_tab.custom_minimum_size = Vector2(128,26)
	_training_tab.disabled = library.is_lab()
	_training_tab.pressed.connect(_set_mode.bind(true))
	tabs.add_child(_training_tab)
	_loadout_tab = Button.new()
	_loadout_tab.text = "LOADOUT"
	_loadout_tab.toggle_mode = true
	_loadout_tab.custom_minimum_size = Vector2(128,26)
	_loadout_tab.pressed.connect(_set_mode.bind(false))
	tabs.add_child(_loadout_tab)
	_notice = Label.new()
	_notice.custom_minimum_size.x = 824
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.add_theme_font_size_override("font_size",11)
	stack.add_child(_notice)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",16)
	stack.add_child(body)
	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(230,180)
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll.follow_focus = true
	body.add_child(list_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation",4)
	list_scroll.add_child(_list)
	var detail_column := VBoxContainer.new()
	detail_column.custom_minimum_size = Vector2(0,180)
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail_column)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.custom_minimum_size = Vector2(0,96)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail.add_theme_font_size_override("normal_font_size",13)
	detail_column.add_child(_detail)
	_rank_path = HBoxContainer.new()
	_rank_path.add_theme_constant_override("separation",6)
	detail_column.add_child(_rank_path)
	_upgrade_button = Button.new()
	_upgrade_button.pressed.connect(_train_selected)
	detail_column.add_child(_upgrade_button)
	_slot_header = HBoxContainer.new()
	detail_column.add_child(_slot_header)
	var slot_title := Label.new()
	slot_title.text = "COMBAT SLOTS · 1–5 / 6–0"
	slot_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_title.add_theme_font_size_override("font_size",12)
	_slot_header.add_child(slot_title)
	_clear_button = Button.new()
	_clear_button.text = "Clear selected slot"
	_clear_button.tooltip_text = "Clear the last slot you clicked. Right-click also clears a slot."
	_clear_button.pressed.connect(func() -> void: _equip_selected(_last_slot,true))
	_slot_header.add_child(_clear_button)
	_slots = GridContainer.new()
	_slots.columns = 5
	_slots.add_theme_constant_override("h_separation",6)
	_slots.add_theme_constant_override("v_separation",6)
	detail_column.add_child(_slots)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(824,28)
	_status.add_theme_font_size_override("font_size",11)
	_status.text = "Changes take effect immediately. Press Esc to return."
	stack.add_child(_status)
	_selected = String(library.entries()[0].definition.ability_id)
	_training_mode = trainer_access and not library.is_lab()
	library.library_changed.connect(_refresh)
	get_viewport().size_changed.connect(_center_panel)
	_refresh()
	_center_panel.call_deferred()
	_list.get_child(0).grab_focus()

func _center_panel() -> void:
	_panel.size = Vector2(860,480)
	_panel.position = (get_viewport().get_visible_rect().size-_panel.size)/2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()

func _refresh() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var focus_name: StringName = focused.name if focused != null and is_ancestor_of(focused) else &""
	for container in [_list,_slots]:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
	_notice.text = "Select a technique, then click a combat slot to assign it. Occupied slots swap; right-click clears." if library.can_edit() else "Loadout is read-only here. Return to Sanctuary to arrange skills and visit Eira to train."
	if _training_mode: _notice.text = "Earn levels in expeditions, return to Eira, then train the next rank. Every upgrade is permanent in normal play."
	_training_tab.set_pressed_no_signal(_training_mode)
	_loadout_tab.set_pressed_no_signal(not _training_mode)
	_slot_header.visible = not _training_mode
	_slots.visible = not _training_mode
	_rank_path.visible = _training_mode
	_core_button.visible = not _training_mode
	if library.is_lab(): _notice.text = "Lab preview only. Select a technique, then a slot to assign it; right-click clears."
	_core_button.disabled = not library.can_edit()
	_clear_button.disabled = not library.can_edit() or _last_slot == 0 or library.actor.skill_loadout.get_slot(_last_slot).ability == null
	var techniques := library.entries()
	techniques.sort_custom(func(a: AbilityComponent,b: AbilityComponent) -> bool: return KingSkillCatalog.IDS.find(String(a.definition.ability_id)) < KingSkillCatalog.IDS.find(String(b.definition.ability_id)))
	for ability in techniques:
		var id := String(ability.definition.ability_id)
		var button := Button.new()
		button.name = "Technique_"+id
		var assigned: int = library.current_ids().find(id)+1
		var key := library.actor.skill_loadout.get_slot(assigned).get_key_label() if assigned > 0 else "—"
		var course := library.training_info(id)
		var subtitle: String = course.ranks[course.rank] if _training_mode else ("Slot "+key if assigned > 0 else "Not equipped")
		subtitle += " · "+ability.definition.get_damage_type_label()
		button.text = "%s\n%s" % [course.name,subtitle]
		button.icon = ability.definition.icon
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width",24)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 42
		button.add_theme_font_size_override("font_size",11)
		button.toggle_mode = true
		button.set_pressed_no_signal(id == _selected)
		button.pressed.connect(func() -> void: _selected = id; _refresh())
		_list.add_child(button)
		if id == _selected:
			_detail.text = "[b]"+course.name+"[/b] · "+course.role+"\n"+ability.definition.get_description_with_damage_type()
			_detail.text += "\n\n[b]Equipped:[/b] "+("slot "+key if assigned > 0 else "not assigned")
	_refresh_training()
	for index in SkillLoadoutDefinition.SLOT_COUNT:
		var slot := library.actor.skill_loadout.get_slot(index+1)
		var button := Button.new()
		button.name = "Slot%d" % (index+1)
		button.text = "[%s]\n%s" % [slot.get_key_label(),slot.ability.hud_name if slot.ability else "EMPTY"]
		button.custom_minimum_size = Vector2(108,44)
		button.add_theme_font_size_override("font_size",10)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = not library.can_edit() or not library.is_learned(_selected)
		button.tooltip_text = "Assign selected technique to slot %s. Existing skills swap. Right-click to clear." % slot.get_key_label()
		button.pressed.connect(_equip_selected.bind(index+1,false))
		button.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				button.accept_event()
				_equip_selected(index+1,true))
		_slots.add_child(button)
		if slot.ability != null and String(slot.ability.ability_id) == _selected:
			button.modulate = Color("d7bf81")
	if not focus_name.is_empty():
		var restored := _panel.find_child(String(focus_name),true,false) as Control
		if restored != null: restored.grab_focus()
	_center_panel.call_deferred()

func _set_mode(training: bool) -> void:
	_training_mode = training
	_refresh()

func _refresh_training() -> void:
	for child in _rank_path.get_children():
		_rank_path.remove_child(child)
		child.queue_free()
	var info := library.training_info(_selected)
	var rank: int = info.rank
	_detail.text += "\n[b]Current:[/b] "+info.ranks[rank]+" · "+info.benefits[rank]
	for index in info.ranks.size():
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var style := StyleBoxFlat.new()
		style.bg_color = Color("222837") if index <= rank else Color("121720")
		style.border_color = Color("c0a665") if index == rank else Color("4e4d55")
		style.set_border_width_all(1)
		style.set_content_margin_all(6)
		card.add_theme_stylebox_override("panel",style)
		_rank_path.add_child(card)
		var caption := Label.new()
		caption.text = info.ranks[index]+"\n"+("Learned" if index <= rank else "Level %d" % info.levels[index-1])
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size",11)
		card.add_child(caption)
	_upgrade_button.visible = _training_mode and not library.is_lab()
	if not _training_mode: return
	var required: int = info.required_level
	var eligible := library.can_upgrade_skill(_selected,trainer_access)
	if required == 0:
		_detail.text += "\n\n[b]Training complete.[/b] This technique is fully trained."
		_upgrade_button.text = "Fully trained"
	elif not trainer_access:
		_detail.text += "\n\n[b]Next:[/b] "+info.benefits[rank+1]+"\nVisit Eira · requires Level %d (current %d)." % [required,info.current_level]
		_upgrade_button.text = "Visit Eira to train"
	else:
		_detail.text += "\n\n[b]Next:[/b] "+info.ranks[rank+1]+" · "+info.benefits[rank+1]+"\n[b]Requirement:[/b] Level %d · current Level %d\n[b]Cost:[/b] Free training. Train once to keep this rank." % [required,info.current_level]
		_upgrade_button.text = "Train "+info.ranks[rank+1] if eligible else "Requires Level %d" % required
	_upgrade_button.disabled = not eligible
func _equip_selected(slot_number: int, clear: bool) -> void:
	if slot_number <= 0: return
	_last_slot = slot_number
	var slot := library.actor.skill_loadout.get_slot(slot_number)
	var key := slot.get_key_label()
	var previous := slot.get_display_name()
	var selected_name := ""
	for ability in library.entries():
		if String(ability.definition.ability_id) == _selected: selected_name = ability.definition.display_name
	if library.equip("" if clear else _selected,slot_number):
		_status.text = "Slot %s cleared." % key if clear else "%s assigned to [%s]. Previous skill: %s." % [selected_name,key,previous]
		_slots.get_child(slot_number-1).grab_focus()
	else:
		_status.text = "Loadout could not be changed. Return to Sanctuary when King is ready."

func _restore_core() -> void:
	_status.text = "Core skills restored to slots 1–5." if library.equip_core_kit() else "Loadout could not be changed right now."

func _train_selected() -> void:
	var info := library.training_info(_selected)
	var trained := library.upgrade_skill(_selected,trainer_access)
	_status.text = info.name+" trained. Your combat skill is updated." if trained else "Training was not applied. Check the requirement or try again."

func _close() -> void:
	if _closing: return
	_closing = true
	if is_instance_valid(return_menu) and return_menu.visible: return_menu.close_menu()
	if _owns_pause: get_tree().paused = false
	queue_free()
