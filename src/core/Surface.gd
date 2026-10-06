class_name Surface

static var _shader: Shader = null
static var _fallback: ImageTexture = null
static var _tex_cache: Dictionary = {}

static func _get_shader() -> Shader:
	if _shader == null:
		_shader = load("res://shaders/surface.gdshader")
	return _shader

static func _flat() -> ImageTexture:
	if _fallback == null:
		var img := Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
		img.set_pixel(0, 0, Color(0.5, 0.5, 1.0, 1.0))
		_fallback = ImageTexture.create_from_image(img)
	return _fallback

static func _tex(kind: String, suffix: String) -> Texture2D:
	var key := kind + suffix
	if _tex_cache.has(key):
		return _tex_cache[key]
	var path := "res://assets/textures/" + kind + "_" + suffix + ".jpg"
	var t: Texture2D = null
	if ResourceLoader.exists(path):
		t = load(path) as Texture2D
	if t == null:
		t = _flat()
	_tex_cache[key] = t
	return t

static func textured(base: Color, kind: String, tex_scale: float = 0.42, tint: float = 0.35, normal_strength: float = 1.0, saturation: float = 1.0) -> ShaderMaterial:
	var m := mat(base, 0.35, 0.9, 0.3)
	m.set_shader_parameter("use_tex", 1.0)
	m.set_shader_parameter("tex_scale", tex_scale)
	m.set_shader_parameter("tint_amount", tint)
	m.set_shader_parameter("tex_saturation", saturation)
	m.set_shader_parameter("normal_strength", normal_strength)
	m.set_shader_parameter("tex_value", 0.022)
	m.set_shader_parameter("albedo_tex", _tex(kind, "diff"))
	m.set_shader_parameter("normal_tex", _tex(kind, "nor_gl"))
	m.set_shader_parameter("rough_tex", _tex(kind, "rough"))
	m.set_shader_parameter("ao_tex", _tex(kind, "ao"))
	return m

static func mat(base: Color, grime: float = 0.6, rough: float = 0.86, bump: float = 0.45) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = _get_shader()
	m.set_shader_parameter("base_color", base)
	m.set_shader_parameter("grime_color", base.darkened(0.72))
	m.set_shader_parameter("grime_amount", grime)
	m.set_shader_parameter("roughness_base", rough)
	m.set_shader_parameter("bump_strength", bump)
	m.set_shader_parameter("streak_amount", grime * 0.5)
	return m

static func metal(base: Color, rough: float = 0.28) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = base
	m.metallic = 0.92
	m.metallic_specular = 0.6
	m.roughness = rough
	return m

static func mirror_glass() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("39424f")
	m.metallic = 0.5
	m.metallic_specular = 0.34
	m.roughness = 0.44
	return m

static func flat(base: Color, emission: float = 0.0, emissive: Color = Color(1, 1, 1)) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = base
	m.roughness = 0.7
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = emissive
		m.emission_energy_multiplier = emission
	return m