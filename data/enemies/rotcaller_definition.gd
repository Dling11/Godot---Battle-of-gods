class_name RotcallerDefinition
extends EnemyDefinition

@export var damage_type := DamageInfo.DamageType.MAGIC

## Prototype tuning; campaign waves do not include this archetype yet.
@export_range(16,64,1) var zone_radius := 32.0
@export_range(2,12,.1) var cast_interval := 5.0
@export_range(.2,2,.05) var interruption_recovery := .8
