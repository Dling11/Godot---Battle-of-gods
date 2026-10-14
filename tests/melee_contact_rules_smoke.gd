extends SceneTree

const ITEM = preload("res://data/items/equipment/king_iron_reaper.tres")
const ROOTLING = preload("res://entities/enemies/rootling/rootling.tscn")
const HUSK = preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn")
var checks := 0
var failures := 0
var delivered: Array[DamageInfo] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var source := CharacterBody2D.new()
	root.add_child(source)
	var hitbox := MeleeHitbox.new()
	root.add_child(hitbox)
	hitbox.hit_landed.connect(func(_target: HurtboxComponent, info: DamageInfo) -> void: delivered.append(info))
	var light: Rootling = ROOTLING.instantiate()
	root.add_child(light)
	light.set_physics_process(false)
	light.global_position = Vector2(72, 0)
	light.health_component.set_maximum_health(1000, false)
	light.health_component.set_current_health(1000)
	var hurtbox := light.get_node("Hurtbox") as HurtboxComponent
	var combo := ITEM.weapon_definition.combo
	check(combo.contact_rule(0) == null and combo.contact_rule(2) == null, "Ordinary cuts unexpectedly apply the specialty")
	hitbox.activate(20, source, Vector2.RIGHT, 16, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(1))
	hitbox._try_hit(hurtbox)
	check(delivered.size() == 1 and delivered[0].amount == 20, "Hook altered damage or lost accepted contact")
	check(light.knockback_component.velocity.x < 0 and light.knockback_component.velocity.length() <= 300, "Light target was not pulled inward by the bounded impulse")
	hitbox._try_hit(hurtbox)
	check(delivered.size() == 1 and light.health_component.current_health == 980, "Hook awards duplicate damage")
	light.knockback_component.clear()
	light.global_position = Vector2(31, 0)
	hitbox.activate(20, source, Vector2.RIGHT, 16, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(1))
	hitbox._try_hit(hurtbox)
	check(light.knockback_component.velocity.length() > 0 and light.knockback_component.velocity.length() <= 37.5, "Close hook overshoots its 28px stand-off")
	light.knockback_component.clear()
	light.global_position = Vector2(20, 0)
	hitbox.activate(20, source, Vector2.RIGHT, 16, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(1))
	hitbox._try_hit(hurtbox)
	check(light.knockback_component.velocity.is_zero_approx(), "Point-blank hook drags a target through King")
	var boss: RootboundHusk = HUSK.instantiate()
	root.add_child(boss)
	boss.set_physics_process(false)
	boss.health_component.set_current_health(boss.health_component.maximum_health)
	boss.global_position = Vector2(72, 0)
	hitbox.activate(20, source, Vector2.RIGHT, 16, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(1))
	hitbox._try_hit(boss.get_node("Hurtbox"))
	check(not boss.knockback_component.accepts_light_pressure() and boss.knockback_component.velocity.x >= 0, "Husk ignores its authored pull resistance")
	for hp in [400.0, 399.0]:
		light.health_component.set_current_health(hp)
		delivered.clear()
		hitbox.activate(20, source, Vector2.RIGHT, 0, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(3))
		hitbox._try_hit(hurtbox)
		check(delivered.size() == 1 and delivered[0].amount == (25 if hp < 400 else 20), "Reap does not use pre-hit HP strictly below 40 percent")
	light.health_component.set_current_health(300)
	light.health_component.armor_rating = 100
	delivered.clear()
	hitbox.activate(20, source, Vector2.RIGHT, 0, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(3))
	# Production crit chance caps at 50 percent. Force a resolved critical
	# for composition coverage rather than relying on a random capped roll.
	hitbox._is_critical = true
	hitbox._damage = 30
	hitbox._try_hit(hurtbox)
	check(delivered[0].is_critical and delivered[0].raw_amount == 37.5 and delivered[0].amount == 18.75, "Reap bypasses armor or critical composition")
	delivered.clear()
	hitbox.activate(20, source, Vector2.RIGHT)
	hitbox._try_hit(hurtbox)
	check(delivered[0].raw_amount == 20 and delivered[0].light_pull_distance == 0, "Specialty leaks into ordinary directional hits")
	delivered.clear()
	hitbox.activate_radial(20, source, Vector2.ZERO)
	hitbox._try_hit(hurtbox)
	check(delivered[0].raw_amount == 20 and delivered[0].light_pull_distance == 0, "Specialty leaks into radial skills")
	light.health_component.is_invulnerable = true
	delivered.clear()
	light.knockback_component.clear()
	hitbox.activate(20, source, Vector2.RIGHT, 0, 0, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(1))
	hitbox._try_hit(hurtbox)
	check(delivered.is_empty() and light.knockback_component.velocity.is_zero_approx(), "Blocked contact still pulls a target")
	# Real free movement must respect the cap too, without a wall hiding overshoot.
	light.health_component.is_invulnerable = false
	light.health_component.armor_rating = 0
	light.target = source
	light.set_physics_process(true)
	light.state = Rootling.State.CHASE
	for distance in [72.0, 31.0]:
		light.global_position = Vector2(distance, 0)
		light.velocity = Vector2.ZERO
		light._applied_knockback_velocity = Vector2.ZERO
		light.knockback_component.clear()
		hitbox.activate(1, source, Vector2.RIGHT, 16, 0.5, 0, 1.5, 0, DamageInfo.DamageType.PHYSICAL, combo.contact_rule(1))
		hitbox._try_hit(hurtbox)
		await create_timer(0.2).timeout
		check(light.position.x < distance and distance - light.position.x <= 24.01 and light.position.x >= 27.99, "Physical free pull exceeds its cap or stand-off")
	for node in [source, hitbox, light, boss]: node.queue_free()
	await process_frame
	print("MELEE_CONTACT_RULES checks=", checks, " failures=", failures)
	quit(1 if failures else 0)


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
