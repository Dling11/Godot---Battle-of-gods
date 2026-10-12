extends SceneTree

const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const RootlingProfile: DropProfileDefinition = preload(
	"res://data/loot/forest/enemies/rootling_drop_profile.tres"
)
const HuskProfile: DropProfileDefinition = preload(
	"res://data/loot/forest/enemies/rootbound_husk_drop_profile.tres"
)
const HogProfile: DropProfileDefinition = preload(
	"res://data/loot/forest/enemies/armored_hog_drop_profile.tres"
)
const Stage3Table: LootTableDefinition = preload(
	"res://data/loot/forest/stages/stage_3_loot_table.tres"
)
const Stage5Table: LootTableDefinition = preload(
	"res://data/loot/forest/stages/stage_5_loot_table.tres"
)
const ChestScene = preload("res://gameplay/loot/stage_reward_chest.tscn")
const PickupScene = preload("res://gameplay/loot/material_pickup.tscn")
const Stage1Scene = preload("res://levels/test_arena/test_arena.tscn")
const Stage2Scene = preload("res://levels/stage_2/stage_2.tscn")
const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")
const Stage5Scene = preload("res://levels/stage_5/stage_5.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_reset_loot_state()
	var loot_state := root.get_node("LootState")
	var loot_service := root.get_node("LootService")
	var material_inventory := root.get_node("MaterialInventory")
	var recipe_discovery := root.get_node("RecipeDiscovery")

	for material: MaterialDefinition in MaterialCatalog.materials:
		if (
			material.icon == null
			or material.icon.get_width() != 24
			or material.icon.get_height() != 24
		):
			_fail("%s does not own an approved 24x24 runtime icon." % material.display_name)
			return

	var enemy_scene_paths := [
		"res://entities/enemies/mireling/mireling.tscn",
		"res://entities/enemies/rootling/rootling.tscn",
		"res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn",
		"res://entities/enemies/bramble_spitter/bramble_spitter.tscn",
		"res://entities/enemies/rootbound_husk/rootbound_husk.tscn",
		"res://entities/enemies/armored_hog/armored_hog.tscn",
	]
	for scene_path: String in enemy_scene_paths:
		var packed_enemy_scene := load(scene_path) as PackedScene
		var enemy: Node = packed_enemy_scene.instantiate()
		var rewards := enemy.get_node("EnemyRewardComponent") as EnemyRewardComponent
		if rewards.drop_profile == null or not rewards.drop_profile.has_valid_layout():
			_fail("%s has no valid runtime drop profile." % scene_path)
			return
		enemy.free()

	for scene: PackedScene in [Stage1Scene, Stage2Scene]:
		var stage := scene.instantiate()
		var controller := stage.get_node(
			"GameplayServices/EncounterController"
		) as EncounterController
		if (
			controller.completion_reward_mode
				!= EncounterController.CompletionRewardMode.DIRECT_PORTAL
			or controller.reward_chest_scene != null
			or controller.stage_loot_table != null
		):
			_fail("Stage I and II must bank clear loot without spawning chests.")
			return
		stage.free()
	var stage_3 := Stage3Scene.instantiate()
	var stage_3_controller := stage_3.get_node(
		"GameplayServices/EncounterController"
	) as EncounterController
	if (
		stage_3_controller.completion_reward_mode
			!= EncounterController.CompletionRewardMode.STAGE_CHEST
		or stage_3_controller.reward_chest_scene == null
		or stage_3_controller.stage_loot_table != Stage3Table
		or not Stage3Table.has_valid_layout()
		or stage_3_controller.reward_chest_tier
			!= StageRewardChest.ChestTier.ROOTBOUND_RELIQUARY
	):
		_fail("Stage III must use its authored Rootbound Reliquary payout.")
		return
	stage_3.free()
	var stage_5 := Stage5Scene.instantiate()
	if (
		stage_5.get("stage_loot_table") != Stage5Table
		or stage_5.get("king_portrait") == null
		or stage_5.get("reward_parent") == null
	):
		_fail("Stage V did not bind its reward table, King portrait, and Y-sorted chest owner.")
		return
	stage_5.free()

	if (
		RootlingProfile.common_drops.size() != 1
		or RootlingProfile.common_drops[0].chance >= 1.0
		or RootlingProfile.common_drops[0].bad_luck_protection_key.is_empty()
	):
		_fail("Ordinary enemy common materials must be protected percentage rolls.")
		return
	for miss in range(5):
		loot_state.record_bad_luck_result(&"forest_root_fiber_misses", false)
	for miss in range(11):
		loot_state.record_bad_luck_result(
			&"forest_young_heartwood_misses",
			false
		)
	loot_service.configure_seed_for_testing(20260729)
	var rootling_drops: Array[Dictionary] = loot_service.resolve_enemy_drops(
		RootlingProfile
	)
	if (
		_quantity_for(rootling_drops, &"forest_root_fiber") < 1
		or _quantity_for(rootling_drops, &"forest_young_heartwood") != 1
		or loot_state.get_bad_luck_misses(&"forest_young_heartwood_misses") != 0
	):
		_fail("Protected percentage Rootling loot did not resolve at its cap.")
		return
	var husk_drops: Array[Dictionary] = loot_service.resolve_enemy_drops(HuskProfile)
	if (
		_quantity_for(husk_drops, &"forest_husk_heartwood") < 2
		or _quantity_for(husk_drops, &"forest_rootbound_core") < 1
	):
		_fail("The Rootbound Husk did not resolve both guaranteed boss materials.")
		return
	for miss in range(5):
		loot_state.record_bad_luck_result(&"forest_armored_hog_hide_misses", false)
	for miss in range(11):
		loot_state.record_bad_luck_result(&"forest_living_bark_plate_misses", false)
	var hog_drops: Array[Dictionary] = loot_service.resolve_enemy_drops(HogProfile)
	if (
		_quantity_for(hog_drops, &"forest_armored_hog_hide") < 1
		or _quantity_for(hog_drops, &"forest_living_bark_plate") < 1
	):
		_fail("The Armored Hog's protected hide and bark-plate drops did not resolve at their caps.")
		return

	var pickup_stage := Stage1Scene.instantiate()
	var pickup_controller := pickup_stage.get_node(
		"GameplayServices/EncounterController"
	) as EncounterController
	pickup_controller.auto_start = false
	root.add_child(pickup_stage)
	var pickup_player := pickup_controller.player
	var pickup := PickupScene.instantiate() as MaterialPickup
	pickup.auto_collect_delay = 0.01
	pickup.configure(
		MaterialCatalog.find_material(&"forest_root_fiber"),
		1,
		pickup_player
	)
	pickup_controller.actors.add_child(pickup)
	pickup.global_position = pickup_player.global_position + Vector2(120.0, 0.0)
	pickup.begin_pop(Vector2.UP)
	var pickup_deadline := Time.get_ticks_msec() + 2000
	while (
		material_inventory.get_quantity(&"forest_root_fiber") == 0
		and Time.get_ticks_msec() < pickup_deadline
	):
		await process_frame
	if material_inventory.get_quantity(&"forest_root_fiber") != 1:
		_fail("A visible enemy drop did not magnetically auto-collect.")
		return
	if not material_inventory.add_material(
		&"forest_root_fiber",
		material_inventory.MAX_MATERIAL_QUANTITY - 1
	):
		_fail("The capped-pickup fixture could not fill its material stack.")
		return
	var capped_pickup := PickupScene.instantiate() as MaterialPickup
	capped_pickup.auto_collect_delay = 0.01
	capped_pickup.configure(
		MaterialCatalog.find_material(&"forest_root_fiber"),
		2,
		pickup_player
	)
	pickup_controller.actors.add_child(capped_pickup)
	capped_pickup.global_position = pickup_player.global_position + Vector2(20.0, 0.0)
	capped_pickup.begin_pop(Vector2.UP)
	var capped_pickup_deadline := Time.get_ticks_msec() + 2000
	while is_instance_valid(capped_pickup) and Time.get_ticks_msec() < capped_pickup_deadline:
		await process_frame
	if (
		is_instance_valid(capped_pickup)
		or material_inventory.get_quantity(&"forest_root_fiber")
			!= material_inventory.MAX_MATERIAL_QUANTITY
	):
		_fail("A loot pickup remained in the world after reaching a full material stack.")
		return
	pickup_stage.queue_free()
	await process_frame

	_reset_loot_state()
	material_inventory.add_material(&"forest_root_fiber", 5)
	if not loot_service.begin_expedition():
		_fail("LootService could not capture an expedition reward baseline.")
		return
	loot_state.record_bad_luck_result(&"forest_mire_membrane_misses", false)
	loot_service.grant_material(
		MaterialCatalog.find_material(&"forest_mire_resin"),
		2,
		&"enemy_drop"
	)
	if (
		not loot_service.abort_expedition_rewards()
		or material_inventory.get_quantity(&"forest_root_fiber") != 5
		or material_inventory.get_quantity(&"forest_mire_resin") != 0
		or loot_state.get_bad_luck_misses(&"forest_mire_membrane_misses") != 0
	):
		_fail("Abandoning an expedition did not roll uncommitted loot back.")
		return

	_reset_loot_state()
	loot_service.begin_expedition()
	var stage_5_first: Dictionary = loot_service.claim_stage_reward(Stage5Table)
	if (
		not bool(stage_5_first.get("success", false))
		or not bool(stage_5_first.get("first_clear", false))
		or material_inventory.get_quantity(&"forest_varkuun_core") != 2
		or not root.get_node("StoryState").has_key_item(&"forest_core_gear_seal")
		or not root.get_node("StoryState").has_discovery(&"forest_core_gear_crafting")
	):
		_fail("Stage V first clear did not grant two Varkuun Cores and the permanent gear seal.")
		return
	loot_service.begin_expedition()
	var stage_5_replay: Dictionary = loot_service.claim_stage_reward(Stage5Table)
	if (
		not bool(stage_5_replay.get("success", false))
		or bool(stage_5_replay.get("first_clear", true))
		or material_inventory.get_quantity(&"forest_varkuun_core") != 3
		or not (stage_5_replay.get("key_item_ids", PackedStringArray()) as PackedStringArray).is_empty()
	):
		_fail("Stage V replay did not grant exactly one repeat catalyst without repeating the seal.")
		return

	_reset_loot_state()
	material_inventory.apply_debug_testing_preset()
	if not material_inventory.add_material(
		&"forest_varkuun_core",
		material_inventory.MAX_MATERIAL_QUANTITY
			- material_inventory.DEBUG_TEST_MATERIAL_QUANTITY
	):
		_fail("The full Varkuun Core stack fixture could not reach its cap.")
		return
	loot_service.begin_expedition()
	var debug_varkuun_chest := ChestScene.instantiate() as StageRewardChest
	debug_varkuun_chest.configure(
		Stage5Table,
		StageRewardChest.ChestTier.VARKUUN_CHEST
	)
	root.add_child(debug_varkuun_chest)
	await process_frame
	var debug_chest_result := debug_varkuun_chest.claim_for_testing()
	await physics_frame
	if (
		not bool(debug_chest_result.get("success", false))
		or debug_varkuun_chest.chest_sprite.texture != debug_varkuun_chest.open_texture
		or material_inventory.get_quantity(&"forest_varkuun_core")
			!= material_inventory.MAX_MATERIAL_QUANTITY
		or _quantity_for(
			debug_chest_result.get("overflow_materials", []),
			&"forest_varkuun_core"
		) != 2
	):
		_fail("A full material stack blocked or overfilled the production Stage V chest reward.")
		return

	_reset_loot_state()
	loot_service.begin_expedition()
	loot_service.configure_seed_for_testing(91)
	var first_clear: Dictionary = loot_service.claim_stage_reward(Stage3Table)
	if (
		not bool(first_clear.get("success", false))
		or not bool(first_clear.get("first_clear", false))
		or material_inventory.get_quantity(&"forest_root_fiber") < 3
		or material_inventory.get_quantity(&"forest_mire_resin") < 3
		or material_inventory.get_quantity(&"forest_forsaken_cloth") < 2
		or material_inventory.get_quantity(&"forest_barbed_seed") < 2
		or material_inventory.get_quantity(&"forest_weathered_fittings") < 1
		or not (
			first_clear.get("recipe_ids", PackedStringArray())
				as PackedStringArray
		).is_empty()
		or not (
			recipe_discovery.create_snapshot().get(
				"discovered_recipe_ids",
				PackedStringArray()
			) as PackedStringArray
		).is_empty()
		or not loot_state.has_first_clear_claim(Stage3Table.first_clear_claim_id)
		or loot_service.has_active_expedition()
	):
		_fail("Stage III first-clear payout did not commit only its authored materials.")
		return

	var fiber_before_replay: int = material_inventory.get_quantity(&"forest_root_fiber")
	loot_service.begin_expedition()
	loot_service.configure_seed_for_testing(92)
	var replay: Dictionary = loot_service.claim_stage_reward(Stage3Table)
	if (
		not bool(replay.get("success", false))
		or bool(replay.get("first_clear", true))
		or material_inventory.get_quantity(&"forest_root_fiber") < fiber_before_replay + 2
		or not (replay.get("recipe_ids", PackedStringArray()) as PackedStringArray).is_empty()
	):
		_fail("The Stage III replay payout repeated first-clear rewards or omitted guarantees.")
		return

	_reset_loot_state()
	loot_service.begin_expedition()
	var chest := ChestScene.instantiate() as StageRewardChest
	chest.configure(Stage3Table)
	root.add_child(chest)
	await process_frame
	await create_timer(0.4).timeout
	if (
		not chest.get_node("Footprint") is StaticBody2D
		or chest.z_index != 0
		or chest.chest_tier != StageRewardChest.ChestTier.FOREST_CACHE
		or chest.physical_body.collision_layer != 1
	):
		_fail("The ordinary stage chest lacks its colliding Y-sorted footprint.")
		return
	var chest_result := chest.claim_for_testing()
	await physics_frame
	if (
		not bool(chest_result.get("success", false))
		or chest.chest_sprite.texture != chest.open_texture
		or chest.physical_body.collision_layer != 0
		or material_inventory.get_quantity(&"forest_barbed_seed") < 2
	):
		_fail("The reusable Forest Cache tier did not visibly open and grant its table.")
		return

	var reliquary := ChestScene.instantiate() as StageRewardChest
	reliquary.configure(
		Stage3Table,
		StageRewardChest.ChestTier.ROOTBOUND_RELIQUARY
	)
	root.add_child(reliquary)
	await process_frame
	if (
		reliquary.chest_sprite.texture != reliquary.rootbound_closed_texture
		or reliquary.get_display_name() != "ROOTBOUND RELIQUARY"
	):
		_fail("The Rootbound mini-boss chest did not select its distinct tier art.")
		return
	reliquary.queue_free()

	var varkuun_chest := ChestScene.instantiate() as StageRewardChest
	varkuun_chest.configure(
		Stage5Table,
		StageRewardChest.ChestTier.VARKUUN_CHEST
	)
	root.add_child(varkuun_chest)
	await process_frame
	if (
		varkuun_chest.chest_sprite.texture != varkuun_chest.varkuun_closed_texture
		or varkuun_chest.get_display_name() != "VARKUUN'S CHEST"
		or varkuun_chest.interaction_text != "PRESS F TO OPEN VARKUUN'S CHEST"
		or varkuun_chest.varkuun_closed_texture.get_size() != Vector2(74.0, 66.0)
		or varkuun_chest.varkuun_open_texture.get_size() != Vector2(74.0, 66.0)
	):
		_fail("The Stage V major-boss chest did not select its distinct Varkuun tier.")
		return
	varkuun_chest.queue_free()

	var loot_snapshot: Dictionary = loot_state.create_snapshot()
	loot_state.reset_state()
	if (
		not loot_state.restore_snapshot(loot_snapshot)
		or not loot_state.has_first_clear_claim(Stage3Table.first_clear_claim_id)
	):
		_fail("LootState did not persist and reconstruct stage claims.")
		return

	print("Loot chances, magnetic pickups, chest tiers, rollback, and claim smoke test passed.")
	quit(0)


func _quantity_for(stacks: Array, material_id: StringName) -> int:
	for stack: Dictionary in stacks:
		var material := stack.get("material") as MaterialDefinition
		if material != null and material.material_id == material_id:
			return int(stack.get("quantity", 0))
	return 0


func _reset_loot_state() -> void:
	root.get_node("LootService").reset_expedition_tracking()
	root.get_node("MaterialInventory").reset_inventory()
	root.get_node("RecipeDiscovery").reset_discoveries()
	root.get_node("LootState").reset_state()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
