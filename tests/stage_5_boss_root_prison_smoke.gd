extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const BossScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")
const PrisonTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_root_prison_sheet_128x112.png")
const ExecutionTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_root_execution_sheet_192x192.png")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var effects := Node2D.new()
	effects.add_to_group("boss_effects")
	root.add_child(effects)
	var player := PlayerScene.instantiate() as Player
	player.global_position = Vector2(360.0, 260.0)
	root.add_child(player)
	var boss := BossScene.instantiate() as Stage5Boss
	boss.target = player
	boss.global_position = Vector2(260.0, 260.0)
	boss.root_wind_up_seconds = 0.05
	boss.root_tracking_seconds = 0.32
	boss.root_escape_seconds = 0.28
	boss.root_execution_seconds = 0.12
	boss.root_recovery_seconds = 0.08
	root.add_child(boss)
	await process_frame
	await physics_frame
	player.health_component.set_maximum_health(600.0, false)
	player.health_component.set_current_health(600.0)
	boss.state = Stage5Boss.State.CHASE

	var execution_events: Array[bool] = []
	boss.root_executed.connect(func(_position: Vector2, hit: bool) -> void: execution_events.append(hit))
	if not (player.ability_3_component as SovereignPursuitComponent).request_cast_at(player.global_position + Vector2(80.0, 0.0), 12.0):
		_fail("Root test could not begin King's movement skill.")
		return
	boss._root_ready = true
	await physics_frame
	if boss.state != Stage5Boss.State.ROOT_WIND_UP:
		_fail("Post-jump root cadence did not enter its wind-up before ordinary melee.")
		return
	await create_timer(boss.root_wind_up_seconds + boss.root_tracking_seconds + 0.04).timeout
	if not player.is_restrained_by(boss):
		_fail("Root warning did not capture the player at the locked foot position.")
		return
	if player.ability_3_component.phase != AbilityComponent.Phase.IDLE:
		_fail("Root capture did not cancel the active movement skill.")
		return
	if boss._root_effect == null or boss._root_effect.global_position.distance_to(player.global_position) > 0.1:
		_fail("Root prison did not lock at the player's foot position.")
		return
	var prison := boss._root_effect.get_node("Prison") as AnimatedSprite2D
	var execution := boss._root_effect.get_node("Execution") as AnimatedSprite2D
	var prompt := boss._root_effect.get_node("StrugglePrompt") as Label
	if not prompt.visible or prompt.text != "MASH DASH / TAP  •  0/5":
		_fail("Captured roots do not show the world-space repeated-input prompt.")
		return
	if prison.sprite_frames.get_frame_count(&"warning") != 2 or prison.sprite_frames.get_frame_count(&"capture") != 2:
		_fail("Root prison lost its authored warning/capture frame ranges.")
		return
	if execution.sprite_frames.get_frame_count(&"execute") != 8:
		_fail("Root execution lost one of its eight chronological frames.")
		return
	if not prison.sprite_frames.get_animation_loop(&"capture"):
		_fail("Captured roots no longer flex between their two living poses.")
		return
	for column in range(8):
		var prison_bounds := PrisonTexture.get_image().get_region(Rect2i(column * 128, 0, 128, 112)).get_used_rect()
		if prison_bounds.size.x > 64 or prison_bounds.size.y > 44:
			_fail("Root prison no longer matches King's compact gameplay scale.")
			return
		var execution_bounds := ExecutionTexture.get_image().get_region(Rect2i(column * 192, 0, 192, 192)).get_used_rect()
		if execution_bounds.position.x < 5 or execution_bounds.end.x > 187:
			_fail("Root execution frame %d contains adjacent-frame edge leakage." % column)
			return
	if player.request_primary_attack() or player.request_ability(1):
		_fail("Rooted player was able to attack or cast a skill.")
		return
	var locked_position := boss._root_effect.global_position
	for press in range(boss.root_break_points):
		if not player.request_evade(Vector2.RIGHT):
			_fail("Dash input did not convert into a root-struggle press.")
			return
		if press == 0 and prompt.text != "MASH DASH / TAP  •  1/5":
			_fail("World-space struggle prompt did not advance with Dash input.")
			return
	if player.is_restrained():
		_fail("Five struggle presses did not break the root prison.")
		return
	player.global_position += Vector2(90.0, 0.0)
	await physics_frame
	if boss._root_effect.global_position != locked_position:
		_fail("Broken root prison followed the escaping player.")
		return
	var health_after_capture := player.health_component.current_health
	await create_timer(boss.root_escape_seconds + boss.root_execution_seconds + 0.08).timeout
	if player.health_component.current_health != health_after_capture or execution_events != [false]:
		_fail("Escaped root execution still damaged the player.")
		return

	player.global_position = Vector2(360.0, 260.0)
	boss.state = Stage5Boss.State.CHASE
	boss._begin_root_prison(player.global_position - boss.global_position)
	await create_timer(boss.root_wind_up_seconds + boss.root_tracking_seconds + 0.04).timeout
	if not player.is_restrained_by(boss):
		_fail("Second root prison did not capture for the failure-path test.")
		return
	var before_execution := player.health_component.current_health
	await create_timer(boss.root_escape_seconds + 0.06).timeout
	if not is_equal_approx(before_execution - player.health_component.current_health, boss.root_execution_damage):
		_fail("Failed escape did not receive exactly the authored 300 execution damage.")
		return
	if player.is_restrained() or execution_events != [false, true]:
		_fail("Execution did not release the restraint or report its hit.")
		return

	# Avoiding the capture through the real dash state is not immunity to the
	# delayed world-locked eruption. Remaining inside its ground core still hits.
	player.health_component.set_current_health(600.0)
	player.global_position = Vector2(360.0, 260.0)
	boss._spawn_root_prison()
	await process_frame
	if not player.evade_component.request_evade(Vector2.RIGHT):
		_fail("Root location-hazard test could not enter the real dash state.")
		return
	boss._lock_root_prison()
	if player.is_restrained_by(boss):
		_fail("Real dash state did not avoid the root's restraint boundary.")
		return
	player.evade_component.cancel_evade()
	var before_location_execution := player.health_component.current_health
	boss._execute_root_prison()
	if not is_equal_approx(before_location_execution - player.health_component.current_health, boss.root_execution_damage):
		_fail("Dash-avoided player remained in the locked root zone but escaped its 300-damage eruption.")
		return
	if execution_events != [false, true, true]:
		_fail("Root location hazard did not report the dash-avoided in-zone execution hit.")
		return

	print("Stage 5 root warning, capture, skill lock, struggle escape, world lock, and in-zone 300-damage execution passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
