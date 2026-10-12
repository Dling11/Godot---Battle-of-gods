shader_type canvas_item;
render_mode unshaded;
uniform bool buried = false;
uniform vec2 ground_axis = vec2(0.0, 1.0);
uniform float ground_offset = 0.0;
uniform float foot_y = 32.0;
varying float registered_y;
varying vec4 vertex_tint;
void vertex() {
	registered_y = dot(VERTEX, ground_axis) + ground_offset;
	vertex_tint = COLOR;
}
void fragment() {
	COLOR = vertex_tint * texture(TEXTURE, UV);
	if (buried && registered_y > foot_y) { discard; }
}
