extends SceneTree

const BossScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")
const DialogueScene = preload("res://ui/dialogue/dialogue_panel.tscn")
const BossPortrait = preload("res://assets/characters/enemies/portraits/stage_5_boss_portrait_96x96.png")
const KingPortrait = preload("res://assets/characters/playable/king/greatsword/king_greatsword_portrait_96x96.png")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var boss := BossScene.instantiate() as Stage5Boss
	root.add_child(boss)
	await process_frame
	var audio := boss.get_node("BossAudio")
	for player_name in [
		"Step", "Lunge", "Slap", "JumpLaunch", "JumpAir", "JumpImpact",
		"RootPrison", "RootLock", "RootExecutionRumble", "RootExecutionImpact",
		"Hurt", "Phase", "Defeat",
	]:
		var player := audio.get_node_or_null(player_name) as AudioStreamPlayer
		if player == null or player.stream == null or player.bus != &"SFX":
			_fail("Varkuun audio player %s lost its real stream or SFX routing." % player_name)
			return
	boss.root_locked.emit(Vector2.ZERO, true)
	await process_frame
	if not (audio.get_node("RootLock") as AudioStreamPlayer).playing:
		_fail("Root lock did not play its dedicated capture cue.")
		return
	boss.root_executed.emit(Vector2.ZERO, true)
	await process_frame
	if (
		not (audio.get_node("RootExecutionRumble") as AudioStreamPlayer).playing
		or not (audio.get_node("RootExecutionImpact") as AudioStreamPlayer).playing
	):
		_fail("The 300-damage root execution did not play both rumble and impact layers.")
		return
	var health := boss.get_node("HealthComponent") as HealthComponent
	var phase_crossing_raw_damage := (
		health.maximum_health
		* 0.70
		* (100.0 + health.armor_rating)
		/ 100.0
	)
	health.apply_damage(DamageInfo.new(phase_crossing_raw_damage, null, Vector2.ZERO))
	await process_frame
	if not bool(audio.get("_phase_played")):
		_fail("Varkuun's 30-percent phase cue remained coupled to movement instead of accepted damage.")
		return

	var dialogue := DialogueScene.instantiate() as DialoguePanel
	root.add_child(dialogue)
	dialogue.show_dialogue("VARKUUN", ["FIRST", "SECOND", "THIRD"])
	await process_frame
	await process_frame
	var body := dialogue.get_node("Panel/Margin/Root/Text/BodyLabel") as Label
	if body.text != "FIRST":
		_fail("Dialogue did not begin on its first line.")
		return
	var press := InputEventKey.new()
	press.keycode = KEY_SPACE
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventKey.new()
	release.keycode = KEY_SPACE
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	if body.text != "SECOND":
		_fail("One Space press did not advance dialogue by exactly one line (now %s)." % body.text)
		return
	dialogue.close_dialogue(true)
	await process_frame

	var skip_result := [true]
	dialogue.dialogue_closed.connect(
		func(completed: bool) -> void: skip_result[0] = completed,
		CONNECT_ONE_SHOT
	)
	dialogue.show_conversation([
		{"speaker": "VARKUUN", "text": "FEAR ME", "portrait": BossPortrait},
		{"speaker": "KING", "text": "NO", "portrait": KingPortrait},
	])
	await process_frame
	await process_frame
	var speaker := dialogue.get_node("Panel/Margin/Root/Text/Header/SpeakerLabel") as Label
	var portrait := dialogue.get_node("Panel/Margin/Root/Portrait") as TextureRect
	if speaker.text != "VARKUUN" or portrait.texture != BossPortrait:
		_fail("Conversation did not begin with Varkuun's speaker identity and portrait.")
		return
	dialogue.advance()
	if speaker.text != "KING" or portrait.texture != KingPortrait:
		_fail("Conversation did not swap to King's speaker identity and portrait.")
		return
	var skip := dialogue.get_node("Panel/Margin/Root/Text/Header/SkipButton") as Button
	skip.pressed.emit()
	await process_frame
	if dialogue.visible or paused or bool(skip_result[0]):
		_fail("Mouse Skip did not close the conversation as an incomplete cinematic.")
		return

	dialogue.queue_free()
	boss.queue_free()
	await process_frame
	await process_frame
	print("Varkuun action/root audio, speaker-swapping conversation, single advance, and mouse Skip passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
