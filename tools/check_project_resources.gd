extends SceneTree

## Check every retained runtime resource after a fresh editor import.
## global classes and format-string loads require more than a literal graph.
const ROOTS=["assets","autoload","data","entities","environment","gameplay","levels","ui","tools","tests"]
var checked:=0
var failures:=0

func _initialize()->void:
	for folder in ROOTS: _visit("res://"+folder)
	print("PROJECT_RESOURCES checked=",checked," failures=",failures)
	quit(1 if failures else 0)

func _visit(folder:String)->void:
	var directory:=DirAccess.open(folder)
	if directory==null: return
	directory.list_dir_begin()
	var name:=directory.get_next()
	while not name.is_empty():
		var file:=folder.path_join(name)
		if directory.current_is_dir():
			if not name.begins_with("."): _visit(file)
		elif file.get_extension() in ["gd","tscn","tres","gdshader"]:
			checked+=1
			if ResourceLoader.load(file)==null:
				failures+=1
				push_error("Retained resource cannot load: "+file)
		name=directory.get_next()
	directory.list_dir_end()
