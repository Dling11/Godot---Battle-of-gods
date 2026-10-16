extends "res://gameplay/presentation/registered_melee_ribbons.gd"

## Current Greatsword raster motion. Melee owns phases, contact, damage and hit dedupe.
const Landing = preload("res://assets/characters/playable/king/greatsword_unified/landing.png")
const VerticalSlash = preload("res://assets/characters/playable/king/greatsword_unified/vertical_slash.png")
const VerticalLanding = preload("res://assets/characters/playable/king/greatsword_unified/vertical_landing.png")
const SpinSlash = preload("res://assets/characters/playable/king/greatsword_unified/spin_slash.png")
const VERTICAL_SLASH_SCALE := Vector2(.46,.38)
const VERTICAL_GROUND_SCALE := Vector2(.40,.30)
const LandingSound = preload("res://assets/audio/sfx/player/greatsword_heavy/ground.wav")
@export var side_cleave_anchor := Vector2(128,128)
@export var up_cleave_anchor := Vector2(128,32)
@export var down_cleave_anchor := Vector2(128,224)
var landing_sprite: Sprite2D
var landing_count := 0
var last_landing_world := Vector2.ZERO
var _landing_tween: Tween
var _landing_audio: AudioStreamPlayer2D
var _vertical_landing := false
var _landing_row := 0

func _ready() -> void:
	super._ready()
	landing_sprite = _sprite(Landing)
	landing_sprite.top_level = true
	landing_sprite.scale = Vector2.ONE*.40
	landing_sprite.modulate.a = .82
	add_child(landing_sprite)
	_landing_audio = AudioStreamPlayer2D.new()
	_landing_audio.stream = LandingSound
	_landing_audio.bus = &"SFX"
	_landing_audio.volume_db = -12
	_landing_audio.pitch_scale = 1.0
	add_child(_landing_audio)
	pose_presenter.pose_changed.connect(_pose_changed)

func _sprite(texture: Texture2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	var region := AtlasTexture.new()
	region.atlas = texture
	region.region = Rect2(0,0,256,256)
	region.filter_clip = true
	sprite.texture = region
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.hide()
	return sprite

func _phase(phase: int,duration: float) -> void:
	if phase==MeleeAttackComponent.Phase.WIND_UP: clear()
	if phase!=MeleeAttackComponent.Phase.ACTIVE:
		if _tween!=null and _tween.is_valid(): _tween.kill()
		if is_instance_valid(slash_sprite): slash_sprite.hide()
		return # Ground dust is allowed to finish across recovery.
	clear()
	if not _prepare_contact_shape(): return
	_row = clampi(_attack.combo_step,0,3)
	var actor := _attack.owner as Node2D
	_contact_origin = actor.to_local(_attack.collision_shape.global_position)
	_configure_contact_mask()
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame,0.0,15.999 if _row==2 else 7.999,maxf(duration,.0001))
	# A tween starts inside the phase's physics tick and can finish a tick
	# before authority leaves ACTIVE. Hold its last cel until _phase hides it.
	if _row==3: _land()

func _set_frame(value: float) -> void:
	_frame = clampi(int(value),0,15 if _row==2 else 7)
	if not is_instance_valid(slash_sprite): return
	var direction := _attack.get_attack_direction()
	var vertical := _row==3 and absf(direction.y)>=absf(direction.x)
	var region := slash_sprite.texture as AtlasTexture
	region.atlas = SpinSlash if _row==2 else (VerticalSlash if vertical else atlas)
	var spin_row := 0 if absf(direction.x)>absf(direction.y) else (1 if direction.y<0 else 2)
	region.region = Rect2(_frame*256,spin_row*256 if _row==2 else ((0 if direction.y<0 else 1)*256 if vertical else _row*256),256,256)
	slash_sprite.show()
	_update_anchor()

func _pose_changed(_pose: int) -> void:
	if is_instance_valid(slash_sprite) and slash_sprite.visible: _update_anchor()

func _update_anchor() -> void:
	var direction := _attack.get_attack_direction()
	var side := absf(direction.x)>absf(direction.y)
	if _row!=3:
		slash_sprite.transform = layout.for_attack(direction,_row)
		slash_sprite.position += _contact_origin
		contact_mask.set_shader_parameter("actor_origin",slash_sprite.transform.origin)
		contact_mask.set_shader_parameter("actor_axis_x",slash_sprite.transform.x)
		contact_mask.set_shader_parameter("actor_axis_y",slash_sprite.transform.y)
		return
	# A falling blade is above the floor; its painted endpoint is registered to
	# the actual steel tip. It has no extra contact authority behind King.
	contact_mask.set_shader_parameter("edge_count",0)
	slash_sprite.rotation = 0
	slash_sprite.scale = Vector2(-.44 if direction.x<0 else .44,.44)
	var pivot := _landing_point()
	var source := side_cleave_anchor
	if not side:
		# Authored rear/front cleaves follow the screen's floor depth. Register
		# the endpoint to the actual blade, never a rotated horizontal ribbon.
		slash_sprite.scale = VERTICAL_SLASH_SCALE
		source = up_cleave_anchor if direction.y<0 else down_cleave_anchor
	var offset := (source-Vector2(128,128))*slash_sprite.scale
	slash_sprite.position = pivot-offset.rotated(slash_sprite.rotation)

func _landing_point() -> Vector2:
	return to_local(pose_presenter.weapon_sprite.to_global(pose_presenter.definition.weapon_tip))

func _land() -> void:
	landing_count += 1
	last_landing_world = to_global(_landing_point())
	var direction := _attack.get_attack_direction()
	_vertical_landing = absf(direction.y)>=absf(direction.x)
	_landing_row = 0 if direction.y<0 else 1
	(landing_sprite.texture as AtlasTexture).atlas = VerticalLanding if _vertical_landing else Landing
	landing_sprite.scale = VERTICAL_GROUND_SCALE if _vertical_landing else Vector2.ONE*.40
	# Both compact ground rows are registered to their painted floor centre.
	landing_sprite.global_position = last_landing_world
	_set_landing_frame(0)
	_landing_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_landing_tween.tween_method(_set_landing_frame,0.0,7.999,.28)
	_landing_tween.tween_callback(landing_sprite.hide)
	if DisplayServer.get_name()!="headless": _landing_audio.play()
	var feedback := CombatFeedbackPresenter.find_for_player(_attack.owner as Player)
	if feedback!=null and feedback.camera!=null:
		# Contact feedback happens later in this physics tick. Submit to its
		# sole camera owner afterward instead of fighting its offset tween.
		_pulse_landing.call_deferred(feedback)

func _pulse_landing(feedback: CombatFeedbackPresenter) -> void:
	if is_instance_valid(feedback) and landing_sprite.visible and _attack.phase==MeleeAttackComponent.Phase.ACTIVE and _attack.combo_step==3:
		feedback.request_camera_pulse(1.9)

func _set_landing_frame(value: float) -> void:
	(landing_sprite.texture as AtlasTexture).region = Rect2(clampi(int(value),0,7)*256,_landing_row*256 if _vertical_landing else 0,256,256)
	landing_sprite.show()

func clear() -> void:
	super.clear()
	if _landing_tween!=null and _landing_tween.is_valid(): _landing_tween.kill()
	if is_instance_valid(landing_sprite): landing_sprite.hide()
	if is_instance_valid(_landing_audio): _landing_audio.stop()

func _exit_tree() -> void:
	clear()
	if is_instance_valid(pose_presenter) and pose_presenter.pose_changed.is_connected(_pose_changed):
		pose_presenter.pose_changed.disconnect(_pose_changed)
	super._exit_tree()
