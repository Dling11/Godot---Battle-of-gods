extends Node

## Trial root replaces campaign flow before tree entry; no story/save/loot hooks.
@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var encounter_controller: EncounterController

func _ready() -> void:
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	combat_hud.show_story_message("ROTCaller TRIAL · HIT TO INTERRUPT OR LEAVE THE RING",3.0)
