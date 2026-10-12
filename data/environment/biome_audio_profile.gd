class_name BiomeAudioProfile
extends Resource

## Immutable recording selection and restrained mix; scene nodes own playback.
@export var bed_stream: AudioStream
@export var cue_stream: AudioStream
@export var bed_volume_db := -29.0
@export var cue_volume_db := -19.0
@export var combat_reduction_db := 6.0
@export var cue_interval := Vector2(18, 32)
@export var cue_max_distance := 900.0

