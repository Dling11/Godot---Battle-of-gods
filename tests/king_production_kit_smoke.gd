extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const PlayerScene = preload("res://entities/player/player.tscn")
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_production_kit_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var actor: Player = lab.player
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	var review: Node = lab.get_node("KingCombatReview")
	var body: AnimatedSprite2D = actor.get_node("VisualRoot/Body")
	check(body.sprite_frames.get_frame_texture("idle_down",0).atlas == (load("res://assets/characters/playable/king/shared_bodies/sword/frames.tres") as SpriteFrames).get_frame_texture("idle_down",0).atlas and body.scale == Vector2(.5, .5), "Current canonical Sword art is not production")
	check(body.material == null and body.get_script().resource_path == "res://entities/player/presentation/king_spellward_animation.gd", "Canonical Sword locomotion should retain its baked outline")
	check(library.entries().size() == 5 and library.current_ids().slice(0, 5) == KingSkillCatalog.IDS, "Retired Oath abilities leaked into the collection")
	check(actor.ability_1_component is EarthsplitterComponent and actor.ability_1_component.definition.display_name == "Earthsplitter", "Skill 1 is not Earthsplitter")
	check(actor.ability_2_component is MoltenCrashComponent and actor.ability_2_component.definition.form == MoltenCrashDefinition.Form.FOUNDATION, "Skill 2 is not blue Foundation")
	check(actor.get_node("AbilityPivot/SovereignPursuitVisual/EffectSprite").sprite_frames == load("res://assets/vfx/abilities/king/sovereign_pursuit_review/landing_frames.tres"), "Skill 3 blade-cut art is not production")
	check(KingSkillCatalog.valid_slots(["crosscut_advance", "griefwake", "starfall_step", "oathstorm"]), "Legacy save IDs cannot be read")
	check(KingSkillCatalog.migrate_legacy_slots(["crosscut_advance", "griefwake", "starfall_step", "oathstorm"]).slice(0, 5) == KingSkillCatalog.IDS, "Legacy save IDs do not migrate to the core kit")
	check(KingSkillCatalog.expanded_slots(["echoing_sever", "crosscut_advance", "", ""]).slice(0, 2) == ["echoing_sever", ""], "Mixed save duplicates were not removed")
	check(review.set_earthsplitter_form(EarthsplitterDefinition.Form.FAN), "Skill 1 Lab form selection failed")
	check(actor.ability_1_component.definition.form == EarthsplitterDefinition.Form.FAN and library.current_ids()[0] == "echoing_sever", "Skill 1 form lost its slot identity")
	check(review.set_molten_form(MoltenCrashDefinition.Form.ADVANCED), "Skill 2 Lab form selection failed")
	check(actor.ability_2_component.definition.form == MoltenCrashDefinition.Form.ADVANCED and library.current_ids()[1] == "riftbreak", "Skill 2 form lost its slot identity")
	check(review.set_pursuit_rank(SovereignPursuitDefinition.Rank.MATURE), "Skill 3 Lab rank selection failed")
	check((actor.ability_3_component as SovereignPursuitComponent).get_max_charges() == 3 and actor.ability_3_component.get_target_range_pixels() == 280.0, "Skill 3 Lab rank did not set stock and range")
	check(review.set_pursuit_rank(SovereignPursuitDefinition.Rank.FOUNDATION), "Skill 3 Lab rank did not restore")
	check(review.set_earthsplitter_form(EarthsplitterDefinition.Form.FOUNDATION) and review.set_molten_form(MoltenCrashDefinition.Form.FOUNDATION), "Lab forms did not restore")
	lab.set_enemy_ai_enabled(false)
	actor.ability_1_component.clear_cooldown()
	check(actor.request_ability(1) and actor.ground_point_targeting.is_targeting(), "Earthsplitter did not open its fixed lane aim")
	actor.ground_point_targeting.update_aim(actor.global_position + Vector2.RIGHT * 160.0, Vector2.ZERO)
	actor.ground_point_targeting.confirm_targeting()
	await create_timer(.43, false).timeout
	check(actor.ability_1_component is EarthsplitterComponent and not get_nodes_in_group("earthsplitter_sequences").is_empty(), "Earthsplitter did not release its ground wave")
	await create_timer(.7, false).timeout
	actor.ability_2_component.clear_cooldown()
	check(actor.request_ability(2), "Molten Crash did not start from its slot")
	await create_timer(.25, false).timeout
	check(actor.ability_2_component is MoltenCrashComponent and not get_nodes_in_group("molten_crash_effects").is_empty(), "Molten Crash did not release its visual contact")
	await create_timer(.9, false).timeout
	var session := root.get_node("RunSession")
	session.king_skill_layout_version = 0
	session.king_skill_slots = ["crosscut_advance", "griefwake", "starfall_step", "oathstorm"]
	var restored := PlayerScene.instantiate() as Player
	root.add_child(restored)
	await process_frame
	check(restored.get_node("KingSkillLibrary").current_ids().slice(0, 5) == KingSkillCatalog.IDS and session.king_skill_slots.slice(0, 5) == KingSkillCatalog.IDS, "A loaded Oath save was not migrated")
	restored.queue_free()
	lab.queue_free()
	print("KING_PRODUCTION_KIT_SMOKE_FAILURES=", failures)
	quit(1 if failures else 0)


func check(ok: bool, reason: String) -> void:
	if not ok:
		failures += 1
		push_error(reason)
