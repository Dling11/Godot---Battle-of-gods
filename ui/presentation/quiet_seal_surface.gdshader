shader_type canvas_item;
render_mode unshaded;

// One canonical engraving: generated poses change the ring and its ornaments.
// Move light across that engraving instead of redrawing the physical emblem.
uniform float animation_phase = 0.0;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec2 cell_size = vec2(112.0);
	vec2 sheet_pixel = UV / TEXTURE_PIXEL_SIZE;
	vec2 cell_pixel = floor(mod(sheet_pixel, cell_size) + vec2(0.001)) + vec2(0.5);
	vec4 engraving = texture(TEXTURE, cell_pixel * TEXTURE_PIXEL_SIZE);
	float phase = mod(animation_phase, 6.28318530718);
	vec2 radial = cell_pixel - vec2(56.0, 60.0);
	float angle = atan(radial.y, radial.x);
	float highlight = pow(0.5 + 0.5 * cos(angle - phase), 12.0);
	float gold = step(0.25, max(engraving.r, max(engraving.g, engraving.b)));
	float light = 1.0 + gold * (0.18 * highlight + 0.025 * sin(phase + angle));
	COLOR = vec4(engraving.rgb * light, engraving.a) * vertex_tint;
}
