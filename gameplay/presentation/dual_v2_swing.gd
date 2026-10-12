extends "res://gameplay/presentation/axe_swing_trail.gd"

## Complete raster ribbons observe authoritative contact phases. No hits here.
const Up = preload("res://assets/characters/playable/king/dual_v2/slash_up.png")
const Down = preload("res://assets/characters/playable/king/dual_v2/slash_down.png")
const Dust = preload("res://assets/characters/playable/king/huge_greatsword_proof/impact.png")
const Impact = preload("res://gameplay/presentation/weapon_impact_presenter.gd")
var pose_presenter: Node2D
var slash_sprite: Sprite2D
var plant_bursts := 0

func bind_pose_presenter(presenter: Node2D) -> void:
	pose_presenter = presenter

func _ready() -> void:
	super._ready()
	slash_sprite = Sprite2D.new()
	var frame := AtlasTexture.new()
	frame.atlas = atlas
	frame.region = Rect2(0,0,192,192)
	frame.filter_clip = true
	slash_sprite.texture = frame
	slash_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slash_sprite.hide()
	add_child(slash_sprite)
	pose_presenter.pose_changed.connect(_pose_changed)

func _phase(phase: int,duration: float) -> void:
	clear()
	if phase!=MeleeAttackComponent.Phase.ACTIVE: return
	_row = clampi(_attack.combo_step,0,4)
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame,0.0,3.999,maxf(duration,.0001))
	_tween.tween_callback(slash_sprite.hide)

func _set_frame(value: float) -> void:
	_frame = clampi(int(value),0,3)
	if not is_instance_valid(slash_sprite): return
	var direction := _attack.get_attack_direction()
	var region := slash_sprite.texture as AtlasTexture
	region.atlas = atlas if absf(direction.x)>absf(direction.y) or _row==3 else (Up if direction.y<0 else Down)
	region.region = Rect2(_frame*192,_row*192,192,192)
	slash_sprite.show()
	_update_anchor()

func _update_anchor() -> void:
	var direction := _attack.get_attack_direction()
	var side := absf(direction.x)>absf(direction.y)
	var lift: float = pose_presenter.definition.lift_pixels[pose_presenter.pose_index]*.5
	if _row==3:
		slash_sprite.transform = Transform2D(0,Vector2.ONE*1.18,0,Vector2(0,-32+lift))
	elif side:
		slash_sprite.transform = Transform2D(0,Vector2(-.95 if direction.x<0 else .95,.95),0,Vector2(22*(-1 if direction.x<0 else 1),-31+lift))
	else:
		# Raster curves are registered in the floor camera plane, not a tall rotated UI panel.
		var pivot := Vector2(0,-16+lift)+direction*25
		slash_sprite.transform = Transform2D(0,Vector2(.95,.65),0,pivot)*Transform2D(direction.angle(),Vector2.ZERO)

func _pose_changed(pose: int) -> void:
	if is_instance_valid(slash_sprite) and slash_sprite.visible: _update_anchor()
	if pose!=3 or not pose_presenter._resting or pose_presenter._drawing or pose_presenter.definition!=pose_presenter.idle_definition: return
	for sprite: Sprite2D in [pose_presenter.weapon_sprite,pose_presenter.offhand_sprite]:
		var burst := Impact.Burst.new()
		burst.atlas = Dust
		burst.row = 1
		burst.duration = .24
		burst.top_level = true
		burst.position = sprite.to_global(pose_presenter.definition.weapon_tip)
		burst.scale = Vector2.ONE*.18
		burst.z_index = 4
		add_child(burst)
		plant_bursts += 1

func _draw() -> void:
	pass

func clear() -> void:
	super.clear()
	if is_instance_valid(slash_sprite): slash_sprite.hide()
	for child in get_children():
		if child is Impact.Burst: child.queue_free()

func _exit_tree() -> void:
	clear()
	if is_instance_valid(pose_presenter) and pose_presenter.pose_changed.is_connected(_pose_changed): pose_presenter.pose_changed.disconnect(_pose_changed)
	super._exit_tree()
