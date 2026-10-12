extends SceneTree

const NUMBER = preload("res://ui/world/damage_number.tscn")
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var normal: DamageNumber = NUMBER.instantiate()
	normal.configure(248.0,Color.WHITE)
	root.add_child(normal)
	var critical: DamageNumber = NUMBER.instantiate()
	critical.configure(248.0,Color(1.0,.28,.30),24.0,true)
	root.add_child(critical)
	await process_frame
	check(normal.label.text == "248", "Normal damage label changed")
	check(critical.label.text == "CRIT 248", "Critical indicator missing")
	check(critical.label.label_settings != normal.label.label_settings, "Critical font settings mutate the shared normal resource")
	check(critical.label.label_settings.font_size > normal.label.label_settings.font_size, "Critical font-size override is hidden by LabelSettings")
	check(critical.label.get_minimum_size().y > normal.label.get_minimum_size().y, "Critical digits do not render taller")
	check(absf(critical.label.position.x+critical.label.size.x*.5)<1.0, "Critical label is not centered over the contact")
	print("CRITICAL_NUMBER_METRICS normal_font=%d critical_font=%d normal_height=%s critical_height=%s" % [normal.label.label_settings.font_size,critical.label.label_settings.font_size,normal.label.get_minimum_size().y,critical.label.get_minimum_size().y])
	normal.queue_free()
	critical.queue_free()
	await process_frame
	print("CRITICAL_NUMBER_READABILITY checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
