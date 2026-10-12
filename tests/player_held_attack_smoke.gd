extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
var actor: Player
var lab: Node
var started: Array[int] = []

func _run() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size # Inject mouse coordinates in viewport pixels.
	root.get_node("SaveService").configure_storage_path_for_testing("user://held_attack_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	lab = LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	actor = lab.player
	actor.set_physics_process(false)
	actor.apply_debug_testing_preset()
	actor.attack_component.attack_started.connect(func() -> void: started.append(actor.attack_component.combo_step))
	for item: EquipmentDefinition in actor.weapon_catalog.weapons:
		actor.held_attack.cancel()
		actor._clear_buffered_action()
		actor.attack_component.cancel_attack()
		actor.set_weapon_definition(item.weapon_definition)
		actor.attack_component.reset_combo()
		actor._set_facing_direction(Vector2.RIGHT)
		var family := actor.get_node("WeaponFamilyPresentation")
		if family.presenter != null: family.presenter._rest_timer.stop()
		started.clear()
		await mouse(true,world_point(actor.global_position+Vector2(170,0)))
		check(actor.held_attack.held,"World mouse press did not latch "+item.display_name)
		var deadline := Time.get_ticks_msec()+10000
		var steps := item.weapon_definition.combo.step_count()
		while started.size()<steps+2 and Time.get_ticks_msec()<deadline: await physics_frame
		check(started.size()>=steps+2,"Hold did not loop the full combo "+item.display_name)
		var expected: Array[int] = []
		for index in steps+2: expected.append(index%steps)
		check(started.slice(0,steps+2)==expected,"Hold skipped the combo order for "+item.display_name)
		await physics_frame
		await mouse(false,world_point(actor.global_position+Vector2(170,0)))
		var count := started.size()
		check(not actor.held_attack.held and not actor._buffered_primary_from_hold,"Release kept automatic intent")
		await idle()
		await wait_seconds(.22)
		check(started.size()==count,"Release launched a ghost followup "+item.display_name)
	# A short click remains exactly one manual attack.
	started.clear()
	actor.attack_component.reset_combo()
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	await mouse(false,world_point(actor.global_position+Vector2(170,0)))
	await idle()
	await wait_seconds(.25)
	check(started==[0],"Short click repeats after release")
	# UI button presses never become held world attacks.
	lab.review_tabs.current_tab = 2
	await process_frame
	var review: Node = lab.review_tabs.get_child(2)
	var button: Button = review.buttons.values()[0]
	await mouse(true,button.get_global_rect().get_center())
	check(not actor.held_attack.held,"Weapons button latched a world attack")
	await mouse(false,button.get_global_rect().get_center())
	# Release still reaches the always-processing intent while the Bag pauses.
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	paused = true
	await mouse(false,Vector2(700,300))
	check(not actor.held_attack.held,"Paused mouse release was lost")
	paused = false
	actor.attack_component.cancel_attack()
	actor._clear_buffered_action()
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	actor.held_attack._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	check(not actor.held_attack.held,"Focus loss kept held input")
	await mouse(false,Vector2(700,300))
	actor.attack_component.cancel_attack()
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	actor.set_cinematic_locked(true)
	check(not actor.held_attack.held and actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Cinematic lock did not cancel hold")
	actor.set_cinematic_locked(false)
	await mouse(false,Vector2(700,300))
	# Release owns only its own buffer, never a deliberate queued skill/click.
	actor._buffer_action(Player.BufferedAction.ABILITY,Vector2.RIGHT,1)
	actor.held_attack.cancel()
	check(actor._buffered_action==Player.BufferedAction.ABILITY,"Hold cancellation erased another input")
	actor._clear_buffered_action()
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	actor.interaction_started.emit()
	check(not actor.held_attack.held,"NPC interaction kept repeating")
	await mouse(false,Vector2(700,300))
	actor.attack_component.cancel_attack()
	actor.interaction_finished.emit()
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	actor.request_evade(Vector2.LEFT)
	check(not actor.held_attack.held,"Dodge kept repeating")
	await mouse(false,Vector2(700,300))
	actor._clear_buffered_action()
	actor.attack_component.cancel_attack()
	actor.evade_component.cancel_evade()
	await mouse(true,world_point(actor.global_position+Vector2(170,0)))
	actor.request_ability(1)
	check(not actor.held_attack.held,"Skill kept repeating")
	await mouse(false,Vector2(700,300))
	actor._clear_buffered_action()
	actor.attack_component.cancel_attack()
	actor._cancel_all_targeting()
	for ability in actor.get_all_ability_components(): ability.cancel_cast()
	actor.held_attack.cancel()
	print("HELD_ATTACK checks=",checks," failures=",failures)
	lab.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)

func world_point(world: Vector2) -> Vector2:
	return actor.get_viewport_transform()*world

func mouse(pressed: bool,point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = point
	event.global_position = point
	Input.parse_input_event(event)
	await process_frame
	await physics_frame

func idle() -> void:
	var deadline := Time.get_ticks_msec()+5000
	while actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
	check(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Attack never finished")

func wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout
