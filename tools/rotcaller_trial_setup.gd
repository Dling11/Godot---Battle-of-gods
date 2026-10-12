extends RefCounted

const TrialFlow = preload("res://tools/rotcaller_trial_flow.gd")
const TrialEncounter = preload("res://tools/rotcaller_trial_encounter.gd")
const Caster = preload("res://entities/enemies/rotcaller/rotcaller.tscn")

static func create(with_spitter := false) -> Node:
	var stage: Node = load("res://levels/stage_4/stage_4.tscn").instantiate()
	var player: Player = stage.player
	var hud: CombatHUD = stage.combat_hud
	var menu: CharacterMenu = stage.character_menu
	var controller: EncounterController = stage.encounter_controller
	var exports := {}
	for property: Dictionary in controller.get_property_list():
		if property.usage & PROPERTY_USAGE_STORAGE and property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			exports[property.name] = controller.get(property.name)
	controller.set_script(TrialEncounter)
	for property: String in exports: controller.set(property,exports[property])
	var wave := EncounterWaveDefinition.new()
	wave.title = "Rotcaller · interrupt or evade"
	wave.spawn_interval = .12
	wave.rootling_count = 2
	wave.bramble_spitter_count = 1 if with_spitter else 0
	var caster := EncounterSpawnEntryDefinition.new()
	caster.enemy_scene = Caster
	caster.count = 1
	wave.spawn_entries.append(caster)
	controller.waves = [wave]
	controller.max_active_enemies = 4 if with_spitter else 3
	controller.auto_start = false
	controller.inter_wave_delay = .5
	controller.gated_wave_numbers = []
	stage.set_script(TrialFlow)
	stage.player = player
	stage.combat_hud = hud
	stage.character_menu = menu
	stage.encounter_controller = controller
	stage.get_node("UI/StageTitle").hide()
	return stage
