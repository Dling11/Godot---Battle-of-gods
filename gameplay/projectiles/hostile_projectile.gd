class_name HostileProjectile
extends Area2D

@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var speed := 110.0
@export_range(0.1, 10.0, 0.1, "suffix:s") var lifetime_seconds := 3.0
@export_range(0.0, 1000.0, 1.0) var knockback_strength := 35.0
@export var impact_effect_scene: PackedScene

var _damage := 0.0
var _direction := Vector2.RIGHT
var _source: Node
var _resolved := false
var _travel_remaining := INF


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime_seconds).timeout.connect(_expire)


func launch(direction: Vector2, damage: float, source: Node, travel_distance: float = INF) -> void:
	_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	_damage = damage
	_source = source
	_travel_remaining = maxf(travel_distance, 0.0)
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	var travel_step := speed * delta
	if not is_inf(_travel_remaining) and travel_step >= _travel_remaining:
		global_position += _direction * _travel_remaining
		_travel_remaining = 0.0
		_resolve_impact()
		return
	global_position += _direction * travel_step
	if not is_inf(_travel_remaining):
		_travel_remaining -= travel_step


func _on_area_entered(area: Area2D) -> void:
	if not area is HurtboxComponent:
		return
	var hurtbox := area as HurtboxComponent
	## A ranged attacker may die while its already-fired projectile remains in
	## flight. Never pass that previously-freed Object through DamageInfo's typed
	## source parameter; the hit remains valid but becomes source-less.
	var valid_source: Node = _source if is_instance_valid(_source) else null
	if hurtbox.receive_hit(DamageInfo.new(_damage, valid_source, _direction, knockback_strength)):
		_resolve_impact()


func _on_body_entered(_body: Node2D) -> void:
	_resolve_impact()


func _resolve_impact(effect_override: PackedScene = null) -> void:
	if _resolved:
		return
	_resolved = true
	var effect_scene := effect_override if effect_override != null else impact_effect_scene
	var parent := get_parent()
	if effect_scene != null and is_instance_valid(parent):
		var impact := effect_scene.instantiate() as Node2D
		if impact != null:
			parent.add_child(impact)
			impact.global_position = global_position
	queue_free()


func _expire() -> void:
	if is_instance_valid(self):
		queue_free()
