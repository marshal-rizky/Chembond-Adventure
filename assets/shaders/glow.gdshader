shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 0.6);
uniform float glow_size : hint_range(0.0, 4.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float pulse = 1.0 + pulse_amount * sin(TIME * pulse_speed);

	// Sample nearby pixels for glow
	float glow = 0.0;
	vec2 pixel_size = TEXTURE_PIXEL_SIZE * glow_size;
	for (float x = -2.0; x <= 2.0; x += 1.0) {
		for (float y = -2.0; y <= 2.0; y += 1.0) {
			glow += texture(TEXTURE, UV + vec2(x, y) * pixel_size).a;
		}
	}
	glow /= 25.0;

	// Mix original with glow
	vec4 glow_layer = glow_color * glow * pulse;
	COLOR = mix(glow_layer, tex * COLOR, tex.a);
	COLOR.a = max(glow_layer.a * 0.5, tex.a);
}
