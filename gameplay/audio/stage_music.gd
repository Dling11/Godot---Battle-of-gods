extends Node

## Stage-local selection routed through the global music owner.

@export var music_stream: AudioStream
@export var encounter: EncounterController
@export var exploration_volume_db := -13.0
@export var combat_volume_db := -13.0
@export var cleared_volume_db := -17.0


func _ready() -> void:
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.play_music(music_stream, exploration_volume_db)
	if encounter != null:
		encounter.wave_changed.connect(_on_wave_changed)
		encounter.stage_cleared.connect(_on_stage_cleared)


func _on_wave_changed(_index: int, _total: int, _title: String) -> void:
	get_node("/root/AudioDirector").set_music_volume(music_stream, combat_volume_db)


func _on_stage_cleared() -> void:
	get_node("/root/AudioDirector").set_music_volume(music_stream, cleared_volume_db)
