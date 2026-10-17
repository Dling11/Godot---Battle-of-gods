extends Node2D

## Bounded event-driven recorded spin, activation and finishing audio.
var component: WarCycloneComponent
var loop: AudioStreamPlayer2D
var cue: AudioStreamPlayer2D
var _envelope: Tween
var _last_ack := -1000

func configure(actor: Player) -> void:
	component = actor.war_cyclone
	loop = _voice(-26)
	cue = _voice(-14)
	var stream := (component.definition as WarCycloneDefinition).swing_sound.duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size()/2
	loop.stream = stream
	component.phase_changed.connect(_phase)
	component.channel_reaffirmed.connect(_acknowledge)
	component.ability_finished.connect(_stop)

func _voice(db: float) -> AudioStreamPlayer2D:
	var voice := AudioStreamPlayer2D.new()
	voice.bus = &"SFX"
	voice.volume_db = db
	add_child(voice)
	return voice

func _phase(phase: int,_seconds: float) -> void:
	if DisplayServer.get_name()=="headless": return
	var tuning := component.definition as WarCycloneDefinition
	if _envelope!=null and _envelope.is_valid(): _envelope.kill()
	if phase==AbilityComponent.Phase.WIND_UP:
		loop.stop()
		_play_cue(tuning.activation_sound,-14,1.0)
	elif phase==AbilityComponent.Phase.ACTIVE:
		loop.pitch_scale = clampf(.5/component.turn_period,.85,1.5)
		loop.volume_db = -36
		loop.play()
		_envelope = create_tween()
		_envelope.tween_property(loop,"volume_db",-23.0,.06)
	elif phase==AbilityComponent.Phase.RECOVERY:
		_envelope = create_tween()
		_envelope.tween_property(loop,"volume_db",-48.0,.12)
		_envelope.tween_callback(loop.stop)
		_play_cue(tuning.finish_sound,-17,.95)

func _acknowledge() -> void:
	var now := Time.get_ticks_msec()
	if now-_last_ack<180 or DisplayServer.get_name()=="headless": return
	_last_ack = now
	_play_cue((component.definition as WarCycloneDefinition).activation_sound,-25,1.15)

func _play_cue(stream: AudioStream,db: float,pitch: float) -> void:
	cue.stream = stream
	cue.volume_db = db
	cue.pitch_scale = pitch
	cue.play()

func _stop() -> void:
	if _envelope!=null and _envelope.is_valid(): _envelope.kill()
	loop.stop()
	cue.stop()

func _exit_tree() -> void:
	if _envelope!=null and _envelope.is_valid(): _envelope.kill()
