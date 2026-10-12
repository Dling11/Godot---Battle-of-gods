class_name CounterableHostileProjectile
extends HostileProjectile

signal countered

@export var counter_effect_scene: PackedScene

@onready var health_component: HealthComponent = %HealthComponent


func _ready() -> void:
	super._ready()
	if health_component == null:
		push_error("CounterableHostileProjectile requires a HealthComponent.")
		return
	health_component.died.connect(_on_countered)


func _on_countered() -> void:
	if _resolved:
		return
	countered.emit()
	_resolve_impact(counter_effect_scene)
