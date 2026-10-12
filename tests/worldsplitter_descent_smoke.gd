extends SceneTree

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const VISUAL = preload("res://gameplay/abilities/king/worldsplitter_visual.gd")
const TARGET = preload("res://entities/training/training_target.tscn")
const OUT := "res://tmp/review/characters/king/worldsplitter_momentum_2026_09_27/"
var checks := 0
var failures := 0
var hits := [0,0,0,0,0,0,0]
var dealt := [0.0,0.0,0.0,0.0,0.0,0.0,0.0]
var stuns: Array[float] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var session := root.get_node("RunSession")
	session.reset_run()
	var lab: Node = LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.set_enemy_ai_enabled(false)
	lab.set_player_invincible(true)
	var actor: Player = lab.player
	var skill := actor.ability_4_component as KingSkill4Component
	var review: Node = lab.get_node("KingCombatReview")
	var targets: Array[Node2D] = []
	var point := Vector2(465,315)
	for index in 7:
		var target := TARGET.instantiate() as Node2D
		lab.actors.add_child(target)
		target.collision_layer = 0
		var hp := target.get_node("HealthComponent") as HealthComponent
		hp.set_maximum_health(10000.0,false)
		hp.set_current_health(10000.0)
		hp.damaged.connect(func(info: DamageInfo) -> void:
			hits[index]+=1
			dealt[index]+=info.amount
			if index == 0: stuns.append(info.stun_seconds))
		targets.append(target)
	for rank in 3:
		actor.global_position = Vector2(300,340)
		check(review.set_worldsplitter_rank(rank), "Lab upgrade refused")
		check(session.king_worldsplitter_rank == 0, "Lab preview changed campaign rank")
		var tuning := skill.definition as KingSkill4Definition
		check(actor.get_ability_component_for_slot(5) == skill, "Upgrade disconnected slot 5")
		check(tuning.explosion_radius_pixels == [88.0,96.0,104.0][rank], "Rank radius wrong")
		hits = [0,0,0,0,0,0,0]
		dealt = [0.0,0.0,0.0,0.0,0.0,0.0,0.0]
		stuns.clear()
		var rim := tuning.explosion_radius_pixels-6.0
		var offsets := [Vector2.ZERO,Vector2(rim,0),Vector2(tuning.explosion_radius_pixels+20.0,0),Vector2(0,-rim),Vector2(0,rim),Vector2(-rim,0),Vector2(-1,-1).normalized()*rim]
		for index in 7:
			targets[index].global_position = point+offsets[index]
		await physics_frame
		await physics_frame
		check(skill.request_cast_at(point,25.0), "Rank cast refused")
		await create_timer(.35,false,true).timeout
		check(not skill.is_casting() and hits == [0,0,0,0,0,0,0], "Movement return must precede damage")
		await capture("rank_%d_high_arrival.png" % rank)
		check(not review.set_worldsplitter_rank((rank+1)%3), "Upgrade changed a released cast")
		var start := actor.global_position
		Input.action_press("player_move_left")
		await create_timer(.12,false,true).timeout
		Input.action_release("player_move_left")
		check(actor.global_position.distance_to(start) > 3.0, "Manual movement remains locked after release")
		check(is_instance_valid(skill._visual) and skill._visual.global_position == point, "Effect followed moving King")
		check(is_zero_approx(skill._visual._sword.rotation), "Straight sword rotated")
		await capture("rank_%d_formation.png" % rank)
		check(actor.request_evade(Vector2.LEFT), "Released descent blocked dodge")
		# Cancelling recovery after release must not remove the autonomous skill.
		skill.cancel_cast()
		var visual: Node2D = skill._visual
		var contact_blades: Array[int] = []
		var previous_depth: Dictionary = {}
		var moved_only_down := true
		for contact in tuning.strike_count():
			for tick in 90:
				if visual._contact_index >= contact: break
				for blade in visual._blades:
					var id: int = blade.get_instance_id()
					var depth: float = blade._sword.position.y
					if previous_depth.has(id) and depth < previous_depth[id]-.01: moved_only_down = false
					previous_depth[id] = depth
				await physics_frame
			check(visual._contact_index == contact, "Contact did not arrive in sequence")
			check(hits[0] == contact+1 and hits[2] == 0, "Plunge hit count or outside-radius exclusion failed")
			check(visual._sword.position.y >= 60.0 and visual._sword_material.get_shader_parameter("buried"), "Blade did not drive deep before detonation")
			var blade_id: int = visual._sword.get_instance_id()
			check(not contact_blades.has(blade_id), "A previous sword bounced back for another strike")
			contact_blades.append(blade_id)
			check(visual.global_position == point, "Repeated plunge drifted away from chosen point")
			check(skill.is_current_strike_final() == (contact == rank), "Feedback misidentified the final plunge")
			check(visual._sword_material.get_shader_parameter("crimson") == (1.0 if rank == 2 or contact > 0 else 0.0), "Rank/contact blade color incorrect")
			await capture("rank_%d_plunge_%d.png" % [rank,contact+1])
			await create_timer(.065,false,true).timeout
			check(visual._ground.visible, "Radial blast missing on contact")
			await capture("rank_%d_blast_%d.png" % [rank,contact+1])
			if contact < tuning.strike_count()-1:
				check(stuns[contact] == 0.0, "An early plunge stunned")
				await create_timer(.065,false,true).timeout
				check(visual._blades.size() > contact+1 and visual._blades[contact+1]._sword.position.y < 0 and visual._blades[contact]._sword.position.y >= 60, "Fresh sword did not form above the consumed blade")
				check(visual._blades[contact+1]._summon.visible, "New blade missing summoning effects")
				await capture("rank_%d_summon_%d.png" % [rank,contact+2])
		check(moved_only_down, "A summoned sword moved upward or bounced")
		check(hits == [rank+1,1,0,1,1,1,1], "Radial blast missed a cardinal/diagonal rim target or hit outside its radius")
		check(stuns.back() == .5, "Final plunge lost designated stun")
		check(is_equal_approx(dealt[0],25.0*[5.2,6.0,7.0][rank]), "Rank total damage budget changed unexpectedly")
		await create_timer(.06,false,true).timeout
		check(visual._sword.visible and visual._sword.texture == VISUAL.Sword and visual._sword.position.y >= 60.0, "Consumed sword did not fracture while embedded")
		await capture("rank_%d_final_shatter.png" % rank)
		await create_timer(1.1,false,true).timeout
		check(get_nodes_in_group("worldsplitter_effects").is_empty() and get_nodes_in_group("worldsplitter_sequences").is_empty(), "Released effects leaked")

	# Reset/defeat cancels pending world authority, unlike ordinary movement.
	skill.clear_cooldown()
	check(skill.request_cast_at(point,25.0), "Defeat fixture refused")
	await create_timer(.35,false,true).timeout
	var before := hits.duplicate()
	actor.is_defeated = true
	await create_timer(.7,false,true).timeout
	check(hits == before and get_nodes_in_group("worldsplitter_sequences").is_empty() and get_nodes_in_group("worldsplitter_effects").is_empty(), "Defeat left pending damage/effects")
	for kind in ["sword","ground","summon"]:
		var atlas: Image = (VISUAL.Sword if kind == "sword" else (VISUAL.Summon if kind == "summon" else VISUAL.Ground)).get_image()
		check(atlas.get_size() == Vector2i(2048,2048), "Atlas dimensions incorrect")
		var hashes: Array[int] = []
		var binary := true
		var padded := true
		for index in 16:
			var frame := atlas.get_region(Rect2i(Vector2i(index%4,index/4)*512,Vector2i(512,512)))
			var bounds := frame.get_used_rect()
			padded = padded and bounds.position.x > 8 and bounds.position.y > 8 and bounds.end.x < 504 and bounds.end.y < 504
			hashes.append(hash(frame.get_data()))
			for y in range(bounds.position.y,bounds.end.y):
				for x in range(bounds.position.x,bounds.end.x):
					var a := frame.get_pixel(x,y).a
					if a != 0.0 and a != 1.0: binary = false
		var unique: Dictionary = {}
		for h in hashes: unique[h] = true
		check(binary and padded and unique.size() == 16, "Atlas alpha/padding/unique-frame contract failed")
		if kind == "ground":
			var peak := atlas.get_region(Rect2i(Vector2i(0,512),Vector2i(512,512)))
			var bounds := peak.get_used_rect()
			var aspect := float(bounds.size.x)/float(bounds.size.y)
			check(aspect > .8 and aspect < 1.2, "AOE art collapsed into a narrow sideways splash")
			check(absf(float(maxi(bounds.size.x,bounds.size.y))-VISUAL.Blade.GROUND_DIAMETER) < 16.0, "Radial artwork no longer matches its damage-radius scale")
	lab.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("WORLDSPLITTER_DESCENT: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	# GPU readback/PNG writes must not advance this sub-second choreography.
	# Let the real combat hitstop release its pause before owning a capture pause.
	while paused: await process_frame
	var previous_pause := paused
	paused = true
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file) == OK, "GPU capture failed")
	await process_frame
	await process_frame
	paused = previous_pause

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)


