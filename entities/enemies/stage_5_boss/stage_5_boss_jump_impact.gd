extends Node2D

const ImpactTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_jump_impact_sheet_192x112.png")
const SpikeTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_jump_spikes_sheet_192x112.png")

@onready var sprite: AnimatedSprite2D = $Impact
@onready var spikes: AnimatedSprite2D = $Spikes


func _ready() -> void:
	sprite.sprite_frames = _build_frames(ImpactTexture, 8, 10.0)
	spikes.sprite_frames = _build_frames(SpikeTexture, 6, 11.0)
	sprite.play(&"impact")
	spikes.play(&"impact")
	spikes.animation_finished.connect(func() -> void: spikes.visible = false, CONNECT_ONE_SHOT)
	await sprite.animation_finished
	await get_tree().create_timer(1.35).timeout
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.55)
	await tween.finished
	queue_free()


func _build_frames(texture: Texture2D, count: int, speed: float) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"impact")
	frames.set_animation_loop(&"impact", false)
	frames.set_animation_speed(&"impact", speed)
	for column in range(count):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(column * 192, 0, 192, 112)
		frames.add_frame(&"impact", atlas)
	return frames
