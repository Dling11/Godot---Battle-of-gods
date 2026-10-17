extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const PauseMenuScene = preload("res://ui/pause_menu.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").configure_storage_path_for_testing("user://hud_action_controls_smoke.json")
	root.get_node("SaveService").delete_profile()
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var hud := HudScene.instantiate() as CombatHUD
	var pause_menu := PauseMenuScene.instantiate() as PauseMenu
	root.add_child(player)
	root.add_child(hud)
	root.add_child(pause_menu)
	hud.bind_player(player)
	await process_frame

	if hud.options_button.get_node("Keycap").text != "ESC":
		_fail("The pause entry is not the compact Menu action.")
		return
	await process_frame
	var tray := hud.get_node("ActionTray") as Control
	var dash_rect := hud.dash_slot.get_global_rect()
	var skill_rect := hud.get_skill_slot(1).get_global_rect()
	if (
		not tray.get_global_rect().encloses(dash_rect)
		or not tray.get_global_rect().encloses(skill_rect)
		or dash_rect.position.x < skill_rect.end.x
		or hud.dash_slot.size != Vector2(40,40)
		or hud.get_skill_slot(1).size != Vector2(40,40)
		or hud.get_skill_slot(10).visible
		or hud.attack_button.is_visible_in_tree()
		or hud.get_node("EclipseFrame").visible
		or absf(hud.size.y-tray.get_global_rect().end.y-2) > 1
	):
		_fail("Adaptive dock geometry: tray=%s dash=%s skill=%s viewport=%s empty=%s" % [tray.get_global_rect(),dash_rect,skill_rect,hud.size,hud.get_skill_slot(10).visible])
		return
	if hud.get_skill_slot(1).key_label.text != "1" or hud.get_skill_slot(4).key_label.text != "4":
		_fail("HUD action numbering changed the saved skill identities.")
		return
	var dash_sound := player.get_node("PlayerActionSfx/Dash") as AudioStreamPlayer2D
	if dash_sound.stream == null or dash_sound.stream.resource_path != "res://assets/audio/sfx/player_dash_grounded.wav" or dash_sound.stream.get_length() < 0.18 or dash_sound.stream.get_length() > 0.20 or dash_sound.bus != &"SFX":
		_fail("The Space/Dash action is not wired to its grounded SFX cue on the combat bus.")
		return
	var skill_one := hud.get_skill_slot(1)
	hud._on_skill_targeting_started(skill_one.ability_component)
	if skill_one.state_label.text != "AIM  RMB":
		_fail("A targeted skill does not expose its compact right-click cancel hint.")
		return
	hud._on_skill_targeting_ended()
	if skill_one.state_label.text != "READY":
		_fail("Cancelling targeted-skill presentation did not restore its ready state.")
		return

	hud.options_button.pressed.emit()
	if not pause_menu.visible or not paused:
		_fail("The top-right Menu button did not open the shared pause menu.")
		return
	pause_menu.close_menu()

	hud.dash_slot.activation_button.pressed.emit()
	if (
		not player.evade_component.is_dashing()
		or hud.dash_slot.activation_button.disabled
		or hud.dash_slot.state_label.text == "DODGE"
	):
		_fail("The clickable dash HUD control did not start dash and display its cooldown.")
		return
	var denied_actions: Array[StringName] = []
	player.action_denied.connect(func(action: StringName) -> void: denied_actions.append(action))
	hud.dash_slot.activation_button.pressed.emit()
	if denied_actions != [&"dash_cooldown"]:
		_fail("A cooldown Dash tap did not reach the shared denied-action feedback.")
		return
	player.evade_component.cancel_evade()
	if hud.dash_slot.activation_button.disabled or hud.dash_slot.state_label.text != "DODGE":
		_fail("The dash HUD control did not return to Ready after cancellation.")
		return

	var restraint_source := Node.new()
	root.add_child(restraint_source)
	if not player.try_begin_root_restraint(restraint_source, 5):
		_fail("HUD test could not begin the reusable root restraint.")
		return
	if hud.dash_slot.key_label.text != "TAP" or hud.dash_slot.state_label.text != "BREAK 0/5":
		_fail("Root restraint did not convert the visible Dash slot into its tap indicator.")
		return
	for press in range(5):
		hud.dash_slot.activation_button.pressed.emit()
	if player.is_restrained() or hud.dash_slot.key_label.text != "SPACE" or hud.dash_slot.state_label.text != "DODGE":
		_fail("Five visible Dash-slot taps did not restore UI: restrained=%s key=%s state=%s" % [player.is_restrained(), hud.dash_slot.key_label.text, hud.dash_slot.state_label.text])
		return
	player.evade_component._cooldown_time_remaining = 0.6
	hud.dash_slot.show_restraint_progress(5, 5)
	hud.dash_slot.clear_restraint_progress()
	if hud.dash_slot.activation_button.disabled or hud.dash_slot.state_label.text == "DODGE":
		_fail("Clearing restraint presentation discarded the Dash action's real cooldown state.")
		return
	player.evade_component.cancel_evade()

	var debug_event := InputEventAction.new()
	debug_event.action = "debug_max_progression"
	debug_event.pressed = true
	player._unhandled_input(debug_event)
	var skill_two := hud.get_skill_slot(2)
	skill_two.activation_button.pressed.emit()
	if not player.ability_2_component.is_casting() or player.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Clicking a skill HUD slot did not cast only the skill.")
		return

	print("HUD action controls smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
