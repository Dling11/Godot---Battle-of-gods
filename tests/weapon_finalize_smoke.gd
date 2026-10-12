extends SceneTree

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const TARGET = preload("res://entities/training/training_target.tscn")
const ITEMS := [preload("res://data/items/equipment/king_signature_sword.tres"),preload("res://data/items/equipment/king_iron_beard_axe.tres"),preload("res://data/items/equipment/king_twinsteel.tres"),preload("res://data/items/equipment/king_royal_greatsword_v2.tres")]
const OUT := "res://tmp/review/combat/weapon_impact_closure_2026_10_07/"
var evidence_path := OUT
var checks := 0
var failures := 0
var accepted: Array[Dictionary] = []
var phases: Array[float] = []
var rows: Array[Dictionary] = []

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"):
			evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	root.size = Vector2i(1280,720)
	root.get_node("SaveService").configure_storage_path_for_testing("user://weapon_finalize_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	await process_frame
	var actor: Player = lab.player
	actor.apply_debug_testing_preset()
	actor.set_process_unhandled_input(false)
	actor.set_physics_process(false)
	var attack := actor.attack_component
	var feedback := CombatFeedbackPresenter.find_for_player(actor)
	check(feedback != null,"Real Lab has no accepted-contact presenter")
	feedback.hitstop_enabled = false
	attack.set_equipment_attack_speed_bonus(0.0)
	attack.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void:
		accepted.append({"target":target.get_parent().get_instance_id(),"amount":info.amount,"type":info.damage_type,"knockback":info.knockback_strength,"stagger":info.stagger_seconds})
	)
	attack.phase_changed.connect(func(_phase: int, seconds: float) -> void: phases.append(seconds))
	var menu: CharacterMenu = lab.get_node("UI/CharacterMenu")
	for index in ITEMS.size():
		var item: EquipmentDefinition = ITEMS[index]
		var weapon := item.weapon_definition
		check(actor.equip_owned_weapon(item),"Bag ownership cannot equip "+item.display_name)
		actor.position = Vector2(350,300)
		actor._set_facing_direction(Vector2.RIGHT)
		await physics_frame
		check(weapon.hit_audio != null and weapon.hit_audio.variations.size()==3,"Missing dry contact pool")
		check(is_equal_approx(weapon.damage,25.0),"Basic tuning changed skill power")
		check(item.show_combo_details and item.get_stat_summary().contains("BASE DPS"),"Bag omits combo DPS")
		check(is_equal_approx(WeaponCombatReadout.duration(weapon),[1.91,3.19,2.20,2.34][index]),"Readout duration disagrees with accepted phase data")
		var targets: Array[Node2D] = []
		for side in [-1,1]:
			var target: Node2D = TARGET.instantiate()
			lab.get_node("World/Actors").add_child(target)
			target.collision_layer = 0
			target.get_node("HealthComponent").set_maximum_health(10000,false)
			target.get_node("HealthComponent").set_current_health(10000)
			targets.append(target)
		var health: HealthComponent = targets[0].get_node("HealthComponent")
		var initial_health := health.current_health
		var expected_loss := 0.0
		attack.reset_combo()
		for step in WeaponCombatReadout.steps(weapon):
			for target_index in targets.size():
				targets[target_index].global_position = attack.collision_shape.global_position + Vector2(42, -10 if target_index==0 else 10)
			await physics_frame
			accepted.clear()
			phases.clear()
			var audio_before: int = feedback._weapon_impact_index
			check(actor.request_primary_attack(),"Normal attack was rejected")
			var deadline := Time.get_ticks_msec()+4000
			while attack.phase != MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
			await physics_frame
			check(accepted.size()==2,"Cleave omitted a target or duplicated a paired-blade contact")
			check(feedback._weapon_impact_index==audio_before+1,"Cleave plays more than one shared impact")
			var range_hit := WeaponCombatReadout.step_range(weapon,step)
			for hit in accepted:
				check(hit.amount>=range_hit.x-0.001 and hit.amount<=range_hit.y+0.001,"Actual damage disagrees with Bag range")
				check(hit.type==DamageInfo.DamageType.PHYSICAL,"Weapon hit lost physical typing")
				check(is_equal_approx(hit.knockback,weapon.knockback_strength*weapon.combo.knockback_multipliers[step]),"Weapon control multiplier is wrong")
				if hit.target==targets[0].get_instance_id(): expected_loss+=hit.amount
			var audio_profile := weapon.get_hit_audio_for_step(step)
			check(audio_profile!=null,"Cut has no accepted-hit profile")
			if index==3:
				check((audio_profile!=weapon.hit_audio)==(step==3),"Greatsword smash override leaked into normal cuts")
			var audible := false
			for child in feedback.effects_parent.get_children():
				if child is AudioStreamPlayer2D and child.stream==audio_profile.stream_for(audio_before):
					audible = child.playing and child.bus==&"SFX" and is_equal_approx(child.volume_db,audio_profile.volume_db) and is_equal_approx(child.pitch_scale,audio_profile.pitch_for(audio_before))
			check(audible,"Native accepted hit did not play its family impact on SFX")
			while attack.phase != MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
			check(attack.phase==MeleeAttackComponent.Phase.IDLE,"Attack never recovered")
			check(phases.size()==3,"Basic contact lost a phase")
			if phases.size()==3:
				var real_seconds := phases[0]+phases[1]+phases[2]
				var data_seconds := weapon.combo.windups[step]+weapon.combo.contacts[step]+weapon.combo.recoveries[step]
				check(is_equal_approx(real_seconds,data_seconds),"Displayed cadence disagrees with runtime phases")
		check(is_equal_approx(initial_health-health.current_health,expected_loss),"Accepted HP loss differs from reported damage")
		# Armor changes applied damage, not the unbuffed Bag estimate.
		check(is_equal_approx(health.resolve_damage(20,DamageInfo.DamageType.PHYSICAL),20),"Neutral target changed physical damage")
		health.armor_rating=100
		check(is_equal_approx(health.resolve_damage(20,DamageInfo.DamageType.PHYSICAL),10),"Physical damage bypasses armor")
		for target in targets: target.queue_free()
		await physics_frame
		actor._clear_buffered_action()
		attack.reset_combo()
		var miss_audio_before: int = feedback._weapon_impact_index
		check(actor.request_primary_attack(),"Empty swing cannot start")
		var miss_deadline := Time.get_ticks_msec()+4000
		while attack.phase != MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<miss_deadline: await physics_frame
		check(feedback._weapon_impact_index==miss_audio_before,"Empty air swing creates a monster-impact sound")
		menu.open_menu()
		menu._on_equipment_selected(item)
		await process_frame
		await process_frame
		check(menu.equipment_detail_panel.item_icon.texture==item.icon and menu.equipment_detail_panel.item_icon.size==Vector2(64,64),"Bag preview omits or resizes finalized icon")
		check(menu.equipment_detail_panel.synergy_body.text.contains("Damage per hit"),"Bag lacks actual combo damage description")
		await capture(["sword_bag.png","axe_bag.png","dual_bag.png","greatsword_bag.png"][index])
		menu.close_menu()
		rows.append({"item":item.display_name,"base_roll":str(WeaponCombatReadout.base_range(weapon)),"combo_seconds":WeaponCombatReadout.duration(weapon),"base_dps":WeaponCombatReadout.base_dps(weapon),"chain_damage":str(WeaponCombatReadout.chain_range(weapon))})
	check(actor.weapon_catalog.weapons.size()==5 and actor.weapon_catalog.find_weapon(&"weapon_king_royal_greatsword")==null,"Retired Greatsword remains in the playable catalog")
	# Unchanged Varkuun equipment still uses the optional legacy audio fallback.
	var legacy_item := actor.weapon_catalog.find_weapon(&"weapon_varkuun_edge_essence")
	check(actor.equip_owned_weapon(legacy_item),"Cannot equip the unchanged campaign weapon")
	var legacy_before: int = feedback._weapon_impact_index
	feedback._play_basic_impact(actor.global_position)
	check(feedback._weapon_impact_index==legacy_before,"Null audio profile receives new impact cycling")
	var legacy_found := false
	for child in feedback.effects_parent.get_children():
		if child is AudioStreamPlayer2D and child.stream==feedback.sword_hit_sound:
			legacy_found = child.playing and is_equal_approx(child.pitch_scale,1.0) and is_zero_approx(child.volume_db)
	check(legacy_found,"Optional legacy impact fallback changed")
	menu._inventory_sort_mode=&"dps"
	check(menu._equipment_sort_less(ITEMS[1],ITEMS[2]) and menu._equipment_sort_less(ITEMS[2],ITEMS[0]),"DPS sort does not order actual nominal weapon DPS")
	menu._inventory_sort_mode=&"hit"
	check(menu._equipment_sort_less(ITEMS[1],ITEMS[0]) and menu._equipment_sort_less(ITEMS[0],ITEMS[2]),"Hit sort does not order maximum base rolls")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	FileAccess.open(evidence_path+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"weapons":rows},"\t"))
	lab.clear_simulation()
	# Let the last audition's transient stream finish before fixture teardown.
	await create_timer(.65).timeout
	lab.queue_free()
	await process_frame
	await process_frame
	print("Weapon finalize smoke: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	check(root.get_texture().get_image().save_png(evidence_path+filename)==OK,"Failed native Bag capture")
