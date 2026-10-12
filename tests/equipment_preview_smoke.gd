extends SceneTree

const KingCatalog = preload("res://data/items/king_weapon_catalog.tres")
const KingSword = preload("res://data/weapons/king_signature_sword.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var expected_slots := PackedStringArray([
		"WEAPON", "HEAD", "PLATE", "GLOVES", "LEGGINGS", "BOOTS",
		"BRACER", "AMULET", "RING", "TALISMAN",
	])
	if PackedStringArray(EquipmentDefinition.Slot.keys()) != expected_slots:
		_fail("EquipmentDefinition lost the finalized one-weapon, five-armor, four-accessory slot contract.")
		return
	if (
		not KingCatalog.has_valid_layout()
		or KingCatalog.weapons.size() != 5
		or KingCatalog.default_weapon.weapon_definition != KingSword
		or KingSword.weapon_id != &"weapon_king_signature_sword"
		or not KingSword.uses_integrated_visual
		or KingSword.world_texture != null
		or KingSword.attack_style.style_id != &"king_sword_form"
		or not is_equal_approx(KingSword.basic_damage_minimum, 10.0)
		or not is_equal_approx(KingSword.basic_damage_maximum, 12.0)
	):
		_fail("King's signature sword identity, integrated presentation, or 10-12 normal damage is invalid.")
		return
	var varkuun_edge := KingCatalog.find_weapon(&"weapon_varkuun_edge_essence")
	if (
		varkuun_edge == null
		or not varkuun_edge.is_equippable_weapon()
		or not varkuun_edge.weapon_definition.uses_integrated_visual
		or not is_equal_approx(varkuun_edge.weapon_definition.damage, 38.0)
		or not is_equal_approx(varkuun_edge.weapon_definition.basic_damage_minimum, 16.0)
		or not is_equal_approx(varkuun_edge.weapon_definition.basic_damage_maximum, 20.0)
		or not is_equal_approx(varkuun_edge.weapon_definition.critical_chance_ratio, 0.08)
		or not is_equal_approx(varkuun_edge.weapon_definition.critical_damage_multiplier, 1.5)
		or not is_equal_approx(varkuun_edge.weapon_definition.wind_up_seconds, KingSword.wind_up_seconds)
		or not is_equal_approx(varkuun_edge.weapon_definition.active_seconds, KingSword.active_seconds)
		or not is_equal_approx(varkuun_edge.weapon_definition.recovery_seconds, KingSword.recovery_seconds)
		or varkuun_edge.get_stat_summary() != "BASIC HIT 16-20  •  SKILL POWER 38  •  CRIT 8%  •  PHYSICAL"
		or varkuun_edge.get_comparison_summary(KingCatalog.default_weapon)
		!= "+6 MIN HIT  •  +8 MAX HIT  •  +13 SKILL POWER  •  +8% CRIT"
		or not varkuun_edge.synergy_description.contains("150% damage")
	):
		_fail("Varkuun Edge lost its clear Stage 6-15 damage, crit, or unchanged-timing contract.")
		return
	print("King equipment catalog smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
