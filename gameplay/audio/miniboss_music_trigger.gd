class_name MinibossMusicTrigger
extends Node

@export var encounter_controller: EncounterController
@export var miniboss_music: AudioStream
@export var cleared_volume_db := -17.0


func _ready() -> void:
	if encounter_controller == null:
		push_error("MinibossMusicTrigger requires an EncounterController.")
		return
	encounter_controller.wave_changed.connect(_on_wave_changed)
	encounter_controller.stage_cleared.connect(_on_stage_cleared)


func _on_wave_changed(index: int, _total: int, _title: String) -> void:
	if index < 1 or index > encounter_controller.waves.size():
		return
	var wave := encounter_controller.waves[index - 1] as EncounterWaveDefinition
	if wave == null or wave.rootbound_husk_count <= 0:
		return
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.play_music(miniboss_music)


func _on_stage_cleared() -> void:
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.set_music_volume(miniboss_music,cleared_volume_db)
