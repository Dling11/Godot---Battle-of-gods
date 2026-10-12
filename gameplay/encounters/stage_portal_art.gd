class_name StagePortalArt
extends RefCounted

const FAMILY := [
	preload("res://assets/environment/portals/threat_family/calm_frames.tres"),
	preload("res://assets/environment/portals/threat_family/ominous_frames.tres"),
	preload("res://assets/environment/portals/threat_family/grasp_frames.tres"),
	preload("res://assets/environment/portals/threat_family/divine_frames.tres"),
	preload("res://assets/environment/portals/threat_family/unknowable_frames.tres"),
]
const MAW := preload("res://assets/environment/portals/threat_family/maw_frames.tres")
const STABLE_SURFACE := preload("res://gameplay/encounters/stage_portal_stable_surface.gdshader")
# Register the animated currents to the reference's solid-body centroid. These
# measured whole-pixel offsets never resize/translate the portal node or outline.
const SURFACES := [
	{"reference":1, "center":Vector2(98,91), "radius":Vector2(23,44),
	 "offsets":[Vector2(4,0),Vector2(0,0),Vector2(-2,1),Vector2(0,0),Vector2(2,-3),Vector2(0,-3),Vector2(-1,-3),Vector2(-1,-3)]},
	{"reference":2, "center":Vector2(97,90), "radius":Vector2(24,43),
	 "offsets":[Vector2(5,1),Vector2(3,0),Vector2(0,0),Vector2(-3,0),Vector2(6,-4),Vector2(3,-6),Vector2(1,-4),Vector2(-3,-5)]},
	{"reference":0, "center":Vector2(91,87), "radius":Vector2(23,45),
	 "offsets":[Vector2(0,0),Vector2(1,0),Vector2(1,0),Vector2(0,0),Vector2(1,0),Vector2(0,0),Vector2(-1,1),Vector2(0,0)]},
	{"reference":0, "center":Vector2(96,88), "radius":Vector2(24,38),
	 "offsets":[Vector2(0,0),Vector2(-1,0),Vector2(-1,1),Vector2(-5,1),Vector2(-1,-3),Vector2(-1,-4),Vector2(-1,-3),Vector2(-4,-3)]},
	{"reference":0, "center":Vector2(96,87), "radius":Vector2(23,44),
	 "offsets":[Vector2(0,0),Vector2(1,0),Vector2(1,0),Vector2(0,0),Vector2(1,-2),Vector2(0,-2),Vector2(0,-1),Vector2(0,-1)]},
	{"reference":2, "center":Vector2(96,90), "radius":Vector2(25,43),
	 "offsets":[Vector2(5,0),Vector2(4,-1),Vector2(0,0),Vector2(0,0),Vector2(4,-5),Vector2(5,-5),Vector2(1,-4),Vector2(1,-4)]},
]

static func frames_for(tier: int, boss_variant: int = 0) -> SpriteFrames:
	if tier == 2 and boss_variant == 1:
		return MAW
	return FAMILY[clampi(tier, 0, FAMILY.size()-1)]

static func surface_for(tier: int, boss_variant: int = 0) -> ShaderMaterial:
	var index: int = [0,1,2,4,5][clampi(tier,0,4)]
	if tier == 2 and boss_variant == 1: index = 3
	var spec: Dictionary = SURFACES[index]
	var material := ShaderMaterial.new()
	material.shader = STABLE_SURFACE
	material.set_shader_parameter("reference_frame",spec.reference)
	material.set_shader_parameter("core_center",spec.center)
	material.set_shader_parameter("core_radius",spec.radius)
	material.set_shader_parameter("registration",PackedVector2Array(spec.offsets))
	material.set_shader_parameter("hand_detail",index == 2)
	return material
