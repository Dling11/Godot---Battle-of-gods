extends "res://tools/launch_combat_impact_review.gd"

## Native Stage IV / moving AI. Record evidence; do not assert machine timings.
const OUT := "res://tmp/review/combat/critical_impact_2026_10_04/"
var contacts := 0
var contact_ticks: Dictionary = {}

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/combat/critical_impact_2026_10_04/"))
	_showcase_crit = false
	_counter_enabled = false
	await super._run()
	root.size = Vector2i(960,540)
	toolbar.hide()
	var count := 8
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--targets="): count = clampi(argument.trim_prefix("--targets=").to_int(),1,8)
	var actor: Player = stage.player
	actor.set_physics_process(false)
	actor.health_component.set_maximum_health(99999,false)
	actor.health_component.set_current_health(99999)
	_spawn_batch(count)
	await create_timer(1.1).timeout
	var enemies: Array[Node] = []
	for child in stage.encounter_controller.actors.get_children():
		if child != actor and child.get("definition") is EnemyDefinition: enemies.append(child)
	assert(enemies.size()==count,"Review did not materialize the requested real enemy batch")
	for foe in enemies:
		var health: HealthComponent = foe.get_node("HealthComponent")
		health.set_maximum_health(10000,false)
		health.set_current_health(10000)
	actor.ability_1_component.hit_landed.connect(func(_target: HurtboxComponent,_info: DamageInfo) -> void:
		contacts += 1
		contact_ticks[Engine.get_physics_frames()] = true)
	var results: Array[Dictionary] = []
	results.append(await _sample("moving_AI_baseline",1.0,count))
	for pass_index in 2:
		for index in enemies.size():
			# Keep AI on; only establish a reproducible starting lane for the cast.
			enemies[index].global_position = actor.global_position+Vector2(55+index*11,(index%2)*6-3)
		await physics_frame
		actor.ability_1_component.clear_cooldown()
		contacts = 0
		contact_ticks.clear()
		assert(actor.ability_1_component.request_cast_at(actor.global_position+Vector2(320,0),actor.attack_component.weapon.damage))
		results.append(await _sample("first_cast" if pass_index==0 else "repeat_cast",1.8,count))
	var file := FileAccess.open(OUT+"stage4_horde_%d.json" % count,FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"display":DisplayServer.get_name(),"fixture":"real Stage IV, moving Rootlings and one Rotcaller for >=3; vulnerable stationary King, high HP, no rewards/saves; fresh process per batch; not a cold campaign/GPU/phone profile","results":results},"\t"))
	stage.queue_free()
	await process_frame
	quit()

func _sample(label: String,seconds: float,count: int) -> Dictionary:
	var start := Time.get_ticks_usec()
	var previous := start
	var frames: Array[float] = []
	var process_peak := 0.0
	var physics_peak := 0.0
	var nodes_peak := 0
	var draws_peak := 0
	var pauses := 0
	var was_paused := false
	var health_before: float = stage.player.health_component.current_health
	while Time.get_ticks_usec()-start < seconds*1000000.0:
		await process_frame
		var now := Time.get_ticks_usec()
		frames.append((now-previous)/1000.0)
		previous = now
		process_peak = maxf(process_peak,Performance.get_monitor(Performance.TIME_PROCESS)*1000.0)
		physics_peak = maxf(physics_peak,Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.0)
		nodes_peak = maxi(nodes_peak,int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
		draws_peak = maxi(draws_peak,int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		if paused and not was_paused: pauses += 1
		was_paused = paused
	frames.sort()
	var record := {"sample":label,"targets":count,"contacts":contacts,"contact_ticks":contact_ticks.size(),"global_pauses":pauses,"king_health_lost":health_before-stage.player.health_component.current_health,"frame_p50_ms":frames[int((frames.size()-1)*.5)],"frame_p95_ms":frames[int((frames.size()-1)*.95)],"frame_max_ms":frames[-1],"process_peak_ms":process_peak,"physics_peak_ms":physics_peak,"nodes_peak":nodes_peak,"draw_calls_peak":draws_peak}
	print("STAGE4_HORDE "+JSON.stringify(record))
	return record
