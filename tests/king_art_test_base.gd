extends "res://tests/sanctuary_test_base.gd"

## Shared anatomy checks; no obsolete weapon-review fixtures.

func same_opaque(a: Image,b: Image) -> bool:
	for y in a.get_height():
		for x in a.get_width():
			var ac := a.get_pixel(x,y)
			var bc := b.get_pixel(x,y)
			if ac.a!=bc.a or (ac.a>.65 and ac!=bc): return false
	return true

func anatomy_connected(body: Image,glove: Vector2i,head: Rect2i) -> bool:
	body.convert(Image.FORMAT_RGBA8)
	var bytes := body.get_data()
	var width := body.get_width()
	var visited := PackedByteArray()
	visited.resize(width*body.get_height())
	var queue := PackedInt32Array([glove.y*width+glove.x])
	visited[queue[0]]=1
	var cursor := 0
	while cursor<queue.size():
		var point := Vector2i(queue[cursor]%width,queue[cursor]/width)
		cursor+=1
		for dy in range(-1,2):
			for dx in range(-1,2):
				var next := point+Vector2i(dx,dy)
				if next.x<0 or next.y<0 or next.x>=width or next.y>=body.get_height(): continue
				var id := next.y*width+next.x
				if visited[id] or bytes[id*4+3]<200: continue
				visited[id]=1
				queue.append(id)
	var opaque := 0
	var head_opaque := 0
	var connected_head := 0
	for id in visited.size():
		if bytes[id*4+3]<200: continue
		opaque+=1
		if head.has_point(Vector2i(id%width,id/width)):
			head_opaque+=1
			if visited[id]: connected_head+=1
	return queue.size()>=opaque*.97 and head_opaque>200 and connected_head>=head_opaque*.97
