extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var audio_director := root.get_node_or_null("AudioDirector")
	if audio_director == null:
		_fail("AudioDirector autoload is unavailable.")
		return
	await process_frame
	if AudioServer.get_bus_index("Music") < 0:
		_fail("AudioDirector did not create the dedicated Music bus.")
		return
	if audio_director.process_mode != Node.PROCESS_MODE_ALWAYS or audio_director.music_player.process_mode != Node.PROCESS_MODE_ALWAYS:
		_fail("Music playback would pause with dialogue or menu modals.")
		return
	var grove_music := load("res://assets/audio/music/cathedral_in_the_forest.ogg") as AudioStream
	audio_director.play_music(grove_music)
	await process_frame
	if DisplayServer.get_name() != "headless":
		await create_timer(1.1).timeout
	if audio_director.music_player.stream != grove_music:
		_fail("AudioDirector did not assign the approved Grove music stream.")
		return
	if not is_equal_approx(audio_director.music_player.volume_db, AudioDirector.DEFAULT_MUSIC_VOLUME_DB):
		_fail("Ordinary stage music lost its restrained default playback level.")
		return
	if grove_music is AudioStreamOggVorbis and not (grove_music as AudioStreamOggVorbis).loop:
		_fail("The approved Grove music is not configured to loop.")
		return
	paused = true
	await process_frame
	if not audio_director.music_player.can_process():
		_fail("Music player stopped processing while gameplay was paused.")
		return
	paused = false
	audio_director.play_music(grove_music, -7.0)
	if DisplayServer.get_name() != "headless":
		await create_timer(.6).timeout
	if not is_equal_approx(audio_director.music_player.volume_db, -7.0):
		_fail("A boss encounter cannot request its dedicated louder music level.")
		return
	audio_director.stop_music()
	grove_music = null
	await process_frame
	print("Audio director smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
