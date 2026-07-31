shader_type canvas_item;
render_mode blend_add;

uniform vec4 core_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.25, 0.6, 1.0, 1.0);
uniform vec4 particle_color : source_color = vec4(0.8, 0.95, 1.0, 1.0);

uniform float core_length : hint_range(0.05, 1.0) = 0.35;
uniform float core_width : hint_range(0.02, 0.5) = 0.18;
uniform float core_brightness : hint_range(0.0, 4.0) = 2.0;
uniform float glow_strength : hint_range(0.0, 3.0) = 1.2;
uniform float glow_size : hint_range(0.05, 1.0) = 0.45;
uniform float pulse_speed : hint_range(0.0, 20.0) = 6.0;

uniform int particle_count : hint_range(0, 64) = 18;
uniform float particle_size : hint_range(0.02, 0.4) = 0.12;
uniform float particle_speed : hint_range(0.0, 2.0) = 0.8;
uniform float particle_lifetime : hint_range(0.1, 2.0) = 0.7;
uniform float particle_spread : hint_range(0.0, 1.0) = 0.6;
uniform float tail_bias : hint_range(0.0, 1.0) = 0.7;

uniform float pixel_size : hint_range(0.5, 8.0, 0.5) = 2.0;
uniform float shade_levels : hint_range(1.0, 16.0) = 4.0;

float hash11(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec2 grid = TEXTURE_PIXEL_SIZE * pixel_size;
	vec2 snapped = (floor(UV / grid) + vec2(0.5)) * grid;
	vec2 p = snapped - vec2(0.5);

	vec2 core_uv = p / vec2(core_width, core_length);
	float core = smoothstep(1.0, 0.0, length(core_uv));
	float pulse = 0.85 + 0.15 * sin(TIME * pulse_speed);

	float glow = glow_strength * smoothstep(glow_size, 0.0, length(p));
	glow = floor(glow * shade_levels) / shade_levels;

	float particles = 0.0;
	for (int i = 0; i < particle_count; i++) {
		float seed = float(i) + 0.5;
		float phase = fract(TIME / particle_lifetime + hash11(seed * 1.31));

		float angle = hash11(seed * 7.77) * TAU;
		vec2 dir_radial = vec2(cos(angle), sin(angle));
		vec2 dir_tail = vec2(
			(hash11(seed * 3.31) - 0.5) * particle_spread,
			1.0 + (hash11(seed * 5.51) - 0.5) * particle_spread
		);
		vec2 dir = normalize(mix(dir_radial, dir_tail, tail_bias));

		float speed = particle_speed * (0.35 + 0.9 * hash11(seed * 2.17));
		vec2 pos = dir * phase * speed;

		float fade_in = smoothstep(0.0, 0.25, phase);
		float fade_out = 1.0 - smoothstep(0.4, 1.0, phase);
		float pd = distance(p, pos) / particle_size;
		particles += fade_in * fade_out * smoothstep(1.0, 0.0, pd) * 2.0;
	}
	particles = floor(particles * shade_levels) / shade_levels;

	vec3 col = core_color.rgb * core * core_brightness * pulse;
	col += glow_color.rgb * glow * pulse;
	col += particle_color.rgb * particles;
	float a = max(core * core_brightness * pulse, max(glow * pulse, particles));
	COLOR = vec4(col, clamp(a, 0.0, 1.0));
}
