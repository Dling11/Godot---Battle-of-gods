extends SceneTree

const MenuScene = preload("res://ui/material_exchange/umi_exchange_menu.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("MaterialInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	root.get_node("EnemyMemory").reset_memory()
	root.get_node("MaterialInventory").add_material_batch({
		&"forest_mire_resin": 12,
		&"forest_root_fiber": 30,
		&"forest_living_bark_plate": 3,
	})
	root.get_node("RunSession").update_progression(0, 100)
	var menu := MenuScene.instantiate() as UmiExchangeMenu
	root.add_child(menu)
	await process_frame
	menu.open_menu()
	await process_frame
	if menu.get_node("Panel").size.x > 770.0 or menu.get_node("Panel").size.y > 430.0:
		_fail("Umi's exchange surface exceeded its compact 760x420 contract.")
		return
	if menu.get_node("Panel/Margin/Root/SellPage/ListPanel/ListScroll/SellList").get_child_count() != 3:
		_fail("Umi's sell list did not discover owned sellable materials from catalog metadata.")
		return
	menu.show_transmute_page()
	await process_frame
	if menu.get_node("Panel/Margin/Root/TransmutePage/Targets/Scroll/TargetList").get_child_count() != 9:
		_fail("Umi's reconstruction targets did not mirror the catalog's low-drop rarities.")
		return
	var target_list: VBoxContainer = menu.get_node("Panel/Margin/Root/TransmutePage/Targets/Scroll/TargetList")
	var owned_target_button: Button
	for child: Node in target_list.get_children():
		if child is Button and "LIVING BARK PLATE" in child.text:
			owned_target_button = child
			break
	if owned_target_button == null or "×3" not in owned_target_button.text:
		_fail("Umi's reconstruction row did not expose the owned target quantity.")
		return
	owned_target_button.pressed.emit()
	await process_frame
	var target_meta: Label = menu.get_node("Panel/Margin/Root/TransmutePage/Detail/Stack/TargetMeta")
	if "OWNED 3" not in target_meta.text:
		_fail("Umi's selected target detail did not expose the owned quantity.")
		return
	if menu.get_node("Panel/Margin/Root/TransmutePage/Fuel/Scroll/FuelList").get_child_count() != 2:
		_fail("Umi's fuel list did not retain owned Common materials for melding.")
		return
	menu.close_menu()
	menu.queue_free()
	await process_frame
	print("Compact metadata-driven Umi exchange menu smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
