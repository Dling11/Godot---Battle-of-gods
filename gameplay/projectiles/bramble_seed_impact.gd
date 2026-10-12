extends Node2D

@onready var impact_sfx: AudioStreamPlayer2D = %ImpactSfx
@onready var body: AnimatedSprite2D = %Body


func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		impact_sfx.play()
	body.play(&"impact")
	body.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
	get_tree().create_timer(0.45).timeout.connect(func() -> void:
		if is_instance_valid(self):
			queue_free()
	)
