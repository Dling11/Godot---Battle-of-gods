extends SceneTree

const ACTIVE_PATHS := [
"res://assets/environment/sanctuary/weapon_court/training_pavilion.png",
"res://assets/characters/npcs/veyr/idle.png",
"res://assets/environment/sanctuary/weapon_court/veil_gate.png",
"res://assets/environment/sanctuary/weapon_court/veil_energy.png",
"res://assets/environment/sanctuary/weapon_court/training_post.png",
"res://levels/sanctuary/town/sanctuary_town.gd",
"res://assets/characters/npcs/armskeeper/renewal/sprite_frames.tres",
"res://assets/characters/npcs/skillkeeper/renewal/sprite_frames.tres",
"res://assets/characters/npcs/rootweaver/renewal/sprite_frames.tres",
"res://assets/characters/npcs/umi/renewal/sprite_frames.tres",
	"res://assets/characters/playable/king/shared_bodies/sword/frames.tres",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_sprite_frames.tres",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sprite_frames.tres",
]

const RETIRED_RUNTIME_PATHS := [
	"res://assets/environment/sanctuary/landmarks/angel_expedition_portal_ground_192x192.png",
	"res://assets/environment/sanctuary/landmarks/generated/angel_expedition_portal_static_192x256.png",
	"res://assets/environment/sanctuary/landmarks/generated/sanctuary_portal_energy_4x_44x112.png",
	"res://assets/vfx/abilities/weapons/axe_war_cyclone/spin_body.png",
	"res://assets/vfx/abilities/weapons/axe_war_cyclone/recovery_body.png",
	"res://assets/vfx/abilities/weapons/axe_war_cyclone/slash.png",
	"res://art_source/generated",
	"res://assets/characters/awakened",
	"res://assets/characters/prototype",
	"res://assets/characters/sprites_24x32",
	"res://assets/characters/playable/opaw",
	"res://assets/skills/opaw",
	"res://data/abilities/opaw",
	"res://data/items/opaw_weapon_catalog.tres",
	"res://data/progression/opaw_path.tres",
	"res://data/progression/opaw_vitality.tres",
	"res://gameplay/abilities/opaw",
	"res://ui/shops",
	"res://entities/npcs/weapon_merchant",
	"res://environment/props/sanctuary/mushroom_dwelling.tscn",
	"res://environment/props/sanctuary/merchant_hall.tscn",
	"res://environment/props/sanctuary/weapon_stall.tscn",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_attack_sheet_96x64_from_scratch.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_attack_sheet_96x64_v2.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64_from_scratch.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64_passing_v2.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64_v2.png",
]


func _initialize() -> void:
	for path in ACTIVE_PATHS:
		if not ResourceLoader.exists(path):
			_fail("Required active or supported rollback resource is missing: %s" % path)
			return
	for path in RETIRED_RUNTIME_PATHS:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path) or DirAccess.dir_exists_absolute(absolute_path):
			_fail("Retired material leaked back into Godot runtime folders: %s" % path)
			return
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://art_source/archive")):
		_fail("Retired archives must remain outside the maintained working tree.")
		return
	print("Runtime/archive boundary smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
