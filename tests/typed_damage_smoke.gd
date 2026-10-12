extends SceneTree

const PLAYER = preload("res://entities/player/player.tscn")
const HOG = preload("res://entities/enemies/armored_hog/armored_hog.tscn")
var checks := 0
var failures := 0
var guard_amount := 0.0
var guard_kind := -1
var delivered: Array[DamageInfo] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://typed_damage_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var health := HealthComponent.new()
	health.maximum_health = 10000.0
	root.add_child(health)
	health.set_equipment_defenses(100.0,.2,300.0)
	check(is_equal_approx(health.resolve_damage(100.0),40.0), "Legacy physical mitigation changed")
	check(is_equal_approx(health.resolve_damage(100.0,DamageInfo.DamageType.MAGIC),20.0), "Magic ignores its separate resistance")
	check(is_equal_approx(health.resolve_damage(100.0,DamageInfo.DamageType.PURE),100.0), "Pure damage did not bypass reductions")
	check(is_equal_approx(health.resolve_damage(100.0,999),40.0), "Invalid type became pure damage")
	for kind: int in [DamageInfo.DamageType.PHYSICAL,DamageInfo.DamageType.MAGIC,DamageInfo.DamageType.PURE]:
		var before := health.current_health
		var info := DamageInfo.new(100.0,null,Vector2.RIGHT,0.0,0.0,true,0.0,kind)
		check(health.apply_damage(info), "Typed damage refused")
		check(is_equal_approx(before-health.current_health,[40.0,20.0,100.0][kind]), "Typed accepted HP damage incorrect")
		check(info.is_critical and info.damage_type == kind and info.stun_seconds == 0.0, "Type/crit implied a stun or lost metadata")
		check(is_equal_approx(info.amount,before-health.current_health) and info.raw_amount == 100.0, "Accepted feedback amount disagrees with HP")
	var before := health.current_health
	health.set_temporary_shield(60.0)
	check(health.apply_damage(DamageInfo.new(100.0,null,Vector2.ZERO,0.0,0.0,false,0.0,DamageInfo.DamageType.PURE)), "Pure shield hit refused")
	check(is_equal_approx(before-health.current_health,40.0) and health.shield_health == 0.0, "Pure bypassed temporary shield")
	health.damage_absorber = func(info: DamageInfo) -> bool:
		guard_amount = info.amount
		guard_kind = info.damage_type
		return true
	before = health.current_health
	check(health.apply_damage(DamageInfo.new(100.0,null,Vector2.ZERO,0.0,0.0,false,0.0,DamageInfo.DamageType.PURE)), "Pure guard hit refused")
	check(guard_amount == 100.0 and guard_kind == DamageInfo.DamageType.PURE and health.current_health == before, "Pure bypassed authored guard")
	health.damage_absorber = Callable()
	health.is_invulnerable = true
	check(not health.apply_damage(DamageInfo.new(100.0,null,Vector2.ZERO,0.0,0.0,false,0.0,DamageInfo.DamageType.PURE)), "Pure bypassed invulnerability")
	health.is_invulnerable = false
	health.is_damage_immune = true
	check(not health.apply_damage(DamageInfo.new(100.0,null,Vector2.ZERO,0.0,0.0,false,0.0,DamageInfo.DamageType.PURE)), "Pure bypassed debug/cinematic immunity")
	health.is_damage_immune = false
	check(DamageInfo.new(1.0,null,Vector2.ZERO).damage_type == DamageInfo.DamageType.PHYSICAL, "Legacy payload default changed")
	check(DamageInfo.new(1.0,null,Vector2.ZERO,0.0,0.0,false,0.0,-10).damage_type == DamageInfo.DamageType.PHYSICAL, "Invalid payload type was not sanitized")
	var actor: Player = PLAYER.instantiate()
	root.add_child(actor)
	actor.set_physics_process(false)
	await process_frame
	check(actor.ability_1_component.definition.get_damage_type_label() == "PHYSICAL DAMAGE", "Earthsplitter type wrong")
	check(actor.ability_2_component.definition.get_damage_type_label() == "MAGIC DAMAGE", "Molten Crash type wrong")
	check(actor.ability_3_component.definition.get_damage_type_label() == "PHYSICAL DAMAGE", "Pursuit blade impact type wrong")
	check(actor.ability_4_component.definition.get_damage_type_label() == "MAGIC DAMAGE", "Worldsplitter type wrong")
	check(actor.get_ability_component_for_slot(4).definition.get_damage_type_label() == "SELF BUFF", "Vow mislabeled as damage")
	var hitbox := MeleeHitbox.new()
	root.add_child(hitbox)
	hitbox.activate(100.0,actor,Vector2.RIGHT,0.0,0.0,0.0,1.5,0.0,DamageInfo.DamageType.MAGIC)
	check(hitbox._damage_type == DamageInfo.DamageType.MAGIC, "Directional hitbox loses type")
	hitbox.activate_radial(100.0,actor,Vector2.ZERO,0.0,0.0,0.0,1.5,0.0,DamageInfo.DamageType.PURE)
	check(hitbox._damage_type == DamageInfo.DamageType.PURE, "Radial hitbox loses type")
	hitbox.deactivate()
	var hog: ArmoredHog = HOG.instantiate()
	root.add_child(hog)
	hog.set_physics_process(false)
	hog.global_position = Vector2(300,300)
	hog.facing_direction = Vector2.RIGHT
	hog.state = ArmoredHog.State.BRACE
	hog.health_component.set_invulnerable(false)
	actor.global_position = Vector2(340,300)
	before = hog.health_component.current_health
	var guarded := DamageInfo.new(20.0,actor,Vector2.LEFT,0.0,.1,true,.5,DamageInfo.DamageType.PURE)
	check(hog.get_node("Hurtbox").receive_hit(guarded), "Hog guarded contact refused")
	check(guarded.is_critical and guarded.damage_type == DamageInfo.DamageType.PURE, "Hog brace erased critical/type metadata")
	check(is_equal_approx(guarded.amount,before-hog.health_component.current_health), "Hog guarded number disagrees with accepted damage")
	check(guarded.stun_seconds == 0.0, "Hog brace lost hard-stun protection")
	hog.queue_free()
	await process_frame
	var target: Node2D = load("res://entities/training/training_target.tscn").instantiate()
	root.add_child(target)
	target.collision_layer = 0
	var target_health: HealthComponent = target.get_node("HealthComponent")
	target_health.set_maximum_health(10000,false)
	target_health.set_current_health(10000)
	target_health.damaged.connect(func(info: DamageInfo) -> void: delivered.append(info))
	for slot in [1,2,5]:
		var ability: AbilityComponent = actor.get_ability_component_for_slot(slot)
		ability.definition = ability.definition.duplicate(true)
		if slot == 2: ability.definition.configure_form(MoltenCrashDefinition.Form.MATURE)
		if slot == 5: ability.apply_rank(2)
		ability.set_critical_profile(0.0,1.5)
		ability.clear_cooldown()
		target.global_position = actor.global_position+Vector2(55,0)
		await physics_frame
		await physics_frame
		delivered.clear()
		var accepted: bool = ability.request_cast(Vector2.RIGHT,25.0) if slot == 2 else ability.request_cast_at(target.global_position,25.0)
		check(accepted,"Typed skill cast refused")
		await create_timer(1.5).timeout
		var expected_contacts: int = ability.definition.strike_count() if slot==5 else (1 if slot==1 else 2)
		check(delivered.size()==expected_contacts,"Released skill %d lost or duplicated its contacts: %d/%d" % [slot,delivered.size(),expected_contacts])
		for info in delivered:
			check(info.damage_type == (DamageInfo.DamageType.PHYSICAL if slot==1 else DamageInfo.DamageType.MAGIC),"Released skill/pulse lost damage type")
	var plate: EquipmentDefinition = load("res://data/items/equipment/forest/stage_5_core/heartwood_plate.tres")
	check(root.get_node("GearInventory").acquire_item(plate) and actor.equip_owned_equipment(plate),"Heartwood Plate could not equip")
	check(actor.health_component.armor_rating == 30.0 and actor.health_component.magic_resistance_rating == 30.0,"Equipment lost physical or magic defense")
	check(plate.get_stat_summary().contains("MAGIC RESIST +30"),"Equipment summary hides magic resistance")
	for node in [health,actor,hitbox,target]: node.queue_free()
	await process_frame
	print("TYPED_DAMAGE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
