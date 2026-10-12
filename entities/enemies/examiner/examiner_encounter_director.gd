class_name ExaminerEncounterDirector
extends Node

const ExaminerTheme = preload("res://assets/audio/music/boss/examiner/examiner_ethereal_vocal_loop.mp3")

@export var player: Player
@export var camera: Camera2D
@export var arena: CourtOfFirstMeasure
@export var dialogue: DialoguePanel
@export var combat_hud: CombatHUD

var examiner: Examiner
var _transition_running := false
var _camera_home := Vector2.ZERO
var _music_player: AudioStreamPlayer
var _music_tween: Tween
var _silence_timer: Timer
var _outro_running := false
var _binding_revision := 0
var _camera_tween: Tween
var _last_remark_ms := -10000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_camera_home = camera.position if camera != null else Vector2.ZERO
	_music_player = _make_music_player(ExaminerTheme, -14.0)
	_silence_timer = Timer.new()
	_silence_timer.one_shot = true
	_silence_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	_silence_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_silence_timer.timeout.connect(_on_impact_silence)
	add_child(_silence_timer)
	if dialogue != null:
		dialogue.dialogue_closed.connect(_on_dialogue_closed)


func bind(next_examiner: Examiner) -> void:
	_binding_revision += 1
	_outro_running = false
	_transition_running = false
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	if examiner != null and is_instance_valid(examiner):
		_stop_theme()
		_disconnect_examiner()
	examiner = next_examiner
	_transition_running = false
	if examiner == null:
		_stop_theme()
		if arena != null:
			arena.reset_trial()
		if player != null:
			player.set_cinematic_locked(false)
		if camera != null:
			camera.position = _camera_home
		if dialogue != null and dialogue.visible:
			dialogue.close_dialogue(false)
		return
	arena.set_sanctuary(false)
	examiner.trial_started.connect(_on_trial_started)
	examiner.trial_finished.connect(_on_trial_finished)
	examiner.phase_transition_requested.connect(_on_phase_transition_requested)
	examiner.divine_descent_launched.connect(_on_divine_descent_launched)
	examiner.divine_descent_impact.connect(_on_divine_descent_impact)
	examiner.phase_two_started.connect(_on_phase_two_started)
	examiner.berserk_started.connect(_on_berserk_started)
	examiner.state_changed.connect(_on_technique_state)
	examiner.victory_started.connect(_on_victory_started)
	examiner.victory_ready.connect(_on_victory_ready)
	examiner.combat_remark.connect(_on_combat_remark)
	examiner.tree_exited.connect(_on_examiner_exited)
	_start_theme()


func force_divine_descent() -> bool:
	return examiner != null and is_instance_valid(examiner) and examiner.request_phase_transition()


func _on_phase_transition_requested() -> void:
	if _transition_running or examiner == null:
		return
	_transition_running = true
	var revision := _binding_revision
	player.set_cinematic_locked(true)
	_duck_for_dialogue()
	var focus_offset := examiner.global_position - player.global_position + Vector2(0.0, -24.0)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_camera_tween = tween
	tween.tween_property(camera, "position", focus_offset, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	if revision != _binding_revision or examiner == null or not is_instance_valid(examiner):
		return
	dialogue.show_dialogue("THE EXAMINER", ["You seek the hundredth gate. You are not ready.", "Break my seal. Silence my judgment."])


func _on_dialogue_closed(_completed: bool) -> void:
	if _outro_running:
		_finish_victory()
		return
	if not _transition_running or examiner == null or not is_instance_valid(examiner):
		return
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_camera_tween = tween
	var revision := _binding_revision
	tween.tween_property(camera, "position", _camera_home, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if revision == _binding_revision and examiner != null and is_instance_valid(examiner):
		_tween_theme(-9.5, 0.24)
		examiner.begin_divine_descent()


func _on_divine_descent_launched(charge_seconds: float) -> void:
	arena.begin_divine_descent_charge(charge_seconds)
	player.set_cinematic_locked(false)
	_tween_theme(-12.0, 0.32)
	_silence_timer.start(maxf(charge_seconds - 0.10, 0.05))
	if combat_hud != null:
		combat_hud.show_story_message("SANCTUARY OPEN  |  REACH THE CYAN CIRCLE" if examiner._trial_succeeded else "FINAL VERDICT  |  NO SANCTUARY", charge_seconds - 0.25)


func _on_divine_descent_impact(world_position: Vector2) -> void:
	# Leave the foundation nearly absent at contact so the dedicated landing
	# body pose and impact SFX carry the weight without a competing song.
	_tween_theme(-28.0, 0.06)
	var protected := arena.resolve_divine_descent(player, examiner.definition.verdict_damage, examiner)
	if combat_hud != null:
		combat_hud.show_story_message("WORTH PROVEN  |  SANCTUARY HELD" if protected else "FINAL VERDICT  |  SEAL UNBROKEN", 1.35)
	var feedback := get_tree().current_scene.find_child("CombatFeedback", true, false) if get_tree().current_scene != null else null
	if feedback != null and feedback.has_method("request_camera_pulse"):
		feedback.request_camera_pulse(8.0)
	# The actor owns the visible body impact; the arena owns the exact damage.
	if examiner != null:
		examiner.global_position = world_position


func _on_impact_silence() -> void:
	if examiner == null or not is_instance_valid(examiner):
		return
	_tween_theme(-42.0, 0.07)


func _on_phase_two_started() -> void:
	_transition_running = false
	arena.set_sanctuary(false)
	_tween_theme(-10.0, 0.72)
	if combat_hud != null:
		combat_hud.show_story_message("SECOND MEASURE", 1.8)


func _on_berserk_started() -> void:
	_tween_theme(-8.5, 1.4)
	if combat_hud != null:
		combat_hud.show_story_message("ENOUGH.  |  LET ME SHOW YOU WHAT YOU SERVE.", 2.5)


func _make_music_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var audio := AudioStreamPlayer.new()
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	audio.bus = &"Music"
	audio.stream = stream
	audio.volume_db = volume_db
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	add_child(audio)
	return audio


func _start_theme() -> void:
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.call("stop_music")
	if DisplayServer.get_name() == "headless":
		return
	_music_player.volume_db = -14.0
	_music_player.play()


func _duck_for_dialogue() -> void:
	_tween_theme(-22.0, 0.28)


func _tween_theme(volume_db: float, duration: float) -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.tween_property(_music_player, "volume_db", volume_db, duration)


func _stop_theme() -> void:
	if _silence_timer != null:
		_silence_timer.stop()
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	if _music_player != null:
		_music_player.stop()


func _disconnect_examiner() -> void:
	if examiner.victory_started.is_connected(_on_victory_started):
		examiner.victory_started.disconnect(_on_victory_started)
	if examiner.victory_ready.is_connected(_on_victory_ready):
		examiner.victory_ready.disconnect(_on_victory_ready)
	if examiner.combat_remark.is_connected(_on_combat_remark):
		examiner.combat_remark.disconnect(_on_combat_remark)
	if examiner.state_changed.is_connected(_on_technique_state):
		examiner.state_changed.disconnect(_on_technique_state)
	if examiner.berserk_started.is_connected(_on_berserk_started):
		examiner.berserk_started.disconnect(_on_berserk_started)
	if examiner.trial_started.is_connected(_on_trial_started):
		examiner.trial_started.disconnect(_on_trial_started)
	if examiner.trial_finished.is_connected(_on_trial_finished):
		examiner.trial_finished.disconnect(_on_trial_finished)
	if examiner.phase_transition_requested.is_connected(_on_phase_transition_requested):
		examiner.phase_transition_requested.disconnect(_on_phase_transition_requested)
	if examiner.divine_descent_launched.is_connected(_on_divine_descent_launched):
		examiner.divine_descent_launched.disconnect(_on_divine_descent_launched)
	if examiner.divine_descent_impact.is_connected(_on_divine_descent_impact):
		examiner.divine_descent_impact.disconnect(_on_divine_descent_impact)
	if examiner.phase_two_started.is_connected(_on_phase_two_started):
		examiner.phase_two_started.disconnect(_on_phase_two_started)
	if examiner.tree_exited.is_connected(_on_examiner_exited):
		examiner.tree_exited.disconnect(_on_examiner_exited)


func _on_examiner_exited() -> void:
	_binding_revision += 1
	_outro_running = false
	_transition_running = false
	player.set_cinematic_locked(false)
	camera.position = _camera_home
	_stop_theme()
	arena.set_sanctuary(false)
	examiner = null


func _on_trial_started() -> void:
	arena.set_sanctuary(false)
	player.set_cinematic_locked(false)
	if combat_hud != null:
		combat_hud.show_story_message("BORROWED SUN  |  SHATTER HIS SEAL TO INTERRUPT" if examiner._charged_skill == &"sun" else "TRIAL OF WORTH  |  BREAK HIS SEAL BEFORE HE LEAPS", 3.0)
		if examiner._charged_skill == &"firmament":
			combat_hud.show_story_message("CRIMSON FIRMAMENT  |  BREAK THE SEAL OR WEATHER THE RAIN", 3.4)


func _on_trial_finished(success: bool, _sanctuary: Vector2) -> void:
	arena.set_sanctuary(false)
	if combat_hud != null:
		var failure := "BORROWED SUN  |  MOVE FROM ITS LANDING MARK" if examiner._charged_skill == &"sun" else "SEAL UNBROKEN  |  VERDICT CANNOT BE DODGED"
		if examiner._charged_skill == &"firmament":
			failure = "CRIMSON FIRMAMENT  |  KEEP MOVING. READ THE MARKS."
		var success_text := "SEAL SHATTERED  |  HE IS EXPOSED. ATTACK!"
		if success:
			match examiner.seals_broken:
				1: success_text = "SEAL SHATTERED  |  Good. You are beginning to see."
				2: success_text = "SEAL SHATTERED  |  Again? Then I shall ask more of you."
				3: success_text = "SEAL SHATTERED  |  Do not mistake patience for weakness."
		combat_hud.show_story_message(success_text if success else failure, 2.6)


func _on_technique_state(state: Examiner.State, _duration: float) -> void:
	if state == Examiner.State.FIRMAMENT_BARRAGE and combat_hud != null:
		combat_hud.show_story_message("CRIMSON FIRMAMENT  |  KEEP MOVING. READ THE MARKS.", 4.0)


func _on_combat_remark(text: String) -> void:
	if combat_hud == null or Time.get_ticks_msec() - _last_remark_ms < 6000:
		return
	_last_remark_ms = Time.get_ticks_msec()
	combat_hud.show_story_message(text, 1.6)


func _on_victory_started() -> void:
	_transition_running = false
	_outro_running = false
	if dialogue != null and dialogue.visible:
		dialogue.close_dialogue(false)
	_outro_running = true
	_silence_timer.stop()
	arena.reset_trial()
	player.set_cinematic_locked(true)
	_tween_theme(-24.0, 0.7)
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	_camera_tween = create_tween()
	_camera_tween.tween_property(camera, "position", examiner.global_position - player.global_position + Vector2(0,-24), 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if combat_hud != null:
		combat_hud.show_story_message("THE TRIAL FALLS SILENT", 1.4)


func _on_victory_ready() -> void:
	if not _outro_running or not is_instance_valid(examiner):
		return
	if dialogue == null:
		_finish_victory()
		return
	dialogue.show_conversation([
		{"speaker":"THE EXAMINER", "text":"You have earned the right to continue."},
		{"speaker":"KING", "text":"Then the hundredth gate. My family..."},
		{"speaker":"THE EXAMINER", "text":"Hold to that purpose. It has brought you farther than you know."},
		{"speaker":"THE EXAMINER", "text":"Go. The path will remember that you passed my measure."},
	])


func _finish_victory() -> void:
	_outro_running = false
	if not is_instance_valid(examiner):
		return
	var revision := _binding_revision
	var broken := examiner.seals_broken
	var attempted := examiner.seals_attempted
	examiner.complete_victory()
	_camera_tween = create_tween()
	_camera_tween.tween_property(camera, "position", _camera_home, 0.35)
	await _camera_tween.finished
	if revision != _binding_revision:
		return
	player.set_cinematic_locked(false)
	if combat_hud != null:
		combat_hud.show_story_message("TRIAL COMPLETE  |  SEALS BROKEN %d/%d" % [broken, attempted], 4.0)
