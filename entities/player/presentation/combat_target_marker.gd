class_name CombatTargetMarker
extends Node2D

## Lightweight world-space selection mark; target authority stays in the
## targeting component and this node only follows/presents it.

@export var targeting_component: PlayerCombatTargetingComponent

var _pulse_time := 0.0


func _ready() -> void:
	top_level = true
	z_index = 30
	visible = false
	if targeting_component == null:
		push_error("CombatTargetMarker requires a targeting component.")
		return
	targeting_component.target_changed.connect(_on_target_changed)
	set_process(false)


func _process(delta: float) -> void:
	if not targeting_component.has_valid_target():
		visible = false
		set_process(false)
		return
	_pulse_time += delta
	global_position = targeting_component.target_actor.global_position + Vector2(0.0, -30.0)
	queue_redraw()


func _draw() -> void:
	## A restrained overhead chevron keeps selection readable without painting a
	## second red footprint ring beneath every selected enemy.
	var bob := sin(_pulse_time * 5.0) * 1.5
	var color := Color(1.0, 0.34, 0.24, 0.96)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-6.0, -3.0 + bob),
			Vector2(0.0, 4.0 + bob),
			Vector2(6.0, -3.0 + bob),
			Vector2(4.0, -6.0 + bob),
			Vector2(0.0, -1.0 + bob),
			Vector2(-4.0, -6.0 + bob),
		]),
		color
	)


func _on_target_changed(actor: Node2D, _health: HealthComponent, _display_name: String) -> void:
	visible = actor != null
	set_process(actor != null)
	if actor != null:
		global_position = actor.global_position + Vector2(0.0, -30.0)
		_pulse_time = 0.0
		queue_redraw()
