extends Node2D

## One summoned blade. It only moves downward and is consumed by its detonation.
const Sword = preload("res://assets/vfx/abilities/king/worldsplitter/detailed/sword.png")
const Ground = preload("res://assets/vfx/abilities/king/worldsplitter/summoned/impact.png")
const Summon = preload("res://assets/vfx/abilities/king/worldsplitter/summoned/summon.png")
const MATERIAL_CODE := """
shader_type canvas_item;
uniform float crimson = 0.0;
uniform bool buried = false;
uniform float ground_y = 0.0;
varying vec4 tint;
varying float world_y;
void vertex(){ tint=COLOR; world_y=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).y; }
void fragment(){
	if(buried && world_y>ground_y+2.0) discard;
	vec4 c=texture(TEXTURE,UV);
	vec3 red=vec3(c.b,max(0.0,c.g-max(c.b-c.r,0.0)*0.55),c.r);
	c.rgb=mix(c.rgb,red,crimson);
	COLOR=c*tint;
}
"""
const BURIAL_DEPTH := 60.0
const DROP_HEIGHT := 144.0
# Measured occupied diameter of the packed peak frames, excluding empty gutters.
const GROUND_DIAMETER := 218.0
var crimson := false
var blast_radius := 88.0
var _sword: Sprite2D
var _ground: Sprite2D
var _summon: Sprite2D
var _sword_material: ShaderMaterial
var _age := 0.0
var _flight_age := -1.0
var _flight_duration := .42
var _contact_age := -1.0
var _fresh_formation := false

func _ready() -> void:
	_sword = _sprite(Sword, .96, -1)
	_ground = _sprite(Ground, blast_radius*2.0/GROUND_DIAMETER, -2)
	_summon = _sprite(Summon, .70, 0)
	_ground.visible = false
	_sword_material = _sword.material as ShaderMaterial
	_sword.position.y = -DROP_HEIGHT
	_summon.position.y = -DROP_HEIGHT-82.0
	_frame(_sword, 0)
	_frame(_summon, 0)

func _sprite(texture: Texture2D, size: float, depth: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE*size
	sprite.z_index = depth
	var shader := Shader.new()
	shader.code = MATERIAL_CODE
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("crimson", 1.0 if crimson else 0.0)
	sprite.material = material
	add_child(sprite)
	return sprite

func launch(duration: float, form_from_shards := false) -> void:
	_flight_duration = duration
	_flight_age = 0.0
	_fresh_formation = form_from_shards

func impact() -> void:
	_contact_age = 0.0
	_sword.position.y = BURIAL_DEPTH
	_sword_material.set_shader_parameter("ground_y", global_position.y)
	_sword_material.set_shader_parameter("buried", true)
	_ground.visible = true
	_ground.modulate.a = 1.0
	_frame(_ground, 2)
	_frame(_sword, 9)
	_summon.visible = false

func advance(delta: float) -> void:
	_age += delta
	if _contact_age >= 0.0:
		_contact_age += delta
		# Full area is readable immediately; its front breaks outward over .08s.
		var frame := 2+int(_contact_age/.028) if _contact_age < .084 else 5+int((_contact_age-.084)/.035)
		_frame(_ground, mini(15, frame))
		_ground.modulate.a = clampf((.52-_contact_age)/.12, 0.0, 1.0)
		_ground.visible = _contact_age < .52
		# Keep driving down while the exposed blade breaks; never extract it.
		_sword.position.y = BURIAL_DEPTH+minf(_contact_age/.16,1.0)*12.0
		_frame(_sword, 9+mini(6,int(_contact_age/.035)))
		_sword.visible = _contact_age < .245
	elif _flight_age >= 0.0:
		_flight_age += delta
		var t := clampf(_flight_age/_flight_duration, 0.0, 1.0)
		var entering := .80
		var formation := .28 if _fresh_formation else .20
		if t < entering:
			var travel := clampf((t-formation)/(entering-formation),0.0,1.0)
			_sword.position.y = lerpf(-DROP_HEIGHT,0.0,pow(travel,2.15))
			if _fresh_formation and t < formation:
				_frame(_sword,mini(3,int(t/formation*4)))
			else:
				_frame(_sword,4+mini(3,int(travel*4)))
		else:
			_sword.position.y = lerpf(0.0,BURIAL_DEPTH,(t-entering)/(1.0-entering))
			_sword_material.set_shader_parameter("ground_y",global_position.y)
			_sword_material.set_shader_parameter("buried",true)
			_frame(_sword, 8)
			_ground.visible = true
			_frame(_ground, mini(1,int((t-entering)/.10)))
		_frame(_summon, mini(15,2+int(t*14)))
		_summon.position.y = _sword.position.y-82.0
		_summon.visible = t < .90
	else:
		_frame(_sword,mini(3,int(_age/.045)))
		_frame(_summon,mini(3,int(_age/.045)))

func _frame(sprite: Sprite2D, index: int) -> void:
	index = clampi(index,0,15)
	sprite.region_rect = Rect2(Vector2(index%4,index/4)*512.0,Vector2(512,512))
