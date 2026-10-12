extends StaticBody2D

@onready var health_component = %HealthComponent
@onready var health_label: Label = %HealthLabel
@onready var body_visual: Polygon2D = %BodyVisual


func _ready() -> void:
	_update_health(health_component.current_health, health_component.maximum_health)


func _update_health(current: float, maximum: float) -> void:
	health_label.text = "%d / %d" % [ceili(current), ceili(maximum)]


func _on_damaged(_info) -> void:
	var tween := create_tween()
	body_visual.modulate = Color(1.8, 0.8, 0.8, 1.0)
	tween.tween_property(body_visual, "modulate", Color.WHITE, 0.12)


func _on_died() -> void:
	health_component.current_health = health_component.maximum_health
	health_component.health_changed.emit(
		health_component.current_health,
		health_component.maximum_health
	)

