extends Node

const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const RewardChestScene = preload("res://gameplay/loot/stage_reward_chest.tscn")
const NEXT_STAGE_PATH := "res://levels/stage_6/stage_6.tscn"
const ExpeditionFeedbackScript = preload("res://ui/expeditions/expedition_feedback.gd")
const ExpeditionRoute = preload("res://data/expeditions/dead_forest.tres")
var expedition_feedback: Node

const ExpeditionDefeatReturnScript = preload(
	"res://gameplay/expeditions/expedition_defeat_return.gd"
)

@export var player: Player
@export var boss: Stage5Boss
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var boss_hud: BossHealthHUD
@export var boss_trigger: Area2D
@export var portal_parent: Node2D
@export var portal_spawn_point: Marker2D
@export var reward_parent: Node2D
@export var stage_loot_table: LootTableDefinition
@export var dialogue_panel: DialoguePanel
@export var boss_portrait: Texture2D
@export var king_portrait: Texture2D
@export var boss_music: AudioStream
@export var entrance_descent: AudioStreamPlayer
@export var entrance_landing: AudioStreamPlayer
@export var approach_encounter: EncounterController
@export var review_hold_approach := false
@export var outdoor_audio: Node2D

var _boss_started := false
var stage_completed := false
var _restart_enabled := false
var _boss_defeat_position := Vector2.ZERO


func _ready() -> void:
	if (
		player == null
		or boss == null
		or combat_hud == null
		or character_menu == null
		or boss_hud == null
		or boss_trigger == null
		or portal_parent == null
		or portal_spawn_point == null
		or reward_parent == null
		or stage_loot_table == null
		or not stage_loot_table.has_valid_layout()
		or dialogue_panel == null
		or boss_portrait == null
		or king_portrait == null
	):
		push_error("Stage5Flow is missing a required dependency.")
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.begin_expedition()
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	expedition_feedback = ExpeditionFeedbackScript.install(self, ExpeditionRoute)
	player.defeated.connect(_on_player_defeated)
	boss.health_component.died.connect(_on_boss_died)
	boss.target = null
	boss.health_component.is_damage_immune = true
	boss.set_physics_process(false)
	boss.visible = false
	boss_trigger.body_entered.connect(_on_boss_trigger_entered)
	combat_hud.show_story_message("STAGE V  •  THE DEAD FOREST", 3.0)
	if approach_encounter != null:
		approach_encounter.stage_cleared.connect(_on_approach_cleared)
		if not review_hold_approach:
			_start_approach()


func _start_approach() -> void:
	await get_tree().create_timer(2.0).timeout
	if not player.is_defeated: approach_encounter.start_encounter()


func _on_approach_cleared() -> void:
	combat_hud.show_story_message("THE SENTRIES FALL · REACH THE NORTHERN BASIN",3.0)
	# Crossing the basin during the guard fight must not require leaving/reentering.
	if boss_trigger.overlaps_body(player): _on_boss_trigger_entered(player)


func _on_boss_trigger_entered(body: Node2D) -> void:
	if _boss_started or body != player or player.is_defeated:
		return
	if approach_encounter != null and not approach_encounter._completion_spawned:
		return
	_boss_started = true
	boss_trigger.set_deferred("monitoring", false)
	_run_boss_entrance()


func _run_boss_entrance() -> void:
	if dialogue_panel == null or boss_portrait == null or boss_music == null or entrance_descent == null or entrance_landing == null:
		push_error("Stage5Flow is missing an entrance presentation dependency: dialogue=%s portrait=%s music=%s descent=%s landing=%s" % [dialogue_panel != null, boss_portrait != null, boss_music != null, entrance_descent != null, entrance_landing != null])
		return
	combat_hud.show_story_message("THE GROVE HOLDS ITS BREATH", 1.0)
	await get_tree().create_timer(0.65).timeout
	boss.visible = true
	entrance_descent.play()
	var visual := boss.get_node_or_null("Visual")
	if visual != null:
		visual.call("set_jump_height", 158.0)
		var descent := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		descent.tween_method(func(height: float) -> void: visual.call("set_jump_height", height), 158.0, 0.0, 0.62)
		await descent.finished
	entrance_landing.play()
	boss.play_entrance_landing()
	await get_tree().create_timer(0.22).timeout
	dialogue_panel.dialogue_closed.connect(_on_boss_dialogue_closed, CONNECT_ONE_SHOT)
	dialogue_panel.show_conversation(
		[
			{
				"speaker": "VARKUUN, LORD OF THE WITHERED GROVE",
				"text": "Do you feel it, mortal? The grove is holding its breath. It knows its lord.",
				"portrait": boss_portrait,
			},
			{
				"speaker": "KING",
				"text": "A lord does not butcher what he swore to protect.",
				"portrait": king_portrait,
			},
			{
				"speaker": "VARKUUN, LORD OF THE WITHERED GROVE",
				"text": "I was crown and claw before your bloodline learned fear. Every root beneath you already closes around your grave.",
				"portrait": boss_portrait,
			},
			{
				"speaker": "KING",
				"text": "Then you are not its lord. You are its last disease.",
				"portrait": king_portrait,
			},
			{
				"speaker": "VARKUUN, LORD OF THE WITHERED GROVE",
				"text": "Fear me, little king. Kneel before Varkuun—or be rooted beneath my throne.",
				"portrait": boss_portrait,
			},
			{
				"speaker": "KING",
				"text": "Good. I was getting tired of chasing gods.",
				"portrait": king_portrait,
			},
		]
	)
	if DisplayServer.get_name() == "headless":
		dialogue_panel.close_dialogue(true)


func _on_boss_dialogue_closed(_completed: bool) -> void:
	expedition_feedback.boss_started()
	boss.health_component.is_damage_immune = false
	if outdoor_audio != null: outdoor_audio.set_combat_active(true)
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.play_music(boss_music, -7.0)
	boss.target = player
	boss.set_physics_process(true)
	boss_hud.bind_boss(boss.health_component, "VARKUUN, LORD OF THE WITHERED GROVE", "DEAD FOREST")
	combat_hud.show_story_message("THE WITHERED GROVE ANSWERS", 2.0)


func _on_boss_died() -> void:
	expedition_feedback.boss_defeated()
	if outdoor_audio != null: outdoor_audio.set_combat_active(false)
	_boss_defeat_position = boss.global_position
	combat_hud.show_story_message("THE LORD REFUSES TO FALL", 1.6)
	dialogue_panel.dialogue_closed.connect(
		_on_boss_defeat_dialogue_closed,
		CONNECT_ONE_SHOT
	)
	dialogue_panel.show_conversation([
		{
			"speaker": "VARKUUN, LORD OF THE WITHERED GROVE",
			"text": "Impossible... I am the grove's root. Its crown.",
			"portrait": boss_portrait,
		},
		{
			"speaker": "VARKUUN, LORD OF THE WITHERED GROVE",
			"text": "If I fall... what will answer the hunger beneath?",
			"portrait": boss_portrait,
		},
		{
			"speaker": "KING",
			"text": "Then let the forest breathe—and face whatever comes next.",
			"portrait": king_portrait,
		},
	])


func _on_boss_defeat_dialogue_closed(_completed: bool) -> void:
	_finish_boss_defeat_presentation()


func _finish_boss_defeat_presentation() -> void:
	# Let Varkuun's complete collapse, corpse hold, and synchronized fade resolve
	# before the reward replaces his silhouette at the same world position.
	await get_tree().create_timer(2.2).timeout
	combat_hud.show_story_message("VARKUUN FALLS  •  CLAIM THE LORD'S HOARD", 3.0)
	_spawn_reward_chest()


func _spawn_reward_chest() -> void:
	var chest := RewardChestScene.instantiate() as StageRewardChest
	chest.configure(stage_loot_table, StageRewardChest.ChestTier.VARKUUN_CHEST)
	reward_parent.add_child(chest)
	chest.global_position = _boss_defeat_position
	chest.proximity_changed.connect(combat_hud.show_interaction_prompt)
	chest.reward_claimed.connect(_on_reward_claimed, CONNECT_ONE_SHOT)


func _on_reward_claimed(_result: Dictionary) -> void:
	var enemy_memory := get_node_or_null("/root/EnemyMemory")
	if enemy_memory != null:
		enemy_memory.record_defeat(&"varkuun")
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.remember_story(&"forest_stage_5_cleared")
		story_state.record_boss_victory(&"stage_5_boss")
		story_state.record_discovery(&"dead_forest")
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.save_profile()
	combat_hud.show_story_message("THE LORD'S SEAL IS YOURS  •  THE DEAD FOREST FALLS SILENT", 3.2)
	_spawn_forward_portal()
	stage_completed = true
	expedition_feedback.boss_reward_claimed()


func _spawn_forward_portal() -> void:
	var portal := PortalScene.instantiate() as StagePortal
	portal.target_scene_path = NEXT_STAGE_PATH
	portal.portal_tier = StagePortal.PortalTier.NORMAL
	portal_parent.add_child(portal)
	portal.global_position = _boss_defeat_position
	portal.proximity_changed.connect(combat_hud.show_interaction_prompt)


func _unhandled_input(event: InputEvent) -> void:
	if not _restart_enabled or not event.is_action_pressed("arena_restart"):
		return
	ExpeditionDefeatReturnScript.request(self)


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_restart_enabled = true
