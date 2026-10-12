extends SceneTree

const Burst = preload("res://entities/player/presentation/king_contact_burst.gd")
const OUT := "res://tmp/review/characters/king/worldsplitter_activation_fix/"
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var lab: Node = load("res://levels/combat_lab/combat_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.set_enemy_ai_enabled(false)
	var actor: Player = lab.player
	actor.position = Vector2(310,335)
	var effects := actor.get_node("GreatswordEffects")
	var skill := actor.ability_4_component as KingSkill4Component
	for rank in 3:
		skill.apply_rank(rank)
		skill.clear_cooldown()
		var target := actor.global_position + Vector2(190, [-40,0,40][rank])
		check(skill.request_cast_at(target,25.0), "Cast refused")
		await create_timer(.22,false,true).timeout
		var bursts := 0
		for child in effects.get_children():
			if child is Burst: bursts += 1
		check(bursts == 0, "Worldsplitter release spawned a generic crater on King")
		check(is_instance_valid(skill._visual) and skill._visual.global_position == target and not skill._visual._ground.visible, "Ground must remain at target and hidden until contact")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			DirAccess.make_dir_recursive_absolute(OUT)
			var label := "before" if "--before-fix" in OS.get_cmdline_user_args() else "after"
			check(root.get_texture().get_image().save_png(OUT+"%s_rank_%d.png" % [label,rank]) == OK, "Capture failed")
		await create_timer(.46,false,true).timeout
		check(skill._visual._ground.visible and skill._visual.global_position == target, "Real target crater disappeared")
		await create_timer(1.3,false,true).timeout
	# The generic observer must still serve techniques without their own burst.
	actor.ability_3_component.strike_started.emit(0,1,.1)
	var pursuit_bursts := 0
	for child in effects.get_children():
		if child is Burst: pursuit_bursts += 1
	check(pursuit_bursts == 1, "Pursuit lost its generic landing feedback")
	lab.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("WORLDSPLITTER_ACTIVATION: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
