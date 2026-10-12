extends Node2D

@export var hoof_player: AudioStreamPlayer2D
@export var brace_player: AudioStreamPlayer2D
@export var snort_player: AudioStreamPlayer2D
@export var crash_player: AudioStreamPlayer2D


func play_hoofbeat() -> void:
	_play(hoof_player, randf_range(0.94, 1.06))


func play_brace(state: ArmoredHog.State, _duration_seconds: float) -> void:
	if state == ArmoredHog.State.BRACE:
		_play(brace_player, 1.0)
		_play(snort_player, randf_range(0.80, 0.86))


func play_crash() -> void:
	_play(crash_player, randf_range(0.94, 1.0))


func _play(player: AudioStreamPlayer2D, pitch: float) -> void:
	if player == null or player.stream == null or DisplayServer.get_name() == "headless":
		return
	player.pitch_scale = pitch
	player.play()
