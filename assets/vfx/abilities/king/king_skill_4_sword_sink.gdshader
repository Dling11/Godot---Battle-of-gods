shader_type canvas_item;

uniform float visible_cutoff_uv : hint_range(0.0, 1.0) = 1.0;


void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (UV.y > visible_cutoff_uv) {
		discard;
	}
	COLOR = pixel;
}
