class_name EnemyHealthBar
extends Node2D

@export var health_component: HealthComponent
@export_range(0.5, 10.0, 0.1, "suffix:s") var visible_duration := 2.2

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var hide_timer: Timer = %HideTimer


func _ready() -> void:
	if health_component == null:
		push_error("EnemyHealthBar requires a HealthComponent reference.")
		hide()
		return
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	progress_bar.max_value = health_component.maximum_health
	progress_bar.value = health_component.current_health
	hide()


func _on_health_changed(current: float, maximum: float) -> void:
	progress_bar.max_value = maximum
	progress_bar.value = current
	if current <= 0.0 or current >= maximum:
		hide_timer.stop()
		hide()
		return
	show()
	hide_timer.start(visible_duration)


func _on_died() -> void:
	hide_timer.stop()
	hide()


func _on_hide_timer_timeout() -> void:
	hide()
