class_name SummonEffect
extends Node2D

## Presentation contract. EncounterController alone owns arrival/actor timing.
var released := false

func release() -> void:
	released = true
