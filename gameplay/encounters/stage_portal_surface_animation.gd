extends AnimatedSprite2D

## Presentation-only subframe interpolation. Use AnimatedSprite's own clock so
## speed changes, pause, and the 7→0 seam stay synchronized with actual frames.
func _process(_delta: float) -> void:
	var surface := material as ShaderMaterial
	if surface != null:
		surface.set_shader_parameter("frame_blend", frame_progress if is_playing() else 0.0)
