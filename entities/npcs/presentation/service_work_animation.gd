extends Node

## Planted work poses observe dialogue; service and collision authority stay on DialogueNpc.
var npc: DialogueNpc
var sprite: AnimatedSprite2D
var frames: SpriteFrames
var nameplate: Node2D
var _enabled := true
var _talking := false
var _attention: Timer
var _animation: StringName

func setup(hub: Node, node_name: String, display_name: String, role: String, label_offset := Vector2(0, -64)) -> void:
	npc = hub.get_node("World/Actors/" + node_name)
	sprite = npc.get_node("Sprite")
	frames = sprite.sprite_frames
	_animation = sprite.animation
	_attention = Timer.new()
	_attention.one_shot = true
	_attention.wait_time = 1.1
	_attention.timeout.connect(_resume_work)
	add_child(_attention)
	nameplate = preload("res://entities/npcs/presentation/npc_nameplate.gd").new()
	nameplate.npc_name = display_name
	nameplate.role_name = role
	nameplate.position = label_offset
	npc.add_child(nameplate)
	npc.proximity_changed.connect(func(near: bool, _text: String, _icon: Texture2D) -> void: nameplate.set_near(near))
	npc.dialogue_requested.connect(func(_speaker: String, _lines: Array[String], _portrait: Texture2D) -> void:
		_talking = true
		_hold())
	hub.dialogue_panel.dialogue_closed.connect(func(_completed: bool) -> void:
		_talking = false
		_resume_work())
	var strike: AudioStreamPlayer2D = npc.get_node_or_null("ForgeStrikeAudio")
	if strike != null:
		sprite.frame_changed.connect(func() -> void:
			if _enabled and sprite.animation == _animation and sprite.frame == 5: strike.play())
	nameplate.set_near(npc._player_inside)

func set_enabled(value: bool) -> void:
	_enabled = value
	_attention.stop()
	nameplate.visible = value
	if value and not _talking: _resume_work()
	else: _hold()

func greet() -> void:
	if not _enabled or _talking: return
	_hold()
	_attention.start()

func _hold() -> void:
	sprite.pause()
	sprite.frame = 0

func _resume_work() -> void:
	if _enabled and not _talking: sprite.play(_animation)
