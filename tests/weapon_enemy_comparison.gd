extends SceneTree

## Actual Lab, Player and authored enemy components. Controlled contacts test
## damage/control; moving eight-enemy samples measure this desktop session.
const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ROOTLING = preload("res://entities/enemies/rootling/rootling.tscn")
const HOG = preload("res://entities/enemies/armored_hog/armored_hog.tscn")
const ITEMS := [preload("res://data/items/equipment/king_signature_sword.tres"),preload("res://data/items/equipment/king_iron_beard_axe.tres"),preload("res://data/items/equipment/king_twinsteel.tres"),preload("res://data/items/equipment/king_royal_greatsword_v2.tres")]
const OUT := "res://tmp/review/combat/weapon_impact_closure_2026_10_07/"
var evidence_path := OUT
var checks := 0
var failures := 0
var lab: Node
var actor: Player
var feedback: CombatFeedbackPresenter
var accepted: Array[Dictionary] = []
var resolved_push: Dictionary = {}
var phase_seconds: Array[float] = []
var control_rows: Array[Dictionary] = []
var moving_rows: Array[Dictionary] = []

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"):
			evidence_path = argument.trim_prefix("--output=").trim_suffix("/")+"/"
	_run.call_deferred()

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").configure_storage_path_for_testing("user://weapon_enemy_comparison.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.get_node("WeaponInventory").reset_inventory()
	lab = LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	actor = lab.player
	actor.apply_debug_testing_preset()
	actor.set_process_unhandled_input(false)
	actor.set_physics_process(false)
	actor.attack_component.set_equipment_attack_speed_bonus(0.0)
	lab.set_player_invincible(true)
	feedback = CombatFeedbackPresenter.find_for_player(actor)
	actor.attack_component.hit_landed.connect(func(target: HurtboxComponent,info: DamageInfo) -> void:
		accepted.append({"target":target.get_parent().get_instance_id(),"damage":info.amount,"raw":info.raw_amount,"knockback":info.knockback_strength,"stagger":info.stagger_seconds,"type":info.damage_type}))
	actor.attack_component.phase_changed.connect(func(_phase: int,seconds: float) -> void: phase_seconds.append(seconds))
	for item: EquipmentDefinition in ITEMS:
		check(actor.equip_owned_weapon(item),"Cannot equip "+item.display_name)
		for target_count in [1,8]:
			await _controlled(item,ROOTLING,target_count)
		await _controlled(item,HOG,1)
		await _moving(item)
	DirAccess.make_dir_recursive_absolute(evidence_path)
	FileAccess.open(evidence_path+"enemy_comparison.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"display":DisplayServer.get_name(),"scope":"real Combat Lab and enemy scenes; high HP, no rewards/saves; controlled bodies pinned, authentic damage/defense/knockback/stagger components; separate eight-Rootling moving-AI samples with normal feedback; this is one desktop session, not cold campaign/export/phone profiling","controlled":control_rows,"moving":moving_rows},"\t"))
	lab.clear_simulation()
	lab.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("WEAPON_ENEMY_COMPARISON: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _spawn(scene: PackedScene,count: int,pinned: bool) -> Array[Node2D]:
	lab.clear_simulation()
	lab.set_enemy_ai_enabled(not pinned)
	await process_frame
	for index in count: lab._spawn_enemy(scene,index,count)
	await create_timer(0.9).timeout
	var enemies: Array[Node2D] = []
	for enemy: Node2D in lab._active_enemies:
		enemy.health_component.set_maximum_health(10000,false)
		enemy.health_component.set_current_health(10000)
		if pinned: enemy.set_physics_process(false)
		var identity := enemy.get_instance_id()
		enemy.knockback_component.knockback_started.connect(func(velocity: Vector2) -> void: resolved_push[identity] = velocity.length())
		enemies.append(enemy)
	return enemies

func _place(enemies: Array[Node2D],distance: float,spread: float) -> void:
	for index in enemies.size():
		var hurtbox := enemies[index].get_node("Hurtbox") as HurtboxComponent
		var local_offset := hurtbox.global_position-enemies[index].global_position
		enemies[index].global_position = actor.attack_component.collision_shape.global_position + Vector2(distance,(index-(enemies.size()-1)*.5)*spread)-local_offset
		enemies[index].velocity = Vector2.ZERO
		enemies[index].knockback_component.clear()

func _controlled(item: EquipmentDefinition,scene: PackedScene,count: int) -> void:
	feedback.hitstop_enabled = false
	actor.global_position = Vector2(350,300)
	actor._set_facing_direction(Vector2.RIGHT)
	var enemies := await _spawn(scene,count,true)
	check(enemies.size()==count,"Real enemy sample has incorrect population")
	var weapon := item.weapon_definition
	var cuts: Array[Dictionary] = []
	for step in WeaponCombatReadout.steps(weapon):
		actor._clear_buffered_action()
		actor.attack_component.reset_combo()
		actor.attack_component._next_combo_step = step
		_place(enemies,25.0,2.0)
		await physics_frame
		accepted.clear()
		resolved_push.clear()
		phase_seconds.clear()
		var audio_before := feedback._weapon_impact_index
		check(actor.request_primary_attack(),"Controlled enemy strike was rejected")
		await _until_idle()
		check(accepted.size()==count,"Actual enemy contact was missing or duplicated")
		check(feedback._weapon_impact_index==audio_before+1,"Horde impact audio multiplied per target")
		check(phase_seconds.size()==3,"Actual enemy exchange lost a phase")
		if phase_seconds.size()==3:
			check(is_equal_approx(phase_seconds[0]+phase_seconds[1]+phase_seconds[2],weapon.combo.windups[step]+weapon.combo.contacts[step]+weapon.combo.recoveries[step]),"Actual recovery differs from authored cadence")
		var seen := {}
		var damage_sum := 0.0
		var max_push := 0.0
		var expected := WeaponCombatReadout.step_range(weapon,step)
		for hit in accepted:
			check(not seen.has(hit.target),"Two blades awarded duplicate enemy damage")
			seen[hit.target] = true
			check(hit.type==DamageInfo.DamageType.PHYSICAL,"Basic damage lost physical typing")
			check(hit.raw>=expected.x-.01 and hit.raw<=expected.y+.01,"Real enemy raw damage disagrees with Bag")
			var enemy := instance_from_id(hit.target) as Node2D
			check(enemy!=null and is_equal_approx(hit.damage,enemy.health_component.resolve_damage(hit.raw,DamageInfo.DamageType.PHYSICAL)),"Authored enemy mitigation was bypassed")
			var actual_push: float = resolved_push.get(hit.target,0.0)
			check(is_equal_approx(actual_push,hit.knockback*enemy.definition.knockback_multiplier()),"Authored enemy knockback resistance was bypassed")
			damage_sum += hit.damage
			max_push = maxf(max_push,actual_push)
		cuts.append({"step":step+1,"targets_hit":accepted.size(),"total_damage":damage_sum,"maximum_resolved_push":max_push,"phase_seconds":phase_seconds.duplicate(),"raw_expected":str(expected),"shared_impact_cues":feedback._weapon_impact_index-audio_before})
	# Empirical contact boundary: use the same real hurtbox at its near/far edge.
	var reach_hits := []
	for distance in [weapon.get_melee_forward_reach_pixels()-4,weapon.get_melee_forward_reach_pixels()+40]:
		actor.global_position = Vector2(350,300)
		actor._clear_buffered_action()
		actor.attack_component.reset_combo()
		_place(enemies,distance,0.0)
		await physics_frame
		accepted.clear()
		check(actor.request_primary_attack(),"Reach probe was rejected")
		await _until_idle()
		reach_hits.append(accepted.size())
	check(reach_hits[0]>0 and reach_hits[1]==0,"Real hurtbox near/far reach does not match the weapon")
	var record := {"weapon":item.display_name,"enemy":enemies[0].definition.display_name,"targets":count,"base_dps":WeaponCombatReadout.base_dps(weapon),"nominal_seconds":WeaponCombatReadout.duration(weapon),"frontal_shape_reach":weapon.get_melee_forward_reach_pixels(),"reach_probe_hits":reach_hits,"cuts":cuts}
	control_rows.append(record)
	print("WEAPON_CONTROL: ",JSON.stringify(record))

func _moving(item: EquipmentDefinition) -> void:
	feedback.hitstop_enabled = true
	actor.global_position = Vector2(350,300)
	actor._set_facing_direction(Vector2.RIGHT)
	var enemies := await _spawn(ROOTLING,8,false)
	_place(enemies,45.0,8.0)
	await _sample(item,"moving_AI_baseline",1.0,false)
	for pass_index in 2:
		actor._clear_buffered_action()
		actor.attack_component.reset_combo()
		actor.global_position = Vector2(350,300)
		_place(enemies,30.0,7.0)
		await physics_frame
		await _sample(item,"first_combo" if pass_index==0 else "repeat_combo",WeaponCombatReadout.duration(item.weapon_definition)+.75,true)

func _sample(item: EquipmentDefinition,label: String,seconds: float,attack_now: bool) -> void:
	accepted.clear()
	var audio_before := feedback._weapon_impact_index
	var start := Time.get_ticks_usec()
	var previous := start
	var frames: Array[float] = []
	var process_peak := 0.0
	var physics_peak := 0.0
	var nodes_peak := 0
	var queued_step := -1
	var pauses := 0
	var was_paused := false
	if attack_now: check(actor.request_primary_attack(),"Moving horde attack was rejected")
	while Time.get_ticks_usec()-start<seconds*1000000:
		await process_frame
		var now := Time.get_ticks_usec()
		frames.append((now-previous)/1000.0)
		previous = now
		process_peak = maxf(process_peak,Performance.get_monitor(Performance.TIME_PROCESS)*1000)
		physics_peak = maxf(physics_peak,Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000)
		nodes_peak = maxi(nodes_peak,int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
		if paused and not was_paused: pauses += 1
		was_paused = paused
		var attack := actor.attack_component
		if attack_now and attack.phase==MeleeAttackComponent.Phase.ACTIVE and attack.combo_step<item.weapon_definition.combo.step_count()-1 and queued_step!=attack.combo_step:
			actor.request_primary_attack()
			queued_step = attack.combo_step
	frames.sort()
	if attack_now:
		check(accepted.size()>0,"Moving actual horde received no contacts")
		check(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Moving combo exceeded its bounded recovery")
	var record := {"weapon":item.display_name,"sample":label,"enemies":8,"contacts":accepted.size(),"shared_impact_cues":feedback._weapon_impact_index-audio_before,"global_hitstop_events":pauses,"frame_p50_ms":frames[int((frames.size()-1)*.5)],"frame_p95_ms":frames[int((frames.size()-1)*.95)],"frame_max_ms":frames[-1],"process_peak_ms":process_peak,"physics_peak_ms":physics_peak,"nodes_peak":nodes_peak}
	moving_rows.append(record)
	print("WEAPON_MOVING: ",JSON.stringify(record))

func _until_idle() -> void:
	var deadline := Time.get_ticks_msec()+5000
	while actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
	check(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Controlled strike never recovered")
