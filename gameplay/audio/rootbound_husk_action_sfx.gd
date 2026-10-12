class_name RootboundHuskActionSfx
extends Node2D

## Rootbound Husk-specific layered cue observer. Telegraphs use a woody creak;
## eruptions combine a root snap with a lower earth body.

@export var wind_up_player: AudioStreamPlayer2D
@export var eruption_player: AudioStreamPlayer2D
@export var earth_player: AudioStreamPlayer2D


func play_wind_up(_payload: Variant = null, _duration_seconds: Variant = null) -> void:
	_play(wind_up_player)


func play_eruption(_payload: Variant = null) -> void:
	_play(eruption_player)
	_play(earth_player)


func _play(player: AudioStreamPlayer2D) -> void:
	if player != null and player.stream != null and DisplayServer.get_name() != "headless":
		player.play()
