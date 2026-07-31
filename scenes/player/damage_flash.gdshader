shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 0.2, 0.2, 1.0);
uniform float flash_strength : hint_range(0.0, 1.0) = 1.0;
uniform int blink_count : hint_range(1, 10) = 3;
uniform float blink_duration : hint_range(0.1, 2.0) = 0.5;
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 tinted = mix(tex.rgb, flash_color.rgb, flash_strength * flash_amount);
	COLOR = vec4(tinted, tex.a);
}
