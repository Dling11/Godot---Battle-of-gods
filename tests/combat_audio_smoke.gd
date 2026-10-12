extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const ThrallScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")
const SpitterScene = preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn")
const ImpactScene = preload("res://gameplay/projectiles/bramble_seed_impact.tscn")
const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")
const PlayerDashGrounded = preload("res://assets/audio/sfx/player_dash_grounded.wav")
const EarthsplitterVisual = preload("res://gameplay/abilities/king/earthsplitter_visual.gd")
const MoltenCrashVisual = preload("res://gameplay/abilities/king/molten_crash_visual.gd")
const PlayerHurtImpact = preload("res://assets/audio/sfx/player_hurt_impact.wav")
const PlayerActionDenied = preload("res://assets/audio/sfx/ui/player_action_denied.mp3")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	if AudioServer.get_bus_index("Music") < 0 or AudioServer.get_bus_index("SFX") < 0 or AudioServer.get_bus_index("UI") < 0:
		_fail("AudioDirector did not create the Music, SFX, and UI buses.")
		return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	var player_sfx := player.get_node("PlayerActionSfx") as PlayerActionSfx
	if (
		not _valid_sfx_player(player_sfx.sword_swing_player)
		or not _valid_sfx_player(player_sfx.dash_player)
		or not _valid_sfx_player(player_sfx.sovereign_pursuit_launch_player)
		or not _valid_sfx_player(player_sfx.sovereign_pursuit_landing_player)
		or not _valid_sfx_player(player_sfx.skill_4_formation_player)
		or not _valid_sfx_player(player_sfx.skill_4_first_impact_player)
		or not _valid_sfx_player(player_sfx.skill_4_explosion_player)
		or not _valid_sfx_player(player_sfx.action_denied_player)
		or EarthsplitterVisual.Impact == null or EarthsplitterVisual.Swing == null
		or MoltenCrashVisual.Impact == null or MoltenCrashVisual.Swing == null
	):
		_fail("King's attack, four skills, dash, and denied-action SFX are not fully assigned to the SFX bus.")
		return
	if player_sfx.dash_player.stream != PlayerDashGrounded or player_sfx.dash_player.volume_db > -11.0:
		_fail("Player dash does not use the accepted grounded swoosh at a safe volume.")
		return
	if player_sfx.action_denied_player.stream != PlayerActionDenied:
		_fail("Cooldown rejection does not use the dedicated real CC0 denied-action recording.")
		return
	var denied_actions: Array[StringName] = []
	player.action_denied.connect(func(action: StringName) -> void: denied_actions.append(action))
	if not player.request_ability(2) or player.request_ability(2) or denied_actions != [&"skill_cooldown"]:
		_fail("Repeated skill input did not emit exactly one shared cooldown-denied request.")
		return
	player.ability_2_component.cancel_cast()
	player.ability_2_component.clear_cooldown()
	if not player.request_evade(Vector2.RIGHT) or player.request_evade(Vector2.RIGHT) or denied_actions != [&"skill_cooldown", &"dash_cooldown"]:
		_fail("Repeated Dash input did not emit the shared cooldown-denied request.")
		return
	player.evade_component.cancel_evade()

	var thrall := ThrallScene.instantiate() as ForsakenThrall
	var mireling := MirelingScene.instantiate() as Mireling
	var spitter := SpitterScene.instantiate() as BrambleSpitter
	for enemy in [thrall, mireling, spitter]:
		root.add_child(enemy)
	var thrall_sfx := thrall.get_node("ActionSfx") as ActorActionSfx
	var mireling_sfx := mireling.get_node("ActionSfx") as ActorActionSfx
	var spitter_sfx := spitter.get_node("ActionSfx") as ActorActionSfx
	if not _valid_sfx_player(thrall_sfx.primary_player) or thrall_sfx.primary_state != ForsakenThrall.State.ACTIVE:
		_fail("Thrall claw SFX is not synchronized with its active attack state.")
		return
	if not _valid_sfx_player(mireling_sfx.primary_player) or not _valid_sfx_player(mireling_sfx.secondary_player):
		_fail("Mireling leap and landing SFX are not configured.")
		return
	if mireling_sfx.primary_state != Mireling.State.LEAP or mireling_sfx.secondary_state != Mireling.State.ACTIVE:
		_fail("Mireling SFX states do not match leap and landing authority.")
		return
	if not _valid_sfx_player(spitter_sfx.primary_player):
		_fail("Bramble Spitter firing SFX is not configured.")
		return

	var impact := ImpactScene.instantiate()
	root.add_child(impact)
	var impact_player := impact.get_node("ImpactSfx") as AudioStreamPlayer2D
	if not _valid_sfx_player(impact_player):
		_fail("Bramble seed impact SFX is not configured.")
		return
	var arena := ArenaScene.instantiate()
	var feedback := arena.get_node("GameplayServices/CombatFeedback") as CombatFeedbackPresenter
	if (
		feedback.sword_hit_sound == null
		or feedback.ability_hit_sound == null
		or feedback.player_hurt_sound == null
	):
		_fail("Accepted sword/ability hits and player-damage SFX are not configured in the arena.")
		return
	if feedback.player_hurt_sound != PlayerHurtImpact or feedback.player_hurt_sound == thrall_sfx.primary_player.stream:
		_fail("Player damage does not use a distinct impact sound.")
		return
	arena.free()
	print("Combat audio smoke test passed.")
	quit(0)


func _valid_sfx_player(player: AudioStreamPlayer2D) -> bool:
	return player != null and player.stream != null and player.bus == &"SFX"


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
