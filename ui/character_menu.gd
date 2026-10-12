class_name CharacterMenu
extends Control

## Paused Character & Bag and Skills surface. WeaponInventory and
## MaterialInventory own mutable state; this menu only selects, presents, and
## requests safe equips.

const SkillSlotCardScene = preload("res://ui/skills/skill_slot_card.tscn")
const InventorySlotButtonScene = preload("res://ui/inventory/inventory_slot_button.tscn")
const EquipmentSlotCardScene = preload("res://ui/equipment/equipment_slot_card.tscn")
const ProgressionReadout = preload("res://ui/hud/progression_readout.gd")
const PaperdollPresenter = preload("res://ui/inventory/centered_paperdoll_presenter.gd")
const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const Stage5CoreEquipment: EquipmentCatalogDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core_catalog.tres"
)
const BAG_CAPACITY := 24
const BAG_COLUMNS := 12
const EQUIPMENT_SLOT_NAMES := [
	"Head",
	"Weapon Essence",
	"Plate",
	"Gloves",
	"Leggings",
	"Boots",
	"Bracer",
	"Amulet",
	"Ring",
	"Talisman",
]
const EQUIPMENT_SLOT_TYPES := [
	EquipmentDefinition.Slot.HEAD,
	EquipmentDefinition.Slot.WEAPON,
	EquipmentDefinition.Slot.PLATE,
	EquipmentDefinition.Slot.GLOVES,
	EquipmentDefinition.Slot.LEGGINGS,
	EquipmentDefinition.Slot.BOOTS,
	EquipmentDefinition.Slot.BRACER,
	EquipmentDefinition.Slot.AMULET,
	EquipmentDefinition.Slot.RING,
	EquipmentDefinition.Slot.TALISMAN,
]
const WEAPON_ESSENCE_SLOT_INDEX := 1
const FUTURE_SKILL_TIERS := [
	{
		"node_name": "UltimateSlot",
		"display_name": "Ultimate",
		"description": "A future high-power skill tier. No ability or input is assigned yet.",
	},
	{
		"node_name": "RealityBreakingSlot",
		"display_name": "Reality Breaking",
		"description": "A future finisher tier beyond Ultimate. No ability or input is assigned yet.",
	},
]

signal menu_closed

var _skillkeeper_access := false
var collection_button: Button
var _skill_context: Label
var _future_tiers: HBoxContainer

@export var player: Player

@onready var level_label: Label = %LevelLabel
@onready var vitality_label: Label = %VitalityLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var close_button: Button = %CloseButton
@onready var gear_tab_button: Button = %GearTabButton
@onready var skills_tab_button: Button = %SkillsTabButton
@onready var gear_page: Control = %GearPage
@onready var skills_page: Control = %SkillsPage
@onready var equipment_slots: Control = %EquipmentSlots
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var equipment_detail_panel: EquipmentDetailPanel = %EquipmentDetailPanel
@onready var bag_capacity_label: Label = %BagCapacityLabel
@onready var bag_empty_label: Label = %BagEmptyLabel
@onready var all_filter_button: Button = %AllFilterButton
@onready var equipment_filter_button: Button = %EquipmentFilterButton
@onready var materials_filter_button: Button = %MaterialsFilterButton
@onready var consumables_filter_button: Button = %ConsumablesFilterButton
@onready var key_filter_button: Button = %KeyFilterButton
@onready var sort_button: Button = %SortButton
@onready var skills_container: GridContainer = %Skills
@onready var skill_detail_label: Label = %SkillDetailLabel
@onready var portrait_aura: Polygon2D = %PortraitAura
@onready var weapon_preview: Sprite2D = %WeaponPreview
@onready var attack_label: Label = %AttackLabel

var _owns_pause := false
var _inventory_slots: Array[InventorySlotButton] = []
var _selectable_inventory_slots: Array[InventorySlotButton] = []
var _equipment_cards: Array[InventorySlotButton] = []
var _material_cards: Array[InventorySlotButton] = []
var _equipment_slot_cards: Array[EquipmentSlotCard] = []
var _skill_cards: Array[SkillSlotCard] = []
var _future_skill_cards: Array[SkillSlotCard] = []
var _active_page := &"gear"
var _active_inventory_filter := &"all"
var _inventory_sort_mode := &"slot"
var _portrait_rotation_tween: Tween
var _family_portrait: Node2D
var _portrait_pulse_tween: Tween
var _selected_equipment: EquipmentDefinition
var _selected_material: MaterialDefinition
var _search_query := ""
@onready var bag_search: LineEdit = %BagSearch
@onready var bag_scroll: ScrollContainer = %BagScroll
@onready var bag_footer: Label = %BagFooter


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	PaperdollPresenter.apply_skin(self)
	equipment_slots.resized.connect(_layout_equipment_slots)
	if player == null:
		push_error("CharacterMenu requires a Player reference.")
		return
	var progression := player.progression_component
	progression.progression_changed.connect(_update_progression)
	progression.coins_changed.connect(_update_coins)
	player.health_component.health_changed.connect(_update_vitality)
	player.skill_loadout_changed.connect(_on_skill_loadout_changed)
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory != null:
		material_inventory.material_quantity_changed.connect(_on_material_quantity_changed)
		material_inventory.inventory_reset.connect(_on_material_inventory_reset)
	var gear_inventory := get_node_or_null("/root/GearInventory")
	if gear_inventory != null:
		gear_inventory.gear_acquired.connect(_on_gear_inventory_changed.unbind(1))
		gear_inventory.gear_equipped.connect(_on_gear_inventory_changed.unbind(3))
		gear_inventory.inventory_reset.connect(_on_gear_inventory_changed)
	var weapon_inventory := get_node_or_null("/root/WeaponInventory")
	if weapon_inventory != null:
		weapon_inventory.weapon_acquired.connect(_on_gear_inventory_changed.unbind(1))
		weapon_inventory.weapon_equipped.connect(_on_gear_inventory_changed.unbind(2))
		weapon_inventory.inventory_reset.connect(_on_gear_inventory_changed)
	_update_progression(progression.level, progression.total_experience, 0)
	_update_coins(progression.coins)
	_update_vitality(
		player.health_component.current_health,
		player.health_component.maximum_health
	)
	_configure_tabs()
	_configure_inventory_filters()
	bag_search.text_changed.connect(_on_bag_search_changed)
	sort_button.pressed.connect(_cycle_inventory_sort)
	equipment_detail_panel.equip_requested.connect(_on_equipment_equip_requested)
	_build_character_bag()
	collection_button = Button.new()
	collection_button.add_theme_font_size_override("font_size",11)
	collection_button.pressed.connect(func() -> void: player.get_node("KingSkillLibrary").open_collection(_skillkeeper_access))
	skills_page.get_node("SkillHeader").add_child(collection_button)
	_skill_context = Label.new()
	_skill_context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_skill_context.add_theme_font_size_override("font_size",11)
	skills_page.add_child(_skill_context)
	skills_page.move_child(_skill_context, 0)
	_refresh_skill_context()
	_build_skill_cards()
	_show_page(&"gear", false)
	_start_portrait_aura()
	hide()


func _input(event: InputEvent) -> void:
	if is_instance_valid(player.get_node("KingSkillLibrary")._collection):
		return
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()
		return
	if visible or get_tree().paused or not event.is_action_pressed("player_character_menu"):
		return
	get_viewport().set_input_as_handled()
	open_menu()


func open_menu() -> void:
	if visible or get_tree().paused:
		return
	_build_character_bag()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	_focus_default_control()


func open_skillkeeper_menu() -> void:
	if visible or get_tree().paused:
		return
	_skillkeeper_access = true
	_refresh_skill_context()
	_show_page(&"skills", false)
	open_menu()
	var library: KingSkillLibrary = player.get_node("KingSkillLibrary")
	library.open_collection(true)
	library._collection.return_menu = self


func close_menu() -> void:
	if not visible:
		return
	hide()
	var library: KingSkillLibrary = player.get_node("KingSkillLibrary")
	if is_instance_valid(library._collection): library._collection._close()
	_skillkeeper_access = false
	_refresh_skill_context()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	menu_closed.emit()


func _exit_tree() -> void:
	if _owns_pause and get_tree() != null:
		get_tree().paused = false


func _update_progression(_level: int, _total_experience: int, _next_level_experience: int) -> void:
	if not is_instance_valid(player):
		return
	var progression := player.progression_component
	var readout := ProgressionReadout.describe(progression)
	level_label.text = "LEVEL %d / %d" % [progression.level,progression.definition.maximum_level]
	experience_bar.max_value = readout.maximum
	experience_bar.value = readout.value
	experience_label.text = readout.text
	experience_label.tooltip_text = readout.help
	level_label.tooltip_text = readout.help


func _update_coins(total_coins: int) -> void:
	coin_label.text = "%d COINS" % total_coins


func _update_vitality(current: float, maximum: float) -> void:
	vitality_label.text = "HP %d/%d" % [ceili(current), ceili(maximum)]


func _configure_tabs() -> void:
	var tab_group := ButtonGroup.new()
	tab_group.allow_unpress = false
	gear_tab_button.button_group = tab_group
	skills_tab_button.button_group = tab_group
	gear_tab_button.pressed.connect(_show_page.bind(&"gear", true))
	skills_tab_button.pressed.connect(_show_page.bind(&"skills", true))
	gear_tab_button.focus_neighbor_right = gear_tab_button.get_path_to(skills_tab_button)
	gear_tab_button.focus_neighbor_left = gear_tab_button.get_path_to(skills_tab_button)
	skills_tab_button.focus_neighbor_right = skills_tab_button.get_path_to(gear_tab_button)
	skills_tab_button.focus_neighbor_left = skills_tab_button.get_path_to(gear_tab_button)
	close_button.focus_neighbor_bottom = close_button.get_path_to(gear_tab_button)


func _configure_inventory_filters() -> void:
	# Only implemented inventory kinds belong in the playable category bar.
	consumables_filter_button.hide()
	key_filter_button.hide()
	for button: Button in [all_filter_button,equipment_filter_button,materials_filter_button,sort_button]:
		button.add_theme_font_size_override("font_size",9)
		button.custom_minimum_size.y = 22
	bag_footer.add_theme_font_size_override("font_size",8)
	bag_capacity_label.add_theme_font_size_override("font_size",9)
	var filter_group := ButtonGroup.new()
	filter_group.allow_unpress = false
	var filters := {
		all_filter_button: &"all",
		equipment_filter_button: &"equipment",
		materials_filter_button: &"materials",
		consumables_filter_button: &"consumables",
		key_filter_button: &"key",
	}
	for button: Button in filters:
		button.button_group = filter_group
		button.pressed.connect(_set_inventory_filter.bind(filters[button]))
	all_filter_button.set_pressed_no_signal(true)


func _show_page(page: StringName, focus_content: bool = true) -> void:
	_active_page = page
	var showing_gear := page == &"gear"
	gear_page.visible = showing_gear
	skills_page.visible = not showing_gear
	gear_tab_button.set_pressed_no_signal(showing_gear)
	skills_tab_button.set_pressed_no_signal(not showing_gear)
	_refresh_page_focus_links()
	if focus_content and visible:
		_focus_default_control()


func _set_inventory_filter(filter_name: StringName) -> void:
	if _active_inventory_filter == filter_name:
		return
	_active_inventory_filter = filter_name
	bag_scroll.scroll_vertical = 0
	_build_inventory_grid()
	if visible and _active_page == &"gear":
		_focus_default_control()


func _refresh_page_focus_links() -> void:
	var first_control: Control
	var last_control: Control
	if _active_page == &"gear" and not _selectable_inventory_slots.is_empty():
		first_control = _selectable_inventory_slots[0]
		last_control = _selectable_inventory_slots[-1]
	elif not _skill_cards.is_empty():
		first_control = _skill_cards[0]
		last_control = _skill_cards[-1]
	else:
		return
	gear_tab_button.focus_neighbor_bottom = gear_tab_button.get_path_to(first_control)
	skills_tab_button.focus_neighbor_bottom = skills_tab_button.get_path_to(first_control)
	close_button.focus_neighbor_top = close_button.get_path_to(last_control)


func _build_character_bag() -> void:
	_build_equipment_slots()
	_build_inventory_grid()


func _build_equipment_slots() -> void:
	_clear_children(equipment_slots)
	_equipment_slot_cards.clear()
	if player.weapon_catalog == null or not player.weapon_catalog.has_valid_layout():
		push_error("CharacterMenu requires a valid weapon catalog definition.")
		return
	var equipped_weapon := player.get_equipped_weapon_item()
	for index in EQUIPMENT_SLOT_NAMES.size():
		var slot_type: EquipmentDefinition.Slot = EQUIPMENT_SLOT_TYPES[index]
		var equipped_item := (
			equipped_weapon
			if slot_type == EquipmentDefinition.Slot.WEAPON
			else player.get_equipped_gear(slot_type)
		)
		var slot_card := EquipmentSlotCardScene.instantiate() as EquipmentSlotCard
		equipment_slots.add_child(slot_card)
		slot_card.configure(
			EQUIPMENT_SLOT_NAMES[index],
			slot_type,
			equipped_item,
			PaperdollPresenter.EMPTY_ICONS[index]
		)
		slot_card.equipment_dropped.connect(_on_equipment_equip_requested)
		slot_card.equipment_inspected.connect(_on_equipment_selected)
		_equipment_slot_cards.append(slot_card)
	_layout_equipment_slots()


func _layout_equipment_slots() -> void:
	PaperdollPresenter.arrange(equipment_slots, _equipment_slot_cards)


func _build_inventory_grid() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var focused_item: StringName = focused.name if focused != null and inventory_grid.is_ancestor_of(focused) else &""
	_clear_children(inventory_grid)
	_inventory_slots.clear()
	_selectable_inventory_slots.clear()
	_equipment_cards.clear()
	_material_cards.clear()
	if player.weapon_catalog == null or not player.weapon_catalog.has_valid_layout():
		return
	var button_group := ButtonGroup.new()
	button_group.allow_unpress = false
	var weapon_inventory := get_node_or_null("/root/WeaponInventory")
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	var selected_slot: InventorySlotButton
	var owned_equipment := _get_sorted_owned_equipment(weapon_inventory)

	if _active_inventory_filter in [&"all", &"equipment"]:
		for item: EquipmentDefinition in owned_equipment:
			if not _matches_search(item.display_name+" "+item.get_slot_name()+" "+item.get_rarity_name()): continue
			var slot := _create_inventory_slot(button_group)
			var equipped := _is_equipment_equipped(item)
			slot.configure_equipment(
				item,
				equipped,
				item.is_compatible_with(player.character_class_id)
			)
			slot.equipment_selected.connect(_on_equipment_selected)
			_equipment_cards.append(slot)
			if item == _selected_equipment or (
				_selected_equipment == null and equipped
			):
				selected_slot = slot

	if _active_inventory_filter in [&"all", &"materials"] and material_inventory != null:
		var sorted_materials := _get_sorted_owned_materials(material_inventory)
		for material: MaterialDefinition in sorted_materials:
			if not _matches_search(material.display_name+" "+material.get_family_name()+" "+material.get_rarity_name()): continue
			var quantity: int = int(material_inventory.get_quantity(material.material_id))
			if quantity <= 0:
				continue
			var slot := _create_inventory_slot(button_group)
			slot.configure_material(material, quantity)
			slot.material_selected.connect(_on_material_selected)
			_material_cards.append(slot)
			if material == _selected_material:
				selected_slot = slot

	var visible_item_count := _selectable_inventory_slots.size()
	for _index in range(visible_item_count, BAG_CAPACITY):
		var empty_slot := InventorySlotButtonScene.instantiate() as InventorySlotButton
		inventory_grid.add_child(empty_slot)
		empty_slot.configure_empty()
		_inventory_slots.append(empty_slot)

	var material_count := _get_sorted_owned_materials(material_inventory).size() if material_inventory != null else 0
	bag_capacity_label.text = "SHOWING %d" % visible_item_count
	bag_footer.text = "%d equipment · %d material types · Materials use no bag space. Select an item to inspect or equip." % [owned_equipment.size(),material_count]
	bag_empty_label.visible = visible_item_count == 0
	bag_empty_label.text = _get_empty_filter_message()
	if selected_slot == null and not _selectable_inventory_slots.is_empty():
		selected_slot = _selectable_inventory_slots[0]
	if selected_slot != null:
		selected_slot.set_pressed_no_signal(true)
		if selected_slot.kind == InventorySlotButton.Kind.EQUIPMENT:
			_on_equipment_selected(selected_slot.equipment_definition)
		elif selected_slot.kind == InventorySlotButton.Kind.MATERIAL:
			_on_material_selected(selected_slot.material_definition)
	else:
		equipment_detail_panel.configure_empty("No matching items" if not _search_query.is_empty() else "No items in this category")
	_configure_inventory_focus()
	_refresh_page_focus_links()
	if not focused_item.is_empty():
		var restored := inventory_grid.get_node_or_null(NodePath(focused_item)) as Control
		if restored != null: restored.grab_focus()

func _on_bag_search_changed(query: String) -> void:
	_search_query = query.strip_edges().to_lower()
	bag_scroll.scroll_vertical = 0
	_build_inventory_grid()

func _matches_search(value: String) -> bool:
	return _search_query.is_empty() or value.to_lower().contains(_search_query)


func _create_inventory_slot(button_group: ButtonGroup) -> InventorySlotButton:
	var slot := InventorySlotButtonScene.instantiate() as InventorySlotButton
	inventory_grid.add_child(slot)
	slot.button_group = button_group
	_inventory_slots.append(slot)
	_selectable_inventory_slots.append(slot)
	return slot


func _get_sorted_owned_equipment(weapon_inventory: Node) -> Array[EquipmentDefinition]:
	var result: Array[EquipmentDefinition] = []
	if weapon_inventory != null:
		for item: EquipmentDefinition in player.weapon_catalog.weapons:
			if weapon_inventory.owns_weapon(item.item_id):
				result.append(item)
	var gear_inventory := get_node_or_null("/root/GearInventory")
	if gear_inventory != null:
		result.append_array(gear_inventory.get_owned_items())
	result.sort_custom(_equipment_sort_less)
	return result


func _get_sorted_owned_materials(material_inventory: Node) -> Array[MaterialDefinition]:
	var result: Array[MaterialDefinition] = []
	for material: MaterialDefinition in MaterialCatalog.materials:
		if material_inventory.get_quantity(material.material_id) > 0:
			result.append(material)
	result.sort_custom(_material_sort_less.bind(material_inventory))
	return result


func _equipment_sort_less(a: EquipmentDefinition, b: EquipmentDefinition) -> bool:
	match _inventory_sort_mode:
		&"name":
			return a.display_name.naturalnocasecmp_to(b.display_name) < 0
		&"rarity":
			if a.rarity != b.rarity:
				return a.rarity > b.rarity
		&"quantity":
			pass
		&"hit", &"dps":
			var a_score := 0.0
			var b_score := 0.0
			if a.weapon_definition != null:
				a_score = WeaponCombatReadout.base_dps(a.weapon_definition) if _inventory_sort_mode == &"dps" else WeaponCombatReadout.base_range(a.weapon_definition).y
			if b.weapon_definition != null:
				b_score = WeaponCombatReadout.base_dps(b.weapon_definition) if _inventory_sort_mode == &"dps" else WeaponCombatReadout.base_range(b.weapon_definition).y
			if not is_equal_approx(a_score, b_score):
				return a_score > b_score
	if a.slot != b.slot:
		return a.slot < b.slot
	return a.display_name.naturalnocasecmp_to(b.display_name) < 0


func _material_sort_less(a: MaterialDefinition, b: MaterialDefinition, inventory: Node) -> bool:
	match _inventory_sort_mode:
		&"name":
			return a.display_name.naturalnocasecmp_to(b.display_name) < 0
		&"rarity":
			if a.rarity != b.rarity:
				return a.rarity > b.rarity
		&"quantity":
			var a_quantity: int = inventory.get_quantity(a.material_id)
			var b_quantity: int = inventory.get_quantity(b.material_id)
			if a_quantity != b_quantity:
				return a_quantity > b_quantity
	if a.material_family != b.material_family:
		return a.material_family < b.material_family
	return a.display_name.naturalnocasecmp_to(b.display_name) < 0


func _cycle_inventory_sort() -> void:
	var modes: Array[StringName] = [&"slot", &"name", &"rarity", &"quantity", &"hit", &"dps"]
	_inventory_sort_mode = modes[(modes.find(_inventory_sort_mode) + 1) % modes.size()]
	sort_button.text = "SORT: %s" % String(_inventory_sort_mode).to_upper()
	_build_inventory_grid()


func _is_equipment_equipped(item: EquipmentDefinition) -> bool:
	if item == null:
		return false
	if item.slot == EquipmentDefinition.Slot.WEAPON:
		return player.get_equipped_weapon_item() == item
	return player.get_equipped_gear(item.slot) == item


func _get_empty_filter_message() -> String:
	if not _search_query.is_empty(): return "NO MATCHING ITEMS · Clear search or choose another category."
	match _active_inventory_filter:
		&"materials":
			return "NO MATERIALS COLLECTED • MONSTER DROPS ARRIVE WITH STAGE LOOT"
		&"consumables":
			return "CONSUMABLE POUCH NOT YET UNLOCKED"
		&"key":
			return "NO KEY ITEMS"
	return "NO ITEMS IN THIS VIEW"


func _configure_inventory_focus() -> void:
	if _selectable_inventory_slots.is_empty():
		return
	for index in _selectable_inventory_slots.size():
		var slot := _selectable_inventory_slots[index]
		var row := index / BAG_COLUMNS
		var row_start := row * BAG_COLUMNS
		var row_count := mini(
			BAG_COLUMNS,
			_selectable_inventory_slots.size() - row_start
		)
		var column := index - row_start
		var left_index := row_start + posmod(column - 1, row_count)
		var right_index := row_start + ((column + 1) % row_count)
		var up_index := index - BAG_COLUMNS
		var down_index := index + BAG_COLUMNS
		slot.focus_neighbor_left = slot.get_path_to(_selectable_inventory_slots[left_index])
		slot.focus_neighbor_right = slot.get_path_to(_selectable_inventory_slots[right_index])
		slot.focus_neighbor_top = (
			slot.get_path_to(_selectable_inventory_slots[up_index])
			if up_index >= 0
			else slot.get_path_to(all_filter_button)
		)
		slot.focus_neighbor_bottom = (
			slot.get_path_to(_selectable_inventory_slots[down_index])
			if down_index < _selectable_inventory_slots.size()
			else slot.get_path_to(close_button)
		)


func _on_equipment_selected(definition: EquipmentDefinition) -> void:
	if definition == null or player.weapon_catalog == null:
		return
	_selected_equipment = definition
	_selected_material = null
	_refresh_equipment_detail(definition)


func _on_material_selected(definition: MaterialDefinition) -> void:
	if definition == null:
		return
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory == null:
		return
	_selected_material = definition
	_selected_equipment = null
	equipment_detail_panel.configure_material(
		definition,
		material_inventory.get_quantity(definition.material_id)
	)


func _on_equipment_equip_requested(definition: EquipmentDefinition) -> void:
	if definition == null or not definition.is_compatible_with(player.character_class_id):
		return
	if player.equip_owned_equipment(definition):
		_selected_equipment = definition
		_selected_material = null
		_build_equipment_slots()
		_build_inventory_grid()


func _refresh_equipment_presentation(selected: EquipmentDefinition) -> void:
	var equipped := player.get_equipped_weapon_item()
	if equipped == null:
		return
	for card: InventorySlotButton in _equipment_cards:
		card.configure_equipment(
			card.equipment_definition,
			_is_equipment_equipped(card.equipment_definition),
			card.equipment_definition.is_compatible_with(player.character_class_id)
		)
		card.set_pressed_no_signal(card.equipment_definition == selected)
	if _equipment_slot_cards.size() > WEAPON_ESSENCE_SLOT_INDEX:
		_equipment_slot_cards[WEAPON_ESSENCE_SLOT_INDEX].configure(
			"Weapon Essence",
			EquipmentDefinition.Slot.WEAPON,
			equipped,
			PaperdollPresenter.EMPTY_ICONS[WEAPON_ESSENCE_SLOT_INDEX]
		)
	weapon_preview.texture = equipped.weapon_definition.world_texture
	weapon_preview.position = equipped.weapon_definition.sprite_offset_from_grip
	_refresh_family_portrait(equipped.weapon_definition)
	attack_label.text = "MOUSE: %s" % equipped.display_name.to_upper()
	_refresh_equipment_detail(selected)


func _refresh_family_portrait(weapon: WeaponDefinition) -> void:
	var canvas := weapon_preview.get_parent().get_parent()
	var body := canvas.get_node("Body") as AnimatedSprite2D
	if is_instance_valid(_family_portrait) and weapon.family_presentation != null and _family_portrait.definition == weapon.family_presentation.idle_poses:
		return
	if is_instance_valid(_family_portrait):
		canvas.remove_child(_family_portrait)
		_family_portrait.queue_free()
		_family_portrait = null
	body.visible = weapon.family_presentation == null
	if weapon.family_presentation == null:
		return
	var pose := preload("res://gameplay/presentation/weapon_family_pose_presenter.gd").new()
	pose.configure(weapon.family_presentation.idle_poses, player.attack_component, false)
	pose.position = Vector2(76, 120)
	# One native texel per screen pixel fits the huge blade inside the paper doll.
	pose.scale = Vector2.ONE
	canvas.add_child(pose)
	pose.set_pose(7) # Family rest pose: planted greatsword or back-stowed axe.
	_family_portrait = pose


func _refresh_equipment_detail(selected: EquipmentDefinition) -> void:
	var equipped := player.get_equipped_weapon_item()
	if equipped == null or selected == null:
		return
	weapon_preview.texture = equipped.weapon_definition.world_texture
	weapon_preview.position = equipped.weapon_definition.sprite_offset_from_grip
	_refresh_family_portrait(equipped.weapon_definition)
	attack_label.text = "MOUSE: %s" % equipped.display_name.to_upper()
	equipment_detail_panel.configure(
		selected,
		_is_equipment_equipped(selected),
		selected.is_compatible_with(player.character_class_id),
		_get_equipped_item_for_slot(selected.slot)
	)


func _get_equipped_item_for_slot(slot: EquipmentDefinition.Slot) -> EquipmentDefinition:
	if slot == EquipmentDefinition.Slot.WEAPON:
		return player.get_equipped_weapon_item()
	return player.get_equipped_gear(slot)


func _on_material_quantity_changed(
	_material_id: StringName,
	_quantity: int
) -> void:
	if visible:
		_build_inventory_grid()


func _on_material_inventory_reset() -> void:
	_selected_material = null
	if visible:
		_build_inventory_grid()


func _on_gear_inventory_changed() -> void:
	if visible:
		_build_character_bag()


func _build_skill_cards() -> void:
	_clear_children(skills_container)
	_skill_cards.clear()
	_future_skill_cards.clear()
	if _future_tiers == null:
		_future_tiers = HBoxContainer.new()
		_future_tiers.name = "FutureTiers"
		_future_tiers.add_theme_constant_override("separation",8)
		skills_page.add_child(_future_tiers)
		skills_page.move_child(_future_tiers,skills_page.get_node("SkillDetail").get_index()+1)
	else:
		_clear_children(_future_tiers)
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		push_error("CharacterMenu requires a complete ten-slot skill loadout.")
		return
	var button_group := ButtonGroup.new()
	button_group.allow_unpress = false
	for slot: SkillSlotDefinition in player.skill_loadout.get_ordered_slots():
		var card := SkillSlotCardScene.instantiate() as SkillSlotCard
		skills_container.add_child(card)
		card.configure(slot)
		card.button_group = button_group
		card.slot_selected.connect(_on_skill_slot_selected)
		_skill_cards.append(card)
	for tier: Dictionary in FUTURE_SKILL_TIERS:
		var preview := SkillSlotCardScene.instantiate() as SkillSlotCard
		_future_tiers.add_child(preview)
		preview.configure_locked_preview(
			tier["node_name"],
			tier["display_name"],
			tier["description"]
		)
		preview.custom_minimum_size = Vector2(144,30)
		preview.add_theme_font_size_override("font_size",8)
		preview.add_theme_constant_override("icon_max_width",16)
		_future_skill_cards.append(preview)
	_configure_skill_focus()
	if not _skill_cards.is_empty():
		_skill_cards[0].set_pressed_no_signal(true)
		_on_skill_slot_selected(_skill_cards[0].slot_definition)


func _on_skill_loadout_changed() -> void:
	_build_character_bag()
	_build_skill_cards()
	if visible:
		_refresh_page_focus_links()


func _configure_skill_focus() -> void:
	if _skill_cards.is_empty():
		return
	for index in _skill_cards.size():
		var card := _skill_cards[index]
		var row_start: int = index / skills_container.columns * skills_container.columns
		var previous := _skill_cards[row_start+posmod(index-row_start-1,skills_container.columns)]
		var next := _skill_cards[row_start+posmod(index-row_start+1,skills_container.columns)]
		card.focus_neighbor_left = card.get_path_to(previous)
		card.focus_neighbor_right = card.get_path_to(next)
		card.focus_neighbor_top = card.get_path_to(_skill_cards[index-skills_container.columns] if index >= skills_container.columns else skills_tab_button)
		card.focus_neighbor_bottom = card.get_path_to(_skill_cards[index+skills_container.columns] if index+skills_container.columns < _skill_cards.size() else collection_button)
	skills_tab_button.focus_neighbor_bottom = skills_tab_button.get_path_to(_skill_cards[0])
	close_button.focus_neighbor_top = close_button.get_path_to(collection_button)


func _focus_default_control() -> void:
	if _active_page == &"gear" and not _selectable_inventory_slots.is_empty():
		_selectable_inventory_slots[0].grab_focus()
	elif not _skill_cards.is_empty():
		_skill_cards[0].grab_focus()
	else:
		close_button.grab_focus()


func _on_skill_slot_selected(definition: SkillSlotDefinition) -> void:
	_selected_skill = definition
	if definition.is_equipped():
		skill_detail_label.text = "%s\n%s\nSLOT %d • EQUIPPED • PRESS %s DURING COMBAT" % [
			definition.get_display_name().to_upper(),
			definition.get_description(),
			definition.slot_number,
			definition.get_key_label(),
		]
	else:
		skill_detail_label.text = "%s\n%s\nSLOT %d • SEALED • %s" % [
			definition.get_display_name().to_upper(),
			definition.get_description(),
			definition.slot_number,
			definition.unlock_hint,
		]

	if definition.is_equipped():
		var mastery := player.get_node("KingMastery") as KingMasteryComponent
		skill_detail_label.text += "\nRESOLVE: 3 landed swings → next skill +25%% (8s). Pursuit → Molten Crash within 1.2s: +15%%.\nLEVEL MASTERY: +%d%% skill damage (maximum +18%%)." % roundi((mastery.definition.level_multiplier(player.progression_component.level)-1.0)*100)


var _selected_skill: SkillSlotDefinition


func _refresh_skill_context() -> void:
	if collection_button == null: return
	collection_button.text = "TRAIN & ARRANGE" if _skillkeeper_access else "ARRANGE SKILLS"
	_skill_context.text = "EIRA · SKILL TRAINING   Select a technique to check its next upgrade and arrange your combat slots." if _skillkeeper_access else "COMBAT LOADOUT   Arrange learned techniques in Sanctuary. Visit Eira for skill upgrades."


func _start_portrait_aura() -> void:
	if _portrait_rotation_tween != null:
		_portrait_rotation_tween.kill()
	if _portrait_pulse_tween != null:
		_portrait_pulse_tween.kill()
	_portrait_rotation_tween = create_tween().set_loops()
	_portrait_rotation_tween.tween_property(portrait_aura, "rotation", TAU, 8.0).from(0.0)
	_portrait_pulse_tween = create_tween().set_loops()
	_portrait_pulse_tween.tween_property(portrait_aura, "modulate:a", 0.28, 1.2).from(0.72).set_trans(Tween.TRANS_SINE)
	_portrait_pulse_tween.tween_property(portrait_aura, "modulate:a", 0.72, 1.4).set_trans(Tween.TRANS_SINE)


func _clear_children(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
