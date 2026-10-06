class_name Sign
extends RefCounted

const FONT_SIZE := 64

static func label(parent: Node3D, pos: Vector3, txt: String, height: float = 0.34, tint: Color = Color("cfd8e6"), plate: bool = true, yaw: float = 0.0) -> MeshInstance3D:
	var tm := TextMesh.new()
	tm.text = txt
	tm.font_size = FONT_SIZE
	tm.pixel_size = height / float(FONT_SIZE)
	tm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.albedo_color = tint
	mat.roughness = 0.85
	mat.metallic = 0.0
	mat.emission_enabled = true
	mat.emission = tint
	mat.emission_energy_multiplier = 0.10
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	tm.material = mat

	var mi := MeshInstance3D.new()
	mi.mesh = tm
	mi.position = pos
	mi.rotation.y = yaw
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)

	if plate:
		_plate(mi, tm, tint)
	return mi

static func _plate(mi: MeshInstance3D, tm: TextMesh, tint: Color) -> void:
	var s: Vector3 = tm.get_aabb().size
	if s.x <= 0.001 or s.y <= 0.001:
		return
	var qm := QuadMesh.new()
	qm.size = Vector2(s.x + s.y * 0.75, s.y + s.y * 0.55)
	var qmat := StandardMaterial3D.new()
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.albedo_color = Color(0.045, 0.052, 0.068, 1.0)
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qmat.albedo_color.a = 0.8
	qmat.render_priority = -1
	qmat.no_depth_test = false
	qm.material = qmat

	var qi := MeshInstance3D.new()
	qi.mesh = qm
	qi.position = Vector3(0.0, 0.0, -0.03)
	qi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.add_child(qi)