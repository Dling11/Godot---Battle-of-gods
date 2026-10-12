extends Node2D

## Local raster contact/ground effects. Never issues damage or global hitstop.
var attack: MeleeAttackComponent
var atlas: Texture2D
var presentation_anchor: Node2D
var ground_step := 2
## Registered blade landing in actor space; stays inside the slam contact fan.
var ground_offset := Vector2(46,32)
## Side-view review mirrors the body in X, rather than rotating its ground Y.
var mirror_horizontal_landing := false
## Optional authored contact landmark, already in anchor-local space.
var ground_position_provider: Callable
var _contact_shown := false
var bursts_created := 0

class Burst extends Node2D:
	var atlas: Texture2D
	var row := 0
	var frame := 0
	var duration := 0.22
	var animate := true
	var _region: AtlasTexture
	var _tween: Tween
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_region = AtlasTexture.new()
		_region.atlas = atlas
		var sprite := Sprite2D.new()
		sprite.texture = _region
		if row==1: sprite.position.y = -52
		add_child(sprite)
		_set_frame(frame)
		if animate:
			_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			_tween.tween_method(_set_frame,0.0,3.999,duration)
			_tween.tween_callback(queue_free)
	func _set_frame(value: float) -> void:
		frame = clampi(int(value),0,3)
		var cell := Vector2(atlas.get_width()/4.0,atlas.get_height()/2.0)
		_region.region = Rect2(Vector2(frame,row)*cell,cell)
	func _exit_tree() -> void:
		if _tween!=null and _tween.is_valid(): _tween.kill()

func _ready() -> void:
	assert(attack!=null and atlas!=null)
	if presentation_anchor==null: presentation_anchor = attack.owner as Node2D
	assert(presentation_anchor!=null)
	attack.phase_changed.connect(_phase)
	attack.hit_landed.connect(_hit)
	attack.attack_finished.connect(clear)
	set_process(false)
	set_physics_process(false)

func _phase(phase: int,_duration: float) -> void:
	if phase==MeleeAttackComponent.Phase.WIND_UP: _contact_shown = false
	if phase==MeleeAttackComponent.Phase.ACTIVE and attack.combo_step==ground_step:
		var direction := attack.get_attack_direction()
		var landing := Vector2(ground_offset.x*(-1 if direction.x<0 else 1),ground_offset.y) if mirror_horizontal_landing else ground_offset.rotated(direction.angle())
		if ground_position_provider.is_valid(): landing = ground_position_provider.call()
		_spawn(1,landing,0.5,0.30)

func _hit(hurtbox: HurtboxComponent,_info: DamageInfo) -> void:
	# One flash per accepted cut, not one texture/tween for every crowd target.
	if _contact_shown: return
	_contact_shown = true
	var actor := attack.owner as Node2D
	_spawn(0,actor.to_local(hurtbox.global_position),0.24,0.20)

func _spawn(row: int,local_point: Vector2,world_scale: float,duration: float) -> void:
	var burst := Burst.new()
	burst.atlas = atlas
	burst.row = row
	burst.duration = duration
	burst.top_level = true
	burst.position = presentation_anchor.to_global(local_point)
	burst.scale = presentation_anchor.global_scale*world_scale
	burst.z_index = 4
	add_child(burst)
	bursts_created += 1

func clear() -> void:
	for child in get_children():
		if child is Burst:
			remove_child(child)
			child.queue_free()

func _exit_tree() -> void:
	if is_instance_valid(attack):
		if attack.phase_changed.is_connected(_phase): attack.phase_changed.disconnect(_phase)
		if attack.hit_landed.is_connected(_hit): attack.hit_landed.disconnect(_hit)
		if attack.attack_finished.is_connected(clear): attack.attack_finished.disconnect(clear)
