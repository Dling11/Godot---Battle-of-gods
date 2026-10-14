extends RefCounted

## Offline packing only: preserve complete generated strokes, use one density
## and explicit source grid anchors, remove translucent generation haze.
const SOURCE := "res://art_source/generated/characters/king/iron_reaper_cadence_2026_10_14/"
const OUTPUT := "res://assets/characters/playable/king/iron_reaper/slash.png"

static func build() -> Error:
	var recipe: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"packing.json"))
	if FileAccess.get_sha256(SOURCE+"white-ribbons-source.png")!=recipe.source_sha256: return ERR_INVALID_DATA
	var source := Image.load_from_file(SOURCE+"white-ribbons-source.png")
	var atlas := Image.create(2048,768,false,Image.FORMAT_RGBA8)
	for row in 3:
		for frame in 8:
			var bounds := Rect2i(recipe.x_edges[frame],recipe.y_edges[row],recipe.x_edges[frame+1]-recipe.x_edges[frame],recipe.y_edges[row+1]-recipe.y_edges[row])
			var anchor := Vector2(recipe.x_anchors[frame],recipe.y_anchors[row])
			var count := 0
			for y in 256:
				for x in 256:
					var sample_point := Vector2(x-128,(255-y if row==1 else y)-128)/float(recipe.density)+anchor
					var point := Vector2i(sample_point.round())
					if not bounds.has_point(point): continue
					var color := source.get_pixelv(point)
					if color.a*255<float(recipe.alpha_threshold): continue
					if x<8 or x>247 or y<8 or y>247: return ERR_INVALID_DATA
					color.a = 1.0
					atlas.set_pixel(frame*256+x,row*256+y,color)
					count += 1
			if count<100: return ERR_INVALID_DATA
	return atlas.save_png(OUTPUT)
