extends Node2D

## All visible contact light is clipped to the authoritative collision polygon.
## This observer cannot activate hitboxes, move the actor, or award damage.
const Trail = preload("res://assets/vfx/abilities/king/greatsword/white_slash_96x96.png")
const Impact = preload("res://assets/vfx/abilities/king/greatsword/steel_impact_192x192.png")
const Burst = preload("res://entities/player/presentation/king_contact_burst.gd")
const Sounds := [preload("res://assets/audio/sfx/player/greatsword/cut.wav"),preload("res://assets/audio/sfx/player/greatsword/return.wav"),preload("res://assets/audio/sfx/player/greatsword/cleave.wav")]
const ResolveSound = preload("res://assets/audio/sfx/player/greatsword/resolve.wav")
const Footstep = preload("res://assets/audio/sfx/player/greatsword/step.wav")
var _actor: Player
var _mastery: KingMasteryComponent
var _trail_frame := -1.0
var _trail_tween: Tween
var _sound: AudioStreamPlayer2D
var _step: AudioStreamPlayer2D
var _resolve: AudioStreamPlayer2D
var _linked := false
var _previous_stacks := 0

func _ready() -> void:
	_actor = get_parent() as Player
	_sound = _audio(-12)
	_step = _audio(-23)
	_resolve = _audio(-16)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 2
	_actor.ready.connect(_bind)

func _bind() -> void:
	_mastery = _actor.get_node("KingMastery")
	_actor.attack_component.phase_changed.connect(_on_attack_phase)
	_actor.attack_component.attack_finished.connect(_clear_trail)
	_mastery.resolve_changed.connect(_on_resolve)
	_mastery.link_changed.connect(func(available: bool) -> void: _linked = available; queue_redraw())
	_mastery.technique_empowered.connect(_on_empowered)
	_actor.defeated.connect(_on_defeated)
	var body: AnimatedSprite2D = _actor.get_node("VisualRoot/Body")
	body.frame_changed.connect(func() -> void:
		if String(body.animation).begins_with("walk_") and body.frame in [0,2] and _actor.velocity.length()>5:
			_play(_step,Footstep,1.0 if body.frame == 0 else .94)
	)
	for ability in [_actor.ability_1_component,_actor.ability_2_component,_actor.ability_3_component,_actor.ability_4_component]:
		if ability != null:
			ability.strike_started.connect(_on_strike.bind(ability))

func _on_attack_phase(phase: int, duration: float) -> void:
	_clear_trail()
	if phase != MeleeAttackComponent.Phase.ACTIVE:
		return
	var family := _actor.get_node_or_null("WeaponFamilyPresentation")
	if family != null and family.uses_family_clip():
		return # Approved family presenter owns these contact rasters and cues.
	var step := _actor.attack_component.combo_step
	var sound_index: int = [0,1,2,2,1][clampi(step,0,4)]
	if _actor.attack_component.weapon.family_presentation != null:
		sound_index = _actor.attack_component.weapon.family_presentation.sound_index(step)
	_play(_sound,Sounds[sound_index],1.0)
	_trail_frame = 1.0
	_trail_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_trail_tween.tween_method(_set_trail,1.0,4.0,duration)

func _set_trail(value: float) -> void:
	_trail_frame = value
	queue_redraw()

func _clear_trail() -> void:
	if _trail_tween != null and _trail_tween.is_valid():
		_trail_tween.kill()
	_trail_frame = -1.0
	queue_redraw()

func _draw() -> void:
	if _actor == null or _mastery == null:
		return
	if _trail_frame >= 0 and _actor.attack_component.phase == MeleeAttackComponent.Phase.ACTIVE:
		var shape := _actor.attack_component.collision_shape.shape as ConvexPolygonShape2D
		if shape != null:
			var transform := global_transform.affine_inverse() * _actor.attack_component.collision_shape.global_transform
			var points := PackedVector2Array()
			var uvs := PackedVector2Array()
			var index := clampi(int(_trail_frame),0,3)
			for point in shape.points:
				points.append(transform * point)
				var uv := Vector2(point.x/36.0,point.y/44.0+.5)
				if _actor.attack_component.combo_step == 1:
					uv.y = 1.0-uv.y
				var atlas_row := 1 if _actor.attack_component.combo_step == 2 else 0
				uvs.append((uv+Vector2(index,atlas_row))/Vector2(4,2))
			draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,Trail)
	if _mastery.stacks > 0:
		for index in _mastery.definition.resolve_hits:
			var color := Color("d6f4ff") if index < _mastery.stacks else Color("354353")
			draw_rect(Rect2(-9+index*6,-36,4,3),color)
	if _linked:
		draw_line(Vector2(-7,-31),Vector2(6,-31),Color("7fcfff"),1)

func _on_resolve(stacks: int, maximum: int) -> void:
	queue_redraw()
	if stacks == maximum and _previous_stacks < maximum:
		_play(_resolve,ResolveSound,1.0)
	_previous_stacks = stacks

func _on_empowered(_ability: AbilityComponent, resolved: bool, linked: bool) -> void:
	if resolved or linked:
		_play(_resolve,ResolveSound,1.2)

func _on_strike(index: int, _count: int, duration: float, ability: AbilityComponent) -> void:
	# These skills own their contact visuals. Worldsplitter's strike signal is
	# release, not impact; its legacy hitbox still sits at King's upper body.
	if ability is MoltenCrashComponent or ability is KingSkill4Component:
		return
	var burst := Burst.new()
	add_child(burst)
	burst.top_level = true
	burst.global_position = ability.hitbox.global_position
	burst.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shape := ability.collision_shape.shape
	if shape is CircleShape2D:
		burst.show_radial(Impact,shape.radius,minf(duration+.25,.55),ability.cast_power_multiplier>1.2)
	else:
		burst.global_rotation = ability.hitbox.global_rotation
		burst.show_cleave(Trail,ability.collision_shape.shape,minf(duration,.12),index==1)

func _on_defeated() -> void:
	_clear_trail()
	for player in [_sound,_step,_resolve]:
		player.stop()
	for child in get_children():
		if child is Burst:
			child.queue_free()

func _audio(volume: float) -> AudioStreamPlayer2D:
	var player := AudioStreamPlayer2D.new()
	player.bus = &"SFX"
	player.volume_db = volume
	player.max_distance = 700
	add_child(player)
	return player

func _play(player: AudioStreamPlayer2D, stream: AudioStream, pitch: float) -> void:
	if DisplayServer.get_name() != "headless":
		player.stream = stream
		player.pitch_scale = pitch
		player.play()
