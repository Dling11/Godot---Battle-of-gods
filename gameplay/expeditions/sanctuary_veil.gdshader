shader_type canvas_item;
render_mode unshaded;

// The aperture and masonry never change shape. Only the interior light flows.
void fragment() {
	vec4 paint = texture(TEXTURE,UV);
	float drift = .85 + .15*sin(UV.y*22.0-TIME*1.5+sin(UV.x*12.0+TIME*.7));
	paint.rgb *= drift;
	COLOR = paint*COLOR;
}
