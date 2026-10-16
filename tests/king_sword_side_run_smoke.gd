extends "res://tests/king_production_art_contract.gd"

const RUN = preload("res://assets/characters/playable/king/sword_unified/side/run.tres")
const AUDIT = "res://art_source/reference/characters/king/sword-side-run.json"

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var audit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(AUDIT))
	check(audit.decision == 224 and audit.frames.size() == 8, "Missing complete side-running cycle")
	check(FileAccess.get_sha256("res://"+str(audit.runtime.atlas)) == audit.runtime.atlas_sha256, "Installed running art differs from reviewed packing")
	check(FileAccess.get_sha256("res://"+str(audit.runtime.resource)) == audit.runtime.resource_sha256, "Running grip/phase data differs from packing")
	verify_complete_clip(RUN,Vector2i(256,256))
	check(RUN.weapon_texture.get_size() == Vector2(20,80) and RUN.weapon_primary_grip == Vector2(10,66), "Running loses the full-size sword or grips the pommel end")
	var minimum := Vector2(INF,INF)
	var maximum := Vector2(-INF,-INF)
	var unique := {}
	var image: Image = RUN.body_atlas.get_image()
	for key in 8:
		var palm: Vector2 = RUN.primary_hands[key]
		minimum = minimum.min(palm)
		maximum = maximum.max(palm)
		var axis: Vector2 = (palm-RUN.secondary_hands[key]).normalized()
		check(absf(axis.angle()-deg_to_rad(-10)) < .001, "Sword wags instead of staying in its lower compact guard")
		var cell := image.get_region(Rect2i(Vector2i(key%4,key/4)*256,Vector2i(256,256)))
		var glove := cell.get_pixelv(Vector2i(palm))
		check(glove.a > .9 and glove.r > glove.g*1.3 and glove.g > glove.b*1.2, "Sword grip misses the complete brown glove")
		verify_visible_hilt(cell,palm)
		check(cell.get_used_rect().position.y in [99,100], "Running shifts the whole crown/neck")
		var body: Array = audit.frames[key].body_bounds
		check(int(body[3]) >= 54 and int(body[3]) <= 59 and int(body[1])+int(body[3]) <= 158, "Whole actor scale or ground origin changed")
		unique[str(audit.frames[key].body_sha256)] = true
	check((maximum-minimum).x <= 3 and (maximum-minimum).y <= 3, "Weapon arm returns to the broad running pump")
	check(unique.size() == 8, "Stride reuses a frozen body instead of complete running poses")
	print("SWORD_SIDE_RUN checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func verify_visible_hilt(cell: Image, palm: Vector2) -> void:
	var steel: Image = RUN.weapon_texture.get_image()
	var guard := 0
	var pommel := 0
	var exposed_rear_grip := 0
	var hidden := 0
	for y in range(int(palm.y)-40,int(palm.y)+31):
		for x in range(int(palm.x)-25,int(palm.x)+81):
			var delta := Vector2(x,y)-palm
			var source := Vector2i(roundi(10+sin(PI/18)*delta.x+cos(PI/18)*delta.y),roundi(66-cos(PI/18)*delta.x+sin(PI/18)*delta.y))
			if source.x<0 or source.x>=20 or source.y<55 or source.y>=80: continue
			var expected := steel.get_pixelv(source)
			if expected.a<.5: continue
			var actual := cell.get_pixel(x,y)
			# Only this same pose's closed glove can occlude its grip.
			if absf(delta.x)<=3 and absf(delta.y)<=3 and actual.a>.9 and actual.r>actual.g*1.3 and actual.g>actual.b*1.2: continue
			if not actual.is_equal_approx(expected): hidden+=1
			if source.y<=60: guard+=1
			if source.y>=77: pommel+=1
			if source.y>=69 and source.y<=72: exposed_rear_grip+=1
	check(hidden==0 and guard>=50 and pommel>=5 and exposed_rear_grip>=6, "Grip sits at the handle end or torso hides the hilt")
