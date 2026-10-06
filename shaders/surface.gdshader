shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(0.17, 0.18, 0.21);
uniform vec3 grime_color : source_color = vec3(0.055, 0.058, 0.068);
uniform float grime_amount : hint_range(0.0, 1.0) = 0.6;
uniform float noise_scale : hint_range(0.2, 12.0) = 2.2;
uniform float fine_scale : hint_range(2.0, 90.0) = 22.0;
uniform float bump_strength : hint_range(0.0, 1.0) = 0.45;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.86;
uniform float roughness_var : hint_range(0.0, 1.0) = 0.26;
uniform float streak_amount : hint_range(0.0, 1.0) = 0.35;
uniform float wear_height : hint_range(0.0, 4.0) = 1.6;

uniform sampler2D albedo_tex : repeat_enable, filter_linear_mipmap;
uniform sampler2D normal_tex : repeat_enable, filter_linear_mipmap;
uniform sampler2D rough_tex : repeat_enable, filter_linear_mipmap;
uniform sampler2D ao_tex : repeat_enable, filter_linear_mipmap;
uniform float use_tex : hint_range(0.0, 1.0) = 0.0;
uniform float tex_scale : hint_range(0.02, 4.0) = 0.42;
uniform float normal_strength : hint_range(0.0, 3.0) = 1.0;
uniform float tint_amount : hint_range(0.0, 1.0) = 0.35;
uniform float tex_saturation : hint_range(0.0, 2.0) = 1.0;
uniform float tex_value : hint_range(0.0, 1.0) = 0.022;

varying vec3 w_pos;
varying vec3 w_nrm;

float hash31(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.zyx + 31.32);
	return fract((p.x + p.y) * p.z);
}

float vnoise(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(mix(hash31(i + vec3(0,0,0)), hash31(i + vec3(1,0,0)), f.x),
		    mix(hash31(i + vec3(0,1,0)), hash31(i + vec3(1,1,0)), f.x), f.y),
		mix(mix(hash31(i + vec3(0,0,1)), hash31(i + vec3(1,0,1)), f.x),
		    mix(hash31(i + vec3(0,1,1)), hash31(i + vec3(1,1,1)), f.x), f.y),
		f.z);
}

float fbm(vec3 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + vec3(v * 1.9, v * 1.4, v * 1.1);
		a *= 0.5;
	}
	return v;
}

float tri_noise(vec3 p, vec3 n, float scale) {
	vec3 an = abs(normalize(n));
	an = pow(an, vec3(4.0));
	an /= max(an.x + an.y + an.z, 0.0001);
	float x = fbm(vec3(p.y, p.z, 0.0) * scale);
	float y = fbm(vec3(p.x, p.z, 11.0) * scale);
	float z = fbm(vec3(p.x, p.y, 23.0) * scale);
	return x * an.x + y * an.y + z * an.z;
}

void vertex() {
	w_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	w_nrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(w_nrm);

	float broad = tri_noise(w_pos, n, noise_scale);
	float fine = tri_noise(w_pos, n, fine_scale);
	float detail = clamp(1.0 - length(fwidth(w_pos)) * fine_scale * 1.7, 0.0, 1.0);
	float grain = mix(broad, fine, 0.42 * detail);

	float vertical = clamp(1.0 - (w_pos.y - wear_height * 0.0) / max(wear_height * 2.2, 0.001), 0.0, 1.0);
	float dirt = clamp(broad * 1.25 - 0.18 + vertical * 0.22, 0.0, 1.0);

	float streak = tri_noise(vec3(w_pos.x * 5.0, w_pos.y * 0.35, w_pos.z * 5.0), n, 1.4);
	streak = smoothstep(0.52, 0.86, streak) * streak_amount * clamp(1.0 - w_pos.y / 3.0, 0.0, 1.0) * detail;

	vec3 mottle = mix(base_color, base_color * 1.18, smoothstep(0.30, 0.80, grain));
	vec3 albedo = mix(mottle, grime_color, dirt * grime_amount);
	albedo = mix(albedo, grime_color * 0.9, streak);

	float rough = clamp(roughness_base - grain * roughness_var + dirt * 0.12, 0.06, 1.0);

	vec3 an = abs(n);
	vec2 tuv;
	vec3 tng;
	vec3 bng;
	if (an.x >= an.y && an.x >= an.z) {
		tuv = w_pos.zy;
		tng = vec3(0.0, 0.0, 1.0);
		bng = vec3(0.0, -1.0, 0.0);
	} else if (an.y >= an.z) {
		tuv = w_pos.xz;
		tng = vec3(1.0, 0.0, 0.0);
		bng = vec3(0.0, 0.0, 1.0);
	} else {
		tuv = w_pos.xy;
		tng = vec3(1.0, 0.0, 0.0);
		bng = vec3(0.0, -1.0, 0.0);
	}
	tuv *= tex_scale;

	vec3 tAlb = texture(albedo_tex, tuv).rgb;
tAlb = mix(vec3(dot(tAlb, vec3(0.2126, 0.7152, 0.0722))), tAlb, tex_saturation);
	float tRgh = texture(rough_tex, tuv).r;
	float tAO = texture(ao_tex, tuv).r;
	vec3 tN = texture(normal_tex, tuv).xyz * 2.0 - 1.0;

	vec3 tint = base_color / max(max(base_color.r, base_color.g), max(base_color.b, 0.0001));
	albedo = mix(albedo, tAlb * mix(vec3(1.0), tint, tint_amount) * tex_value * mix(1.0, tAO, 0.85), use_tex);
	rough = mix(rough, clamp(tRgh * 1.15, 0.45, 1.0), use_tex);

	ALBEDO = albedo;

	ROUGHNESS = rough;
	METALLIC = 0.0;
	SPECULAR = 0.32;

	float e = 0.13;
	float h = tri_noise(w_pos, n, fine_scale);
	float hx = tri_noise(w_pos + vec3(e, 0.0, 0.0), n, fine_scale);
	float hy = tri_noise(w_pos + vec3(0.0, e, 0.0), n, fine_scale);
	float hz = tri_noise(w_pos + vec3(0.0, 0.0, e), n, fine_scale);

	vec3 grad = vec3(hx - h, hy - h, hz - h) / e;
	grad -= n * dot(grad, n);
	vec3 wn = normalize(n - grad * bump_strength * 0.06 * detail);
	wn = normalize(mix(wn, normalize(n + (tng * tN.x + bng * tN.y) * normal_strength), use_tex));
	NORMAL = normalize((VIEW_MATRIX * vec4(wn, 0.0)).xyz);
	NORMAL_MAP_DEPTH = 1.0;
}