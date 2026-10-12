extends "res://gameplay/presentation/axe_swing_trail.gd"

## Opt-in V2 raster motion. Melee owns phases, contact, damage and hit dedupe.
const Landing = preload("res://assets/characters/playable/king/greatsword_front_combo_preview/landing.png")
const VerticalSlash = preload("res://assets/characters/playable/king/greatsword_front_combo_preview/vertical_slash.png")
const VerticalLanding = preload("res://assets/characters/playable/king/greatsword_front_combo_preview/vertical_landing.png")
const VERTICAL_SLASH_SCALE := Vector2(.8,.55)
const VERTICAL_GROUND_SCALE := Vector2(.45,.30)
const LandingSound = preload("res://assets/audio/sfx/abilities/king/riftbreak_ground_slam.wav")
var pose_presenter: Node2D
var slash_sprite: Sprite2D
var landing_sprite: Sprite2D
var landing_count := 0
var last_landing_world := Vector2.ZERO
var _landing_tween: Tween
var _landing_audio: AudioStreamPlayer2D
var _vertical_landing := false
var _landing_row := 0

func bind_pose_presenter(presenter: Node2D) -> void:
	pose_presenter = presenter

func _ready() -> void:
	super._ready()
	slash_sprite = _sprite(atlas)
	add_child(slash_sprite)
	landing_sprite = _sprite(Landing)
	landing_sprite.top_level = true
	landing_sprite.scale = Vector2.ONE*.45
	add_child(landing_sprite)
	_landing_audio = AudioStreamPlayer2D.new()
	_landing_audio.stream = LandingSound
	_landing_audio.bus = &"SFX"
	_landing_audio.volume_db = -15
	_landing_audio.pitch_scale = .88
	add_child(_landing_audio)
	pose_presenter.pose_changed.connect(_pose_changed)

func _sprite(texture: Texture2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	var region := AtlasTexture.new()
	region.atlas = texture
	region.region = Rect2(0,0,192,192)
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
	_row = clampi(_attack.combo_step,0,3)
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame,0.0,3.999,maxf(duration,.0001))
	_tween.tween_callback(slash_sprite.hide)
	if _row==3: _land()

func _set_frame(value: float) -> void:
	_frame = clampi(int(value),0,3)
	if not is_instance_valid(slash_sprite): return
	var direction := _attack.get_attack_direction()
	var vertical := _row==3 and absf(direction.y)>=absf(direction.x)
	var region := slash_sprite.texture as AtlasTexture
	region.atlas = VerticalSlash if vertical else atlas
	region.region = Rect2(_frame*192,(0 if direction.y<0 else 1)*192 if vertical else _row*192,192,192)
	slash_sprite.show()
	_update_anchor()

func _pose_changed(_pose: int) -> void:
	if is_instance_valid(slash_sprite) and slash_sprite.visible: _update_anchor()

func _update_anchor() -> void:
	var direction := _attack.get_attack_direction()
	var side := absf(direction.x)>absf(direction.y)
	slash_sprite.rotation = 0 if side else direction.angle()
	slash_sprite.scale = Vector2(-.8 if direction.x<0 and side else .8,.8)
	var pivot := Vector2.ZERO
	var source := Vector2(30,96)
	if _row==2:
		slash_sprite.rotation = 0 # A floor ellipse keeps the same camera plane.
		pivot = Vector2(0,-12)
		source = Vector2(96,96)
		slash_sprite.scale *= 1.45
	elif _row==3:
		pivot = _landing_point()
		source = Vector2(161,160)
		if not side:
			# Authored rear/front cleaves already follow the screen's floor depth.
			# Register their marked endpoint to the actual blade, not a rotated
			# horizontal ribbon or a generic distance in front of King.
			slash_sprite.rotation = 0
			slash_sprite.scale = VERTICAL_SLASH_SCALE
			source = Vector2(96,40 if direction.y<0 else 152)
	else:
		pivot = to_local(pose_presenter.weapon_rig.global_position)
	var offset := (source-Vector2(96,96))*slash_sprite.scale
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
	landing_sprite.scale = VERTICAL_GROUND_SCALE if _vertical_landing else Vector2.ONE*.45
	var offset := Vector2(0,32 if _landing_row==0 else -32)*VERTICAL_GROUND_SCALE if _vertical_landing else Vector2(0,43*.45)
	landing_sprite.global_position = last_landing_world-offset
	_set_landing_frame(0)
	_landing_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_landing_tween.tween_method(_set_landing_frame,0.0,3.999,.26)
	_landing_tween.tween_callback(landing_sprite.hide)
	if DisplayServer.get_name()!="headless": _landing_audio.play()
	var feedback := CombatFeedbackPresenter.find_for_player(_attack.owner as Player)
	if feedback!=null and feedback.camera!=null:
		# Contact feedback happens later in this physics tick. Submit to its
		# sole camera owner afterward instead of fighting its offset tween.
		_pulse_landing.call_deferred(feedback)

func _pulse_landing(feedback: CombatFeedbackPresenter) -> void:
	if is_instance_valid(feedback) and landing_sprite.visible and _attack.phase==MeleeAttackComponent.Phase.ACTIVE and _attack.combo_step==3:
		feedback.request_camera_pulse(2.6)

func _set_landing_frame(value: float) -> void:
	(landing_sprite.texture as AtlasTexture).region = Rect2(clampi(int(value),0,3)*192,_landing_row*192 if _vertical_landing else 0,192,192)
	landing_sprite.show()

func _draw() -> void:
	pass # Complete raster sprites, never a clipped procedural contact fan.

func clear() -> void:
	super.clear()
	if _landing_tween!=null and _landing_tween.is_valid(): _landing_tween.kill()
	if is_instance_valid(slash_sprite): slash_sprite.hide()
	if is_instance_valid(landing_sprite): landing_sprite.hide()
	if is_instance_valid(_landing_audio): _landing_audio.stop()

func _exit_tree() -> void:
	clear()
	if is_instance_valid(pose_presenter) and pose_presenter.pose_changed.is_connected(_pose_changed):
		pose_presenter.pose_changed.disconnect(_pose_changed)
	super._exit_tree()
