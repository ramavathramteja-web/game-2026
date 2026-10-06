shader_type sky;

uniform vec3 top_color : source_color = vec3(0.012, 0.016, 0.032);
uniform vec3 horizon_color : source_color = vec3(0.045, 0.058, 0.090);
uniform float star_density : hint_range(10.0, 400.0) = 150.0;
uniform float star_cutoff : hint_range(0.90, 1.0) = 0.988;
uniform float star_brightness : hint_range(0.0, 2.0) = 0.85;

float hash21(vec2 p) {
	p = fract(p * vec2(233.34, 851.73));
	p += dot(p, p + 23.45);
	return fract(p.x * p.y);
}

void sky() {
	vec3 d = normalize(EYEDIR);

	vec3 col = mix(horizon_color, top_color, pow(clamp(d.y, 0.0, 1.0), 0.45));
	col = mix(col, horizon_color * 0.5, smoothstep(0.0, 0.30, -d.y));

	vec2 sp = vec2(atan(d.z, d.x), asin(clamp(d.y, -1.0, 1.0)));
	vec2 grid = sp * star_density;
	vec2 cell = floor(grid);
	float pick = hash21(cell);
	float mag = hash21(cell + 7.13);

	vec2 f = fract(grid) - 0.5;
	float pt = smoothstep(0.14, 0.0, length(f)) * step(star_cutoff, pick);

	float twinkle = 0.65 + 0.35 * mag;
	col += vec3(pt * star_brightness * twinkle) * smoothstep(0.02, 0.22, d.y);

	COLOR = col;
}