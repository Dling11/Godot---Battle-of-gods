shader_type canvas_item;

// Complete painted frames fade at the actual melee boundary, without a hard
// rectangular atlas cut. These uniforms observe contact; they cannot deal damage.
uniform int edge_count = 0;
uniform vec2 edge_normals[64];
uniform float edge_distances[64];
uniform vec2 actor_origin;
uniform vec2 actor_axis_x = vec2(1.0, 0.0);
uniform vec2 actor_axis_y = vec2(0.0, 1.0);
uniform float feather_pixels = 3.0;
varying vec2 painted_point;

void vertex() {
	painted_point = VERTEX;
}

void fragment() {
	vec2 point = actor_origin + actor_axis_x * painted_point.x + actor_axis_y * painted_point.y;
	float inside = 10000.0;
	for (int i = 0; i < edge_count; i++) {
		inside = min(inside, dot(edge_normals[i], point) - edge_distances[i]);
	}
	COLOR.a *= smoothstep(0.0, feather_pixels, inside);
}
