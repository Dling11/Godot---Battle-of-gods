extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_twinsteel.tres")
const AXE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const GREAT = preload("res://data/items/equipment/king_royal_greatsword_v2.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
const OUT := "res://tmp/review/combat/king_twinsteel_gameplay_2026_10_05/"
var evidence_path := OUT
var starts: Array[int] = []
var contacts: Array[Dictionary] = []

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"):
			evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	root.size=Vector2i(1280,720)
	root.get_node("SaveService").configure_storage_path_for_testing("user://twinsteel_gameplay_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	root.get_node("RunSession").reset_run()
	var old_snapshot: Dictionary = inventory.create_snapshot()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene=lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	await process_frame
	var actor: Player = lab.player
	actor.position=Vector2(350,300)
	check(not inventory.owns_weapon(ITEM.item_id),"Twinsteel was granted to a fresh campaign without acquisition")
	await key(KEY_F9)
	check(inventory.owns_weapon(ITEM.item_id),"Normal F9 cannot grant Twinsteel")
	check(root.get_node("SaveService")._debug_autosave_suppressed,"F9 no longer suppresses test-kit autosaving")
	actor.set_process_unhandled_input(false)
	actor.set_physics_process(false)
	var menu: CharacterMenu = lab.get_node("UI/CharacterMenu")
	await key(KEY_TAB)
	check(menu.is_visible_in_tree() and paused,"Training Tab does not open the visible Bag")
	menu._on_equipment_selected(ITEM)
	menu.equipment_detail_panel.equip_requested.emit(ITEM)
	check(actor.get_equipped_weapon_item()==ITEM and actor.attack_component.weapon==ITEM.weapon_definition,"Normal Bag cannot equip Twinsteel")
	check(is_instance_valid(menu._family_portrait) and is_instance_valid(menu._family_portrait.offhand_rig),"Paper doll omits the paired blades")
	await capture("training_bag.png")
	await key(KEY_ESCAPE)
	check(not paused and not menu.visible,"Closing Twinsteel Bag leaves controls blocked")
	var attack := actor.attack_component
	var family := actor.get_node("WeaponFamilyPresentation")
	attack.attack_started.connect(func() -> void: starts.append(attack.combo_step))
	attack.hit_landed.connect(func(target: HurtboxComponent,_info: DamageInfo) -> void:
		contacts.append({"target":target.get_parent().get_instance_id(),"step":attack.combo_step})
	)
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		await physics_frame
		check(family.presenter.visible and not actor.get_node("VisualRoot/Body").visible,"Equipped pair draws two bodies")
		actor.velocity=direction*100
		await physics_frame
		var old_pose: int = family.presenter.pose_index
		actor.global_position+=direction*18
		await physics_frame
		check(family.presenter._running and family.presenter.definition==family.profile.run_for(direction) and family.presenter.pose_index!=old_pose,"Normal Player glides or uses the wrong running view")
		if absf(direction.x)>0:
			var main_guard: Vector2 = family.presenter.weapon_sprite.to_global(Vector2(8,41))
			var off_guard: Vector2 = family.presenter.offhand_sprite.to_global(Vector2(8,41))
			var main_texture: Texture2D = family.presenter.weapon_sprite.texture
			var off_texture: Texture2D = family.presenter.offhand_sprite.texture
			check(not main_texture.get_image().get_region(Rect2i(0,43,16,19)).is_invisible() and off_texture.get_image().get_region(Rect2i(0,43,16,19)).is_invisible(),"Normal side run exposes the far handle or removes the held near handle")
			await capture("training_run_right.png" if direction.x>0 else "training_run_left.png")
			check(actor.request_primary_attack(),"Attack from side running rejected")
			check(family.presenter.weapon_sprite.to_global(Vector2(8,41)).distance_to(main_guard)<.01 and family.presenter.offhand_sprite.to_global(Vector2(8,41)).distance_to(off_guard)<.01,"Run-to-attack entry changes the held blade offsets")
			check(family.presenter.weapon_sprite.texture==main_texture and family.presenter.offhand_sprite.texture==off_texture,"Run-to-attack opening flashes the hidden rear handle")
			await until_active(attack)
			check(family.presenter.weapon_sprite.texture==family.presenter.definition.weapon_texture and family.presenter.offhand_sprite.texture==family.presenter.definition.offhand.texture and not family.presenter.weapon_sprite.texture.get_image().get_region(Rect2i(0,43,16,19)).is_invisible() and not family.presenter.offhand_sprite.texture.get_image().get_region(Rect2i(0,43,16,19)).is_invisible(),"Attack fails to restore both complete swords after its carry entry")
			actor._clear_buffered_action()
			attack.cancel_attack()
		actor.velocity=Vector2.ZERO
		await physics_frame
		check(family.presenter.definition==family.profile.idle_for(direction),"Running does not settle to the paired idle")
		attack.reset_combo()
		starts.clear()
		check(actor.request_primary_attack(),"Normal Twinsteel primary input rejected")
		for step in 5:
			await until_active(attack)
			check(attack.combo_step==step and attack.get_attack_direction()==direction,"Buffered Twinsteel chain changes step/facing")
			var root_clip: Resource = family.profile.attack_for(direction)
			check(family.presenter.definition==(root_clip if step==0 else root_clip.follow_up_clips[step-1]),"Normal chain misses its authored directional cel")
			check(family.trail.z_index==(0 if direction==Vector2.UP else 3),"Upward white arcs obscure the body")
			if direction==Vector2.RIGHT and step==3: await capture("training_spin.png")
			if step in [0,4] and DisplayServer.get_name()!="headless":
				await physics_frame
				await physics_frame
				await verify_slash(family,direction,step)
			if step<4:
				check(actor.request_primary_attack(),"Normal input cannot buffer the next Twinsteel cut")
				await until_step(attack,step+1)
		await until_idle(attack)
		check(starts==[0,1,2,3,4] and actor._buffered_action==Player.BufferedAction.NONE,"Normal five-cut chain drops/repeats input")
	actor._set_facing_direction(Vector2.RIGHT)
	var front := make_target(lab,actor.global_position+Vector2(52,0))
	var rear := make_target(lab,actor.global_position+Vector2(-45,0))
	var outside := make_target(lab,actor.global_position+Vector2(110,0))
	await physics_frame
	contacts.clear()
	attack.reset_combo()
	actor.request_primary_attack()
	for step in 5:
		await until_active(attack)
		if step<4:
			actor.request_primary_attack()
			await until_step(attack,step+1)
	await until_idle(attack)
	var unique := {}
	var rear_steps: Array[int] = []
	for hit in contacts:
		var id := "%d/%d"%[hit.target,hit.step]
		check(not unique.has(id),"Two blades deal duplicated damage per input")
		unique[id]=true
		if hit.target==rear.get_instance_id(): rear_steps.append(hit.step)
	check(rear_steps==[3],"Rear contact occurs outside the single hopping spin")
	check(front.get_node("HealthComponent").current_health<10000 and outside.get_node("HealthComponent").current_health==10000,"Production contact ignores the reviewed reach")
	for target in [front,rear,outside]: target.queue_free()
	await process_frame
	# Use the normal skill inputs and their confirmation paths, then cancel.
	for slot in range(1,6):
		var ability := actor.get_ability_component_for_slot(slot)
		check(actor.request_ability(slot),"Equipped pair blocks skill input %d"%slot)
		if slot==1: actor._on_directional_targeting_confirmed(ability,Vector2.RIGHT)
		elif slot in [3,5]: actor._on_ground_targeting_confirmed(ability,actor.global_position+Vector2(24,0))
		await process_frame
		check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Skill %d leaves duplicated weapon/body art"%slot)
		ability.cancel_cast()
		actor._cancel_all_targeting()
		await physics_frame
		await physics_frame
		check(not actor.is_any_ability_casting() and not actor.is_cinematic_locked() and family.presenter.visible,"Skill %d cannot return to the pair"%slot)
	check(actor.request_evade(Vector2.LEFT),"Twinsteel blocks the normal dash")
	await process_frame
	check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Dash duplicates the family body")
	actor.evade_component.cancel_evade()
	await physics_frame
	lab.set_player_invincible(false)
	actor.health_component.set_temporary_shield(0.0)
	check(actor.health_component.apply_damage(DamageInfo.new(1.0,lab,Vector2.RIGHT,0.0,.08)),"Training hit cannot reach the player health pipeline")
	await process_frame
	check(not family.presenter.visible,"Hit reaction does not hide the family body")
	var reaction_deadline := Time.get_ticks_msec()+1000
	while (actor.is_in_hit_recovery() or not family.presenter.visible) and Time.get_ticks_msec()<reaction_deadline:
		await physics_frame
	check(not actor.is_in_hit_recovery() and family.presenter.visible,"Hit recovery cannot restore Twinsteel")
	lab.set_player_invincible(true)
	for item in [AXE,GREAT,ITEM,actor.weapon_catalog.default_weapon,ITEM]:
		check(actor.equip_owned_weapon(item),"Weapon switching rejected "+item.display_name)
		await process_frame
		check(family.profile==item.weapon_definition.family_presentation,"Weapon switch retains the previous family")
		var count := 0
		for child in actor.get_node("VisualRoot").get_children():
			if child.name=="FamilyBody": count+=1
		check(count==(0 if item.weapon_definition.family_presentation==null else 1),"Weapon switch leaks duplicate family nodes")
	var paired_snapshot: Dictionary = inventory.create_snapshot()
	check(inventory.can_restore_snapshot(paired_snapshot) and inventory.restore_snapshot(paired_snapshot),"One-slot pair cannot round-trip an inventory snapshot")
	check(inventory.get_equipped_weapon_id(&"king",&"")==ITEM.item_id,"Snapshot loses equipped Twinsteel")
	await capture("training_equipped.png")
	lab.queue_free()
	await process_frame
	await process_frame
	var stage := preload("res://levels/test_arena/test_arena.tscn").instantiate()
	root.add_child(stage)
	current_scene=stage
	await process_frame
	stage.player.set_physics_process(false)
	stage.player.set_process_unhandled_input(false)
	stage.player._set_facing_direction(Vector2.RIGHT)
	check(stage.player.attack_component.weapon==ITEM.weapon_definition and stage.player.get_node("WeaponFamilyPresentation").presenter.visible,"Normal Stage I loses the equipped pair")
	check(stage.player.request_primary_attack(),"Normal Stage I cannot use Twinsteel")
	await until_active(stage.player.attack_component)
	await capture("stage_1_equipped.png")
	stage.player._clear_buffered_action()
	stage.player.attack_component.cancel_attack()
	stage.queue_free()
	await process_frame
	check(inventory.can_restore_snapshot(old_snapshot) and inventory.restore_snapshot(old_snapshot),"Pre-Twinsteel inventory snapshots stopped restoring")
	FileAccess.open(evidence_path+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"training":true,"normal_stage":1,"skills":5,"art_modified_by_test":false},"\t")+"\n")
	print("TWINSTEEL_GAMEPLAY checks=%d failures=%d"%[checks,failures])
	quit(1 if failures else 0)

func make_target(lab: Node,point: Vector2) -> Node2D:
	var target: Node2D = TARGET.instantiate()
	lab.actors.add_child(target)
	target.global_position=point
	target.get_node("HealthComponent").set_maximum_health(10000,false)
	target.get_node("HealthComponent").set_current_health(10000)
	return target

func until_active(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.ACTIVE,"Timed out before contact")

func until_step(attack: MeleeAttackComponent,step: int) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while (attack.combo_step!=step or attack.phase==MeleeAttackComponent.Phase.IDLE) and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.combo_step==step and attack.phase!=MeleeAttackComponent.Phase.IDLE,"Buffered continuation timed out")

func until_idle(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while attack.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.IDLE,"Twinsteel does not settle")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode=code
	event.keycode=code
	event.pressed=true
	root.push_input(event)
	await process_frame
	event=event.duplicate()
	event.pressed=false
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(evidence_path+file)==OK,"Native capture failed")

func verify_slash(family: Node,direction: Vector2,step: int) -> void:
	# Freeze the same production Player pose for a with/without FX pair.
	# An atlas containing white pixels does not prove its runtime visibility.
	paused=true
	var trail: Node2D = family.trail
	check(trail.visible and trail._row==step and trail._frame>=0,"Actual attack has no active directional trail")
	var label := "right" if direction==Vector2.RIGHT else ("left" if direction==Vector2.LEFT else ("up" if direction==Vector2.UP else "down"))
	var prefix := "opening_cut" if step==0 else "final_slash"
	await capture(prefix+"_"+label+".png")
	var with_fx := root.get_texture().get_image()
	trail.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	var without_fx := root.get_texture().get_image()
	var bright_pixels := 0
	for y in with_fx.get_height():
		for x in with_fx.get_width():
			var a := with_fx.get_pixel(x,y)
			var b := without_fx.get_pixel(x,y)
			if minf(a.r,minf(a.g,a.b))>.55 and a.r+a.g+a.b-b.r-b.g-b.b>.4: bright_pixels+=1
	check(bright_pixels>30,"White "+prefix+" is absent from actual "+label+" rendering")
	print("TWINSTEEL_EFFECT ",prefix," ",label," bright_pixels=",bright_pixels)
	trail.show()
	paused=false
