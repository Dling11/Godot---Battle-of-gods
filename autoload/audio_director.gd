extends Node

## Owns music playback and its dedicated bus. Gameplay emits events; it does not own combat rules.

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const UI_BUS := "UI"
const AMBIENCE_BUS := "Ambience"

var music_player: AudioStreamPlayer

const DEFAULT_MUSIC_VOLUME_DB := -13.0
const SILENT_VOLUME_DB := -48.0
var _music_transition: Tween
var _requested_stream: AudioStream
var _requested_volume_db := DEFAULT_MUSIC_VOLUME_DB


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_ensure_bus(UI_BUS)
	_ensure_bus(AMBIENCE_BUS)
	AudioServer.set_bus_send(AudioServer.get_bus_index(AMBIENCE_BUS), MUSIC_BUS)
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = MUSIC_BUS
	music_player.volume_db = DEFAULT_MUSIC_VOLUME_DB
	add_child(music_player)


func play_music(stream: AudioStream, volume_db := DEFAULT_MUSIC_VOLUME_DB) -> void:
	if stream == null:
		stop_music()
		return
	if _requested_stream == stream:
		set_music_volume(stream, volume_db)
		return
	_requested_stream = stream
	_requested_volume_db = volume_db
	_cancel_transition()
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	# Headless verification has no audio device. Retaining the stream assignment
	# validates scene routing without leaving native OGG playback objects alive at
	# process shutdown.
	if DisplayServer.get_name() == "headless":
		music_player.stream = stream
		music_player.volume_db = volume_db
		return
	_music_transition = create_tween()
	_music_transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if music_player.playing:
		_music_transition.tween_property(music_player, "volume_db", SILENT_VOLUME_DB, .28)
	_music_transition.tween_callback(_switch_requested_track)
	_music_transition.tween_method(_fade_in, 0.0, 1.0, .65)


func set_music_volume(stream: AudioStream, volume_db: float) -> void:
	# Outgoing scenes cannot retune the next scene's music during travel.
	if stream != _requested_stream:
		return
	_requested_volume_db = volume_db
	if DisplayServer.get_name() == "headless":
		music_player.volume_db = volume_db
	elif music_player.stream == stream:
		_cancel_transition()
		_music_transition = create_tween()
		_music_transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_music_transition.tween_property(music_player, "volume_db", volume_db, .45)


func _switch_requested_track() -> void:
	music_player.stop()
	music_player.stream = _requested_stream
	music_player.volume_db = SILENT_VOLUME_DB
	music_player.play()


func _fade_in(weight: float) -> void:
	music_player.volume_db = lerpf(SILENT_VOLUME_DB, _requested_volume_db, weight)


func _cancel_transition() -> void:
	if _music_transition != null:
		_music_transition.kill()
		_music_transition = null


func stop_music() -> void:
	if music_player == null:
		return
	_cancel_transition()
	_requested_stream = null
	music_player.stop()
	music_player.stream = null


func _exit_tree() -> void:
	stop_music()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
