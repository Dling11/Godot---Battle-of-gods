extends Node2D

## Reuses the approved generated barrier/pressure art at King's exact foot origin.
const ART := "res://assets/vfx/abilities/king/unbroken_vow_test/"
const Ground = preload("res://gameplay/abilities/king/earthsplitter_ground_visual.gd")
var actor: Player
var component: UnbrokenVowComponent
var _shell: Sprite2D
var _lip: Sprite2D
var _pressure: Sprite2D
var _current: Sprite2D
var _audio: AudioStreamPlayer2D
var _age := 0.0
var _cast_age := -1.0
var _ending := -1.0
var _hit := 0.0
var _broken := false

func _ready() -> void:
	actor = get_parent() as Player
	component = actor.get_node("UnbrokenVowComponent")
	_shell = _sprite("barrier.png", Vector2(-28, -44), -1)
	_lip = _sprite("barrier.png", Vector2(-28, -1), 3)
	_pressure = _sprite("pressure.png", Vector2(-36, -48), -2)
	_current = _sprite("pressure.png", Vector2(-36, -38), 2)
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV); if(c.r<c.b*1.2 || c.r<c.g*1.3){discard;} COLOR=c*COLOR;}"
	var material := ShaderMaterial.new()
	material.shader = shader
	_current.material = material
	_audio = AudioStreamPlayer2D.new()
	_audio.stream = load(ART + "pressure_contact.wav")
	_audio.bus = &"SFX"
	_audio.volume_db = -9.0
	add_child(_audio)
	actor.ready.connect(_bind)
	hide()
	set_physics_process(false)

func _bind() -> void:
	component.ability_started.connect(_begin_cast)
	component.buff_started.connect(_activate)
	component.buff_ended.connect(_end)
	component.ability_finished.connect(func() -> void:
		if not component.active: _end(false))
	actor.health_component.shield_hit.connect(func(_amount: float) -> void: _hit = .18)
	actor.attack_component.phase_changed.connect(_on_attack_phase)
	actor.defeated.connect(func() -> void: hide(); set_physics_process(false))

func _begin_cast() -> void:
	_age = 0.0
	_cast_age = 0.0
	_ending = -1.0
	show()
	modulate = Color.WHITE
	_pressure.show()
	_current.hide()
	_shell.hide()
	_lip.hide()
	set_physics_process(true)

func _activate() -> void:
	_ending = -1.0
	_shell.show()
	_lip.show()
	_current.show()
	if DisplayServer.get_name() != "headless": _audio.play()

func _end(broken: bool) -> void:
	_ending = 0.0
	_broken = broken
	_cast_age = -1.0
	_current.hide()
	_pressure.hide()
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	_age += delta
	_hit = maxf(0.0, _hit-delta)
	if _cast_age >= 0.0:
		_cast_age += delta
		_region(_pressure, mini(7, int(_cast_age/.04)), 4, Vector2i(144, 112))
		if _cast_age >= .32: _pressure.hide(); _cast_age = -1.0
	var frame := 3 + int(_age/.14)%3
	if _ending >= 0.0:
		_ending += delta
		frame = maxi(0, 2-int(_ending/.08))
		modulate.a = maxf(0.0, 1.0-_ending/.26)
		_shell.modulate = Color(1.5, .65, .7) if _broken else Color.WHITE
		if _ending >= .26:
			hide()
			set_physics_process(false)
	else:
		var low := actor.health_component.shield_health < actor.health_component.shield_maximum*.3
		_shell.modulate = Color(1.8, 1.8, 2.0) if _hit > 0.0 else (Color(.8, .7, 1.0, .65+sin(_age*22)*.15) if low else Color.WHITE)
	_region(_shell, frame, 3, Vector2i(112,112))
	_lip.region_rect = Rect2(_shell.region_rect.position+Vector2(0,86), Vector2(112,26))
	_lip.modulate = _shell.modulate
	_region(_current, 5+int(_age/.10)%3, 4, Vector2i(144,112))

func _on_attack_phase(phase: int, _seconds: float) -> void:
	if phase != MeleeAttackComponent.Phase.ACTIVE or not actor.attack_component.committed_vow_finisher:
		return
	var effect := Ground.new()
	effect.radius = 13.0
	effect.direction = actor.attack_component.get_attack_direction()
	actor.get_parent().add_child(effect)
	effect.global_position = actor.global_position + effect.direction*24.0
	effect.advance_front(effect.global_position)
	effect.finish()
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = .7
	timer.timeout.connect(effect.queue_free)
	effect.add_child(timer)
	timer.start()

func _sprite(file: String, origin: Vector2, depth: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(ART+file)
	sprite.centered = false
	sprite.scale = Vector2(.5,.5)
	sprite.position = origin
	sprite.z_index = depth
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	add_child(sprite)
	return sprite

func _region(sprite: Sprite2D, frame: int, columns: int, cell: Vector2i) -> void:
	sprite.region_rect = Rect2(Vector2(frame%columns, frame/columns)*Vector2(cell), Vector2(cell))
