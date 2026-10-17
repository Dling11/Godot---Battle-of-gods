shader_type canvas_item;
render_mode blend_add;

uniform bool foreground = false;
uniform float orbit_angle = 0.0;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	// Fixed template/radii match the accepted preview; the body never rotates flat.
	vec2 p = (UV-vec2(0.5))/vec2(0.35,0.30);
	float radius = length(p);
	float c = cos(orbit_angle);
	float s = sin(orbit_angle);
	vec2 source_uv = vec2(c*p.x+s*p.y,-s*p.x+c*p.y)*vec2(0.353125,0.1671875)+vec2(0.525,0.496875);
	float inside = step(0.0,source_uv.x)*step(source_uv.x,1.0)*step(0.0,source_uv.y)*step(source_uv.y,1.0);
	vec3 paint = texture(TEXTURE,clamp(source_uv,vec2(0.0015625),vec2(0.9984375))).rgb;
	float band = smoothstep(0.35,0.42,radius)*(1.0-smoothstep(1.08,1.12,radius));
	float front = foreground ? smoothstep(0.51,0.57,UV.y) : 1.0;
	COLOR = vec4(paint*vertex_tint.rgb,vertex_tint.a*band*front*inside);
}
