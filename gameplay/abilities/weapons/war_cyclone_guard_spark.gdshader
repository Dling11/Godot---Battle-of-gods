shader_type canvas_item;
render_mode blend_add;

uniform vec4 energy_color : source_color = vec4(0.24, 0.66, 1.0, 1.0);

void fragment() {
	vec4 paint = texture(TEXTURE, UV);
	float light = max(paint.r, max(paint.g, paint.b));
	float white_core = min(paint.r, min(paint.g, paint.b));
	vec3 tint = mix(energy_color.rgb, vec3(1.0), white_core);
	COLOR = vec4(tint * light * COLOR.rgb, paint.a * COLOR.a);
}
