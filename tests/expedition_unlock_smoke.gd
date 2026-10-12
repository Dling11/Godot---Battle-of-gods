extends SceneTree

const ForgottenGrove = preload("res://data/expeditions/forgotten_grove.tres")
const GroveThorns = preload("res://data/expeditions/thorns_of_the_forgotten_grove.tres")
const RootboundHollow = preload("res://data/expeditions/rootbound_hollow.tres")
const EasternRot = preload("res://data/expeditions/eastern_rot.tres")
const DeadForest = preload("res://data/expeditions/dead_forest.tres")
const ElderAscent = preload("res://data/expeditions/elder_ascent.tres")
const DrownedBells = preload("res://data/expeditions/drowned_bells.tres")
const Progression = preload("res://data/progression/king_path.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var story_state := root.get_node("StoryState")
	var run_session := root.get_node("RunSession")
	story_state.reset_story()
	run_session.reset_run()
	var menu_scene := load("res://ui/expeditions/expedition_menu.tscn") as PackedScene
	var menu := menu_scene.instantiate() as ExpeditionMenu
	var route_order: Array[StringName] = []
	for definition: ExpeditionDefinition in menu.expeditions:
		route_order.append(definition.expedition_id)
	if route_order != [
		&"forgotten_grove",
		&"thorns_of_the_forgotten_grove",
		&"rootbound_hollow",
		&"eastern_rot",
		&"dead_forest",
		&"elder_ascent",
		&"drowned_bells",
	]:
		_fail("The expedition menu does not preserve canonical Stage I-VI order.")
		return
	menu.free()

	for definition: ExpeditionDefinition in [ForgottenGrove, GroveThorns, RootboundHollow, EasternRot, DeadForest, ElderAscent, DrownedBells]:
		if not definition.is_valid_definition():
			_fail("An expedition definition is missing its stable identity or display metadata.")
			return

	if ForgottenGrove.is_available(story_state, 1):
		_fail("The Forgotten Grove opened before the new soul awakened in Sanctuary.")
		return
	story_state.remember_story(&"awakened_in_sanctuary")
	if not ForgottenGrove.is_available(story_state, 1):
		_fail("The introductory route did not open after Sanctuary awakening.")
		return
	if GroveThorns.is_available(story_state, 1):
		_fail("Stage 2 opened before Stage 1's clear flag.")
		return
	story_state.remember_story(&"forgotten_grove_stage_1_cleared")
	if not GroveThorns.is_available(story_state, 1):
		_fail("Stage 2 did not open after Stage 1's clear flag.")
		return

	var hollow_requirement := RootboundHollow.requirement
	var initial_unmet := hollow_requirement.get_unmet_requirements(story_state, 1)
	for expected in [
		"REACH LEVEL 3",
		"STORY: Forgotten Grove Completed",
		"BOSS: Thornbound Warden",
		"KEY ITEM: Cinder Sigil",
	]:
		if expected not in initial_unmet:
			_fail("The Rootbound Hollow omitted an authored requirement: %s" % expected)
			return

	run_session.update_progression(400, 0)
	var player_level := Progression.get_level_for_total_experience(run_session.total_experience)
	story_state.remember_story(&"forgotten_grove_completed")
	story_state.record_boss_victory(&"thornbound_warden")
	story_state.grant_key_item(&"cinder_sigil")
	if player_level != 3 or not hollow_requirement.is_satisfied(story_state, player_level):
		_fail("Combined level, story, boss, and key-item requirements did not resolve.")
		return
	if not RootboundHollow.is_available(story_state, player_level):
		_fail("Stage 3 did not open after its authored requirements were met.")
		return
	if EasternRot.is_available(story_state, player_level):
		_fail("Stage 4 opened before the Rootbound Husk was defeated and its hollow discovered.")
		return
	run_session.update_progression(750, 0)
	player_level = Progression.get_level_for_total_experience(run_session.total_experience)
	story_state.remember_story(&"rootbound_hollow_completed")
	story_state.record_boss_victory(&"rootbound_husk")
	story_state.record_discovery(&"rootbound_hollow")
	if player_level != 4 or not EasternRot.is_available(story_state, player_level):
		_fail("Stage 4 did not open at Level 4 after the Rootbound Hollow clear memories were recorded.")
		return
	if DeadForest.is_available(story_state, player_level):
		_fail("Stage 5 opened before Stage 4 was cleared and Level 5 was reached.")
		return
	run_session.update_progression(1200, 0)
	player_level = Progression.get_level_for_total_experience(run_session.total_experience)
	story_state.remember_story(&"forest_stage_4_cleared")
	story_state.record_discovery(&"eastern_rot")
	if player_level != 5 or not DeadForest.is_available(story_state, player_level):
		_fail("Stage 5 did not open in sequence after the Eastern Rot clear.")
		return
	if ElderAscent.is_available(story_state, player_level):
		_fail("Stage 6 opened before the Stage 5 boss was defeated.")
		return
	run_session.update_progression(1750, 0)
	player_level = Progression.get_level_for_total_experience(run_session.total_experience)
	story_state.remember_story(&"forest_stage_5_cleared")
	story_state.record_boss_victory(&"stage_5_boss")
	story_state.record_discovery(&"dead_forest")
	if player_level < 6 or not ElderAscent.is_available(story_state, player_level):
		_fail("Stage 6 did not open at Level %d; unmet: %s." % [
			player_level,
			", ".join(ElderAscent.get_unmet_requirements(story_state, player_level)),
		])
		return

	story_state.record_discovery(&"remembered_thorn_shrine")
	var snapshot: Dictionary = story_state.create_snapshot()
	story_state.reset_story()
	if story_state.has_boss_victory(&"thornbound_warden"):
		_fail("Resetting story memory retained an old boss victory.")
		return
	if not story_state.restore_snapshot(snapshot):
		_fail("The versioned story snapshot could not be restored.")
		return
	if (
		not story_state.has_story_flag(&"forgotten_grove_completed")
		or not story_state.has_boss_victory(&"thornbound_warden")
		or not story_state.has_key_item(&"cinder_sigil")
		or not story_state.has_discovery(&"remembered_thorn_shrine")
	):
		_fail("Story snapshot restoration lost authored memory categories.")
		return
	if story_state.restore_snapshot({"version": 999}):
		_fail("Story memory accepted an unsupported snapshot version.")
		return

	print("Expedition unlock smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
