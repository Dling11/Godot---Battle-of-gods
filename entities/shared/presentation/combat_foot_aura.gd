class_name CombatFootAura
extends Node2D

## Presentation-only footprint aura. Damage and selection continue to use the
## actor's authored physics shapes; this makes that footprint readable in play.

@export var player_aura := false

var _elapsed := 0.0
var _radius := 12.0
var _tier := EnemyDefinition.CrowdControlTier.LIGHT


func _ready() -> void:
	z_index = -6
	position.y = -1.0
	scale = Vector2(1.0, 0.48)
	var actor := get_parent()
	var definition: Variant = actor.get("definition") if actor != null else null
	if definition is EnemyDefinition:
		_radius = maxf((definition as EnemyDefinition).movement_footprint_radius + 4.0, 10.0)
		_tier = (definition as EnemyDefinition).crowd_control_tier
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed = fmod(_elapsed + delta, TAU * 4.0)
	queue_redraw()


func _draw() -> void:
	var core := Color(0.12, 0.52, 0.65, 0.12) if player_aura else Color(0.52, 0.12, 0.10, 0.1)
	var edge := Color(0.24, 0.78, 0.92, 0.48) if player_aura else Color(0.88, 0.32, 0.20, 0.36)
	var arc_count := 1
	if not player_aura and _tier == EnemyDefinition.CrowdControlTier.ELITE:
		core = Color(0.72, 0.38, 0.08, 0.13)
		edge = Color(1.0, 0.66, 0.18, 0.56)
		arc_count = 2
	elif not player_aura and _tier == EnemyDefinition.CrowdControlTier.BOSS:
		core = Color(0.42, 0.08, 0.18, 0.17)
		edge = Color(0.92, 0.20, 0.38, 0.64)
		arc_count = 3
	draw_circle(Vector2.ZERO, _radius, core)
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 32, edge.darkened(0.28), 1.0)
	for index in arc_count:
		var start := _elapsed * (0.42 + index * 0.08) + index * TAU / arc_count
		draw_arc(Vector2.ZERO, _radius + 2.0 + index * 1.5, start, start + 1.05, 10, edge, 1.5)
