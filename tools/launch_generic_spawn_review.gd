extends "res://tools/launch_enemy_arrival_review.gd"

const GenericArrival := preload("res://gameplay/presentation/generic_enemy_arrival.gd")
const FOES := [
	{"name": "Small: Rootling", "tag": "rootling", "scene": preload("res://entities/enemies/rootling/rootling.tscn")},
	{"name": "Tall: Thrall", "tag": "thrall", "scene": preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")},
	{"name": "Large: Crag Bear", "tag": "bear", "scene": preload("res://entities/enemies/crag_bear/crag_bear.tscn")},
	{"name": "Miniboss: Husk", "tag": "husk", "scene": preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn")}
]
const GENERIC_EVIDENCE := "res://tmp/review/encounters/generic_spawn_2026_10_03/"
var _foe_index := 0
var _dark_ground := false
var _last_count := 1
var _rebuilding := false
var foe_picker: OptionButton

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://generic_spawn_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()
	if "--capture-generic" in OS.get_cmdline_user_args():
		await _capture_generic()
		quit()

func open_review() -> void:
	await super.open_review()
	var effect := GenericArrival.new()
	var packed := PackedScene.new()
	assert(packed.pack(effect) == OK)
	effect.free()
	stage.encounter_controller.summon_effect_scene = packed
	stage.encounter_controller.offsets = [Vector2(150,80),Vector2(220,120),Vector2(90,150),Vector2(-120,70),Vector2(-130,-40),Vector2(20,-160),Vector2(200,-150),Vector2(-190,-140)]
	_visit(Vector2(1040,480) if _dark_ground else Vector2(520,480))
	root.title = "Battle of Gods — ONE Universal Spawn (NO SAVES / REWARDS)"
	var column: VBoxContainer = toolbar.get_child(0)
	var heading: Label = column.get_child(0)
	heading.text = "ONE SHARED MOB SPAWN\nSame four drawings · every size\nWASD · skills · Tab bag · Esc pause"
	foe_picker = OptionButton.new()
	foe_picker.focus_mode = Control.FOCUS_NONE
	foe_picker.add_theme_font_size_override("font_size",11)
	for foe: Dictionary in FOES: foe_picker.add_item(foe.name)
	foe_picker.select(_foe_index)
	foe_picker.item_selected.connect(_choose_foe)
	column.add_child(foe_picker)
	column.move_child(foe_picker,1)
	_batch_buttons[0].text = "Spawn selected foe"
	_button(column,"Replay same batch",_replay)
	_button(column,"Ground: dark" if _dark_ground else "Ground: grass",_change_ground)

func _spawn_batch(count: int) -> void:
	_last_count = count
	if count != 1:
		super._spawn_batch(count)
		return
	for button in _batch_buttons: button.disabled = true
	stage.encounter_controller._spawn_enemy(FOES[_foe_index].scene)

func _choose_foe(index: int) -> void:
	_foe_index = index
	_last_count = 1
	await _replay()

func _change_ground() -> void:
	_dark_ground = not _dark_ground
	await _replay()

func _replay() -> void:
	await reset_review()
	_spawn_batch(_last_count)

func reset_review() -> void:
	_rebuilding = true
	await super.reset_review()
	_rebuilding = false

func _capture_generic() -> void:
	root.size = Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(GENERIC_EVIDENCE))
	await _save_capture("controls.png")
	for index in FOES.size():
		_foe_index = index
		for dark in [false,true]:
			_dark_ground = dark
			await reset_review()
			toolbar.hide()
			_spawn_batch(1)
			for spec in [["warning",.12],["burst",.26],["formed",.88]]:
				await create_timer(spec[1],false).timeout
				await _save_capture(FOES[index].tag+("_dark_" if dark else "_grass_")+spec[0]+".png")

func _save_capture(file: String) -> void:
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(GENERIC_EVIDENCE+file) == OK)
