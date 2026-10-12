class_name TitleBackground
extends Control

const ART := [
	preload("res://assets/ui/title/trio/a.png"),
	preload("res://assets/ui/title/trio/b.png"),
	preload("res://assets/ui/title/trio/c.png"),
]

var selected_index := -1
@onready var base: TextureRect = $Base
@onready var glimmers: Control = %Glimmers

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	select_art(_pick_art())
	for index in glimmers.get_child_count():
		var glimmer := glimmers.get_child(index) as ColorRect
		# Fixed pixels fade quietly; translating them under pixel snapping reads
		# as jitter and the old loop visibly jumped back to its starting position.
		var tween := create_tween().set_loops()
		tween.tween_interval(index * 0.24)
		tween.tween_property(glimmer, "modulate:a", 0.55, 1.8).from(0.08).set_trans(Tween.TRANS_SINE)
		tween.tween_property(glimmer, "modulate:a", 0.08, 2.0)

func select_art(index: int) -> void:
	selected_index = clampi(index, 0, ART.size() - 1)
	base.texture = ART[selected_index]

func _pick_art() -> int:
	# One cosmetic index prevents a repeat after quitting. Profile-scoped path
	# also isolates review/test storage; no gameplay profile is changed.
	var cache_path: String = get_node("/root/SaveService").get_profile_path().get_basename() + "_title_art.cfg"
	var cache := ConfigFile.new()
	cache.load(cache_path)
	var previous := int(cache.get_value("title", "last", -1))
	var picked := (previous + randi_range(1, 2)) % 3 if previous >= 0 and previous < 3 else randi_range(0, 2)
	cache.set_value("title", "last", picked)
	cache.save(cache_path)
	return picked
