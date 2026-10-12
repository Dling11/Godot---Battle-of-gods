extends Node2D

## One independent snapshotted warning/contact, cancelled by caster authority.
signal warning_started(seconds: float)
signal erupted(seconds: float)
@export var radius := 32.0
var _released := false
var _cancelled := false
@onready var hitbox: MeleeHitbox = $Hitbox

func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = radius
	$Hitbox/CollisionShape2D.shape = shape

func begin_warning(seconds: float) -> void:
	warning_started.emit(seconds)

func erupt(damage: float,source: Node,seconds: float,damage_type := DamageInfo.DamageType.PHYSICAL) -> void:
	if _released or _cancelled: return
	_released = true
	hitbox.activate_radial(damage,source,global_position,0.0,0.0,0.0,1.5,0.0,damage_type)
	erupted.emit(seconds)
	get_tree().create_timer(seconds,false).timeout.connect(cancel)

func cancel() -> void:
	_cancelled = true
	hitbox.deactivate()
	hide()
	queue_free()
