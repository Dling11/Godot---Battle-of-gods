extends "res://tests/king_production_art_contract.gd"

const ITEM = preload("res://data/items/equipment/king_signature_sword.tres")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	verify_production_baseline(["assets/characters/playable/king/sword_unified/", "data/weapons/families/sword/"])
	var profile := ITEM.weapon_definition.family_presentation
	check(profile != null and profile.is_valid_profile(), "Default sword has no current family art")
	check(ITEM.item_id == &"weapon_king_signature_sword" and ITEM.weapon_definition.basic_damage_minimum == 10 and ITEM.weapon_definition.basic_damage_maximum == 12 and ITEM.weapon_definition.damage == 25, "Starter identity/damage changed")
	var combo := ITEM.weapon_definition.combo
	var duration := 0.0
	for key in 3: duration += combo.windups[key]+combo.contacts[key]+combo.recoveries[key]
	check(is_equal_approx(duration,1.76) and combo.damage_multipliers == PackedFloat32Array([1,1.15,1.65]), "Current Sword rhythm or damage changed")
	check(combo.windups == PackedFloat32Array([.19,.15,.26]) and combo.contacts == PackedFloat32Array([.105,.105,.12]) and combo.recoveries == PackedFloat32Array([.27,.24,.32]), "Sword loses preparation or quicker cut/recovery")
	check(ITEM.weapon_definition.get_melee_forward_reach_pixels() == 60 and combo.hitbox_shapes[2].points[3].x == 68, "White stroke differs from real reach")
	for direction in [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		var attack: Resource = profile.attack_for(direction)
		for clip: Resource in [attack]+Array(attack.follow_up_clips)+[profile.run_for(direction),profile.idle_for(direction)]:
			verify_complete_clip(clip,Vector2i(256,256))
			check(clip.offhand == null and clip.weapon_texture.get_size() == Vector2(20,80) and clip.weapon_primary_grip == Vector2(10,66), "Sword changes steel/grip or draws a second weapon")
		check(profile.run_for(direction).pose_count == 8, "Sword running lost stride frames")
	verify_white_strokes(profile.swing_atlas.get_image(),12,3)
	print("KING_SWORD_PRODUCTION checks=",checks," failures=",failures)
	quit(1 if failures else 0)
