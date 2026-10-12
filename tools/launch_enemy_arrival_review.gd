extends "res://tools/launch_stage_4_renewal.gd"

class ReviewEncounter extends EncounterController:
	var cursor := 0
	var offsets := [Vector2(180,-70),Vector2(180,50),Vector2(130,-140),Vector2(-150,-80),Vector2(-230,20),Vector2(-120,130),Vector2(130,100),Vector2(260,110)]
	func _choose_spawn_position() -> Vector2:
		var point: Vector2 = player.global_position + offsets[cursor % offsets.size()]
		cursor += 1
		return point
	func _prepare_enemy(enemy: Node) -> void:
		var rewards := enemy.get_node_or_null("EnemyRewardComponent")
		if rewards != null:
			enemy.remove_child(rewards)
			rewards.free()

var _batch_buttons: Array[Button] = []

func _run() -> void:
	var save := root.get_node("SaveService")
	save.configure_storage_path_for_testing("user://enemy_arrival_review.json")
	save.suppress_autosave_for_debug_session()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()
	if "--capture" in OS.get_cmdline_user_args():
		root.size = Vector2i(960,540)
		await create_timer(.2).timeout
		await capture_review("controls.png")
		toolbar.hide()
		_spawn_batch(3)
		await create_timer(.12).timeout
		await capture_review("review_warning.png")
		await create_timer(.48).timeout
		await capture_review("review_emergence.png")
		await create_timer(.5).timeout
		await capture_review("review_walking.png")
		quit()

func open_review() -> void:
	stage = load("res://levels/stage_4/stage_4.tscn").instantiate()
	stage.review_hold_encounter = true
	root.add_child(stage)
	current_scene = stage
	var original: EncounterController = stage.encounter_controller
	var review := ReviewEncounter.new()
	for key in ["player","actors","spawn_points_root","effects_parent","projectiles_parent","portal_spawn_point","summon_effect_scene","rootling_scene"]: review.set(key,original.get(key))
	review.auto_start = false
	review.max_active_enemies = 8
	review._spawning = true
	review._initial_batch_active = true
	original.get_parent().add_child(review)
	stage.encounter_controller = review
	original.queue_free()
	review.enemy_spawned.connect(stage.combat_hud.show_spawn_direction)
	stage.expedition_feedback.view.hide()
	stage.player.health_component.is_damage_immune = true
	_visit(Vector2(768,500))
	root.title = "Battle of Gods — Enemy Arrival (NO SAVES / NO REWARDS)"
	var column := _column("ENEMY ARRIVAL · NO SAVES / REWARDS\nWASD · attack / skills · F7 Lab")
	_batch_buttons.clear()
	_batch_buttons.append(_button(column,"One Rootling",_spawn_batch.bind(1)))
	_batch_buttons.append(_button(column,"Three: roots + caster",_spawn_batch.bind(3)))
	_batch_buttons.append(_button(column,"Eight-live crowd",_spawn_batch.bind(8)))
	_button(column,"Reset review",reset_review)
	var safe := _button(column,"King safe: ON",func() -> void: stage.player.health_component.is_damage_immune = not stage.player.health_component.is_damage_immune)
	safe.pressed.connect(func() -> void: safe.text = "King safe: ON" if stage.player.health_component.is_damage_immune else "King safe: OFF")
	_button(column,"Normal Stage IV",normal_stage)
	await create_timer(.25).timeout

func _spawn_batch(count: int) -> void:
	for button in _batch_buttons: button.disabled = true
	var encounter: EncounterController = stage.encounter_controller
	for index in count:
		encounter._spawn_enemy(load("res://entities/enemies/rotcaller/rotcaller.tscn") if index == 2 else encounter.rootling_scene)

func reset_review() -> void:
	paused = false
	stage.queue_free()
	await process_frame
	await open_review()

func normal_stage() -> void:
	paused = false
	stage.queue_free()
	await process_frame
	_open_stage()

func capture_review(name: String) -> void:
	await RenderingServer.frame_post_draw
	var folder := "res://tmp/review/encounters/arrival_2026_10_03/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	assert(root.get_texture().get_image().save_png(folder+name) == OK)
