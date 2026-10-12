class_name UmiExchangeMenu
extends Control

signal menu_closed

const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)

@onready var coins_label: Label = %CoinsLabel
@onready var sell_tab: Button = %SellTab
@onready var transmute_tab: Button = %TransmuteTab
@onready var sell_page: Control = %SellPage
@onready var transmute_page: Control = %TransmutePage
@onready var sell_list: VBoxContainer = %SellList
@onready var sell_icon: TextureRect = %SellIcon
@onready var sell_name: Label = %SellName
@onready var sell_meta: Label = %SellMeta
@onready var sell_description: Label = %SellDescription
@onready var sell_quantity: SpinBox = %SellQuantity
@onready var sell_result: Label = %SellResult
@onready var sell_button: Button = %SellButton
@onready var target_list: VBoxContainer = %TargetList
@onready var fuel_list: VBoxContainer = %FuelList
@onready var target_icon: TextureRect = %TargetIcon
@onready var target_name: Label = %TargetName
@onready var target_meta: Label = %TargetMeta
@onready var memory_label: Label = %MemoryLabel
@onready var basket_label: Label = %BasketLabel
@onready var transmute_result: Label = %TransmuteResult
@onready var transmute_button: Button = %TransmuteButton
@onready var close_button: Button = %CloseButton

var _selected_sale: MaterialDefinition
var _selected_target: MaterialDefinition
var _fuel: Dictionary = {}
var _owns_pause := false
var _sell_message := ""
var _transmute_message := ""
@onready var _material_inventory: Node = get_node("/root/MaterialInventory")
@onready var _run_session: Node = get_node("/root/RunSession")
@onready var _enemy_memory: Node = get_node("/root/EnemyMemory")
@onready var _exchange_service: Node = get_node("/root/MaterialExchangeService")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sell_quantity.value_changed.connect(_on_sell_quantity_changed)
	_material_inventory.material_quantity_changed.connect(_on_material_quantity_changed)
	_material_inventory.inventory_reset.connect(_refresh_all)
	_run_session.progression_state_changed.connect(_on_progression_changed)
	_enemy_memory.enemy_defeat_recorded.connect(_on_enemy_memory_changed)
	_enemy_memory.memory_charge_spent.connect(_on_enemy_memory_changed)
	_enemy_memory.memory_reset.connect(_refresh_all)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()


func open_menu() -> void:
	if visible:
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	show()
	_show_page(true)
	_refresh_all()
	close_button.grab_focus()


func close_menu() -> void:
	if not visible:
		return
	hide()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	menu_closed.emit()


func _exit_tree() -> void:
	if _owns_pause and get_tree() != null:
		get_tree().paused = false


func show_sell_page() -> void:
	_show_page(true)


func show_transmute_page() -> void:
	_show_page(false)


func _show_page(show_sell: bool) -> void:
	sell_page.visible = show_sell
	transmute_page.visible = not show_sell
	sell_tab.set_pressed_no_signal(show_sell)
	transmute_tab.set_pressed_no_signal(not show_sell)
	_refresh_all()


func _refresh_all(_unused: Variant = null) -> void:
	coins_label.text = "%d GOLD  •  %d MATERIAL KINDS" % [int(_run_session.get("coins")), _owned_kind_count()]
	_rebuild_sell_list()
	_rebuild_target_list()
	_rebuild_fuel_list()
	_refresh_sell_detail()
	_refresh_transmute_detail()


func _rebuild_sell_list() -> void:
	_clear_children(sell_list)
	var first: MaterialDefinition
	for material: MaterialDefinition in MaterialCatalog.materials:
		var owned := int(_material_inventory.call("get_quantity", material.material_id))
		if owned <= 0 or material.get_sell_value() <= 0:
			continue
		if first == null:
			first = material
		var button := _make_material_button(material, "%s  ×%d\n%s  •  %d GOLD EACH" % [material.display_name.to_upper(), owned, material.get_rarity_name().to_upper(), material.get_sell_value()])
		button.pressed.connect(_select_sale.bind(material))
		sell_list.add_child(button)
	if _selected_sale == null or int(_material_inventory.call("get_quantity", _selected_sale.material_id)) <= 0 or _selected_sale.get_sell_value() <= 0:
		_selected_sale = first


func _rebuild_target_list() -> void:
	_clear_children(target_list)
	var first_target: MaterialDefinition
	for material: MaterialDefinition in MaterialCatalog.materials:
		if not material.is_reconstruction_target():
			continue
		if first_target == null:
			first_target = material
		var owned := int(_material_inventory.call("get_quantity", material.material_id))
		var defeats := int(_enemy_memory.call("get_defeat_count", material.source_enemy_id))
		var required := material.get_required_source_defeats()
		var state := "KNOWN" if defeats >= required else "MEMORY %d/%d" % [defeats, required]
		var button := _make_material_button(material, "%s  ×%d\n%s  •  %s" % [material.display_name.to_upper(), owned, material.get_rarity_name().to_upper(), state])
		button.pressed.connect(_select_target.bind(material))
		target_list.add_child(button)
	if _selected_target == null or not _selected_target.is_reconstruction_target():
		_selected_target = first_target


func _rebuild_fuel_list() -> void:
	_clear_children(fuel_list)
	for material: MaterialDefinition in MaterialCatalog.materials:
		var owned := int(_material_inventory.call("get_quantity", material.material_id))
		if owned <= 0 or material.get_meld_value() <= 0 or material == _selected_target:
			continue
		var selected := int(_fuel.get(material.material_id, 0))
		var button := _make_material_button(material, "%s  %d/%d\n+%d MELD EACH  •  CLICK +1  •  RMB -1" % [material.display_name.to_upper(), selected, owned, material.get_meld_value()])
		button.pressed.connect(_add_fuel.bind(material))
		button.gui_input.connect(_on_fuel_gui_input.bind(material))
		fuel_list.add_child(button)


func _refresh_sell_detail() -> void:
	if _selected_sale == null:
		sell_icon.texture = null
		sell_name.text = "NO SELLABLE MATERIALS"
		sell_meta.text = "BOSS MATERIALS ARE PROTECTED"
		sell_description.text = "Return with ordinary materials to exchange them for gold."
		sell_quantity.max_value = 1
		sell_quantity.value = 1
		sell_button.disabled = true
		sell_result.text = _sell_message if not _sell_message.is_empty() else "NOTHING TO SELL"
		return
	var owned := int(_material_inventory.call("get_quantity", _selected_sale.material_id))
	sell_icon.texture = _selected_sale.icon
	sell_name.text = _selected_sale.display_name.to_upper()
	sell_meta.text = "%s  •  %s  •  OWNED %d" % [_selected_sale.get_rarity_name().to_upper(), _selected_sale.get_family_name().to_upper(), owned]
	sell_description.text = _selected_sale.description
	sell_quantity.max_value = maxi(owned, 1)
	sell_quantity.value = clampi(int(sell_quantity.value), 1, maxi(owned, 1))
	var status: Dictionary = _exchange_service.call("get_sell_status", _selected_sale, int(sell_quantity.value))
	sell_button.disabled = not status["success"]
	sell_result.text = _sell_message if not _sell_message.is_empty() else String(status["message"])
	sell_button.text = "SELL  •  +%d GOLD" % (int(sell_quantity.value) * _selected_sale.get_sell_value())


func _refresh_transmute_detail() -> void:
	if _selected_target == null:
		transmute_button.disabled = true
		return
	target_icon.texture = _selected_target.icon
	target_name.text = _selected_target.display_name.to_upper()
	var owned := int(_material_inventory.call("get_quantity", _selected_target.material_id))
	target_meta.text = "%s  •  OWNED %d  •  %d MELD  •  %d GOLD" % [_selected_target.get_rarity_name().to_upper(), owned, _selected_target.get_transmutation_point_cost(), _selected_target.get_transmutation_gold_cost()]
	var defeats := int(_enemy_memory.call("get_defeat_count", _selected_target.source_enemy_id))
	var required := _selected_target.get_required_source_defeats()
	memory_label.text = "SOURCE  •  %s  •  MEMORY %d / %d" % [_selected_target.source_enemy_display_name.to_upper(), defeats, required]
	if _selected_target.rarity == MaterialDefinition.MaterialRarity.BOSS:
		memory_label.text += "  •  CHARGES %d" % int(_enemy_memory.call("get_available_memory_charges", _selected_target.source_enemy_id))
	var points := _fuel_points()
	basket_label.text = "CRUCIBLE  •  %d STACKS  •  %d / %d MELD%s" % [_fuel_units(), points, _selected_target.get_transmutation_point_cost(), _catalyst_suffix()]
	var status: Dictionary = _exchange_service.call("get_transmutation_status", _selected_target, _fuel)
	transmute_result.text = _transmute_message if not _transmute_message.is_empty() else String(status["message"])
	transmute_button.disabled = not status["success"]
	transmute_button.text = "RECONSTRUCT %s" % _selected_target.display_name.to_upper()


func _select_sale(material: MaterialDefinition) -> void:
	_selected_sale = material
	_sell_message = ""
	sell_quantity.value = 1
	_refresh_sell_detail()


func _select_target(material: MaterialDefinition) -> void:
	_selected_target = material
	_transmute_message = ""
	_fuel.clear()
	_rebuild_fuel_list()
	_refresh_transmute_detail()


func _add_fuel(material: MaterialDefinition) -> void:
	_transmute_message = ""
	var selected := int(_fuel.get(material.material_id, 0))
	if selected < int(_material_inventory.call("get_quantity", material.material_id)):
		_fuel[material.material_id] = selected + 1
	_rebuild_fuel_list()
	_refresh_transmute_detail()


func _on_fuel_gui_input(event: InputEvent, material: MaterialDefinition) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_transmute_message = ""
		var selected := int(_fuel.get(material.material_id, 0))
		if selected <= 1:
			_fuel.erase(material.material_id)
		else:
			_fuel[material.material_id] = selected - 1
		rebuild_fuel_after_input()


func rebuild_fuel_after_input() -> void:
	_rebuild_fuel_list()
	_refresh_transmute_detail()


func auto_fill_fuel() -> void:
	if _selected_target == null:
		return
	_fuel = _exchange_service.call("build_automatic_fuel", _selected_target)
	_transmute_message = ""
	_rebuild_fuel_list()
	_refresh_transmute_detail()


func clear_fuel() -> void:
	_fuel.clear()
	_transmute_message = ""
	_rebuild_fuel_list()
	_refresh_transmute_detail()


func sell_selected() -> void:
	if _selected_sale == null:
		return
	var result: Dictionary = _exchange_service.call("try_sell", _selected_sale, int(sell_quantity.value))
	_sell_message = String(result["message"])
	_refresh_all()


func transmute_selected() -> void:
	if _selected_target == null:
		return
	var result: Dictionary = _exchange_service.call("try_transmute", _selected_target, _fuel)
	_transmute_message = String(result["message"])
	if result["success"]:
		_fuel.clear()
	_refresh_all()


func _on_sell_quantity_changed(_value: float) -> void:
	_sell_message = ""
	_refresh_sell_detail()


func _on_material_quantity_changed(_material_id: StringName, _quantity: int) -> void:
	for raw_id: Variant in _fuel.keys():
		var owned := int(_material_inventory.call("get_quantity", StringName(String(raw_id))))
		if owned <= 0:
			_fuel.erase(raw_id)
		elif int(_fuel[raw_id]) > owned:
			_fuel[raw_id] = owned
	_refresh_all()


func _on_progression_changed(_experience: int, _coins: int) -> void:
	_refresh_all()


func _on_enemy_memory_changed(_enemy_id: StringName, _count: int) -> void:
	_refresh_all()


func _make_material_button(material: MaterialDefinition, copy: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 42)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.icon = material.icon
	button.expand_icon = true
	button.text = "  " + copy
	button.tooltip_text = material.description
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


func _fuel_points() -> int:
	var points := 0
	for raw_id: Variant in _fuel:
		var material := MaterialCatalog.find_material(StringName(String(raw_id)))
		if material != null:
			points += material.get_meld_value() * int(_fuel[raw_id])
	return points


func _fuel_units() -> int:
	var units := 0
	for quantity: Variant in _fuel.values():
		units += int(quantity)
	return units


func _catalyst_suffix() -> String:
	if _selected_target == null or _selected_target.get_same_region_rare_catalyst_count() <= 0:
		return ""
	var rare_units := 0
	for raw_id: Variant in _fuel:
		var material := MaterialCatalog.find_material(StringName(String(raw_id)))
		if material != null and material.region_id == _selected_target.region_id and material.rarity == MaterialDefinition.MaterialRarity.RARE:
			rare_units += int(_fuel[raw_id])
	return "  •  RARE %d/%d" % [rare_units, _selected_target.get_same_region_rare_catalyst_count()]


func _owned_kind_count() -> int:
	var count := 0
	for material: MaterialDefinition in MaterialCatalog.materials:
		if int(_material_inventory.call("get_quantity", material.material_id)) > 0:
			count += 1
	return count


func _clear_children(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
