extends "res://gameplay/presentation/axe_swing_trail.gd"

## Keep the meteor raster over the outer blade while retaining contact clipping.
var meteor_clip: Resource
var pose_presenter: Node2D
var source_anchor := Vector2(164,144)
var meteor_texel_scale := 0.30
const CellShader = preload("res://gameplay/presentation/registered_atlas_cell.gdshader")
var _cell_material: ShaderMaterial

func _ready() -> void:
	super._ready()
	_cell_material = ShaderMaterial.new()
	_cell_material.shader = CellShader
	material = _cell_material

func _set_frame(value: float) -> void:
	var previous := _frame
	super._set_frame(value)
	if previous==_frame: return
	_cell_material.set_shader_parameter("cell_min",Vector2(_frame/4.0,_row/float(rows)))
	_cell_material.set_shader_parameter("cell_max",Vector2((_frame+1)/4.0,(_row+1)/float(rows)))

func _phase(phase: int,duration: float) -> void:
	frame_sample_transforms.clear()
	var registered: bool = is_instance_valid(pose_presenter) and _attack.combo_step==2
	var clip: Resource = pose_presenter.definition if registered else meteor_clip
	if phase==MeleeAttackComponent.Phase.ACTIVE and (registered or _attack.combo_step==2) and clip!=null:
		var facing := -1.0 if _attack.get_attack_direction().x<0 else 1.0
		var mirror := Transform2D(Vector2(facing,0),Vector2(0,1),Vector2.ZERO)
		for frame in 4:
			var pose: int = roundi(lerpf(clip.phase_windows[1].x,clip.phase_windows[1].y,float(frame)/3)) if registered else (5 if frame<2 else 6)
			var primary: Vector2 = mirror*((clip.primary_hands[pose]-Vector2(96,64))*0.5+Vector2(0,-16))
			var shaft: Vector2 = mirror.basis_xform((clip.secondary_hands[pose]-clip.primary_hands[pose]).normalized())
			var blade := -shaft
			# Reflect the complete right-facing basis, including handedness.
			var across := Vector2(-blade.y,blade.x)*facing
			var center := primary+blade*35
			var mapping := Transform2D(across*meteor_texel_scale,blade*meteor_texel_scale,center-across*meteor_texel_scale*source_anchor.x-blade*meteor_texel_scale*source_anchor.y)
			frame_sample_transforms.append(mapping.affine_inverse())
	super._phase(phase,duration)
