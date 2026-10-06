class_name Trim

static func _box(parent: Node3D, pos: Vector3, size: Vector3, col: Color, rough: float = 0.8, rot_y: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.rotation_degrees = Vector3(0, rot_y, 0)
	bm.material = Surface.mat(col, 0.55, rough, 0.4)
	parent.add_child(mi)

static func _solid(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	parent.add_child(body)

static func skirting(parent: Node3D, room: Vector3, col: Color = Color("1a1d24")) -> void:
	var hx := room.x * 0.5
	var hz := room.z * 0.5
	var h := 0.16
	var t := 0.06
	_box(parent, Vector3(0, h * 0.5, -hz + t * 0.5), Vector3(room.x, h, t), col.darkened(0.15))
	_box(parent, Vector3(0, h * 0.5, hz - t * 0.5), Vector3(room.x, h, t), col.darkened(0.15))
	_box(parent, Vector3(-hx + t * 0.5, h * 0.5, 0), Vector3(t, h, room.z), col.darkened(0.15))
	_box(parent, Vector3(hx - t * 0.5, h * 0.5, 0), Vector3(t, h, room.z), col.darkened(0.15))

static func dado_rail(parent: Node3D, room: Vector3, height: float, col: Color = Color("20242c")) -> void:
	var hx := room.x * 0.5
	var hz := room.z * 0.5
	var t := 0.05
	var d := 0.09
	_box(parent, Vector3(0, height, -hz + d * 0.5), Vector3(room.x, 0.05, d), col)
	_box(parent, Vector3(0, height, hz - d * 0.5), Vector3(room.x, 0.05, d), col)
	_box(parent, Vector3(-hx + d * 0.5, height, 0), Vector3(d, 0.05, room.z), col)
	_box(parent, Vector3(hx - d * 0.5, height, 0), Vector3(d, 0.05, room.z), col)

static func panel_lines(parent: Node3D, room: Vector3, col: Color = Color("191c23")) -> void:
	var hx := room.x * 0.5
	var hz := room.z * 0.5
	var count := 4
	for i in range(1, count):
		var x: float = -hx + room.x * float(i) / float(count)
		_box(parent, Vector3(x, 1.6, -hz + 0.02), Vector3(0.035, 2.9, 0.03), col)
		_box(parent, Vector3(x, 1.6, hz - 0.02), Vector3(0.035, 2.9, 0.03), col)

static func ceiling_beams(parent: Node3D, room: Vector3, height: float, count: int = 4, col: Color = Color("23272f")) -> void:
	var hx := room.x * 0.5
	for i in count:
		var z: float = -room.z * 0.5 + room.z * (float(i) + 0.5) / float(count)
		_box(parent, Vector3(0, height - 0.13, z), Vector3(room.x, 0.22, 0.18), col)

static func door_frame(parent: Node3D, at: Vector3, width: float, height: float, facing: float, col: Color = Color("272b33")) -> void:
	var t := 0.12
	var d := 0.22
	var w := width
	_box(parent, at + Vector3(-w * 0.5 - t * 0.5, 0, 0), Vector3(t, height + t, d), col, 0.75, facing)
	_box(parent, at + Vector3(w * 0.5 + t * 0.5, 0, 0), Vector3(t, height + t, d), col, 0.75, facing)
	_box(parent, at + Vector3(0, height * 0.5 + t * 0.5, 0), Vector3(w + t * 2.0, t, d), col, 0.75, facing)

static func vent(parent: Node3D, at: Vector3, size: Vector2, facing: float, col: Color = Color("1c2027")) -> void:
	var body := Node3D.new()
	body.position = at
	body.rotation_degrees = Vector3(0, facing, 0)
	parent.add_child(body)
	var frame := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(size.x, size.y, 0.07)
	frame.mesh = bm
	bm.material = Surface.mat(col, 0.7, 0.7, 0.5)
	body.add_child(frame)
	var slats := int(size.y / 0.09)
	for i in slats:
		var s := MeshInstance3D.new()
		var sm := BoxMesh.new()
		sm.size = Vector3(size.x * 0.86, 0.03, 0.05)
		s.mesh = sm
		sm.material = Surface.metal(Color("2a2f38"), 0.45)
		s.position = Vector3(0, -size.y * 0.5 + 0.06 + i * 0.09, 0.05)
		s.rotation_degrees = Vector3(-24, 0, 0)
		body.add_child(s)

static func conduit(parent: Node3D, from: Vector3, to: Vector3, radius: float = 0.05, col: Color = Color("20242b")) -> void:
	var dir := to - from
	var len := dir.length()
	if len < 0.01:
		return
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = len
	cm.radial_segments = 10
	mi.mesh = cm
	cm.material = Surface.metal(col, 0.42)
	mi.position = (from + to) * 0.5
	var axis := dir.normalized()
	if absf(axis.dot(Vector3.UP)) > 0.99:
		mi.rotation_degrees = Vector3(0, 0, 0)
	elif absf(axis.dot(Vector3.RIGHT)) > 0.99:
		mi.rotation_degrees = Vector3(0, 0, 90)
	else:
		mi.rotation_degrees = Vector3(90, 0, 0)
	parent.add_child(mi)