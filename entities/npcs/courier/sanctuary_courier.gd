extends CharacterBody2D

const SHEET = preload("res://assets/characters/npcs/courier/walk_v2.png")
const IDLE = preload("res://assets/characters/npcs/courier/idle.png")
const Talk = preload("res://entities/npcs/courier/courier_dialogue.gd")
const SPEED := 38.0
const STRIDE_DISTANCE := 22.0
var route := PackedVector2Array()
var stop_indices: Array[int] = []
var player: Node2D
var hub: Node
var dialogue: DialogueNpc
var talk_label: Label
var sprite: AnimatedSprite2D
var destination_index := 1
var arrivals := 0
var total_distance := 0.0
var yielding_to_player := false
var _stop_remaining := 0.0
var _blocked_seconds := 0.0
var _enabled := false
var _facing := "right"
var _stride_distance := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6
	collider.shape = shape
	collider.position.y = -4
	add_child(collider)
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-8,0),Vector2(-5,-3),Vector2(5,-3),Vector2(8,0),Vector2(5,3),Vector2(-5,3)])
	shadow.color = Color(0,0,0,.25)
	shadow.z_index = -1
	add_child(shadow)
	sprite = AnimatedSprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(0,-16)
	sprite.scale = Vector2(.5,.5)
	sprite.sprite_frames = SpriteFrames.new()
	sprite.sprite_frames.remove_animation(&"default")
	for row in 4:
		var direction: String = ["down","left","right","up"][row]
		var animation := StringName("walk_" + direction)
		sprite.sprite_frames.add_animation(animation)
		sprite.sprite_frames.set_animation_speed(animation, 6)
		for column in 4:
			var frame := AtlasTexture.new()
			frame.atlas = SHEET
			frame.region = Rect2(column*96,row*96,96,96)
			frame.filter_clip = true
			sprite.sprite_frames.add_frame(animation,frame)
		var idle_animation := StringName("idle_" + direction)
		sprite.sprite_frames.add_animation(idle_animation)
		var idle_frame := AtlasTexture.new()
		idle_frame.atlas = IDLE
		idle_frame.region = Rect2(row*96,0,96,96)
		idle_frame.filter_clip = true
		sprite.sprite_frames.add_frame(idle_animation,idle_frame)
	add_child(sprite)
	sprite.play(&"walk_right")
	_build_dialogue()
	set_enabled(false)

func _build_dialogue() -> void:
	dialogue = Talk.new()
	dialogue.name = "RowanDialogue"
	dialogue.hub = hub
	dialogue.collision_layer = 0
	dialogue.collision_mask = 2
	dialogue.speaker_name = "ROWAN, SANCTUARY COURIER"
	dialogue.dialogue_portrait = load("res://assets/characters/npcs/courier/portrait.png")
	dialogue.dialogue_lines.assign(["Morning rounds: a bundle for Nema, glass for Umi, and another stack of books for Eira.","Nema keeps the western workshop. Umi's blue-roof atelier is across the southern garden. Press M if you lose your way.","I'll keep the road clear. Safe travels, King."])
	var trigger := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 27
	trigger.shape = shape
	dialogue.add_child(trigger)
	add_child(dialogue)
	dialogue.dialogue_requested.connect(hub._on_npc_dialogue_requested.bind(dialogue,false,false,false))
	talk_label = Label.new()
	talk_label.text = "Rowan · Courier\nF · Talk"
	talk_label.position = Vector2(-64,-59)
	talk_label.size = Vector2(128,36)
	talk_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	talk_label.add_theme_font_size_override("font_size",11)
	talk_label.add_theme_color_override("font_outline_color",Color(.08,.1,.1))
	talk_label.add_theme_constant_override("outline_size",3)
	talk_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(talk_label)
	talk_label.hide()
	dialogue.dialogue_requested.connect(func(_speaker: String, _lines: Array[String], _portrait: Texture2D) -> void: talk_label.hide())

func set_enabled(value: bool) -> void:
	_enabled = value
	visible = value
	process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
	set_physics_process(value)
	talk_label.hide()
	velocity = Vector2.ZERO
	if not value: sprite.pause()
	elif not route.is_empty():
		position = route[0]
		destination_index = 1 % route.size()
		_stop_remaining = 1.5
		_blocked_seconds = 0
		_stride_distance = 0

func _physics_process(delta: float) -> void:
	if not _enabled or route.size() < 2: return
	talk_label.visible = dialogue._player_inside and dialogue.can_interact() and not hub.dialogue_panel.visible
	if _stop_remaining > 0:
		_stop_remaining -= delta
		velocity = Vector2.ZERO
		sprite.play(StringName("idle_" + _facing))
		return
	var target := route[destination_index]
	var direction := global_position.direction_to(target)
	yielding_to_player = is_instance_valid(player) and global_position.distance_to(player.global_position) < 28
	if yielding_to_player:
		velocity = Vector2.ZERO
		sprite.play(StringName("idle_" + _facing))
		return
	if global_position.distance_to(target) < 3:
		arrivals += 1
		if stop_indices.has(destination_index): _stop_remaining = 3.5
		destination_index = (destination_index + 1) % route.size()
		return
	var facing := "right" if direction.x >= 0 else "left"
	if absf(direction.y) > absf(direction.x): facing = "down" if direction.y > 0 else "up"
	_facing = facing
	velocity = direction * minf(SPEED, global_position.distance_to(target) / delta)
	var previous := global_position
	move_and_slide()
	var traveled := global_position.distance_to(previous)
	total_distance += traveled
	# Distance, not wall-clock animation, owns footfall phase. Blocked/resting actors do not tread.
	if traveled > .01:
		_stride_distance = fposmod(_stride_distance+traveled,STRIDE_DISTANCE)
		sprite.animation = StringName("walk_"+facing)
		sprite.pause()
		sprite.set_frame_and_progress(int(_stride_distance/STRIDE_DISTANCE*4.0)%4,0)
	else:
		sprite.play(StringName("idle_"+_facing))
	_blocked_seconds = _blocked_seconds + delta if traveled < .05 else 0.0
	if _blocked_seconds > 1.5:
		destination_index = (destination_index - 1 + route.size()) % route.size()
		_blocked_seconds = 0.0
		_stop_remaining = .6
