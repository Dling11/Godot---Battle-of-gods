extends SceneTree

## Non-saving motion study. No Player, combat, inventory or damage authority.
const SOURCE := "res://art_source/generated/characters/king/iron_reaper_side_preview_2026_10_14/preview/"
const LARGE_SOURCE := "res://art_source/generated/characters/king/iron_reaper_oversized_preview_2026_10_14/preview/"
const OUTPUT := "res://tmp/review/iron_reaper_2026_10_14/native/"
const LARGE_OUTPUT := "res://tmp/review/iron_reaper_oversized_2026_10_14/native/"
const ACTIONS := ["sweep", "return", "spin", "reap"]
const NAMES := ["BROAD SWEEP", "RETURN HOOK", "SPINNING CUT", "FINISHING REAP"]
const DURATIONS := [
	[.09, .09, .10, .03, .04, .07, .07, .06],
	[.06, .06, .06, .03, .04, .08, .10, .12],
	[.08, .07, .07, .07, .07, .07, .08, .11],
	[.08, .12, .12, .03, .05, .06, .08, .12],
]
const FINISH_ORDER := [0, 1, 2, 3, 4, 5, 7, 6]
var actors: Array[Sprite2D] = []
var effects: Array[Sprite2D] = []
var atlases: Array[Texture2D] = []
var effect_atlas: Texture2D
var pose_textures: Array[Texture2D] = []
var effect_textures: Array[Texture2D] = []
var status: Label
var comparison: Sprite2D
var cell := Vector2i(256, 224)
var sole := 164
var oversized := false
var output_path := OUTPUT
var elapsed := 0.0
var playing := true
var show_effects := true
var speed := 1.0
var action := 0
var key := 0
var capture := false
var capture_index := 0
var visited: Dictionary = {}

func _initialize() -> void:
	call_deferred("_setup")

func _setup() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960, 600)
	root.content_scale_size = root.size
	root.title = "Battle of Gods — Iron Reaper / Side Motion Preview"
	Engine.max_fps = 60
	RenderingServer.set_default_clear_color(Color("202b33"))
	capture = "--capture" in OS.get_cmdline_user_args()
	oversized = _variant_ready(LARGE_SOURCE) and not "--original" in OS.get_cmdline_user_args()
	output_path = LARGE_OUTPUT if oversized else OUTPUT
	_load_variant()
	_title("IRON REAPER  /  SIDE COMBO STUDY", Vector2(24, 18), 24)
	_title("Fresh complete poses · proposed animation speed · gameplay unchanged", Vector2(24, 52), 16)
	_title("RIGHT", Vector2(110, 110), 18)
	_title("LEFT / EXACT MIRROR", Vector2(590, 110), 18)
	for index in 2:
		var rig := Node2D.new()
		rig.position = Vector2(245 + 470 * index, 335)
		rig.scale = Vector2(1.5 if index == 0 else -1.5, 1.5)
		root.add_child(rig)
		var fx := Sprite2D.new()
		fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		rig.add_child(fx)
		effects.append(fx)
		var actor := Sprite2D.new()
		actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		actor.centered = false
		actor.position = Vector2(-cell.x * .5, -sole)
		rig.add_child(actor)
		actors.append(actor)
	status = _title("", Vector2(24, 415), 20)
	_title("APPROVED KING SCALE / native gameplay size", Vector2(24, 448), 14)
	var reference := Sprite2D.new()
	reference.texture = ImageTexture.create_from_image(Image.load_from_file("res://art_source/reference/characters/king/body_library_v1/right_ready.png"))
	reference.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	reference.scale = Vector2.ONE * .5
	reference.position = Vector2(85, 505)
	root.add_child(reference)
	comparison = Sprite2D.new()
	comparison.texture = pose_textures[0]
	comparison.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	comparison.centered = false
	comparison.position = Vector2(180 - cell.x * .25, 520 - sole * .5)
	comparison.scale = Vector2.ONE * .5
	root.add_child(comparison)
	_title("Reference", Vector2(52, 548), 12)
	_title("Scythe study", Vector2(150, 548), 12)
	_title("Space pause · arrows step · 1–4 cuts · Tab effects · S half speed · Esc close", Vector2(300, 468), 14)
	_title("V compare sizes · Motion preview only; scythe is not equipped in F5/F7.", Vector2(300, 493), 14)
	root.window_input.connect(_input_event)
	_present()
	if "--verify-controls" in OS.get_cmdline_user_args():
		_verify_controls()
		return
	if capture:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path))
		_capture()
	else:
		process_frame.connect(_tick)
	print("IRON_REAPER_REVIEW_READY complete_poses=32 mirrored=true gameplay=false")

func _tick() -> void:
	if playing:
		elapsed = fmod(elapsed + root.get_process_delta_time() * speed, _cycle())
		_sample()
	_present()

func _load_variant() -> void:
	var path: String = LARGE_SOURCE if oversized else SOURCE
	root.title = "Battle of Gods — Iron Reaper / " + ("Oversized" if oversized else "Original") + " Side Preview"
	var registration: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path + "registration.json"))
	cell = Vector2i(registration.cell[0], registration.cell[1])
	sole = int(registration.sole)
	atlases.clear()
	pose_textures.clear()
	effect_textures.clear()
	for name in ACTIONS:
		atlases.append(ImageTexture.create_from_image(Image.load_from_file(path + name + ".png")))
	effect_atlas = ImageTexture.create_from_image(Image.load_from_file(path + "slash.png"))
	for atlas in atlases:
		for frame in 8: pose_textures.append(_region(atlas, frame, 4))
	for frame in 16: effect_textures.append(_region(effect_atlas, frame, 4))
	for actor in actors: actor.position = Vector2(-cell.x * .5, -sole)
	if comparison:
		comparison.texture = pose_textures[0]
		comparison.position = Vector2(180 - cell.x * .25, 520 - sole * .5)

func _variant_ready(path: String) -> bool:
	if not FileAccess.file_exists(path + "registration.json"): return false
	var metadata = JSON.parse_string(FileAccess.get_file_as_string(path + "registration.json"))
	if not metadata is Dictionary or int(metadata.get("failures", 1)) != 0: return false
	if metadata.get("poses", []).size() != 32: return false
	for name in ACTIONS:
		if not FileAccess.file_exists(path + name + ".png"): return false
	return FileAccess.file_exists(path + "slash.png")

func _sample() -> void:
	var time := elapsed - .5
	if time < 0: action = 0; key = 0; return
	for index in 4:
		for frame in 8:
			if time < float(DURATIONS[index][frame]): action = index; key = frame; return
			time -= float(DURATIONS[index][frame])
	action = 0
	key = 0

func _present() -> void:
	var source_key: int = FINISH_ORDER[key] if action == 3 else key
	for index in 2:
		actors[index].texture = pose_textures[action * 8 + source_key]
		var visible := show_effects and key >= 3 and key <= 6 and elapsed >= .5
		effects[index].visible = visible
		if visible:
			effects[index].texture = effect_textures[action * 4 + key - 3]
			effects[index].position = Vector2(0, -22) if action == 2 else Vector2(64 if oversized else 42, -30)
	status.text = ("OVERSIZED  /  " if oversized else "ORIGINAL  /  ") + NAMES[action] + "  /  FRAME " + str(source_key + 1) + "  /  " + ("1x" if speed == 1 else "0.5x") + ("  /  PAUSED" if not playing else "")
	visited[str(action) + "/" + str(source_key)] = true

func _region(atlas: Texture2D, frame: int, columns: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = Rect2(Vector2i(frame % columns, frame / columns) * cell, cell)
	texture.filter_clip = true
	return texture

func _cycle() -> float:
	var total := 1.1
	for durations in DURATIONS:
		for value in durations: total += float(value)
	return total

func _input_event(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.keycode:
		KEY_ESCAPE: quit()
		KEY_SPACE: playing = not playing
		KEY_TAB: show_effects = not show_effects
		KEY_S: speed = .5 if speed == 1 else 1.0
		KEY_V:
			if _variant_ready(LARGE_SOURCE):
				oversized = not oversized
				_load_variant()
		KEY_RIGHT: _step(1)
		KEY_LEFT: _step(-1)
		KEY_1, KEY_2, KEY_3, KEY_4:
			action = int(event.keycode - KEY_1)
			key = 0
			playing = false
			_seek()
	_present()

func _step(direction: int) -> void:
	playing = false
	var next := posmod(action * 8 + key + direction, 32)
	action = next / 8
	key = next % 8
	_seek()

func _seek() -> void:
	elapsed = .5001
	for index in action:
		for value in DURATIONS[index]: elapsed += float(value)
	for frame in key: elapsed += float(DURATIONS[action][frame])

func _verify_controls() -> void:
	var verified := 0
	for selected in 4:
		_press(KEY_1 + selected)
		assert(action == selected and key == 0 and not playing)
		verified += 1
		for step in 4: _press(KEY_RIGHT)
		assert(key == 4 and action == selected)
		_press(KEY_LEFT)
		assert(key == 3 and action == selected)
		verified += 2
		_press(KEY_SPACE)
		assert(playing)
		_sample()
		assert(key == 3 and action == selected)
		verified += 2
		for actor in actors:
			var texture: AtlasTexture = actor.texture
			assert(texture.filter_clip and Rect2(Vector2.ZERO, texture.atlas.get_size()).encloses(texture.region))
			verified += 1
		_press(KEY_TAB)
		assert(not show_effects)
		_press(KEY_TAB)
		assert(show_effects)
		_press(KEY_S)
		assert(speed == .5)
		_press(KEY_S)
		assert(speed == 1)
		verified += 4
	assert(actors[0].get_parent().scale.x == -actors[1].get_parent().scale.x)
	assert(actors[0].position == actors[1].position)
	verified += 2
	if _variant_ready(LARGE_SOURCE):
		var original_variant := oversized
		_press(KEY_V)
		assert(oversized != original_variant)
		assert(actors[0].position == Vector2(-cell.x * .5, -sole))
		assert(comparison.texture == pose_textures[0])
		var metadata_path: String = LARGE_SOURCE if oversized else SOURCE
		var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(metadata_path + "registration.json"))
		assert(sole == int(expected.poses[0].sole))
		assert(is_equal_approx(comparison.position.y + sole * comparison.scale.y, 520))
		_press(KEY_V)
		assert(oversized == original_variant)
		verified += 6
	print("IRON_REAPER_CONTROLS checks=", verified, " failures=0")
	quit()

func _press(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	_input_event(event)

func _capture() -> void:
	var frames := ceili(_cycle() * 60)
	for frame in frames:
		elapsed = frame / 60.0
		_sample()
		_present()
		await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(output_path + "frame_%03d.png" % frame)
		if error != OK: push_error("Preview capture failed"); quit(1); return
		capture_index += 1
	FileAccess.open(output_path + "validation.json", FileAccess.WRITE).store_string(JSON.stringify({"frames": capture_index, "fps": 60, "visited_poses": visited.size(), "expected_poses": 32, "oversized": oversized, "scope": "isolated two-facing motion preview, no combat authority"}, "\t") + "\n")
	print("IRON_REAPER_CAPTURE frames=", capture_index, " poses=", visited.size())
	quit(0 if visited.size() == 32 else 1)

func _title(text: String, position: Vector2, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.add_theme_font_size_override("font_size", size)
	root.add_child(label)
	return label
