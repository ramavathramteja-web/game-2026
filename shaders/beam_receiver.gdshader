shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float aligned : hint_range(0.0, 1.0) = 0.0;
uniform float revealed : hint_range(0.0, 1.0) = 0.0;
uniform float flicker : hint_range(0.0, 1.0) = 1.0;
uniform vec3 idle_color : source_color = vec3(1.0, 0.76, 0.38);
uniform vec3 mark_color : source_color = vec3(0.85, 0.98, 0.65);
uniform vec3 prog_color : source_color = vec3(1.0, 0.88, 0.45);
uniform float ring_radius = 0.34;
uniform float ring_width = 0.024;
uniform float core_radius = 0.045;

void fragment() {
	vec2 p = UV - vec2(0.5);
	float r = length(p);
	float a = atan(p.y, p.x);

	// Main target ring
	float ring = smoothstep(ring_width, 0.0, abs(r - ring_radius));
	// Inner guide ring
	float inner_ring = smoothstep(ring_width * 0.5, 0.0, abs(r - ring_radius * 0.62));
	// Outer aura
	float aura = smoothstep(0.42, 0.20, r) * 0.18;
	// Center bullseye core
	float core = smoothstep(core_radius, 0.0, r);

	// Crosshair alignment tick marks (horizontal and vertical crosshairs)
	float cross_h = smoothstep(0.012, 0.0, abs(p.y)) * step(0.12, abs(p.x)) * step(abs(p.x), ring_radius + 0.06);
	float cross_v = smoothstep(0.012, 0.0, abs(p.x)) * step(0.12, abs(p.y)) * step(abs(p.y), ring_radius + 0.06);
	float ticks = max(cross_h, cross_v);

	// Progress fill arc
	float ang = fract((a + PI) / (2.0 * PI));
	float arc = ring * step(ang, progress) * step(0.001, progress);

	// Dynamic breathing pulse
	float pulse = 0.70 + 0.30 * sin(TIME * 3.0);
	float align_boost = 1.0 + aligned * 1.5;

	vec3 col = idle_color * ring * (0.8 + 0.4 * pulse);
	col += idle_color * ticks * 0.75;
	col += idle_color * aura * pulse;
	col += mark_color * inner_ring * (0.4 + 0.6 * revealed);
	col += mark_color * core * (0.8 + aligned * 1.6) * pulse;
	col += prog_color * arc * 3.5;
	col *= flicker * align_boost;

	ALBEDO = vec3(0.0);
	EMISSION = col * 2.2;
	ALPHA = clamp(ring + inner_ring + core + ticks + arc + aura, 0.0, 1.0);
}