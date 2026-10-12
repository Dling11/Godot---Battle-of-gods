extends SceneTree

var checks := 0
var failures := 0
var native := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	native = DisplayServer.get_name() != "headless"
	var director := root.get_node("AudioDirector")
	var grove := load("res://assets/audio/music/expedition_dark_forest.mp3") as AudioStream
	_check(grove.get_length() > 60 and grove.loop,"New expedition theme is not a complete imported loop")
	_check(grove != load("res://assets/audio/music/cathedral_in_the_forest.ogg"),"Expedition theme still equals the Sanctuary composition")
	var boss := load("res://assets/audio/music/boss/varkuun_battle_rpg_theme_loop.ogg") as AudioStream
	director.stop_music()
	director.play_music(grove)
	await create_timer(1.0).timeout
	_check(director.music_player.stream == grove and is_equal_approx(director.music_player.volume_db,-13.0),"Initial music did not fade to its target")
	var position: float = director.music_player.get_playback_position()
	director.play_music(grove,-16.0)
	await create_timer(.6).timeout
	_check(is_equal_approx(director.music_player.volume_db,-16.0),"Same-track mix failed")
	if native: _check(director.music_player.get_playback_position() > position,"Same track restarted during a volume change")
	director.play_music(boss,-7.0)
	await create_timer(.1).timeout
	director.play_music(grove,-15.0)
	paused = true
	await create_timer(1.1).timeout
	_check(director.music_player.stream == grove and is_equal_approx(director.music_player.volume_db,-15.0),"Rapid handoff did not finish newest request while paused")
	paused = false
	director.play_music(boss,-7.0)
	director.set_music_volume(grove,-33.0)
	await create_timer(1.1).timeout
	_check(director.music_player.stream == boss and is_equal_approx(director.music_player.volume_db,-7.0),"Outgoing scene changed the next scene's mix")
	director.play_music(grove)
	director.stop_music()
	await create_timer(1.0).timeout
	_check(director.music_player.stream == null and not director.music_player.playing,"Canceled handoff restarted music after stop")
	_check(director.find_children("*","AudioStreamPlayer",true,false).size() == 1,"Music handoff overlaps complete tracks")
	var hollow := "--stage-3" in OS.get_cmdline_user_args()
	var eastern := "--stage-4" in OS.get_cmdline_user_args()
	var stage: Node = load("res://levels/stage_4/stage_4.tscn" if eastern else ("res://levels/stage_3/stage_3.tscn" if hollow else "res://levels/stage_2/stage_2.tscn")).instantiate()
	stage.review_hold_encounter = true
	root.add_child(stage)
	current_scene = stage
	stage.player.health_component.is_damage_immune = true
	var ambience: Node2D = stage.get_node("World/EasternRotAudio" if eastern else "World/OutdoorAudio")
	await create_timer(1.0).timeout
	_check(ambience.bed.stream.get_length() > (40 if hollow or eastern else 60) and ambience.cue.stream.get_length() > (1 if hollow or eastern else 3),"Recorded ambience failed to import")
	_check(ambience.bed.stream.loop and not ambience.profile.bed_stream.loop,"Bed looping mutated the shared profile's recording")
	_check(ambience.bed.bus == &"Ambience" and ambience.cue.bus == &"Ambience","Ambience bypassed its dedicated bus")
	_check(AudioServer.get_bus_send(AudioServer.get_bus_index("Ambience")) == &"Music","Music toggle no longer controls outdoor ambience")
	var bed_gain := -30.0 if hollow or eastern else -31.0
	if eastern:
		var west: Node2D = stage.get_node("World/LivingWestAudio")
		_check(ambience.bed is AudioStreamPlayer2D and west.bed is AudioStreamPlayer2D,"Eastern biome beds are not spatial")
		_check(west.global_position.x < 900 and ambience.global_position.x > 1050,"Regional sound centers do not follow the living/rot boundary")
		_check(west.profile.bed_stream != ambience.profile.bed_stream,"Regional sound beds do not distinguish grove and decay")
	_check(is_equal_approx(ambience.bed.volume_db,bed_gain),"Quiet exploration mix is wrong")
	_check(ambience.cue_timer.time_left > 18,"Bird calls are too frequent")
	if native:
		_check(ambience.bed.playing and ambience.bed.get_playback_position() > .2,"Outdoor bed has no device playback")
		ambience._play_cue()
		await create_timer(.15).timeout
		_check(ambience.cue.playing and ambience.cue_positions.has(ambience.cue.position),"Local call is not playing from an authored position")
		# Test a nearby call as well as ordinary distant attenuation.
		ambience.cue.position = stage.player.global_position+Vector2(60,-50)
		var peak := -200.0
		for frame in 12:
			await process_frame
			peak = maxf(peak,AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Ambience"),0))
		_check(peak > -80.0,"Ambient device bus never produced a measurable signal")
	stage.encounter_controller.start_encounter()
	await create_timer(1.1).timeout
	_check(stage.encounter_controller.wave_index == 0 and is_equal_approx(ambience.bed.volume_db,bed_gain-6),"Real encounter start did not duck ambience")
	_check(is_equal_approx(director.music_player.volume_db,-13.0),"Real encounter start did not restore combat music gain")
	# This presentation-only signal fixture checks the clear mix, not rewards.
	stage.encounter_controller.stage_cleared.emit()
	await create_timer(1.0).timeout
	_check(is_equal_approx(ambience.bed.volume_db,bed_gain) and is_equal_approx(director.music_player.volume_db,-17.0),"Clear mix did not recover outdoor sound")
	ambience.set_enabled(false)
	await create_timer(.9).timeout
	_check(not ambience.bed.playing and ambience.cue_timer.is_stopped(),"Disabled ambience retained its playback/timer")
	ambience.set_enabled(true)
	await create_timer(.9).timeout
	_check(not ambience.cue_timer.is_stopped(),"Re-enabled ambience lost its local cues")
	stage.queue_free()
	await process_frame
	await process_frame
	_check(not is_instance_valid(ambience),"Outdoor sound leaked beyond scene teardown")
	director.stop_music()
	print("BIOME_AUDIO_%s: " % ("RENDERED" if native else "HEADLESS"),checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
