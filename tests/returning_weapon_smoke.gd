extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_iron_reaper.tres")
var actor: Player
var lab: Node
var counts: Dictionary = {}
var dummy: Node2D

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://returning_weapon_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	lab = LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	lab.clear_simulation()
	lab._set_examiner_arena(false)
	actor = lab.player
	actor.set_physics_process(false)
	actor.apply_debug_testing_preset()
	var weapon: WeaponDefinition = ITEM.weapon_definition.duplicate()
	weapon.critical_chance_ratio = 0
	weapon.basic_damage_minimum = 10
	weapon.basic_damage_maximum = 10
	actor.set_weapon_definition(weapon)
	check(WeaponCombatReadout.summary(weapon).contains("4 CUTS"),"Bag confuses cuts with released contacts")
	check(WeaponCombatReadout.combo_description(weapon).contains("both must connect"),"Bag hides the two-leg damage condition")
	CombatFeedbackPresenter.find_for_player(actor).hitstop_enabled = false
	actor.attack_component.hit_landed.connect(func(target: HurtboxComponent, _info: DamageInfo) -> void: counts[target] = counts.get(target,0) + 1)
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		for bonus in [0.0,0.5]:
			actor.position = Vector2(350,300)
			actor.attack_component.set_equipment_attack_speed_bonus(bonus)
			var target := _dummy(actor.position + direction * 85)
			var outside := _dummy(actor.position + direction * 250)
			counts.clear()
			await physics_frame
			await _throw(direction)
			var flight: Node2D = actor.attack_component.released_attack
			check(is_instance_valid(flight),"Third cut does not release")
			var spin: AudioStreamPlayer2D = flight.get_node("ReaperFlight/SpinAudio")
			check(spin.playing and spin.bus==&"SFX","Released scythe has no active SFX spin layer")
			check(spin.stream is AudioStreamWAV and spin.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD,"Spin layer does not loop")
			check(is_equal_approx(spin.pitch_scale,1+bonus),"Spin sound does not follow attack speed")
			check(spin.volume_db<=-24,"Spin layer overpowers approved cuts")
			check(is_equal_approx(flight.duration,0.90/(1+bonus)),"Attack speed does not scale the complete flight")
			check(not actor.attack_component.hitbox._enabled,"Local spin remains active during release")
			var peak := 0.0
			var lingering_ticks := 0
			var sustained_spin := true
			var peak_spin_db := -80.0
			var recall_faded := false
			var origin: Vector2 = flight._origin
			while actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
				if is_instance_valid(flight) and flight.progress<0.98 and is_instance_valid(spin):
					sustained_spin = sustained_spin and spin.playing
					peak_spin_db = maxf(peak_spin_db,spin.volume_db)
					if flight.progress>0.90 and spin.volume_db<-34: recall_faded = true
				if is_instance_valid(flight): peak = maxf(peak,flight.global_position.distance_to(origin))
				if is_instance_valid(flight) and flight.progress>=0.3 and flight.progress<0.7:
					lingering_ticks += 1
					check(flight.global_position.is_equal_approx(flight._turn) and not flight.returning,"Spinning weapon moves home before its linger ends")
				await physics_frame
			print("RETURNING_RANGE direction=",direction," bonus=",bonus," peak=",peak," turn=",origin + direction*124)
			check(peak>110 and peak<=124.1,"Released weapon does not reach its authored range")
			check(lingering_ticks>=10,"Linger is missing or too short at supported attack speed")
			check(sustained_spin and is_equal_approx(peak_spin_db,-24),"Spin sound stops during flight or misses its quiet plateau")
			check(recall_faded,"Spinning sound does not fade during recall")
			check(counts.get(target.get_node("Hurtbox"),0)==2,"Expected exactly one outward and one return hit")
			check(is_equal_approx(target.get_node("Health").current_health,988.0),"Damage shares duplicate or lose the third-cut multiplier")
			check(counts.get(outside.get_node("Hurtbox"),0)==0,"Throw hits beyond its reach")
			check(actor.attack_component.released_attack==null and get_nodes_in_group("returning_weapon_attacks").is_empty(),"Caught weapon remains alive")
			check(not is_instance_valid(spin),"Caught scythe leaves its spin voice playing")
			target.queue_free()
			outside.queue_free()
			await process_frame
	# Walls shorten outward travel; recall still completes at a moving owner.
	actor.position = Vector2(500,400)
	var wall := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(8,100)
	collision.shape = rectangle
	wall.add_child(collision)
	wall.position = actor.position + Vector2(70,0)
	lab.actors.add_child(wall)
	await physics_frame
	await _throw(Vector2.RIGHT)
	var wall_flight: Node2D = actor.attack_component.released_attack
	check(wall_flight._turn.x <= wall.position.x-8,"Outbound shaft passes through solid terrain")
	actor.position += Vector2(0,20)
	while actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE: await physics_frame
	check(actor.attack_component.released_attack==null,"Recall cannot catch a moving owner")
	wall.queue_free()
	await process_frame
	# Existing basic attacks buffer dodge until recovery. Once that boundary
	# opens, cancellation must erase damage and visual ownership together.
	await _throw(Vector2.RIGHT)
	var cancelled_spin: AudioStreamPlayer2D = actor.attack_component.released_attack.get_node("ReaperFlight/SpinAudio")
	check(actor.request_evade(Vector2.DOWN),"Throw prevents dodge cancellation")
	while actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE: await physics_frame
	actor._try_execute_buffered_action()
	await physics_frame
	check(actor.attack_component.released_attack==null and get_nodes_in_group("returning_weapon_attacks").is_empty(),"Dodge leaves a detached damage/visual ghost")
	check(not is_instance_valid(cancelled_spin),"Dodge leaves the spin sound playing")
	actor.evade_component.cancel_evade()
	actor._clear_buffered_action()
	lab.queue_free()
	current_scene = null
	await process_frame
	print("RETURNING_WEAPON_SMOKE checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _throw(direction: Vector2) -> void:
	actor._clear_buffered_action()
	actor.attack_component.cancel_attack()
	actor.attack_component._next_combo_step = 2
	actor._set_facing_direction(direction)
	actor.get_node("WeaponFamilyPresentation").presenter._rest_timer.stop()
	check(actor.request_primary_attack(),"Throw request rejected")
	var deadline := Time.get_ticks_msec()+4000
	while actor.attack_component.phase != MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
	check(actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE,"Throw never reaches release")

func _dummy(point: Vector2) -> Node2D:
	var body := Node2D.new()
	body.position = point
	var health := HealthComponent.new()
	health.name = "Health"
	health.maximum_health = 1000
	body.add_child(health)
	var hurtbox := HurtboxComponent.new()
	hurtbox.name = "Hurtbox"
	hurtbox.health_component = health
	hurtbox.collision_layer = 16
	hurtbox.collision_mask = 0
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8
	shape.shape = circle
	hurtbox.add_child(shape)
	body.add_child(hurtbox)
	lab.actors.add_child(body)
	return body
