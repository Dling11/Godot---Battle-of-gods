extends Node2D

## Raster-only observer. Its parent's progress and world position are gameplay
## authority; equipment attack speed changes that clock, never the art scale.
var steel: Sprite2D
var arcs: Sprite2D
var _frame: AtlasTexture
var _trails: Array[Node2D] = []
var _spark_frames: Array[AtlasTexture] = []
var _sparks: Array[Sprite2D] = []
var _presenter: Node2D
var _throw_clip: Resource
var _launch_basis := Transform2D.IDENTITY
var _has_hand_attachment := false
var _spin_direction := 1.0
var spin_audio: AudioStreamPlayer2D
var _spin_envelope: Tween

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	position.y = -18
	var family: Node = get_parent().source.get_node_or_null("WeaponFamilyPresentation")
	if family!=null and is_instance_valid(family.presenter) and family.presenter.visible:
		_presenter = family.presenter
		_throw_clip = _presenter.definition
		_has_hand_attachment = _throw_clip.pose_count>7
		if _has_hand_attachment:
			_launch_basis = _hand_basis(4)
			_spin_direction = -1 if _launch_basis.determinant()<0 else 1
	steel = Sprite2D.new()
	steel.texture = preload("res://assets/characters/playable/king/iron_reaper/rigid_weapon.png")
	steel.centered = false
	steel.position = -Vector2(40, 98)
	var pivot := Node2D.new()
	pivot.name = "SpinningSteel"
	pivot.scale = Vector2.ONE * 0.5
	pivot.add_child(steel)
	add_child(pivot)
	for index in 2:
		var ghost := Node2D.new()
		ghost.scale = Vector2.ONE * 0.5
		var blade := Sprite2D.new()
		blade.texture = steel.texture
		blade.centered = false
		blade.position = steel.position
		blade.modulate = Color(0.88,0.93,1,0.13-index*0.04)
		ghost.add_child(blade)
		add_child(ghost)
		move_child(ghost,0)
		_trails.append(ghost)
	arcs = Sprite2D.new()
	_frame = AtlasTexture.new()
	_frame.atlas = preload("res://assets/characters/playable/king/iron_reaper/orbit.png")
	_frame.filter_clip = true
	arcs.texture = _frame
	arcs.modulate.a = 0.82
	arcs.scale = Vector2(0.78, 0.6)
	add_child(arcs)
	for index in 2:
		var sparks := Sprite2D.new()
		var frame := AtlasTexture.new()
		frame.atlas = preload("res://assets/characters/playable/king/iron_reaper/sparks.png")
		frame.filter_clip = true
		sparks.texture = frame
		sparks.centered = false
		sparks.scale = Vector2.ONE*0.65
		sparks.position = Vector2((-24 if index==0 else 24)-21,18-36)
		sparks.flip_h = index==0
		add_child(sparks)
		_sparks.append(sparks)
		_spark_frames.append(frame)
	_start_spin_audio()
	_process(0)

func _start_spin_audio() -> void:
	var flight := get_parent()
	var source: Player = flight.source
	var loop := preload("res://assets/audio/sfx/player/iron_reaper/spin.wav").duplicate() as AudioStreamWAV
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = roundi(loop.get_length()*loop.mix_rate)
	spin_audio = AudioStreamPlayer2D.new()
	spin_audio.name = "SpinAudio"
	spin_audio.stream = loop
	spin_audio.bus = &"SFX"
	spin_audio.volume_db = -42
	spin_audio.max_distance = 560
	spin_audio.pitch_scale = source.attack_component.weapon.combo.contacts[source.attack_component.combo_step]/flight.duration
	add_child(spin_audio)
	spin_audio.play()
	flight.caught.connect(spin_audio.stop)
	# This short observer follows the same paused/scaled flight clock. No
	# per-frame audio work or sound multiplication when several enemies hit.
	_spin_envelope = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_spin_envelope.tween_property(spin_audio,"volume_db",-24.0,flight.duration*0.12)
	_spin_envelope.tween_interval(flight.duration*0.58)
	_spin_envelope.tween_property(spin_audio,"volume_db",-52.0,flight.duration*0.30)

func _exit_tree() -> void:
	if _spin_envelope!=null and _spin_envelope.is_valid(): _spin_envelope.kill()
	if is_instance_valid(spin_audio): spin_audio.stop()

func _process(_delta: float) -> void:
	var flight := get_parent()
	var basis := _steel_basis_for(flight.progress)
	get_node("SpinningSteel").transform = basis
	for index in _trails.size():
		_trails[index].transform = Transform2D(basis.get_rotation()-_spin_direction*(index+1)*0.38,basis.get_scale(),0,basis.origin)
		_trails[index].visible = flight.progress>0.03 and flight.progress<0.95
	var key := mini(int(flight.progress * 48), 47) % 8
	_frame.region = Rect2(Vector2(key % 4, key / 4) * 128, Vector2.ONE * 128)
	# Entry/exit retain readable steel at release and at the one-hand catch.
	arcs.modulate.a = 0.82 * minf(flight.progress * 12, (1 - flight.progress) * 12 + 0.05)
	var tuning: ReturningWeaponDefinition = flight.tuning
	for index in _sparks.size():
		var spark_key := (key+index*3)%8
		_spark_frames[index].region = Rect2(Vector2(spark_key%4,spark_key/4)*64,Vector2.ONE*64)
		_sparks[index].visible = flight.progress>=tuning.outbound_fraction and flight.progress<tuning.outbound_fraction+tuning.linger_fraction

func _hand_basis(index: int) -> Transform2D:
	# Project the complete actor's authored hand into the released visual's
	# space. Only the raster moves; the swept contact center remains authority.
	var grip: Vector2 = _throw_clip.primary_hands[index]-Vector2(_throw_clip.cell_size)*0.5
	var axis: Vector2 = _throw_clip.secondary_hands[index]-_throw_clip.primary_hands[index]
	var hand := Transform2D(axis.angle()-_throw_clip.weapon_handle_axis.angle(),grip)
	# The flight sprite rotates about (40,98); held steel uses (40,112).
	return global_transform.affine_inverse()*_presenter.global_transform*hand*Transform2D(0,Vector2(0,-14))

func _steel_basis_for(progress: float) -> Transform2D:
	var flight := get_parent()
	var angle: float = flight.direction.angle() + progress * TAU * 6
	var basis := Transform2D(angle,Vector2.ONE*0.5,0,Vector2.ZERO)
	if _has_hand_attachment and is_instance_valid(_presenter):
		var catch_basis := _hand_basis(7)
		var start_angle := _launch_basis.get_rotation()
		var end_angle := start_angle + _spin_direction*TAU*6 + wrapf(catch_basis.get_rotation()-start_angle,-PI,PI)
		var split: float = flight.tuning.outbound_fraction
		var recall: float = split + flight.tuning.linger_fraction
		var spin_clock: float = progress
		if progress<split:
			spin_clock = split*pow(progress/split,1.25)
		elif progress>recall:
			var t: float = (progress-recall)/(1.0-recall)
			spin_clock = recall+(1.0-recall)*(1.0-pow(1.0-t,2))
		angle = lerpf(start_angle,end_angle,spin_clock)
		basis = Transform2D(angle,_launch_basis.get_scale(),0,Vector2.ZERO)
		if progress<0.1:
			basis = _launch_basis.interpolate_with(basis,smoothstep(0,0.1,progress))
		elif progress>0.88:
			basis = basis.interpolate_with(catch_basis,smoothstep(0.88,1,progress))
	return basis
