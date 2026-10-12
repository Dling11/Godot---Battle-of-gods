extends Node

## Atomic sell and reconstruction authority for Umi's Echo Crucible. All
## material behavior comes from MaterialDefinition metadata and the catalog.

signal material_sold(material_id: StringName, quantity: int, gold_received: int)
signal material_transmuted(material_id: StringName)
signal exchange_failed(reason: StringName)

const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const BOSS_MEMORY_INTERVAL := 10


func get_sell_status(material: MaterialDefinition, quantity: int) -> Dictionary:
	if not _is_catalog_material(material) or quantity <= 0:
		return _failure(&"invalid_sale", "INVALID SALE")
	var unit_value := material.get_sell_value()
	if unit_value <= 0:
		return _failure(&"protected_material", "BOSS MATERIALS CANNOT BE SOLD")
	if not MaterialInventory.has_material(material.material_id, quantity):
		return _failure(&"missing_materials", "NOT ENOUGH MATERIALS")
	return {
		"success": true,
		"reason": &"ready",
		"message": "SELL %d FOR %d GOLD" % [quantity, unit_value * quantity],
		"gold": unit_value * quantity,
	}


func try_sell(material: MaterialDefinition, quantity: int) -> Dictionary:
	var status := get_sell_status(material, quantity)
	if not status["success"]:
		exchange_failed.emit(status["reason"])
		return status
	var material_snapshot := MaterialInventory.create_snapshot()
	var run_snapshot := RunSession.create_snapshot()
	if not MaterialInventory.remove_material(material.material_id, quantity):
		return _transaction_failure(&"material_spend_failed", "MATERIAL SPEND FAILED", material_snapshot, run_snapshot)
	if not RunSession.add_coins(int(status["gold"])):
		return _transaction_failure(&"gold_grant_failed", "GOLD GRANT FAILED", material_snapshot, run_snapshot)
	if not SaveService.save_profile():
		return _transaction_failure(&"save_failed", "SALE FAILED TO SAVE", material_snapshot, run_snapshot)
	material_sold.emit(material.material_id, quantity, int(status["gold"]))
	return {
		"success": true,
		"reason": &"sold",
		"message": "SOLD %d %s • +%d GOLD" % [quantity, material.display_name.to_upper(), int(status["gold"])],
	}


func get_transmutation_status(target: MaterialDefinition, fuel: Dictionary) -> Dictionary:
	if not _is_catalog_material(target) or not target.is_reconstruction_target():
		return _failure(&"invalid_target", "MATERIAL CANNOT BE RECONSTRUCTED")
	if not MaterialInventory.can_add_material(target.material_id, 1):
		return _failure(&"stack_full", "MATERIAL STACK IS FULL")
	var defeats := EnemyMemory.get_defeat_count(target.source_enemy_id)
	var required_defeats := target.get_required_source_defeats()
	if defeats < required_defeats:
		return _failure(
			&"memory_locked",
			"SOURCE MEMORY %d / %d  •  DEFEAT %s" % [defeats, required_defeats, target.source_enemy_display_name.to_upper()]
		)
	var fuel_status := _evaluate_fuel(target, fuel)
	if not fuel_status["success"]:
		return fuel_status
	var gold_cost := target.get_transmutation_gold_cost()
	if not RunSession.can_spend_coins(gold_cost):
		return _failure(&"missing_gold", "GOLD %d / %d" % [RunSession.coins, gold_cost])
	if target.rarity == MaterialDefinition.MaterialRarity.BOSS:
		if EnemyMemory.get_available_memory_charges(target.source_enemy_id, BOSS_MEMORY_INTERVAL) <= 0:
			return _failure(&"boss_memory_missing", "BOSS MEMORY CHARGE REQUIRED • 1 PER 10 VICTORIES")
	return {
		"success": true,
		"reason": &"ready",
		"message": "READY • %d/%d MELD • %d GOLD" % [fuel_status["points"], target.get_transmutation_point_cost(), gold_cost],
		"points": fuel_status["points"],
		"gold_cost": gold_cost,
	}


func try_transmute(target: MaterialDefinition, fuel: Dictionary) -> Dictionary:
	var status := get_transmutation_status(target, fuel)
	if not status["success"]:
		exchange_failed.emit(status["reason"])
		return status
	var material_snapshot := MaterialInventory.create_snapshot()
	var run_snapshot := RunSession.create_snapshot()
	var memory_snapshot := EnemyMemory.create_snapshot()
	if not MaterialInventory.remove_material_batch(fuel):
		return _transmutation_failure(&"fuel_spend_failed", "MELD SPEND FAILED", material_snapshot, run_snapshot, memory_snapshot)
	if not MaterialInventory.add_material(target.material_id, 1):
		return _transmutation_failure(&"output_failed", "RECONSTRUCTION OUTPUT FAILED", material_snapshot, run_snapshot, memory_snapshot)
	if not RunSession.spend_coins(int(status["gold_cost"])):
		return _transmutation_failure(&"gold_spend_failed", "GOLD SPEND FAILED", material_snapshot, run_snapshot, memory_snapshot)
	if target.rarity == MaterialDefinition.MaterialRarity.BOSS:
		if not EnemyMemory.spend_memory_charge(target.source_enemy_id, BOSS_MEMORY_INTERVAL):
			return _transmutation_failure(&"boss_memory_spend_failed", "BOSS MEMORY SPEND FAILED", material_snapshot, run_snapshot, memory_snapshot)
	if not SaveService.save_profile():
		return _transmutation_failure(&"save_failed", "RECONSTRUCTION FAILED TO SAVE", material_snapshot, run_snapshot, memory_snapshot)
	material_transmuted.emit(target.material_id)
	return {"success": true, "reason": &"transmuted", "message": "RECONSTRUCTED %s • SAVED" % target.display_name.to_upper()}


func build_automatic_fuel(target: MaterialDefinition) -> Dictionary:
	var candidates: Array[MaterialDefinition] = []
	for material: MaterialDefinition in MaterialCatalog.materials:
		if material != target and material.get_meld_value() > 0 and MaterialInventory.get_quantity(material.material_id) > 0:
			candidates.append(material)
	candidates.sort_custom(func(a: MaterialDefinition, b: MaterialDefinition) -> bool: return a.get_meld_value() < b.get_meld_value())
	var fuel := {}
	var points := 0
	var rare_needed := target.get_same_region_rare_catalyst_count()
	if rare_needed > 0:
		for material: MaterialDefinition in candidates:
			if material.region_id != target.region_id or material.rarity != MaterialDefinition.MaterialRarity.RARE:
				continue
			var take := mini(MaterialInventory.get_quantity(material.material_id), rare_needed)
			if take > 0:
				fuel[material.material_id] = take
				points += take * material.get_meld_value()
				rare_needed -= take
			if rare_needed <= 0:
				break
	for material: MaterialDefinition in candidates:
		if points >= target.get_transmutation_point_cost():
			break
		var already := int(fuel.get(material.material_id, 0))
		var available := MaterialInventory.get_quantity(material.material_id) - already
		if available <= 0:
			continue
		var value := material.get_meld_value()
		var needed := ceili(float(target.get_transmutation_point_cost() - points) / float(value))
		var take := mini(available, needed)
		fuel[material.material_id] = already + take
		points += take * value
	return fuel


func _evaluate_fuel(target: MaterialDefinition, fuel: Dictionary) -> Dictionary:
	if fuel.is_empty() or not MaterialInventory.can_remove_material_batch(fuel):
		return _failure(&"missing_fuel", "SELECT OWNED MATERIALS TO MELD")
	var points := 0
	var same_region_rare_units := 0
	for raw_id: Variant in fuel:
		var material := MaterialCatalog.find_material(StringName(String(raw_id)))
		var quantity := int(fuel[raw_id])
		if material == null or material == target or material.get_meld_value() <= 0:
			return _failure(&"invalid_fuel", "PROTECTED OR CIRCULAR FUEL")
		points += material.get_meld_value() * quantity
		if material.region_id == target.region_id and material.rarity == MaterialDefinition.MaterialRarity.RARE:
			same_region_rare_units += quantity
	var catalysts := target.get_same_region_rare_catalyst_count()
	if same_region_rare_units < catalysts:
		return _failure(&"missing_catalyst", "SAME-REGION RARE CATALYST %d / %d" % [same_region_rare_units, catalysts])
	if points < target.get_transmutation_point_cost():
		return _failure(&"insufficient_points", "MELD VALUE %d / %d" % [points, target.get_transmutation_point_cost()])
	return {"success": true, "points": points}


func _is_catalog_material(material: MaterialDefinition) -> bool:
	return material != null and material.is_valid() and MaterialCatalog.find_material(material.material_id) == material


func _transaction_failure(reason: StringName, message: String, material_snapshot: Dictionary, run_snapshot: Dictionary) -> Dictionary:
	MaterialInventory.restore_snapshot(material_snapshot)
	RunSession.restore_snapshot(run_snapshot)
	exchange_failed.emit(reason)
	return _failure(reason, message)


func _transmutation_failure(reason: StringName, message: String, material_snapshot: Dictionary, run_snapshot: Dictionary, memory_snapshot: Dictionary) -> Dictionary:
	MaterialInventory.restore_snapshot(material_snapshot)
	RunSession.restore_snapshot(run_snapshot)
	EnemyMemory.restore_snapshot(memory_snapshot)
	exchange_failed.emit(reason)
	return _failure(reason, message)


func _failure(reason: StringName, message: String) -> Dictionary:
	return {"success": false, "reason": reason, "message": message}
