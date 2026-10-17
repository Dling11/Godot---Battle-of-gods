extends RefCounted

## Whole-item crop/placement only: existing steel pixels remain untouched.
static var _crops := {}

static func texture(source: Texture2D) -> Texture2D:
	if source == null: return null
	var key := source.get_rid()
	if _crops.has(key): return _crops[key]
	var pixels := source.get_image()
	if pixels == null: return source
	var used := pixels.get_used_rect()
	if not used.has_area(): return source
	var crop := AtlasTexture.new()
	crop.atlas = source
	crop.region = Rect2(used)
	crop.filter_clip = true
	_crops[key] = crop
	return crop

static func fit(icon: TextureRect, area: Rect2) -> void:
	if icon.texture == null: return
	var dimensions := icon.texture.get_size()
	var angle := -.5 if dimensions.y > dimensions.x*2 else 0.0
	var extent := Vector2(absf(cos(angle))*dimensions.x+absf(sin(angle))*dimensions.y,absf(sin(angle))*dimensions.x+absf(cos(angle))*dimensions.y)
	var factor := minf(area.size.x/extent.x,area.size.y/extent.y)
	var shown := dimensions*factor
	icon.set_anchors_preset(Control.PRESET_TOP_LEFT)
	icon.custom_minimum_size = Vector2.ZERO
	icon.size = shown
	icon.position = area.position+(area.size-shown)*.5
	icon.pivot_offset = shown*.5
	icon.rotation = angle
