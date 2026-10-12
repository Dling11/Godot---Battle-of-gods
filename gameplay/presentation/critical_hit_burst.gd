extends HitBurst

## Shared four-drawing critical contact. No damage, control or hitstop authority.
const FRAMES = preload("res://assets/vfx/combat/critical_impact/frames.tres")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rotation = snappedf(_direction.angle(),PI*.5)
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = FRAMES
	add_child(sprite)
	sprite.animation_finished.connect(queue_free)
	sprite.play(&"critical")
