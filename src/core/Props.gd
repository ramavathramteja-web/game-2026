class_name Props

static func crate(parent: Node3D, at: Vector3, size: Vector3, rot_y: float = 0.0) -> void:
	var body := StaticBody3D.new()
	body.position = at + Vector3(0, size.y * 0.5, 0)
	body.rotation_degrees = Vector3(0, rot_y, 0)
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	parent.add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	bm.material = Surface.textured(Color("3a3026"), "wood", 1.6, 0.55, 1.0, 0.8)
	body.add_child(mi)

	var lid := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(size.x * 1.04, 0.05, size.z * 1.04)
	lid.mesh = lm
	lm.material = Surface.textured(Color("453a2c"), "wood", 1.6, 0.55, 1.0, 0.8)
	lid.position = Vector3(0, size.y * 0.5, 0)
	body.add_child(lid)

static func papers(parent: Node3D, at: Vector3, count: int = 5, spread: float = 0.5) -> void:
	for i in count:
		var mi := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(0.21, 0.29)
		mi.mesh = pm
		mi.position = at + Vector3(
			randf_range(-spread, spread), 0.004 + i * 0.002, randf_range(-spread, spread))
		mi.rotation_degrees = Vector3(-90, randf_range(0, 360), 0)
		var m := StandardMaterial3D.new()
		m.albedo_color = Color("6f6a5d").darkened(randf_range(0.05, 0.45))
		m.roughness = 0.98
		m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		pm.material = m
		parent.add_child(mi)

static func chair(parent: Node3D, at: Vector3, rot_y: float = 0.0) -> void:
	var root := Node3D.new()
	root.position = at
	root.rotation_degrees = Vector3(0, rot_y, 0)
	parent.add_child(root)

	var seat := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.44, 0.05, 0.42)
	seat.mesh = sm
	sm.material = Surface.mat(Color("33291f"), 0.7, 0.9, 0.5)
	seat.position = Vector3(0, 0.45, 0)
	root.add_child(seat)

	var back := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.44, 0.5, 0.05)
	back.mesh = bm
	bm.material = Surface.mat(Color("33291f"), 0.7, 0.9, 0.5)
	back.position = Vector3(0, 0.72, -0.19)
	root.add_child(back)

	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var leg := MeshInstance3D.new()
			var lm := BoxMesh.new()
			lm.size = Vector3(0.04, 0.45, 0.04)
			leg.mesh = lm
			lm.material = Surface.metal(Color("2b2f36"), 0.5)
			leg.position = Vector3(0.19 * sx, 0.22, 0.18 * sz)
			root.add_child(leg)

	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.46, 0.9, 0.46)
	cs.shape = bs
	cs.position = Vector3(0, 0.45, 0)
	body.add_child(cs)
	root.add_child(body)

static func cabinet(parent: Node3D, at: Vector3, size: Vector3, rot_y: float = 0.0) -> void:
	var body := StaticBody3D.new()
	body.position = at + Vector3(0, size.y * 0.5, 0)
	body.rotation_degrees = Vector3(0, rot_y, 0)
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	parent.add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	bm.material = Surface.mat(Color("2c313a"), 0.5, 0.55, 0.35)
	body.add_child(mi)

	var drawers := int(size.y / 0.34)
	for i in drawers:
		var d := MeshInstance3D.new()
		var dm := BoxMesh.new()
		dm.size = Vector3(size.x * 0.9, 0.28, 0.04)
		d.mesh = dm
		dm.material = Surface.mat(Color("333944"), 0.45, 0.5, 0.3)
		d.position = Vector3(0, -size.y * 0.5 + 0.2 + i * 0.34, size.z * 0.5 + 0.02)
		body.add_child(d)

static func bucket(parent: Node3D, at: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.16
	cm.bottom_radius = 0.12
	cm.height = 0.26
	cm.radial_segments = 14
	mi.mesh = cm
	mi.position = at + Vector3(0, 0.13, 0)
	cm.material = Surface.metal(Color("4a4f57"), 0.55)
	parent.add_child(mi)