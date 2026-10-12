extends Node

## Per-stage observations only. Services own all grants, clears and travel.
const View = preload("res://ui/expeditions/expedition_feedback_view.gd")
const CompletionReturn = preload("res://gameplay/expeditions/expedition_completion_return.gd")
const ROUTES := [
	preload("res://data/expeditions/forgotten_grove.tres"),
	preload("res://data/expeditions/thorns_of_the_forgotten_grove.tres"),
	preload("res://data/expeditions/rootbound_hollow.tres"),
	preload("res://data/expeditions/eastern_rot.tres"),
	preload("res://data/expeditions/dead_forest.tres"),
	preload("res://data/expeditions/elder_ascent.tres"),
]

var view: Control
var _flow: Node
var _route: ExpeditionDefinition
var _player: Player
var _encounter: EncounterController
var _completed := false
var _defeated := false
var _xp := 0
var _gold := 0
var _start_level := 1
var _start_cap := 4
var _materials := {}
var _overflow := 0
var _clear_result := {}
var _available_before := {}
var _menu_input_was_enabled := true

static func install(flow: Node, route: ExpeditionDefinition) -> Node:
	var feedback := new()
	feedback.name = "ExpeditionFeedback"
	flow.add_child(feedback)
	feedback.configure(flow, route)
	return feedback

func configure(flow: Node, route: ExpeditionDefinition) -> void:
	_flow = flow
	_route = route
	_player = flow.player
	if "encounter_controller" in flow: _encounter = flow.encounter_controller
	_start_level = _player.progression_component.level
	_start_cap = _player.progression_component.get_current_level_cap()
	for entry: ExpeditionDefinition in ROUTES:
		_available_before[entry.expedition_id] = entry.is_available(get_node("/root/StoryState"), _start_level)
	_player.progression_component.rewards_granted.connect(_on_rewards)
	_player.defeated.connect(_on_defeated)
	get_node("/root/LootService").material_granted.connect(_on_material)
	get_node("/root/LootService").stage_reward_granted.connect(_on_chest_reward)
	view = View.new()
	view.name = "ExpeditionFeedbackView"
	var layer := CanvasLayer.new()
	layer.name = "ExpeditionFeedbackLayer"
	layer.layer = 5
	add_child(layer)
	layer.add_child(view)
	view.report_requested.connect(_open_report)
	view.return_requested.connect(_return_home)
	view.report_closed.connect(_restore_menu_input)
	# Reserve distinct right-hand bands for objectives, roster, then loot toast.
	var roster: Control = flow.combat_hud.enemy_roster_panel
	flow.combat_hud.enemy_roster_scroll.custom_minimum_size.y = 100
	roster.offset_top = 204
	roster.offset_bottom = 354
	var toast: Control = flow.combat_hud.get_node("LootToastPanel")
	toast.offset_top = 366
	toast.offset_bottom = 410
	for modal in [flow.character_menu, flow.get_node_or_null("UI/PauseMenu"), flow.get("dialogue_panel") if "dialogue_panel" in flow else null]:
		if modal != null: modal.visibility_changed.connect(_sync_tracker_visibility)
	if _encounter != null:
		_encounter.progress_changed.connect(_update_encounter)
		_encounter.stage_cleared.connect(_on_stage_cleared)
		_encounter.reward_chest_spawned.connect(func(_position: Vector2) -> void: _update_encounter(_encounter.get_progress()))
		_update_encounter(_encounter.get_progress())
	else:
		view.update_objective(_route, "Reach Varkuun's clearing", "Enter the grove to face its lord", 0, 1, false)
		if "approach_encounter" in flow and flow.approach_encounter != null:
			var approach: EncounterController = flow.approach_encounter
			approach.progress_changed.connect(_update_approach)
			_update_approach(approach.get_progress())

func _update_approach(snapshot: Dictionary) -> void:
	if _defeated: return
	if snapshot.state == "preparing":
		var total: int = _flow.approach_encounter.waves[0].total_enemy_count()
		view.update_objective(_route,"Defeat the grove's sentries","%d sentries ahead · Interrupt the Rotcaller" % total,0,total,false)
		return
	if snapshot.state == "complete":
		view.update_objective(_route,"Reach Varkuun's clearing","Sentries defeated · Enter the northern basin",0,1,false)
	else:
		view.update_objective(_route,"Defeat the grove's sentries","%d / %d defeated · Interrupt the Rotcaller" % [snapshot.defeated,snapshot.total],snapshot.defeated,maxi(1,snapshot.total),false)

func _on_rewards(experience: int, coins: int) -> void:
	if _defeated: return
	_xp += experience
	_gold += coins

func _on_material(material: MaterialDefinition, quantity: int, _source: StringName, reached_cap: bool) -> void:
	if _defeated: return
	var current: Dictionary = _materials.get(material.material_id, {"material": material, "quantity": 0})
	current.quantity += quantity
	if current.quantity > 0: _materials[material.material_id] = current
	if reached_cap: view.status.tooltip_text = "Some material stacks are full. The receipt shows only quantities added to your bag."

func _on_chest_reward(result: Dictionary) -> void:
	if _defeated or not bool(result.get("success", false)): return
	_clear_result = result.duplicate(true)
	for stack: Dictionary in result.get("overflow_materials", []): _overflow += int(stack.quantity)

func _on_stage_cleared() -> void:
	if _defeated: return
	_completed = true
	_update_encounter(_encounter.get_progress())

func _update_encounter(snapshot: Dictionary) -> void:
	if _defeated: return
	var action := "Defeat the remaining enemies"
	var detail := "Wave %d / %d · %d / %d defeated" % [snapshot.wave, snapshot.waves, snapshot.defeated, snapshot.total]
	var value: float = snapshot.defeated
	var maximum: float = maxi(1, snapshot.total)
	match snapshot.state:
		"preparing":
			action = "Prepare for the encounter"
			detail = "%d encounter waves ahead" % snapshot.waves
		"reinforcements": detail += " · Incoming"
		"wave_clear":
			action = "Wave cleared"
			detail = "Next wave approaching" if snapshot.wave < snapshot.waves else "Securing the clearing"
		"dialogue":
			action = "Face the Hollow's guardian"
			detail = "Continue or skip the conversation"
		"claim_reward":
			action = "Claim the Rootbound Reliquary"
			detail = "Find the chest · Press F · Exit sealed"
			value = maximum
		"complete":
			action = "Stage complete · Exit open"
			detail = "View rewards or approach the portal [F]"
			value = maximum
	view.update_objective(_route, action, detail, value, maximum, _completed)
	view.objective.tooltip_text = snapshot.title

func boss_started() -> void:
	view.update_objective(_route, "Defeat Varkuun", "The Lord of the Withered Grove", 0, 1, false)

func boss_defeated() -> void:
	view.update_objective(_route, "Claim Varkuun's Chest", "After the farewell · Find the hoard [F]", 1, 1, false)

func boss_reward_claimed() -> void:
	if _defeated: return
	_completed = true
	view.update_objective(_route, "Stage complete · Exit open", "View rewards or approach the portal [F]", 1, 1, true)

func receipt() -> Dictionary:
	var stacks: Array[Dictionary] = []
	var ids := _materials.keys()
	ids.sort()
	for id: Variant in ids: stacks.append(_materials[id].duplicate())
	var progression := _player.progression_component
	var unlocks: Array[String] = []
	var story := get_node("/root/StoryState")
	for entry: ExpeditionDefinition in ROUTES:
		if not _available_before[entry.expedition_id] and entry.is_available(story, progression.level):
			if entry.expedition_id != &"elder_ascent" or OS.is_debug_build():
				unlocks.append(entry.display_name + " · Expedition available")
	if progression.get_current_level_cap() > _start_cap:
		unlocks.append("Level cap %d → %d" % [_start_cap, progression.get_current_level_cap()])
	if _clear_result.get("key_item_ids", PackedStringArray()).has("forest_core_gear_seal"):
		unlocks.append("Weapon & armor crafting · Visit Nema in Sanctuary")
	var recipes: PackedStringArray = _clear_result.get("recipe_ids", PackedStringArray())
	if not recipes.is_empty(): unlocks.append("%d equipment blueprints discovered" % recipes.size())
	var kind := "STAGE COMPLETE"
	if _clear_result.has("first_clear"): kind = "FIRST CLEAR" if _clear_result.first_clear else "REPLAY CLEAR"
	return {"stage": _route.display_name, "clear_kind": kind, "xp": _xp, "gold": _gold, "start_level": _start_level, "level": progression.level, "materials": stacks, "unlocks": unlocks, "overflow": _overflow}

func _open_report() -> void:
	if not _completed or _defeated or get_tree().paused: return
	view.present_receipt(receipt())
	_menu_input_was_enabled = _flow.character_menu.is_processing_input()
	_flow.character_menu.set_process_input(false)
	view.open_report()

func _restore_menu_input() -> void:
	if is_instance_valid(_flow.character_menu): _flow.character_menu.set_process_input(_menu_input_was_enabled)

func _return_home() -> void:
	if not CompletionReturn.can_return(_flow): return
	view.close_report()
	CompletionReturn.request(_flow)

func _on_defeated() -> void:
	_defeated = true
	_completed = false
	view.close_report()
	view.update_objective(_route, "Expedition ended", "Press R to recover in Sanctuary", 0, 1, false)

func _sync_tracker_visibility() -> void:
	var modal_open := false
	for modal in [_flow.character_menu, _flow.get_node_or_null("UI/PauseMenu"), _flow.get("dialogue_panel") if "dialogue_panel" in _flow else null]:
		if modal != null: modal_open = modal_open or modal.visible
	view.tracker.visible = not modal_open
