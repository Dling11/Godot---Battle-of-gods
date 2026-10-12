extends StaticBody2D

## A planted footprint stays authoritative while canopy presentation moves/fades.
@export var foliage := false
@export var phase := 0.0
var _fade: Tween

func _ready() -> void:
	if not foliage: return
	var sprite := get_node("Sprite") as Sprite2D
	var material := ShaderMaterial.new()
	material.shader = preload("res://levels/sanctuary/town/foliage_wind.gdshader")
	material.set_shader_parameter("phase", phase)
	sprite.material = material
	var fade_area := get_node_or_null("CanopyFade") as Area2D
	if fade_area == null: return
	fade_area.body_entered.connect(func(body: Node2D) -> void:
		if body is Player: _set_canopy_opacity(.43))
	fade_area.body_exited.connect(func(body: Node2D) -> void:
		if body is Player: _set_canopy_opacity(1.0))

func _set_canopy_opacity(value: float) -> void:
	if _fade != null: _fade.kill()
	_fade = create_tween()
	_fade.tween_property(get_node("Sprite"), "modulate:a", value, .18)
