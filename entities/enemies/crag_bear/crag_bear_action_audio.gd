class_name CragBearActionAudio
extends Node2D

## Presentation-only Crag Bear action suite. State transitions choose the cue;
## authoritative action timing and damage remain in CragBear.

@export var claw_player: AudioStreamPlayer2D
@export var growl_a_player: AudioStreamPlayer2D
@export var growl_b_player: AudioStreamPlayer2D
@export var slam_player: AudioStreamPlayer2D
@export_range(0.0, 1.0, 0.01) var growl_delay_ratio := 0.28

var _state_token := 0
var _next_growl_variant := 0


func play_state(state: int, duration_seconds: float) -> void:
	_state_token += 1
	var token := _state_token
	match state:
		CragBear.State.BASIC_ACTIVE:
			_play(claw_player)
		CragBear.State.SLAM_WIND_UP:
			_queue_growl(token, duration_seconds)
		CragBear.State.SLAM_ACTIVE:
			_play(slam_player)
		CragBear.State.STAGGER, CragBear.State.DEAD:
			_stop_growls()


func _queue_growl(token: int, wind_up_seconds: float) -> void:
	var delay := clampf(wind_up_seconds * growl_delay_ratio, 0.08, 0.28)
	get_tree().create_timer(delay).timeout.connect(
		func() -> void:
			if token != _state_token:
				return
			var bear := get_parent() as CragBear
			if bear == null or bear.state != CragBear.State.SLAM_WIND_UP:
				return
			var selected := growl_a_player if _next_growl_variant == 0 else growl_b_player
			_next_growl_variant = 1 - _next_growl_variant
			_play(selected)
	)


func _stop_growls() -> void:
	for player in [growl_a_player, growl_b_player]:
		if player != null:
			player.stop()


func _play(player: AudioStreamPlayer2D) -> void:
	if player != null and player.stream != null and DisplayServer.get_name() != "headless":
		player.play()
