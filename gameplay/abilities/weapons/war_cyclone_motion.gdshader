shader_type canvas_item;

uniform vec4 atlas_region = vec4(0.0,0.0,0.25,0.25);
uniform vec4 next_region = vec4(0.0,0.0,0.25,0.25);
uniform float frame_blend = 0.0;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec2 local_uv = clamp((UV-atlas_region.xy)/atlas_region.zw,vec2(0.001953125),vec2(0.998046875));
	vec4 a = texture(TEXTURE,atlas_region.xy+local_uv*atlas_region.zw);
	vec4 b = texture(TEXTURE,next_region.xy+local_uv*next_region.zw);
	float alpha = mix(a.a,b.a,frame_blend);
	vec3 premultiplied = mix(a.rgb*a.a,b.rgb*b.a,frame_blend);
	COLOR = vec4(premultiplied/max(alpha,0.00001),alpha)*vertex_tint;
}
