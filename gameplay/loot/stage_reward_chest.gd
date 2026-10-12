class_name StageRewardChest
extends Area2D

signal reward_claimed(result: Dictionary)
signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)

enum ChestTier {
	FOREST_CACHE,
	ROOTBOUND_RELIQUARY,
	VARKUUN_CHEST,
}

@export var loot_table: LootTableDefinition
@export var chest_sprite: Sprite2D
@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var rootbound_closed_texture: Texture2D
@export var rootbound_open_texture: Texture2D
@export var varkuun_closed_texture: Texture2D
@export var varkuun_open_texture: Texture2D
@export var glow: Polygon2D
@export var visual_root: Node2D
@export var interaction_shape: CollisionShape2D
@export var physical_body: StaticBody2D
@export var physical_shape: CollisionShape2D
@export var spawn_effect: ChestSpawnEffect
@export_enum("Forest Cache", "Rootbound Reliquary", "Varkuun Chest") var chest_tier: int = (
	ChestTier.FOREST_CACHE
)
@export var interaction_text := "PRESS F TO CLAIM REWARD"

var _player_inside := false
var _claimed := false
var _footprint_pending := false


func configure(
	table: LootTableDefinition,
	tier: int = ChestTier.FOREST_CACHE
) -> void:
	loot_table = table
	chest_tier = tier


func _ready() -> void:
	if (
		loot_table == null
		or not loot_table.has_valid_layout()
		or chest_sprite == null
		or closed_texture == null
		or open_texture == null
		or rootbound_closed_texture == null
		or rootbound_open_texture == null
		or varkuun_closed_texture == null
		or varkuun_open_texture == null
		or glow == null
		or visual_root == null
		or interaction_shape == null
		or physical_body == null
		or physical_shape == null
		or spawn_effect == null
	):
		push_error("StageRewardChest requires a valid loot table and chest presentation.")
		queue_free()
		return
	_apply_tier_presentation()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	physical_body.collision_layer = 0
	scale = Vector2(0.68, 0.68)
	visual_root.position.y += 9.0
	var arrival := create_tween().set_parallel()
	arrival.tween_property(self, "scale", Vector2.ONE, 0.28).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	arrival.tween_property(visual_root, "position:y", 0.0, 0.28).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	spawn_effect.play(
		get_tier_accent(),
		chest_tier != ChestTier.FOREST_CACHE
	)
	get_tree().create_timer(0.32).timeout.connect(
		_arm_physical_footprint,
		CONNECT_ONE_SHOT
	)
	var pulse := create_tween().set_loops()
	pulse.tween_property(glow, "modulate:a", 0.42, 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "modulate:a", 0.16, 0.7).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if (
		_claimed
		or not _player_inside
		or not event.is_action_pressed("player_interact")
	):
		return
	get_viewport().set_input_as_handled()
	_claim_reward()


func claim_for_testing() -> Dictionary:
	return _claim_reward()


func _claim_reward() -> Dictionary:
	if _claimed:
		return {"success": false}
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service == null:
		return {"success": false}
	var result: Dictionary = loot_service.claim_stage_reward(loot_table)
	if not bool(result.get("success", false)):
		return result
	_claimed = true
	monitoring = false
	interaction_shape.set_deferred("disabled", true)
	physical_body.set_deferred("collision_layer", 0)
	physical_body.set_deferred("collision_mask", 0)
	_player_inside = false
	proximity_changed.emit(false, "", null)
	chest_sprite.texture = open_texture
	glow.modulate.a = 0.55
	reward_claimed.emit(result)
	var depart := create_tween()
	depart.tween_interval(1.0)
	depart.tween_property(self, "modulate:a", 0.0, 0.3)
	depart.tween_callback(queue_free)
	return result


func get_tier_accent() -> Color:
	if chest_tier == ChestTier.VARKUUN_CHEST:
		return Color(0.58, 0.84, 0.18, 1.0)
	if chest_tier == ChestTier.ROOTBOUND_RELIQUARY:
		return Color(0.67, 0.42, 0.86, 1.0)
	return Color(0.84, 0.68, 0.26, 1.0)


func get_display_name() -> String:
	if chest_tier == ChestTier.VARKUUN_CHEST:
		return "VARKUUN'S CHEST"
	if chest_tier == ChestTier.ROOTBOUND_RELIQUARY:
		return "ROOTBOUND RELIQUARY"
	return "FOREST CACHE"


func _apply_tier_presentation() -> void:
	var footprint := physical_shape.shape.duplicate() as RectangleShape2D
	var interaction := interaction_shape.shape.duplicate() as RectangleShape2D
	if chest_tier == ChestTier.VARKUUN_CHEST:
		closed_texture = varkuun_closed_texture
		open_texture = varkuun_open_texture
		chest_sprite.position.y = -31.0
		glow.position.y = -16.0
		glow.scale = Vector2(1.18, 1.16)
		footprint.size = Vector2(52.0, 16.0)
		interaction.size = Vector2(86.0, 56.0)
		interaction_text = "PRESS F TO OPEN VARKUUN'S CHEST"
	elif chest_tier == ChestTier.ROOTBOUND_RELIQUARY:
		closed_texture = rootbound_closed_texture
		open_texture = rootbound_open_texture
		chest_sprite.position.y = -30.0
		glow.position.y = -16.0
		glow.scale = Vector2(1.15, 1.15)
		footprint.size = Vector2(50.0, 16.0)
		interaction.size = Vector2(82.0, 54.0)
		interaction_text = "PRESS F TO OPEN ROOTBOUND RELIQUARY"
	else:
		chest_sprite.position.y = -20.0
		glow.position.y = -10.0
		footprint.size = Vector2(42.0, 14.0)
		interaction.size = Vector2(72.0, 48.0)
	var glow_color := get_tier_accent()
	glow_color.a = 0.26
	glow.color = glow_color
	physical_shape.shape = footprint
	interaction_shape.shape = interaction
	chest_sprite.texture = closed_texture


func _arm_physical_footprint() -> void:
	if _claimed or not is_inside_tree():
		return
	if _player_inside:
		_footprint_pending = true
		return
	physical_body.collision_layer = 1
	_footprint_pending = false


func _on_body_entered(body: Node2D) -> void:
	if _claimed or not body is Player:
		return
	_player_inside = true
	proximity_changed.emit(true, interaction_text, closed_texture)


func _on_body_exited(body: Node2D) -> void:
	if _claimed or not body is Player:
		return
	_player_inside = false
	proximity_changed.emit(false, "", null)
	if _footprint_pending:
		_arm_physical_footprint()
