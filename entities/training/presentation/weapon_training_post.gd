extends Node2D

## Hit presentation only. The target and lesson retain health/proof authority.
const TEXTURE := preload("res://assets/environment/sanctuary/weapon_court/training_post.png")
const DURATION := .24
var art: Sprite2D
var _reaction: Tween
var _first_frame := 1
var _flecks: Array[Line2D] = []

func configure(target: Node2D) -> void:
	name = "PostPresentation"
	art = Sprite2D.new()
	art.name = "Art"
	art.texture = TEXTURE
	art.hframes = 4
	art.scale = Vector2(.65,.65)
	art.position = Vector2(0,-14.3)
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(art)
	for index in 4:
		var fleck := Line2D.new()
		fleck.width = 1
		fleck.points = PackedVector2Array([Vector2.ZERO,Vector2(1,0)])
		fleck.default_color = Color("c9b07b")
		fleck.modulate.a = 0
		add_child(fleck)
		_flecks.append(fleck)
	target.get_node("HealthComponent").damaged.connect(_on_hit)

func _on_hit(info: DamageInfo) -> void:
	if is_instance_valid(_reaction): _reaction.kill()
	_first_frame = 2 if info.direction.x>=0 else 1
	_animate_hit(0)
	_reaction = create_tween()
	_reaction.tween_method(_animate_hit,0.0,1.0,DURATION)

func _animate_hit(progress: float) -> void:
	if progress<.34: art.frame = _first_frame
	elif progress<.62: art.frame = 3-_first_frame
	elif progress<1: art.frame = 3
	else: art.frame = 0
	art.modulate = Color.WHITE*lerpf(1.18,1,progress)
	art.modulate.a = 1
	for index in _flecks.size():
		var side := -1.0 if index%2==0 else 1.0
		_flecks[index].position = Vector2(side*(5+progress*(6+index)),-20+index*2-progress*8+progress*progress*13)
		_flecks[index].modulate.a = 1-progress
