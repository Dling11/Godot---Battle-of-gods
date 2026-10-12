shader_type canvas_item;
render_mode unshaded;

// Generated cells contain shape/registration drift. Only their inner currents
// are animated; silhouette, ornaments and the ground anchor use one identity.
uniform int reference_frame = 0;
uniform vec2 core_center = vec2(96.0, 88.0);
uniform vec2 core_radius = vec2(24.0, 44.0);
uniform vec2 registration[8];
uniform bool hand_detail = false;
uniform float frame_blend : hint_range(0.0, 1.0) = 0.0;
uniform float rim_glimmer_strength : hint_range(0.0, 0.1) = 0.055;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec2 cell_size = vec2(192.0, 160.0);
	vec2 sheet_pixel = UV / TEXTURE_PIXEL_SIZE;
	int frame_index = clamp(int(floor(sheet_pixel.x / cell_size.x)), 0, 7);
	// Sample explicit texel centers so atlas-column floating-point rounding
	// cannot change which reference edge pixel is selected.
	vec2 cell_pixel = floor(mod(sheet_pixel, cell_size) + vec2(0.001)) + vec2(0.5);
	vec2 anchor_uv = (vec2(float(reference_frame) * cell_size.x, 0.0) + cell_pixel) * TEXTURE_PIXEL_SIZE;
	vec4 anchor = texture(TEXTURE, anchor_uv);
	vec2 source_pixel = clamp(cell_pixel + registration[frame_index], vec2(0.5), cell_size - vec2(0.5));
	vec2 current_uv = (vec2(float(frame_index) * cell_size.x, 0.0) + source_pixel) * TEXTURE_PIXEL_SIZE;
	vec4 current = texture(TEXTURE, current_uv);
	int next_frame = (frame_index + 1) % 8;
	vec2 next_pixel = clamp(cell_pixel + registration[next_frame], vec2(0.5), cell_size - vec2(0.5));
	vec2 next_uv = (vec2(float(next_frame) * cell_size.x, 0.0) + next_pixel) * TEXTURE_PIXEL_SIZE;
	current = mix(current, texture(TEXTURE, next_uv), frame_blend);
	vec2 relative = (cell_pixel - core_center) / core_radius;
	float inner = 1.0 - smoothstep(0.80, 1.0, length(relative));
	// Finger shading can change within a planted hand outline, without replacing
	// the entire gate with a differently drawn pose or exposing transparent gaps.
	if (hand_detail && cell_pixel.x > 115.0 && cell_pixel.x < 146.0 && cell_pixel.y > 55.0 && cell_pixel.y < 111.0) {
		inner = max(inner, 0.65);
	}
	float phase = (float(frame_index) + frame_blend) * 0.785398163;
	float glimmer = 1.0 + rim_glimmer_strength * sin(phase + cell_pixel.y * 0.10);
	vec3 fixed_rim = anchor.rgb * glimmer;
	vec3 energy = mix(fixed_rim, current.rgb, inner * current.a);
	// Alpha ALWAYS comes from the identity frame, including inside the aperture.
	COLOR = vec4(energy, anchor.a) * vertex_tint;
}
