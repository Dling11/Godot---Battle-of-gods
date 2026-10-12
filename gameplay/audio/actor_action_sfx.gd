class_name ActorActionSfx
extends Node2D

## Configurable state/signal observer for enemy action sounds.

@export var primary_player: AudioStreamPlayer2D
@export var secondary_player: AudioStreamPlayer2D
@export var primary_state := -1
@export var secondary_state := -1


func play_state(state: int, _duration_seconds: float) -> void:
	if state == primary_state:
		play_primary()
	if state == secondary_state:
		play_secondary()


func play_primary(_payload: Variant = null) -> void:
	_play(primary_player)


func play_secondary(_payload: Variant = null) -> void:
	_play(secondary_player)


func _play(player: AudioStreamPlayer2D) -> void:
	if player != null and player.stream != null and DisplayServer.get_name() != "headless":
		player.play()
