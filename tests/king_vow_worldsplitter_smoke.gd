extends SceneTree

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const TARGET = preload("res://entities/training/training_target.tscn")
const OUT := "res://tmp/review/characters/king/vow_worldsplitter_2026_09_27/"
var failures := 0
var checks := 0
var hits := [0, 0, 0]
var stuns: Array[float] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var session := root.get_node("RunSession")
	session.reset_run()
	check(KingSkillCatalog.migrate_legacy_slots(["echoing_sever", "riftbreak", "sovereign_pursuit", "king_skill_4"]).slice(0,5) == KingSkillCatalog.IDS, "Old default loadout did not migrate to five skills")
	var custom := ["", "", "", "king_skill_4", "riftbreak", "", "", "", "", "sovereign_pursuit"]
	var migrated := KingSkillCatalog.migrate_legacy_slots(custom)
	check(migrated[3] == "unbroken_vow" and migrated[4] == "king_skill_4" and "riftbreak" in migrated and migrated[9] == "sovereign_pursuit", "Migration lost a customized technique")
	check(KingSkillCatalog.migrate_legacy_slots(migrated) == migrated, "Migration is not idempotent")
	var lab: Node = LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.set_enemy_ai_enabled(false)
	lab.set_player_invincible(false)
	var actor: Player = lab.player
	actor.position = Vector2(320, 340)
	var vow := actor.get_node("UnbrokenVowComponent") as UnbrokenVowComponent
	var world := actor.ability_4_component as KingSkill4Component
	var health := actor.health_component
	var mastery := actor.get_node("KingMastery") as KingMasteryComponent
	check(actor.get_ability_component_for_slot(4) == vow and actor.get_ability_component_for_slot(5) == world, "Fourth/fifth hotkeys are wrong")
	check(lab.combat_hud.get_skill_slot(4).ability_component == vow and lab.combat_hud.get_skill_slot(5).ability_component == world, "HUD bindings do not match skills")
	mastery.stacks = 3
	mastery._link.start(2.0)
	check(actor.request_ability(4), "Real slot 4 input cannot cast")
	await create_timer(.10, false, true).timeout
	check(not vow.active, "Shield activated before pressure contact")
	await create_timer(.09, false, true).timeout

	check(vow.active and is_equal_approx(health.shield_health, health.maximum_health*.25), "Foundation shield missing at contact")
	check(mastery.stacks == 3 and not mastery._link.is_stopped(), "Buff consumed Resolve or Pursuit link")
	await capture("01_vow_release.png")
	await create_timer(.16, false, true).timeout
	check(not vow.is_casting() and not actor.is_cinematic_locked(), "Vow did not return control after .32s")
	check(lab.combat_hud.get_node("VowStatus").visible, "Shield readout is not visible")
	var before := health.current_health
	health.set_equipment_defenses(100.0, 0.0)
	var shield_before := health.shield_health
	health.apply_damage(DamageInfo.new(20.0, actor, Vector2.RIGHT))
	check(is_equal_approx(health.current_health,before) and is_equal_approx(health.shield_health,shield_before-10.0), "Shield must absorb mitigated damage before HP")
	var overflow := 7.0
	var hit := DamageInfo.new((health.shield_health+overflow)*2.0, actor, Vector2.RIGHT)
	hit.ignores_invulnerability = true
	health.apply_damage(hit)
	check(is_equal_approx(health.current_health,before-overflow) and not vow.active and vow.get_damage_bonus() == 0.0, "Partial shield break did not pass overflow/end bonus")
	health.set_equipment_defenses(0.0, 0.0)
	for rank in 3:
		vow.apply_rank(rank)
		actor.get_node("KingSkillLibrary").refresh()
		check(vow.request_cast(Vector2.DOWN), "Rank cannot cast")
		await create_timer(.36, false, true).timeout
		check(vow.active and is_equal_approx(health.shield_health,health.maximum_health*[.25,.30,.35][rank]), "Rank shield does not scale")
		check(is_equal_approx(vow.get_damage_bonus(),[.12,.15,.18][rank]), "Rank damage bonus wrong")
		var expected_speed := actor.movement_component._base_max_speed*(1.0 if rank == 0 else 1.08)
		check(is_equal_approx(actor.movement_component.max_speed,expected_speed), "Rank movement bonus wrong")
	actor.movement_component.set_equipment_speed_bonus(.34)
	check(is_equal_approx(actor.movement_component.max_speed,actor.movement_component._base_max_speed*1.35), "Vow bypasses equipment speed cap")
	actor.attack_component._next_combo_step = 2
	check(actor.request_primary_attack(), "Mature third cut cannot start")
	check(actor.attack_component.committed_vow_finisher and is_equal_approx(actor.attack_component.committed_damage_multiplier,1.48), "Mature finisher bonus missing")
	await create_timer(.27, false, true).timeout
	await capture("02_mature_finisher.png")
	actor.attack_component.cancel_attack()
	vow._duration.timeout.emit()
	check(not vow.active and health.shield_health == 0.0 and is_equal_approx(actor.movement_component.max_speed,actor.movement_component._base_max_speed*1.34), "Expiry did not restore equipment movement")
	actor.movement_component.set_equipment_speed_bonus(0.0)
	vow.clear_cooldown()
	check(vow.request_cast(Vector2.UP), "Up-facing cast refused")
	vow.cancel_cast()
	await create_timer(.20, false, true).timeout
	check(not vow.active and health.shield_health == 0.0, "Interrupted startup granted a shield")
	mastery.clear()
	var targets: Array[Node2D] = []
	var cast_point := Vector2(470,300)
	for index in 3:
		var target := TARGET.instantiate() as Node2D
		lab.actors.add_child(target)
		target.collision_layer = 0 # Match enemy hurtbox tests; dummy art is not terrain.
		target.global_position = cast_point+Vector2([0,78,120][index],0)
		var target_health := target.get_node("HealthComponent") as HealthComponent
		target_health.set_maximum_health(10000.0,false)
		target_health.set_current_health(10000.0)
		target_health.damaged.connect(func(info: DamageInfo) -> void:
			hits[index] += 1
			if index == 0: stuns.append(info.stun_seconds))
		targets.append(target)
	await physics_frame
	await physics_frame
	check(actor.request_ability(5) and actor.ground_point_targeting.is_targeting(), "Slot 5 does not open targeting")
	actor.ground_point_targeting.cancel_targeting()
	check(world.request_cast_at(cast_point, 25.0), "Worldsplitter refused target")

	check(not world.request_cast_at(Vector2.ZERO,25.0) and world.get_target_global_position() == cast_point, "Rejected request altered a committed target")
	await create_timer(.64, false, true).timeout
	check(hits == [1,1,0], "Foundation plunge exceeded its 88px radius or duplicated damage")
	await capture("03_worldsplitter_contact.png")
	await create_timer(.12, false, true).timeout
	check(not world.is_casting(), "Worldsplitter still locks King after .32s")
	check(not get_nodes_in_group("worldsplitter_effects").is_empty(), "Embedded blade disappeared at recovery")
	check(actor.request_evade(Vector2.LEFT), "Released Worldsplitter prevents dodge input")
	await capture("04_worldsplitter_faults.png")
	await create_timer(.18, false, true).timeout

	check(hits == [1,1,0], "Foundation unexpectedly duplicated its one plunge")
	check(stuns == [.5], "Only final heavy contact should stun")
	await capture("05_worldsplitter_pressure.png")
	await create_timer(1.1, false, true).timeout
	check(get_nodes_in_group("worldsplitter_sequences").is_empty() and get_nodes_in_group("worldsplitter_effects").is_empty(), "Released skill nodes did not expire")
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(8,180)
	collision.shape = rectangle
	wall.add_child(collision)
	lab.actors.add_child(wall)
	wall.global_position = cast_point+Vector2(62,0)
	await physics_frame
	await physics_frame
	world.clear_cooldown()
	check(world.request_cast_at(cast_point,25.0), "Terrain test cast refused")
	await create_timer(.95,false,true).timeout
	check(hits == [2,2,0], "Worldsplitter lost authored range through scenery")
	world.clear_cooldown()
	check(actor.request_ability(5), "Terrain preview could not open")
	actor.ground_point_targeting.update_aim(cast_point+Vector2(300,0),Vector2.ZERO)
	var marker := actor.ground_point_targeting._aim_origin()+actor.ground_point_targeting._target_local
	actor.ground_point_targeting.confirm_targeting()
	check(world.get_target_global_position().distance_to(marker) < .01, "Full-range marker and committed impact disagree")
	world.cancel_cast()
	wall.queue_free()
	world.clear_cooldown()
	check(world.request_cast_at(cast_point,25.0), "Interrupted cast refused")
	world.cancel_cast()
	await create_timer(.5,false,true).timeout
	check(hits == [2,2,0], "Cancelled startup still released damage")
	vow.apply_rank(2)
	check(vow.request_cast(Vector2.LEFT), "Left-facing buff cast failed")
	await create_timer(.36, false, true).timeout
	actor.health_component.set_current_health(1.0)
	var verdict := DamageInfo.new(800.0, targets[0], Vector2.LEFT)
	verdict.ignores_invulnerability = true
	health.apply_damage(verdict)
	check(actor.is_defeated and not vow.active and health.shield_health == 0.0, "Verdict/defeat failed to overwhelm and clear shield")
	lab.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("VOW_WORLDSPLITTER: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file) == OK, "Capture failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
