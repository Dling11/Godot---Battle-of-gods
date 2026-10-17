extends Node2D

## Final paired body/cut motion; component alone owns damage, movement and phases.
const Pose = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const Audio = preload("res://gameplay/abilities/weapons/war_cyclone_audio.gd")
var actor: Player
var component: WarCycloneComponent
var body: Node2D
var spin_body: Sprite2D
var ground: Sprite2D
var audio: Node2D
var _sparks: Node2D
var _spark_points: Array[Sprite2D] = []
var _spark_trails: Array[Sprite2D] = []
var _impact: AnimatedSprite2D
var slash: Sprite2D
var front_slash: Sprite2D
var _sequence: Tween
var _fade: Tween
var _drawn_frame := -1
var _contact: AudioStreamPlayer2D
var _last_contact_turn := -1
var _guard_spark: AnimatedSprite2D
var _last_guard_msec := -1000

func _ready() -> void:
	actor = owner as Player
	actor.ready.connect(_bind)
	hide()

func _bind() -> void:
	component = actor.war_cyclone
	var tuning := component.definition as WarCycloneDefinition
	body = Pose.new()
	body.position = Vector2(0,-16)
	body.scale = Vector2.ONE*.5
	assert(body.configure(tuning.spin_for(Vector2.RIGHT),actor.attack_component,false))
	add_child(body)
	spin_body = Sprite2D.new()
	spin_body.texture = tuning.motion_atlas
	spin_body.hframes = 4
	spin_body.vframes = 4
	# Atlas pivot(128,170) meets the physical foot origin at half density.
	spin_body.position = Vector2(0,-21)
	spin_body.scale = Vector2.ONE*.5
	spin_body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var motion_material := ShaderMaterial.new()
	motion_material.shader = preload("res://gameplay/abilities/weapons/war_cyclone_motion.gdshader")
	spin_body.material = motion_material
	add_child(spin_body)
	spin_body.hide()
	slash = _wind_layer(false)
	front_slash = _wind_layer(true)
	move_child(slash,0)
	ground = Sprite2D.new()
	ground.texture = tuning.ground_atlas
	ground.hframes = 4
	ground.vframes = 2
	ground.position = Vector2(0,8-64*.44)
	ground.scale = Vector2.ONE*.44
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(ground)
	move_child(ground,1)
	ground.hide()
	_guard_spark = AnimatedSprite2D.new()
	_guard_spark.sprite_frames = preload("res://assets/vfx/combat/critical_impact/frames.tres")
	_guard_spark.scale = Vector2.ONE*.65
	var spark_material := ShaderMaterial.new()
	spark_material.shader = preload("res://gameplay/abilities/weapons/war_cyclone_guard_spark.gdshader")
	spark_material.set_shader_parameter("energy_color",tuning.wind_color)
	_guard_spark.material = spark_material
	add_child(_guard_spark)
	_guard_spark.hide()
	_guard_spark.animation_finished.connect(_guard_spark.hide)
	_setup_sparks()
	_impact = AnimatedSprite2D.new()
	_impact.sprite_frames = _guard_spark.sprite_frames
	_impact.scale = Vector2.ONE*.7
	_impact.material = spark_material
	add_child(_impact)
	_impact.hide()
	_impact.animation_finished.connect(_impact.hide)
	audio = Audio.new()
	add_child(audio)
	audio.configure(actor)
	_contact = _voice(-16.0)
	component.phase_changed.connect(_phase)
	component.hit_landed.connect(_hit)
	component.guarded_hit.connect(_guarded_hit)
	component.ability_finished.connect(_finished)
	set_process(false)
	set_physics_process(false)

func _wind_layer(foreground: bool) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = (component.definition as WarCycloneDefinition).outer_atlas
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(0,-8)
	sprite.scale = Vector2(.66,.35)*((component.definition.hitbox_shape as CircleShape2D).radius/96.0)
	var material := ShaderMaterial.new()
	material.shader = preload("res://gameplay/abilities/weapons/war_cyclone_wind.gdshader")
	material.set_shader_parameter("foreground",foreground)
	sprite.material = material
	add_child(sprite)
	return sprite

func _physics_process(_delta: float) -> void:
	var tuning := component.definition as WarCycloneDefinition
	var seconds := maxf(tuning.visual_turn_seconds*component.turn_period/tuning.turn_seconds,tuning.minimum_visual_turn_seconds)
	var turn := component.active_elapsed/seconds
	var frame_position := fposmod(turn*16.0,16.0)
	var key := floori(frame_position)
	if key!=_drawn_frame:
		_drawn_frame = key
		spin_body.frame = key
	var next := posmod(key+1,16)
	var region := Vector4((key%4)/4.0,(key/4)/4.0,.25,.25)
	var next_rect := Vector4((next%4)/4.0,(next/4)/4.0,.25,.25)
	spin_body.material.set_shader_parameter("atlas_region",region)
	spin_body.material.set_shader_parameter("next_region",next_rect)
	spin_body.material.set_shader_parameter("frame_blend",frame_position-key)
	for layer in [slash,front_slash]:
		layer.material.set_shader_parameter("orbit_angle",fposmod(turn*tuning.outer_speed_multiplier,1.0)*TAU)
	ground.frame = posmod(floori(component.active_elapsed/.08),8)
	_draw_sparks(component.active_elapsed)

func _setup_sparks() -> void:
	_sparks = Node2D.new()
	add_child(_sparks)
	for key in 16:
		var point := Sprite2D.new()
		point.texture = _guard_spark.sprite_frames.get_frame_texture(&"critical",0)
		point.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		point.scale = Vector2.ONE*(.045+key%3*.004)
		_sparks.add_child(point)
		_spark_points.append(point)
		var trail := Sprite2D.new()
		trail.texture = point.texture
		trail.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		trail.scale = Vector2(.09,.018)
		_sparks.add_child(trail)
		_spark_trails.append(trail)
	_sparks.hide()

func _draw_sparks(seconds: float) -> void:
	var radius_scale := (component.definition.hitbox_shape as CircleShape2D).radius/96.0
	for key in 16:
		var offset := key*.32/16.0
		var age := fposmod(seconds+offset,.32)
		var birth := floori((seconds+offset)/.32)
		var angle := key*TAU/16.0+birth*PI*.5
		var rim := Vector2(cos(angle)*74,sin(angle)*33.6-8)
		var velocity := Vector2(cos(angle)*40-sin(angle)*50,sin(angle)*14+cos(angle)*16)
		var position := rim+velocity*age+Vector2(0,130*age*age)
		var alpha := minf(age/.025,1.0)*pow(1-age/.32,.65)
		_spark_points[key].position = position*radius_scale
		_spark_points[key].modulate = Color(.73,.89,1,alpha*.90)
		_spark_trails[key].position = (position-velocity*.02)*radius_scale
		_spark_trails[key].rotation = velocity.angle()
		_spark_trails[key].modulate = Color(.34,.64,1,alpha*.40)

func _voice(volume: float) -> AudioStreamPlayer2D:
	var voice := AudioStreamPlayer2D.new()
	voice.bus = &"SFX"
	voice.volume_db = volume
	add_child(voice)
	return voice


func _phase(phase: int,duration: float) -> void:
	_stop()
	body.hide()
	spin_body.hide()
	ground.hide()
	_sparks.hide()
	if phase==AbilityComponent.Phase.WIND_UP:
		_select_settle_pose(component.get_cast_direction())
		_last_contact_turn = -1
		show()
		slash.hide()
		front_slash.hide()
		_keys(0,3,duration)
	elif phase==AbilityComponent.Phase.ACTIVE:
		spin_body.show()
		ground.modulate.a = .76
		ground.show()
		_sparks.show()
		_drawn_frame = -1
		slash.modulate.a = .80
		front_slash.modulate.a = .50
		slash.show()
		front_slash.show()
		_physics_process(0.0)
		set_physics_process(true)
	elif phase==AbilityComponent.Phase.RECOVERY:
		# Return through ordinary accepted Axe poses, not a second generated actor.
		_select_settle_pose(actor.facing_direction)
		_keys(13,15,duration)
		_guard_spark.stop()
		_guard_spark.hide()
		ground.show()
		_fade = create_tween().set_parallel(true)
		_fade.tween_property(slash,"modulate:a",0.0,duration)
		_fade.tween_property(front_slash,"modulate:a",0.0,duration)
		_fade.tween_property(ground,"modulate:a",0.0,duration)

func _select_settle_pose(direction: Vector2) -> void:
	body.select_clip((component.definition as WarCycloneDefinition).spin_for(direction))
	body.face_horizontal(-1.0 if direction.x<0 else 1.0)
	body.show()

func _keys(first: int,last: int,seconds: float) -> void:
	_sequence = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	for index in range(first,last+1):
		_sequence.tween_callback(body.set_pose.bind(index))
		_sequence.tween_interval(seconds/float(last-first+1))

func _guarded_hit(info: DamageInfo) -> void:
	var now := Time.get_ticks_msec()
	if now-_last_guard_msec < 80 or not component.has_guard(): return
	_last_guard_msec = now
	var incoming := -info.direction if not info.direction.is_zero_approx() else actor.facing_direction
	_guard_spark.position = incoming.normalized()*24+Vector2(0,-10)
	_guard_spark.show()
	_guard_spark.stop()
	_guard_spark.play(&"critical")

func _hit(target: HurtboxComponent, _info: DamageInfo) -> void:
	if _last_contact_turn == component.get_current_strike_index(): return
	_last_contact_turn = component.get_current_strike_index()
	if DisplayServer.get_name() == "headless": return
	_impact.position = to_local(target.global_position)
	_impact.show()
	_impact.play(&"critical")
	var profile := actor.attack_component.weapon.hit_audio
	if profile != null and not profile.variations.is_empty():
		_contact.stream = profile.stream_for(_last_contact_turn)
		_contact.pitch_scale = profile.pitch_for(_last_contact_turn)
		_contact.play()
	var feedback := CombatFeedbackPresenter.find_for_player(actor)
	if feedback != null: feedback.request_camera_pulse(.35)


func _finished() -> void:
	_stop()
	if is_instance_valid(_contact): _contact.stop()
	if is_instance_valid(_guard_spark):
		_guard_spark.stop()
		_guard_spark.hide()
	if is_instance_valid(_sparks): _sparks.hide()
	if is_instance_valid(_impact):
		_impact.stop()
		_impact.hide()
	hide()

func _stop() -> void:
	set_physics_process(false)
	if _sequence!=null and _sequence.is_valid(): _sequence.kill()
	if _fade!=null and _fade.is_valid(): _fade.kill()

func _exit_tree() -> void:
	_stop()
