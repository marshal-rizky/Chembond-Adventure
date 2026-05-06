shader_type canvas_item;

uniform float grid_size : hint_range(4.0, 128.0) = 20.0;
uniform vec4 bg_color : source_color = vec4(0.027, 0.043, 0.075, 1.0);
uniform vec4 line_color : source_color = vec4(0.078, 0.718, 0.651, 0.12);
uniform float line_width : hint_range(0.5, 4.0) = 0.5;

void fragment() {
	vec2 pixel = FRAGCOORD.xy;
	vec2 grid = mod(pixel, grid_size);
	float on_h = step(grid_size - line_width, grid.x);
	float on_v = step(grid_size - line_width, grid.y);
	float on_line = clamp(on_h + on_v, 0.0, 1.0);
	COLOR = mix(bg_color, line_color, on_line);
}
