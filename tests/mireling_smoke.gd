extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	var mireling := MirelingScene.instantiate()
	mireling.target = player
	root.add_child(player)
	root.add_child(mireling)
	player.global_position = Vector2(200, 200)
	mireling.global_position = Vector2(222, 200)
	player.set_physics_process(false)
	var mireling_body := mireling.get_node("Visual/Body") as AnimatedSprite2D
	if not is_equal_approx(mireling.definition.attack_damage, 8.0):
		_fail("Mireling must retain the balanced early-stage 8 damage.")
		return
	if mireling_body.sprite_frames.get_animation_names().size() != 16:
		_fail("Mireling SpriteFrames contains obsolete or missing animation groups.")
		return
	for direction_name in [&"down", &"left", &"right", &"up"]:
		var idle_name := StringName("idle_%s" % direction_name)
		var hop_name := StringName("hop_%s" % direction_name)
		var attack_name := StringName("attack_%s" % direction_name)
		var dead_name := StringName("dead_%s" % direction_name)
		if mireling_body.sprite_frames.get_frame_count(idle_name) != 1:
			_fail("Mireling %s must use the approved compact walk model." % idle_name)
			return
		if mireling_body.sprite_frames.get_frame_count(hop_name) != 4:
			_fail("Mireling %s must use a four-frame directional locomotion cycle." % hop_name)
			return
		if mireling_body.sprite_frames.get_frame_count(attack_name) != 4:
			_fail("Mireling %s must use the remodeled four-frame body slam." % attack_name)
			return
		if mireling_body.sprite_frames.get_frame_count(dead_name) != 4:
			_fail("Mireling %s must use the remodeled four-frame collapse." % dead_name)
			return
		if mireling_body.sprite_frames.get_animation_loop(attack_name) or mireling_body.sprite_frames.get_animation_loop(dead_name):
			_fail("Mireling attack and death animations must not loop.")
			return
		if mireling_body.sprite_frames.get_animation_speed(dead_name) < 11.0:
			_fail("Mireling collapse does not finish before gameplay cleanup.")
			return
		var idle_frame := mireling_body.sprite_frames.get_frame_texture(idle_name, 0) as AtlasTexture
		var attack_frame := mireling_body.sprite_frames.get_frame_texture(attack_name, 0) as AtlasTexture
		var dead_frame := mireling_body.sprite_frames.get_frame_texture(dead_name, 0) as AtlasTexture
		if (
			idle_frame == null
			or attack_frame == null
			or dead_frame == null
			or idle_frame.atlas.resource_path != "res://assets/characters/enemies/mireling/mireling_walk_sheet_32x32.png"
			or attack_frame.atlas.resource_path != "res://assets/characters/enemies/mireling/mireling_action_sheet_48x32.png"
			or dead_frame.atlas != attack_frame.atlas
			or attack_frame.region.size != Vector2(48.0, 32.0)
		):
			_fail(
				"Mireling %s mixes sheets: idle=%s attack=%s dead=%s same_action_atlas=%s region=%s"
				% [
					direction_name,
					idle_frame.atlas.resource_path if idle_frame != null else "<null>",
					attack_frame.atlas.resource_path if attack_frame != null else "<null>",
					dead_frame.atlas.resource_path if dead_frame != null else "<null>",
					dead_frame.atlas == attack_frame.atlas if dead_frame != null and attack_frame != null else false,
					attack_frame.region.size if attack_frame != null else Vector2.ZERO,
				]
			)
			return
		var idle_height := idle_frame.get_image().get_used_rect().size.y
		var attack_height := attack_frame.get_image().get_used_rect().size.y
		if idle_height > 18 or absi(idle_height - attack_height) > 1:
			_fail("Mireling remodeled actions do not preserve the smaller 18-pixel body scale.")
			return
	var player_health: HealthComponent = player.get_node("HealthComponent")
	if mireling.state != Mireling.State.SPAWNING:
		_fail("Mireling did not begin with materialization.")
		return
	for frame in range(120): await physics_frame
	if player_health.current_health >= player_health.maximum_health:
		_fail("Mireling body slam did not damage the player.")
		return
	mireling.set_physics_process(false)
	mireling.global_position = Vector2(225, 200)
	player._set_facing_direction(Vector2.RIGHT)
	var mireling_health: HealthComponent = mireling.get_node("HealthComponent")
	var health_before_sword := mireling_health.current_health
	if not player.request_primary_attack():
		_fail("Player attack request was rejected against Mireling.")
		return
	for frame in range(40): await physics_frame
	var dealt_damage := health_before_sword - mireling_health.current_health
	if dealt_damage < 10.0 or dealt_damage > 12.0:
		_fail("King's Ashwood basic attack left its authored 10-12 damage range: %s." % [dealt_damage])
		return
	print("Mireling smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
