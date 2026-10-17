extends "res://tests/sanctuary_test_base.gd"

const PROFILE := "user://weapon_mentor_smoke.json"
const Layout = preload("res://levels/sanctuary/town/sanctuary_layout.gd")
class RejectingSave:
	extends Node
	func is_autosave_suppressed_for_debug() -> bool: return false
	func save_profile() -> bool: return false
var committed := 0

func _run() -> void:
	AudioServer.set_bus_mute(0,true)
	root.size = Vector2i(960,540)
	var save := root.get_node("SaveService")
	var training := root.get_node("WeaponTraining")
	check(save.configure_storage_path_for_testing(PROFILE),"Cannot isolate mentor profile")
	save.delete_profile()
	training.reset_training()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	var legacy: Dictionary = save.create_profile_snapshot()
	legacy.extensions.erase("weapon_training")
	check(save.can_restore_profile(legacy),"Pre-mentor profile is rejected")
	check(save.restore_profile(legacy) and not training.has_technique(&"axe_war_cyclone"),"Legacy profile grants an unearned proof")
	var bad: Dictionary = legacy.duplicate(true)
	bad.extensions.weapon_training = {"version":1,"proofs":["invented_unlock"]}
	check(not save.restore_profile(bad),"Unknown proof mutates a save")
	check(not training.complete_axe_lesson(null),"Null trial grants a skill")
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await create_timer(.2).timeout
	var town := hub.get_node("SanctuaryTown")
	var court: Node = town.weapon_court
	var trial: Node = court.trial
	var actor: Player = hub.player
	var old_weapon := actor.attack_component.weapon
	var old_inventory: Dictionary = root.get_node("WeaponInventory").create_snapshot()
	var old_bounds := actor.movement_bounds
	check(not actor.war_cyclone.is_available(),"Fresh player has Cyclone")
	var space := actor.get_world_2d().direct_space_state
	check(not _blocked(space,Layout.MENTOR_APPROACH),"Mentor approach is blocked")
	var veyr: AnimatedSprite2D = court.mentor.get_node("Sprite")
	var orren: AnimatedSprite2D = hub.weapon_merchant.get_node("Sprite")
	var mentor_shadow: Polygon2D = court.mentor.get_node("Shadow")
	check(mentor_shadow.color.a>0 and mentor_shadow.z_index<veyr.z_index,"Mentor has no visible ground shadow below his body")
	check(absf(mentor_shadow.position.y+2)<.1,"Mentor shadow does not share the NPC foot anchor")
	var expected_height := orren.sprite_frames.get_frame_texture(orren.animation,0).get_image().get_used_rect().size.y*absf(orren.global_scale.y)
	for frame in 8:
		var texture := veyr.sprite_frames.get_frame_texture(veyr.animation,frame)
		var used := texture.get_image().get_used_rect()
		var world_height := used.size.y*absf(veyr.global_scale.y)
		var sole := veyr.position.y+(used.end.y-texture.get_height()/2.0)*veyr.scale.y
		check(absf(world_height-expected_height)<=1.5,"Veyr does not match Orren's actual WORLD height")
		check(absf(sole)<=1,"Veyr's boots lose the shared NPC ground origin")
	check(court.pavilion.get_meta(&"service_id")==&"weapon_mentor","Mentor has no purpose-built station")
	check(hub.expedition_altar.position==Layout.GATE and hub.expedition_altar.position.x>768,"Gate was not relocated to its northeast court")
	var post: Node2D = trial.targets[0]
	var post_art: Sprite2D = post.get_node("PostPresentation/Art")
	for frame in 4:
		var cel := post_art.texture.get_image().get_region(Rect2i(frame*64,0,64,64))
		var used := cel.get_used_rect()
		check(absf(post_art.position.y+(used.end.y-32)*post_art.scale.y)<.1,"Dummy reaction moves its ground anchor")
		check(used.size.y*post_art.scale.y<=32,"Dummy reaction grows beyond its normal world size")
	var post_origin := post.position
	var collision_origin: Vector2 = post.get_node("BodyCollision").position
	post.get_node("HealthComponent").apply_damage(DamageInfo.new(1,actor,Vector2.RIGHT))
	check(post_art.frame==2,"Real target damage does not play the directional reaction")
	await create_timer(.3).timeout
	check(post_art.frame==0 and post_art.modulate==Color.WHITE,"Dummy does not return to its ordinary artwork")
	check(post.position==post_origin and post.get_node("BodyCollision").position==collision_origin,"Dummy feedback moves gameplay collision")
	check(not training.has_technique(&"axe_war_cyclone"),"Dummy reaction grants an unearned technique")
	# Trace the actual approach route with King's footprint, including old walls/gate.
	for route: PackedVector2Array in [PackedVector2Array(Layout.MENTOR_ROUTE),PackedVector2Array(Layout.GATE_ROUTE)]:
		for segment in range(route.size()-1):
			var count := ceili(route[segment].distance_to(route[segment+1])/8.0)
			for sample in range(count+1):
				var point := route[segment].lerp(route[segment+1],float(sample)/count)
				check(not _blocked(space,point),"Sanctuary route crosses a solid obstacle at "+str(point))
	actor.position = Layout.MENTOR_APPROACH
	await create_timer(.15).timeout
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F
	key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	check(court.menu.visible and paused,"F does not open weapon lessons")
	check(Rect2(0,0,960,540).encloses(court.menu.get_node("Panel").get_global_rect()),"Mentor menu exceeds the viewport")
	court.close_menu()
	check(not paused,"Mentor leaves the world paused")
	actor.auto_combat.set_auto_skills_enabled(true)
	check(trial.begin(),"Cannot begin Axe lesson without owning an axe")
	await process_frame
	check(Rect2(0,0,960,540).encloses(court.practice_panel.get_global_rect()),"Lesson guidance exceeds the viewport")
	check(actor.war_cyclone.is_available() and actor.war_cyclone.borrowed_for_lesson,"Lesson does not lend Cyclone")
	check(not training.complete_axe_lesson(trial),"Unfinished trial grants proof")
	check(root.get_node("WeaponInventory").create_snapshot()==old_inventory,"Loan changes weapon ownership")
	trial.cancel()
	check(actor.auto_combat.auto_farm_enabled and actor.auto_combat.auto_skills_enabled,"Lesson changes automatic-combat preferences")
	actor.auto_combat.set_auto_farm_enabled(false)
	check(actor.attack_component.weapon==old_weapon and actor.movement_bounds==old_bounds,"Abandon fails to restore equipment/bounds")
	check(not actor.war_cyclone.borrowed_for_lesson and not actor.war_cyclone.is_available(),"Abandon retains the loan")
	await process_frame
	check(trial.begin(),"Cannot restart lesson")
	# Use actual physics contacts from ordinary Axe swings, not synthetic proof events.
	actor.set_physics_process(false)
	for index in 3:
		var target: Node2D = trial.targets[index]
		actor.position = target.position+Vector2(-30,0)
		actor.facing_direction = Vector2.RIGHT
		await create_timer(.08).timeout
		check(actor.attack_component.request_attack(Vector2.RIGHT),"Axe attack rejected")
		await create_timer(.9).timeout
	check(trial.step == trial.Step.CONTROL,"Real Axe contacts do not advance cleave proof")
	actor.position = trial.START
	await create_timer(.08).timeout
	check(actor.request_weapon_technique(),"Loaned F1 cannot cast")
	await create_timer(.8).timeout
	actor.position += Vector2(40,0)
	await create_timer(4.8).timeout
	check(trial.spin_contacts.size() >= 3 and trial.travel>=36,"Real Cyclone fails group/steering proof")
	check(trial.step==trial.Step.DODGE,"Finished spin does not start dodge lesson")
	# Walking out is insufficient: a real accepted dodge is required too.
	actor.position = trial.warning_center+Vector2(70,0)
	await create_timer(1.1).timeout
	check(trial.step==trial.Step.DODGE,"Walking alone completes the dodge proof")
	actor.set_physics_process(true)
	check(actor.request_evade(Vector2.LEFT),"Dodge lesson rejects Space action")
	await create_timer(1.1).timeout
	check(training.has_technique(&"axe_war_cyclone"),"Completed lesson does not grant Cyclone")
	check(actor.attack_component.weapon==old_weapon and actor.movement_bounds==old_bounds,"Completion leaves loaned state")
	check(root.get_node("WeaponInventory").create_snapshot()==old_inventory,"Completion grants a free axe")
	training.reset_training()
	check(save.load_profile()=="res://levels/sanctuary/sanctuary.tscn" and training.has_technique(&"axe_war_cyclone"),"Continue loses learned technique")
	check(training.complete_axe_lesson(trial) and training.create_snapshot().proofs.size()==1,"Repeated claim duplicates proof")
	check(save.restore_profile(legacy) and not training.has_technique(&"axe_war_cyclone"),"Legacy restore retains an unrelated learned skill")
	var rejecting := RejectingSave.new()
	save.name = "RealSaveForRollbackCheck"
	rejecting.name = "SaveService"
	root.add_child(rejecting)
	check(not training.complete_axe_lesson(trial) and not training.has_technique(&"axe_war_cyclone"),"Failed save leaves a permanent proof")
	root.remove_child(rejecting)
	rejecting.free()
	save.name = "SaveService"
	save.suppress_autosave_for_debug_session()
	check(not training.complete_axe_lesson(trial) and not training.has_technique(&"axe_war_cyclone"),"Debug session can permanently claim proof")
	check(not save.load_profile().is_empty() and training.has_technique(&"axe_war_cyclone"),"Valid proof profile fails restore")
	actor.set_weapon_definition(trial.AXE)
	check(actor.war_cyclone.is_available(),"Learned Axe cannot use F1")
	var crafting := root.get_node("CraftingService")
	var recipe: RecipeDefinition = load("res://data/crafting/recipes/forest/iron_beard_axe.tres")
	check(crafting.get_recipe_status(recipe).reason==&"station_required","Axe can be forged away from Nema")
	town.visit_nema()
	var materials := root.get_node("MaterialInventory")
	materials.reset_inventory()
	for ingredient: MaterialStackDefinition in recipe.ingredients:
		check(materials.add_material(ingredient.material.material_id,ingredient.quantity+1),"Cannot fund Axe ingredients")
	root.get_node("RunSession").update_progression(0,recipe.gold_cost+25)
	check(crafting.get_recipe_status(recipe).success,"Earned Axe pattern is not craftable at Nema")
	check(hub.rootforge_menu._is_recipe_available(recipe),"Nema hides earned pattern")
	save.profile_saved.connect(func(_path: String) -> void: committed += 1)
	committed = 0
	check(crafting.try_craft(recipe).success,"Nema cannot forge the learned Axe")
	check(committed==1,"Weapon acquisition saved a partially paid transaction")
	check(root.get_node("RunSession").coins==25,"Axe gold cost is incorrect")
	for ingredient: MaterialStackDefinition in recipe.ingredients:
		check(materials.get_quantity(ingredient.material.material_id)==1,"Axe ingredient spend is incorrect")
	check(root.get_node("WeaponInventory").owns_weapon(recipe.output_id),"Crafted Axe is absent from Bag")
	check(crafting.try_craft(recipe).reason==&"already_owned" and committed==1,"Repeated crafting spends or saves again")
	check(actor.equip_owned_weapon(actor.weapon_catalog.find_weapon(recipe.output_id)) and actor.war_cyclone.is_available(),"Crafted Axe does not activate learned F1")
	check(hub.combat_hud.weapon_technique_dock.visible and hub.combat_hud.get_node("PortraitLinkFrame/WeaponMastery/MasteryState").text.contains("1 PROOF"),"Learned technique/mastery is absent from HUD")
	check(actor.get_node("KingSkillLibrary").entries().size()==KingSkillCatalog.IDS.size(),"Weapon technique leaks into Eira's King-power curriculum")
	# Stage gates can be inspected but retain their authoritative access rules.
	root.get_node("StoryState").remember_story(&"awakened_in_sanctuary")
	hub.expedition_menu.open_menu()
	hub.expedition_menu._select_route(6)
	check(hub.expedition_menu.enter_button.disabled,"Sealed route is enterable")
	hub.expedition_menu._select_route(0)
	check(not hub.expedition_menu.enter_button.disabled,"Stage I is inaccessible")
	hub.expedition_menu.close_menu()
	check(not paused,"Expedition selector leaves pause active")
	actor.position = hub.expedition_altar.position+Vector2(0,48)
	await create_timer(.15).timeout
	check(hub.expedition_altar._player_inside and not hub.expedition_menu.visible,"Approaching gate auto-enters or misses the front apron")
	var interact := InputEventAction.new()
	interact.action = &"player_interact"
	interact.pressed = true
	root.push_input(interact)
	await process_frame
	check(hub.expedition_menu.visible,"F fails at refreshed gate")
	hub.expedition_menu.close_menu()
	hub.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("WEAPON_MENTOR: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
