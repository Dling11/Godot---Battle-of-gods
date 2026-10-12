extends Node2D

## Faint rear trail after contact ends. Presentation only; never issues hits.
var presenter: Node2D
var attack: MeleeAttackComponent
var return_clip: Resource
var atlas: Texture2D
var _sprite: Sprite2D
var _frame: AtlasTexture

func _ready() -> void:
	assert(presenter!=null and attack!=null and return_clip!=null and atlas!=null)
	_frame = AtlasTexture.new()
	_frame.atlas = atlas
	_sprite = Sprite2D.new()
	_sprite.texture = _frame
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = false
	_sprite.scale = Vector2.ONE*0.6
	_sprite.rotation = -PI/2
	_sprite.position = Vector2(0,-40)-Transform2D(-PI/2,Vector2.ZERO).basis_xform(Vector2(128,168)*0.6)
	_sprite.modulate.a = 0.30
	_sprite.hide()
	presenter.weapon_rig.add_child(_sprite)
	presenter.pose_changed.connect(_pose)
	attack.phase_changed.connect(_phase)
	attack.attack_finished.connect(_finish)
	set_process(false)
	set_physics_process(false)

func _pose(index: int) -> void:
	var first := int(return_clip.phase_windows[2].x)
	if presenter.definition!=return_clip or attack.phase!=MeleeAttackComponent.Phase.RECOVERY or index<first or index>first+3:
		_sprite.hide()
		return
	var key := first+3-index
	_frame.region = Rect2(Vector2(key*256,3*256),Vector2(256,256))
	_sprite.modulate.a = 0.20*(1.0-float(index-first)*0.18)
	_sprite.show()

func _phase(_phase_value: int,_seconds: float) -> void:
	_pose(presenter.pose_index)

func _finish() -> void:
	_sprite.hide()

func _exit_tree() -> void:
	if is_instance_valid(_sprite): _sprite.queue_free()
	if is_instance_valid(presenter) and presenter.pose_changed.is_connected(_pose): presenter.pose_changed.disconnect(_pose)
	if is_instance_valid(attack):
		if attack.phase_changed.is_connected(_phase): attack.phase_changed.disconnect(_phase)
		if attack.attack_finished.is_connected(_finish): attack.attack_finished.disconnect(_finish)
