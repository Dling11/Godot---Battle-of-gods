extends "res://tools/launch_generic_spawn_review.gd"

const TARGET = preload("res://entities/training/training_target.tscn")
const WEAPON = preload("res://data/weapons/varkuun_edge_essence.tres")
const OUT := "res://tmp/review/combat/critical_impact_2026_10_04/"
var checks := 0
var failures := 0

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/combat/critical_impact_2026_10_04/"))
	await super._run()
	root.size = Vector2i(960,540)
	toolbar.hide()
	_visit(Vector2(520,480))
	var actor: Player = stage.player
	actor.attack_component.set_weapon_definition(WEAPON)
	actor.set_physics_process(false)
	var target: Node2D = TARGET.instantiate()
	stage.get_node("World/Actors").add_child(target)
	target.global_position = actor.global_position+Vector2(24,0)
	var health: HealthComponent = target.get_node("HealthComponent")
	health.set_maximum_health(10000.0, false)
	health.set_current_health(10000.0)
	await create_timer(.3).timeout
	var presenter := CombatFeedbackPresenter.find_for_player(actor)
	check(presenter != null, "Actual stage feedback presenter missing")
	for critical: bool in [false,true]:
		actor.attack_component.cancel_attack()
		actor.attack_component.hitbox.configure_random_seed_for_testing(_seed_for(critical))
		var before := health.current_health
		check(actor.attack_component.request_attack(Vector2.RIGHT), "Real sword cast refused")
		for tick in 60:
			await physics_frame
			await process_frame
			if health.current_health < before: break
		check(health.current_health < before, "Real sword did not damage its target")
		var number: DamageNumber
		var burst: HitBurst
		for child in presenter.effects_parent.get_children():
			if child is DamageNumber: number = child
			if child is HitBurst: burst = child
		check(number != null and number._is_critical == critical, "Accepted hit critical state not presented")
		check(number != null and number.label.label_settings.font_size == (17 if critical else 11), "Rendered hit number size incorrect")
		check(burst != null and (not critical or burst._tint == presenter.CRITICAL_HIT_TINT), "Critical hit sparks lack red tint")
		if number != null:
			print("CRITICAL_ACTUAL_HIT critical=",critical," damage=",number._amount," text=",number.label.text," font=",number.label.label_settings.font_size)
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OUT+("critical_actual.png" if critical else "normal_actual.png")) == OK, "Native contact capture failed")
		await create_timer(.7).timeout
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(), "Review can mutate ordinary saves")
	stage.queue_free()
	await process_frame
	print("CRITICAL_FEEDBACK_VISUAL checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func _seed_for(critical: bool) -> int:
	for seed in 10000:
		var probe := RandomNumberGenerator.new()
		probe.seed = seed
		if (probe.randf()<WEAPON.critical_chance_ratio) == critical: return seed
	return -1

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
