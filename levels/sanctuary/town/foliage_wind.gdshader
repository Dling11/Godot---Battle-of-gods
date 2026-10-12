shader_type canvas_item;
render_mode unshaded;
uniform float phase = 0.0;
// Expand the quad around its trunk pivot. Pixel-stepped motion never moves the roots.
void vertex() {
	float crown = smoothstep(0.38, 0.92, 1.0 - UV.y);
	float breeze = sin(TIME * 1.35 + phase) + 0.35 * sin(TIME * 2.3 + phase);
	VERTEX.x += round(breeze * crown * 1.6);
}
