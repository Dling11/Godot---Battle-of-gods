extends Node

const ExpeditionFeedbackScript = preload("res://ui/expeditions/expedition_feedback.gd")
const ExpeditionRoute = preload("res://data/expeditions/rootbound_hollow.tres")
var expedition_feedback: Node

const ExpeditionDefeatReturnScript = preload(
	"res://gameplay/expeditions/expedition_defeat_return.gd"
)

@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var encounter_controller: EncounterController
@export var dialogue_panel: DialoguePanel
@export var rootbound_husk_portrait: Texture2D
@export var review_hold_encounter := false

var _restart_enabled := false


func _ready() -> void:
	if player == null or combat_hud == null or character_menu == null or encounter_controller == null or dialogue_panel == null:
		push_error("Stage3Flow requires Player, CombatHUD, CharacterMenu, EncounterController, and DialoguePanel.")
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.begin_expedition()
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	expedition_feedback = ExpeditionFeedbackScript.install(self, ExpeditionRoute)
	player.defeated.connect(_on_player_defeated)
	encounter_controller.stage_cleared.connect(_on_stage_cleared)
	encounter_controller.inter_wave_gate_requested.connect(_on_inter_wave_gate_requested)
	_begin_stage()


func _begin_stage() -> void:
	if review_hold_encounter:
		return
	combat_hud.show_story_message("STAGE III  •  THE ROOTBOUND HOLLOW", 2.5)
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(encounter_controller):
		encounter_controller.start_encounter()


func _on_inter_wave_gate_requested(next_wave_number: int) -> void:
	if next_wave_number != 2:
		encounter_controller.release_inter_wave_gate()
		return
	dialogue_panel.dialogue_closed.connect(_on_husk_dialogue_closed, CONNECT_ONE_SHOT)
	dialogue_panel.show_dialogue(
		"ROOTBOUND HUSK",
		[
			"Ten rootlings severed. Ten young voices returned to the soil." if encounter_controller.waves[0].rootling_count == 10 else "%d rootlings severed. Their voices returned to the soil." % encounter_controller.waves[0].rootling_count,
			"The roots remember every trespass, little wanderer.",
			"Kneel. The Hollow hungers—and I will feed it your bones.",
		],
		rootbound_husk_portrait
	)


func _on_husk_dialogue_closed(_completed: bool) -> void:
	encounter_controller.release_inter_wave_gate()


func _unhandled_input(event: InputEvent) -> void:
	if _restart_enabled and event.is_action_pressed("arena_restart"):
		ExpeditionDefeatReturnScript.request(self)


func _on_stage_cleared() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.remember_story(&"rootbound_hollow_completed")
		story_state.record_boss_victory(&"rootbound_husk")
		story_state.record_discovery(&"rootbound_hollow")
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.save_profile()
	combat_hud.show_story_message("THE HUSK WITHERS  •  THE VEIL YIELDS", 2.8)


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_restart_enabled = true
