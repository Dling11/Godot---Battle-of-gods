extends AnimatedSprite2D

## Shared homepage/loading emblem. The sprite clock animates lighting only;
## the surface samples the canonical engraving with fixed alpha and geometry.
const SURFACE := preload("res://ui/presentation/quiet_seal_surface.gdshader")

func _ready() -> void:
	var surface := ShaderMaterial.new()
	surface.shader = SURFACE
	material = surface
	_update_light()
	visibility_changed.connect(_update_processing)
	_update_processing()

func _update_processing() -> void:
	set_process(is_visible_in_tree())

func _process(_delta: float) -> void:
	if is_playing():
		_update_light()

func _update_light() -> void:
	var count := sprite_frames.get_frame_count(animation)
	var phase := (float(frame) + frame_progress) * TAU / maxi(count, 1)
	(material as ShaderMaterial).set_shader_parameter("animation_phase", phase)
