shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec2 resolution = vec2(1280.0, 720.0);

uniform float exposure : hint_range(0.2, 4.0) = 1.85;
uniform float contrast : hint_range(0.5, 3.0) = 1.14;
uniform float gamma_lift : hint_range(0.0, 1.0) = 0.05;

uniform float edge_strength : hint_range(0.0, 3.0) = 0.34;
uniform float edge_threshold : hint_range(0.0, 0.6) = 0.30;

uniform float hatch_strength : hint_range(0.0, 1.5) = 0.11;
uniform float hatch_scale : hint_range(3.0, 60.0) = 15.0;
uniform float hatch_angle : hint_range(0.0, 3.14159) = 0.7854;

uniform vec3 ink_color : source_color = vec3(0.055, 0.050, 0.048);
uniform vec3 paper_color : source_color = vec3(0.84, 0.81, 0.74);
uniform vec3 tint_cool : source_color = vec3(0.62, 0.70, 0.85);
uniform vec3 tint_warm : source_color = vec3(0.92, 0.78, 0.55);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.10;
uniform float flatten : hint_range(0.0, 1.0) = 0.55;

uniform float grain : hint_range(0.0, 0.5) = 0.055;
uniform float vignette : hint_range(0.0, 1.0) = 0.28;
uniform float grain_speed : hint_range(0.0, 60.0) = 24.0;

float lum(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec3 fetch(vec2 uv) {
	return texture(screen_tex, uv).rgb;
}

float luma_at(vec2 uv) {
	return lum(fetch(uv));
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = 1.0 / resolution;

	vec3 src = fetch(uv);
	float l = lum(src);

	float lifted = pow(clamp(l * exposure, 0.0, 1.0), 1.0 / 2.2);
	float toned = clamp((lifted - 0.5) * contrast + 0.5 + gamma_lift * (1.0 - lifted), 0.0, 1.0);

	float gx = 0.0;
	gx += luma_at(uv + vec2(px.x, 0.0));
	gx -= luma_at(uv - vec2(px.x, 0.0));
	gx += 2.0 * luma_at(uv + vec2(0.0, px.y));
	gx -= 2.0 * luma_at(uv - vec2(0.0, px.y));

	float gy = 0.0;
	gy += luma_at(uv + vec2(0.0, px.y));
	gy -= luma_at(uv - vec2(0.0, px.y));
	gy += 2.0 * luma_at(uv + vec2(px.x, 0.0));
	gy -= 2.0 * luma_at(uv - vec2(px.x, 0.0));

	float grad = sqrt(gx * gx + gy * gy);
	float edge = smoothstep(edge_threshold, edge_threshold + 0.26, grad) * edge_strength;

	float ca = cos(hatch_angle);
	float sa = sin(hatch_angle);
	vec2 hp = vec2(uv.x * resolution.x, uv.y * resolution.y);
	hp = vec2(hp.x * ca - hp.y * sa, hp.x * sa + hp.y * ca);

	float line_a = abs(fract(hp.y / hatch_scale) - 0.5) * 2.0;
	float line_b = abs(fract(hp.x / (hatch_scale * 1.55)) - 0.5) * 2.0;

	float shade_zone = 1.0 - smoothstep(0.04, 0.46, toned);
	float deep_zone = 1.0 - smoothstep(0.03, 0.20, toned);

	float stroke_a = (1.0 - smoothstep(0.0, 0.62, line_a)) * shade_zone;
	float stroke_b = (1.0 - smoothstep(0.0, 0.62, line_b)) * deep_zone;

	float wobble = hash(floor(hp / hatch_scale)) * 0.35;
	float hatch_amt = clamp((stroke_a * (0.62 + wobble) + stroke_b * 0.55) * hatch_strength, 0.0, 1.0);

	vec3 paper = paper_color;
	vec3 ink = ink_color;

	float v = toned;
	vec3 graded = pow(clamp(src * exposure, 0.0, 1.0), vec3(1.0 / 2.2));
	graded = clamp((graded - 0.5) * contrast + 0.5, 0.0, 1.0);
	vec3 col = mix(graded, mix(ink, paper, v), flatten);
	col = mix(col, ink, clamp(hatch_amt, 0.0, 1.0));
	col = mix(col, ink, clamp(edge, 0.0, 1.0));

	float warmth = clamp((lifted - 0.45) * 1.6, 0.0, 1.0);
	float coolness = clamp((0.4 - lifted) * 1.8, 0.0, 1.0);
	col *= mix(vec3(1.0), tint_warm, warmth * tint_strength);
	col *= mix(vec3(1.0), tint_cool, coolness * tint_strength * 1.4);

	float g = hash(uv * resolution + vec2(TIME * grain_speed, TIME * grain_speed * 0.7));
	col += (g - 0.5) * grain * (1.0 - v * 0.5);

	vec2 c = uv - 0.5;
	float vig = 1.0 - dot(c, c) * vignette * 1.9;
	col *= clamp(vig, 0.0, 1.0);

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}