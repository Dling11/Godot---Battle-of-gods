class_name WeaponHitAudioDefinition
extends Resource

## Accepted-contact audio only. Air swings retain their existing presentation.
@export var variations: Array[AudioStream] = []
@export_range(0.5, 2.0, 0.01) var pitch := 1.0
@export_range(-30.0, 0.0, 0.5) var volume_db := -10.0


func stream_for(index: int) -> AudioStream:
	return variations[posmod(index, variations.size())] if not variations.is_empty() else null


func pitch_for(index: int) -> float:
	return pitch * [1.0, 0.97, 1.03][posmod(index, 3)]
