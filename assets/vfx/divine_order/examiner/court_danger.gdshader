shader_type canvas_item;
render_mode unshaded;

uniform vec2 floor_size = vec2(650.0, 390.0);
uniform vec2 ward_points[4];
uniform float ward_enabled[4];
uniform float ward_radius = 54.0;
uniform float progress = 0.0;
uniform float strength = 0.0;

void fragment() {
	vec2 point = UV * floor_size;
	float safe_distance = 10000.0;
	for (int i = 0; i < 4; i++) {
		if (ward_enabled[i] > 0.5) {
			safe_distance = min(safe_distance, distance(point, ward_points[i]));
		}
	}
	float exposed = step(ward_radius, safe_distance);
	float wave = 0.5 + 0.5 * sin(length(point - floor_size * 0.5) * 0.075 - TIME * 4.0);
	float edge = 1.0 - smoothstep(ward_radius, ward_radius + 6.0, safe_distance);
	vec3 danger = mix(vec3(0.45, 0.005, 0.015), vec3(0.95, 0.08, 0.04), wave * 0.45);
	COLOR = vec4(danger, exposed * strength * (0.14 + progress * 0.18 + edge * 0.12));
}
