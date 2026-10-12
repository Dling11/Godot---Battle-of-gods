extends SceneTree

const PLAYER = preload("res://entities/player/player.tscn")
const TARGET = preload("res://entities/training/training_target.tscn")
const COUNTER = preload("res://gameplay/abilities/king/perfect_dodge_counter.gd")
var checks := 0
var failures := 0
var hits: Array[DamageInfo] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://perfect_counter_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var world := Node2D.new()
	root.add_child(world)
	var actor: Player = PLAYER.instantiate()
	world.add_child(actor)
	actor.global_position = Vector2(300,300)
	actor.set_physics_process(false)
	var counter: Node = COUNTER.new()
	actor.add_child(counter)
	var enemy := Node2D.new()
	world.add_child(enemy)
	enemy.add_to_group(&"enemies")
	await process_frame
	check(not counter.is_counter_ready(), "Counter starts ready")
	check(actor.evade_component.request_evade(Vector2.RIGHT), "Initial dodge refused")
	await create_timer(.03).timeout
	check(not actor.health_component.apply_damage(DamageInfo.new(10.0,enemy,Vector2.LEFT)), "Early dodge did not reject enemy damage")
	check(counter.is_counter_ready(), "Real early dodge rejection did not award counter")
	var remaining: float = counter._opportunity.time_left
	actor.health_component.apply_damage(DamageInfo.new(10.0,enemy,Vector2.LEFT))
	check(counter._opportunity.time_left <= remaining, "Same dodge crowd contacts refresh counter")
	paused = true
	await create_timer(.2,true).timeout
	check(counter.is_counter_ready() and is_equal_approx(counter._opportunity.time_left,remaining), "Paused counter opportunity keeps expiring")
	paused = false
	await create_timer(.4).timeout
	for tick in 12:
		if actor.evade_component.is_ready(): break
		await physics_frame
	check(actor.evade_component.is_ready(), "Dodge recovery did not finish normally")
	var target: Node2D = TARGET.instantiate()
	world.add_child(target)
	target.global_position = actor.global_position+Vector2(24,0)
	actor.attack_component.hit_landed.connect(func(_target: HurtboxComponent,info: DamageInfo) -> void: hits.append(info))
	check(actor.attack_component.request_attack(Vector2.RIGHT), "Counter sword refused")
	check(actor.attack_component.committed_perfect_counter and actor.attack_component.committed_damage_type == DamageInfo.DamageType.PURE, "Counter did not snapshot pure damage")
	check(is_equal_approx(actor.attack_component.committed_damage_multiplier,1.25), "Counter bonus budget incorrect")
	await create_timer(.35).timeout
	check(hits.size() == 1 and hits[0].damage_type == DamageInfo.DamageType.PURE, "Actual sword contact lost pure counter type/deduplication")
	check(not counter.is_counter_ready(), "Landed counter did not consume opportunity")
	check(hits.size() == 1 and hits[0].stun_seconds == 0.0, "Pure counter automatically stuns")
	actor.attack_component.cancel_attack()
	check(actor.attack_component.request_attack(Vector2.RIGHT), "Following ordinary attack refused")
	check(not actor.attack_component.committed_perfect_counter and actor.attack_component.committed_damage_type == DamageInfo.DamageType.PHYSICAL, "Pure counter leaks into subsequent ordinary swings")
	actor.attack_component.cancel_attack()
	actor.evade_component.cancel_evade()
	check(actor.evade_component.request_evade(Vector2.RIGHT), "Second dodge refused")
	await create_timer(.135).timeout
	actor.health_component.apply_damage(DamageInfo.new(10.0,enemy,Vector2.LEFT))
	check(not counter.is_counter_ready(), "Late ordinary dodge receives perfect counter")
	actor.evade_component.cancel_evade()
	actor.evade_component.request_evade(Vector2.RIGHT)
	actor.health_component.is_damage_immune = true
	actor.health_component.apply_damage(DamageInfo.new(10.0,enemy,Vector2.LEFT))
	check(not counter.is_counter_ready(), "Debug/cinematic immunity farms counters")
	actor.health_component.is_damage_immune = false
	actor.evade_component.cancel_evade()
	actor.evade_component.request_evade(Vector2.RIGHT)
	actor.health_component.apply_damage(DamageInfo.new(10.0,actor,Vector2.LEFT))
	check(not counter.is_counter_ready(), "Self damage farms counters")
	actor.health_component.apply_damage(DamageInfo.new(10.0,enemy,Vector2.LEFT))
	check(counter.is_counter_ready(), "Valid enemy contact not accepted after self contact")
	actor.evade_component.cancel_evade()
	actor.health_component.apply_damage(DamageInfo.new(1.0,enemy,Vector2.LEFT))
	check(not counter.is_counter_ready(), "Taking damage preserves unused counter")
	target.queue_free()
	await process_frame
	actor.evade_component.cancel_evade()
	check(actor.evade_component.request_evade(Vector2.RIGHT), "Whiff comparison dodge refused")
	actor.health_component.apply_damage(DamageInfo.new(10.0,enemy,Vector2.LEFT))
	check(actor.attack_component.request_attack(Vector2.RIGHT), "Empty counter swing refused")
	await create_timer(.35).timeout
	check(counter.is_counter_ready(), "A missed sword contact consumes the counter")
	await create_timer(.5).timeout
	check(not counter.is_counter_ready(), "Unused counter never expires")
	world.queue_free()
	await process_frame
	print("PERFECT_COUNTER checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
