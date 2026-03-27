shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.4;
uniform float radius : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint_color : source_color = vec4(0.05, 0.05, 0.15, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(uv, center);
	float vignette = smoothstep(radius, radius - softness, dist);
	float darkness = mix(strength, 0.0, vignette);
	COLOR = vec4(tint_color.rgb, darkness);
}
