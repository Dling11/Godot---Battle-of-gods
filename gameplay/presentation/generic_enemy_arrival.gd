extends SummonEffect

## One underfoot raster cue, independent of enemy height or silhouette.
const FRAMES = preload("res://assets/vfx/generic_enemy_arrival/frames.tres")
var sprite: AnimatedSprite2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -1
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = FRAMES
	sprite.position = Vector2(0, -14) # Shared 64px cell, floor at (32,46).
	add_child(sprite)
	sprite.animation_finished.connect(_finished)
	sprite.frame_changed.connect(_fade_remnant)
	sprite.play("warning")

func release() -> void:
	released = true
	sprite.play("release")

func _fade_remnant() -> void:
	if released and sprite.animation == &"release" and sprite.frame == 2:
		create_tween().tween_property(sprite,"modulate:a",0.0,0.56/3.0)

func _finished() -> void:
	if released:
		queue_free()

