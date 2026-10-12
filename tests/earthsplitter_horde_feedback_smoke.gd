extends SceneTree

## Real released wave contacts across different physics ticks, not emitted mocks.
const PLAYER = preload("res://entities/player/player.tscn")
const ENEMY = preload("res://entities/enemies/mireling/mireling.tscn")
var contacts := 0
var contact_frames: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://earthsplitter_horde_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	var world := Node2D.new()
	root.add_child(world)
	var player := PLAYER.instantiate() as Player
	world.add_child(player)
	player.position = Vector2(260,300)
	player.set_physics_process(false)
	var form := EarthsplitterDefinition.Form.FAN if "--fan" in OS.get_cmdline_user_args() else (EarthsplitterDefinition.Form.CASCADE if "--cascade" in OS.get_cmdline_user_args() else EarthsplitterDefinition.Form.FOUNDATION)
	player.ability_1_component.definition = player.ability_1_component.definition.duplicate(true)
	player.ability_1_component.definition.configure_form(form)
	var feedback := CombatFeedbackPresenter.new()
	feedback.player = player
	feedback.effects_parent = world
	feedback.camera = Camera2D.new()
	player.add_child(feedback.camera)
	feedback.damage_number_scene = load("res://ui/world/damage_number.tscn")
	feedback.hit_burst_scene = load("res://gameplay/presentation/hit_burst.tscn")
	world.add_child(feedback)
	player.ability_1_component.hit_landed.connect(func(_hurtbox: HurtboxComponent, _info: DamageInfo) -> void:
		contacts += 1
		contact_frames[Engine.get_physics_frames()] = true
	)
	var target_count := 8
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--targets="): target_count = clampi(argument.trim_prefix("--targets=").to_int(), 1, 8)
	for index in target_count:
		var enemy := ENEMY.instantiate() as Mireling
		var reward := enemy.get_node_or_null("EnemyRewardComponent")
		if reward != null:
			enemy.remove_child(reward)
			reward.free()
		enemy.position = Vector2(290+index*18,300)
		world.add_child(enemy)
		enemy.health_component.maximum_health = 1000
		enemy.health_component.current_health = 1000
		enemy.set_physics_process(false)
	await create_timer(0.8).timeout
	var results: Array[Dictionary] = []
	for pass_index in (2 if "--profile" in OS.get_cmdline_user_args() else 1):
		contacts = 0
		contact_frames.clear()
		player.ability_1_component.clear_cooldown()
		assert(player.ability_1_component.request_cast_at(Vector2(580,300),10.0))
		var start := Time.get_ticks_usec()
		var pauses := 0
		var paused_usec := 0
		var was_paused := false
		var previous := start
		var frame_ms: Array[float] = []
		var peak_process_ms := 0.0
		var peak_physics_ms := 0.0
		var peak_nodes := 0
		var peak_draw_calls := 0
		while Time.get_ticks_usec()-start < 1800000:
			await process_frame
			var now := Time.get_ticks_usec()
			frame_ms.append((now-previous)/1000.0)
			peak_process_ms = maxf(peak_process_ms, Performance.get_monitor(Performance.TIME_PROCESS)*1000)
			peak_physics_ms = maxf(peak_physics_ms, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000)
			peak_nodes = maxi(peak_nodes, int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
			peak_draw_calls = maxi(peak_draw_calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
			if was_paused: paused_usec += now-previous
			if paused and not was_paused: pauses += 1
			was_paused = paused
			previous = now
		frame_ms.sort()
		var record := {"pass": "first" if pass_index == 0 else "repeat", "targets": target_count, "form": form, "contacts": contacts, "contact_ticks": contact_frames.size(), "global_pauses": pauses, "paused_ms": paused_usec/1000.0, "frame_p50_ms": frame_ms[int((frame_ms.size()-1)*.5)], "frame_p95_ms": frame_ms[int((frame_ms.size()-1)*.95)], "frame_max_ms": frame_ms[-1], "process_peak_ms": peak_process_ms, "physics_peak_ms": peak_physics_ms, "nodes_peak": peak_nodes, "draw_calls_peak": peak_draw_calls}
		results.append(record)
		print("EARTHSPLITTER_HORDE "+JSON.stringify(record))
		assert(contacts == target_count*(form+1),"Released wave lost or duplicated its authored target contacts")
		assert(contact_frames.size() > 1 or target_count == 1,"Fixture must span multiple physics ticks")
		if not "--baseline" in OS.get_cmdline_user_args():
			assert(pauses == 0,"Authored travelling wave must not pause the whole game per target")
			assert(CombatFeedbackPresenter.find_for_player(player) == feedback,"Feedback must resolve independently of service folder names")
	if "--profile" in OS.get_cmdline_user_args():
		var folder := "res://tmp/review/encounters/arrival_2026_10_03/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var file := FileAccess.open(folder+"skill1_%d_%d_%s.json" % [target_count,form,DisplayServer.get_name()],FileAccess.WRITE)
		file.store_string(JSON.stringify({"engine":Engine.get_version_info().string, "display":DisplayServer.get_name(), "fixture":"stationary high-HP targets, no enemy AI; first/repeated cast, not a full cold campaign or phone GPU profile", "results":results},"\t"))
	world.queue_free()
	await process_frame
	quit()
