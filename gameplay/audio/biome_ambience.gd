extends Node2D

## Scene-owned ambience. Timers/events avoid per-frame polling and global leaks.
@export var profile: BiomeAudioProfile
@export var encounter: EncounterController
@export var cue_positions: PackedVector2Array
@export var spatial_bed := false
@export var bed_max_distance := 900.0
# Both audio-player classes expose the same stream/mix interface.
var bed: Variant
var cue: AudioStreamPlayer2D
var cue_timer: Timer
var _mix: Tween
var _combat := false
var _enabled := true
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	if profile == null:
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	_random.randomize()
	bed = AudioStreamPlayer2D.new() if spatial_bed else AudioStreamPlayer.new()
	if spatial_bed:
		bed.max_distance = bed_max_distance
		bed.attenuation = 1.2
		bed.panning_strength = .25
	bed.name = "OutdoorBed"
	bed.bus = &"Ambience"
	bed.stream = profile.bed_stream.duplicate() if profile.bed_stream != null else null
	if bed.stream is AudioStreamMP3: bed.stream.loop = true
	if bed.stream is AudioStreamOggVorbis: bed.stream.loop = true
	bed.volume_db = -48.0
	add_child(bed)
	cue = AudioStreamPlayer2D.new()
	cue.name = "LocalOutdoorCue"
	cue.bus = &"Ambience"
	cue.stream = profile.cue_stream
	cue.volume_db = profile.cue_volume_db
	cue.max_distance = profile.cue_max_distance
	cue.attenuation = 1.5
	cue.panning_strength = .65
	add_child(cue)
	cue_timer = Timer.new()
	cue_timer.one_shot = true
	add_child(cue_timer)
	cue_timer.timeout.connect(_play_cue)
	if encounter != null:
		encounter.wave_changed.connect(_on_wave_changed)
		encounter.stage_cleared.connect(_on_stage_cleared)
	set_enabled(true)


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	if bed == null: return
	if enabled:
		if DisplayServer.get_name() != "headless" and bed.stream != null and not bed.playing:
			bed.play()
		_schedule_cue()
	else:
		cue.stop()
		cue_timer.stop()
	_update_mix()


func _on_wave_changed(_index: int, _total: int, _title: String) -> void:
	_combat = true
	_update_mix()


func _on_stage_cleared() -> void:
	_combat = false
	_update_mix()

func set_combat_active(active: bool) -> void:
	## Boss flows have an entrance event rather than another ordinary wave.
	_combat = active
	_update_mix()


func _update_mix() -> void:
	if _mix != null: _mix.kill()
	var gain := profile.bed_volume_db - (profile.combat_reduction_db if _combat else 0.0)
	cue.volume_db = profile.cue_volume_db - (profile.combat_reduction_db if _combat else 0.0)
	_mix = create_tween()
	_mix.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_mix.tween_property(bed, "volume_db", gain if _enabled else -48.0, .8)
	if not _enabled: _mix.tween_callback(bed.stop)


func _play_cue() -> void:
	if not _enabled: return
	if not cue_positions.is_empty() and cue.stream != null:
		cue.position = cue_positions[_random.randi_range(0, cue_positions.size()-1)]
		cue.pitch_scale = _random.randf_range(.96, 1.04)
		if DisplayServer.get_name() != "headless": cue.play()
	_schedule_cue()


func _schedule_cue() -> void:
	if not _enabled or cue_positions.is_empty() or profile.cue_stream == null: return
	cue_timer.start(_random.randf_range(maxf(6.0, profile.cue_interval.x), maxf(6.0, profile.cue_interval.y)))


func _exit_tree() -> void:
	if _mix != null: _mix.kill()
	if bed != null: bed.stop()
	if cue != null: cue.stop()
