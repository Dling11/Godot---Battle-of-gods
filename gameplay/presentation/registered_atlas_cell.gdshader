shader_type canvas_item;

// A blade-bound UV mapping can leave its cell; never sample neighboring frames.
uniform vec2 cell_min = vec2(0.0);
uniform vec2 cell_max = vec2(1.0);

void fragment() {
	if (any(lessThan(UV, cell_min)) || any(greaterThanEqual(UV, cell_max))) {
		COLOR = vec4(0.0);
	}
}
