extends SceneTree

## Offline acceptance gate for reuse of a named complete body, not a resizer.
const LIB := "res://assets/characters/playable/king/body_library/v1/"

func _initialize() -> void:
	var candidate := ""
	var pose := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--candidate="): candidate=argument.trim_prefix("--candidate=")
		if argument.begins_with("--pose="): pose=argument.trim_prefix("--pose=")
	var contract: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LIB+"contract.json"))
	for id in contract.poses:
		if FileAccess.get_sha256(LIB+id+"_body.png")!=contract.poses[id].sha256:
			push_error("Frozen King body changed: "+id); quit(1); return
	if candidate.is_empty() and pose.is_empty():
		print("KING_BODY_LIBRARY verified ",contract.poses.size()," immutable complete body atlases")
		quit(); return
	if not contract.poses.has(pose) or not FileAccess.file_exists(candidate):
		push_error("Use --candidate=res://body.png --pose=<contract pose ID>. New motions need separate complete-pose review."); quit(1); return
	var body := Image.load_from_file(ProjectSettings.globalize_path(candidate))
	var reference := Image.load_from_file(ProjectSettings.globalize_path(LIB+pose+"_body.png"))
	if body==null or body.get_size()!=reference.get_size():
		push_error("King body grid differs from reference: "+pose); quit(1); return
	body.convert(Image.FORMAT_RGBA8); reference.convert(Image.FORMAT_RGBA8)
	var mismatches := 0
	for y in body.get_height():
		for x in body.get_width():
			var a := body.get_pixel(x,y)
			var b := reference.get_pixel(x,y)
			if a.a!=b.a or (a.a>.65 and a!=b): mismatches+=1
	if mismatches:
		push_error("King body differs from "+pose+" at "+str(mismatches)+" pixels. Reuse the complete approved body; do not rescale or stamp its head.")
		quit(1); return
	print("KING_BODY_CANDIDATE matches complete pose ",pose)
	quit()
