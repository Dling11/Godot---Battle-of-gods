shader_type canvas_item;
render_mode unshaded;

// One source texel becomes one screen pixel at the normal 2x development view.
// Padded atlas cells keep neighbor samples away from other animation frames.
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec4 ink = texture(TEXTURE, UV);
	float edge = max(max(texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a,
		texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a),
		max(texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a,
		texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a));
	vec4 outlined = vec4(vec3(0.055, 0.067, 0.086), edge);
	COLOR = mix(outlined, ink, ink.a) * vertex_tint;
}
