class_name TorchDust
extends GPUParticles3D

static func build(parent: Node3D) -> TorchDust:
	var d := TorchDust.new()
	d.name = "TorchDust"
	parent.add_child(d)
	d._configure()
	return d

func _configure() -> void:
	amount = 220
	lifetime = 4.0
	preprocess = 3.0
	local_coords = false
	randomness = 0.9
	fixed_fps = 30
	draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH

	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(2.4, 1.6, 3.0)
	pm.direction = Vector3(0.0, 1.0, 0.0)
	pm.spread = 40.0
	pm.initial_velocity_min = 0.02
	pm.initial_velocity_max = 0.09
	pm.gravity = Vector3(0.0, -0.012, 0.0)
	pm.damping_min = 0.0
	pm.damping_max = 0.05
	pm.scale_min = 0.4
	pm.scale_max = 1.0
	pm.color = Color(1.0, 0.86, 0.66, 0.5)
	process_material = pm

	var quad := QuadMesh.new()
	quad.size = Vector2(0.016, 0.016)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color(1.0, 0.88, 0.70, 0.55)
	mat.disable_receive_shadows = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = mat

	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)