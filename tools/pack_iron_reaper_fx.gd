extends SceneTree

func _initialize() -> void:
	var result := preload("res://tools/build_iron_reaper_fx.gd").build()
	print("IRON_REAPER_FX_PACK result=",result)
	quit(0 if result==OK else 1)
