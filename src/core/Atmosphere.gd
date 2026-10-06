class_name Atmosphere

static func apply(e: Environment, ambient_energy: float = 0.16) -> void:
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_energy = ambient_energy

	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	e.tonemap_exposure = 1.35
	e.tonemap_white = 6.0

	e.adjustment_enabled = true
	e.adjustment_contrast = 1.04
	e.adjustment_saturation = 0.88
	e.adjustment_brightness = 1.0

	e.glow_enabled = true
	e.glow_intensity = 0.35
	e.glow_strength = 1.0
	e.glow_bloom = 0.12
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	e.glow_hdr_threshold = 0.85

	e.ssao_enabled = false
	e.ssao_radius = 1.6
	e.ssao_intensity = 1.4
	e.ssao_power = 1.5
	e.ssao_detail = 0.5

	e.ssil_enabled = false

	e.ssr_enabled = true
	e.ssr_max_steps = 48
	e.ssr_fade_in = 0.15
	e.ssr_fade_out = 2.0
	e.ssr_depth_tolerance = 0.2

	e.fog_enabled = true
	e.fog_light_color = Color("0d1420")
	e.fog_density = 0.018
	e.fog_sky_affect = 0.0
	e.fog_aerial_perspective = 0.0

	e.volumetric_fog_enabled = false
	e.volumetric_fog_density = 0.007
	e.volumetric_fog_albedo = Color(0.72, 0.76, 0.86)
	e.volumetric_fog_emission = Color(0.10, 0.09, 0.07)
	e.volumetric_fog_emission_energy = 0.06
	e.volumetric_fog_length = 64.0
	e.volumetric_fog_detail_spread = 2.0
	e.volumetric_fog_gi_inject = 0.0