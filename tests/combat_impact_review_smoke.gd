extends "res://tools/launch_combat_impact_review.gd"

const TARGET = preload("res://entities/training/training_target.tscn")
const CRIT_FRAMES = preload("res://assets/vfx/combat/critical_impact/frames.tres")
const OUT := "res://tmp/review/combat/critical_impact_2026_10_04/"
var checks := 0
var failures := 0

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/combat/critical_impact_2026_10_04/"))
	await super._run()
	root.size = Vector2i(960,540)
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(), "Review can mutate normal saves")
	check(stage.player.get_node_or_null("PerfectDodgeCounter") != null, "Counter prototype missing from review")
	check(not stage.player.health_component.is_damage_immune, "Counter review silently makes King immune")
	check(CRIT_FRAMES.get_frame_count(&"critical") == 4 and not CRIT_FRAMES.get_animation_loop(&"critical"), "Critical clip not four bounded drawings")
	var atlas: Texture2D
	for index in 4:
		var texture := CRIT_FRAMES.get_frame_texture(&"critical",index) as AtlasTexture
		check(texture != null and texture.region.size == Vector2(48,48), "Critical frame canvas inconsistent")
		if index == 0: atlas = texture.atlas
		check(texture.atlas == atlas, "Critical frames do not share one cached atlas")
		var picture := texture.get_image()
		var binary := true
		for y in picture.get_height():
			for x in picture.get_width():
				var alpha := picture.get_pixel(x,y).a
				if alpha != 0.0 and alpha != 1.0: binary = false
		check(binary, "Critical texture has blurred alpha")
	await _capture("review_controls.png")
	toolbar.hide()
	var actor: Player = stage.player
	actor.set_physics_process(false)
	var target: Node2D = TARGET.instantiate()
	stage.get_node("World/Actors").add_child(target)
	target.global_position = actor.global_position+Vector2(24,0)
	var health: HealthComponent = target.get_node("HealthComponent")
	health.set_maximum_health(10000,false)
	health.set_current_health(10000)
	health.set_equipment_defenses(100.0,.2,300.0)
	var presenter := CombatFeedbackPresenter.find_for_player(actor)
	await create_timer(.2).timeout
	_showcase_crit = false
	for choice in range(1,4):
		_type_choice = choice
		_apply_player_profile()
		actor.attack_component.cancel_attack()
		var before := health.current_health
		check(actor.attack_component.request_attack(Vector2.RIGHT), "Typed review attack refused")
		await _await_contact(health,before)
		var number := _last_number(presenter)
		check(number != null and health.current_health<before, "Real typed review contact missing")
		if number != null:
			check(is_equal_approx(number._amount,before-health.current_health), "Typed number disagrees with actual accepted HP damage")
			var expected := [presenter.PLAYER_HIT_TINT,presenter.MAGIC_HIT_TINT,presenter.PURE_HIT_TINT][choice-1] as Color
			check(number._tint == expected and not number._is_critical, "Type presentation incorrect")
			print("TYPED_REVIEW kind=",DamageInfo.type_name(choice-1)," accepted=",number._amount)
		await _capture("type_%s.png" % DamageInfo.type_name(choice-1).to_lower())
		await create_timer(.65).timeout
	_type_choice = 0
	_showcase_crit = true
	_apply_player_profile()
	check(actor.attack_component.weapon.damage_type == DamageInfo.DamageType.PHYSICAL, "Authored weapon restoration leaked review type")
	var seed := -1
	for value in 10000:
		var random := RandomNumberGenerator.new()
		random.seed = value
		if random.randf()<.5:
			seed = value
			break
	actor.attack_component.cancel_attack()
	actor.attack_component.hitbox.configure_random_seed_for_testing(seed)
	var before := health.current_health
	check(actor.attack_component.request_attack(Vector2.RIGHT), "Critical review cast refused")
	await _await_contact(health,before)
	var critical := _last_number(presenter)
	check(critical != null and critical._is_critical, "Actual critical marker missing")
	var sprite: AnimatedSprite2D
	for child in presenter.effects_parent.get_children():
		if child.get_script() == presenter.CRITICAL_BURST:
			sprite = child.get_child(0) as AnimatedSprite2D
	check(sprite != null and sprite.sprite_frames == CRIT_FRAMES, "Critical marker uses wrong or uncached animation")
	if sprite != null:
		sprite.pause()
		for index in 4:
			sprite.frame = index
			await _capture("critical_frame_%d.png" % index)
		sprite.get_parent().queue_free()
	_longer_reach = true
	_apply_player_profile()
	check(is_equal_approx(actor.attack_component.weapon.get_melee_forward_reach_pixels(),42.0), "42px comparison not applied")
	check(is_equal_approx(actor.attack_component.weapon.get_melee_half_width_pixels(),22.0), "Reach comparison altered width")
	_longer_reach = false
	_apply_player_profile()
	check(is_equal_approx(actor.attack_component.weapon.get_melee_forward_reach_pixels(),36.0), "Authored reach did not restore")
	check(is_equal_approx(load("res://data/weapons/king_signature_sword.tres").get_melee_forward_reach_pixels(),36.0), "Review mutated shared weapon shape")
	target.queue_free()
	await process_frame
	var foe: Rootling = load("res://entities/enemies/rootling/rootling.tscn").instantiate()
	var rewards := foe.get_node("EnemyRewardComponent")
	foe.remove_child(rewards)
	rewards.free()
	foe.target = actor
	foe.position = actor.global_position-Vector2(28,0)
	foe.root_jab_erupted.connect(func(_direction: Vector2) -> void:
		actor.evade_component.request_evade(Vector2.UP), CONNECT_ONE_SHOT)
	stage.get_node("World/Actors").add_child(foe)
	var counter := actor.get_node("PerfectDodgeCounter")
	var deadline := Time.get_ticks_msec()+3000
	var hp_before := actor.health_component.current_health
	while not counter.is_counter_ready() and Time.get_ticks_msec()<deadline:
		await physics_frame
		await process_frame
	check(counter.is_counter_ready(), "Actual Rootling jab does not award the early-dodge counter")
	check(is_equal_approx(actor.health_component.current_health,hp_before), "Perfect dodge took health damage")
	stage.queue_free()
	await process_frame
	print("COMBAT_IMPACT_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func _await_contact(health: HealthComponent,before: float) -> void:
	for tick in 60:
		await physics_frame
		await process_frame
		if health.current_health<before: return

func _last_number(presenter: CombatFeedbackPresenter) -> DamageNumber:
	var result: DamageNumber
	for child in presenter.effects_parent.get_children():
		if child is DamageNumber: result = child
	return result

func _capture(file: String) -> void:
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(OUT+file) == OK, "Native review capture failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
