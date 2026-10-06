class_name Room

## Architectural details that make an interior read as a real building rather
## than a box. Sizes follow real UK dimensions (86mm plates, 1.2m switch height,
## 30cm sockets) so the scale reads correctly next to a 1.7m player.

const PLATE := Vector3(0.086, 0.086, 0.008)
const SWITCH_H := 1.20
const SOCKET_H := 0.30

static func _mat(col: Color, rough: float = 0.72) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	return m

static func _box(parent: Node3D, at: Vector3, size: Vector3, mat: Material,
		rot_y_deg: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = at
	mi.rotation_degrees = Vector3(0, rot_y_deg, 0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)

## A wall socket: plate plus two pin slots.
static func socket(parent: Node3D, at: Vector3, facing: float = 0.0) -> void:
	var plate := _mat(Color("b9bcc2"), 0.55)
	_box(parent, at, PLATE, plate, facing)
	var hole := _mat(Color("14161a"), 0.9)
	var off := Vector3(0.0, 0.0, 0.006)
	_box(parent, at + off + Vector3(-0.011, 0.014, 0.0), Vector3(0.006, 0.016, 0.004), hole, facing)
	_box(parent, at + off + Vector3(0.011, 0.014, 0.0), Vector3(0.006, 0.016, 0.004), hole, facing)
	_box(parent, at + off + Vector3(0.0, -0.012, 0.0), Vector3(0.018, 0.005, 0.004), hole, facing)

## A window, boarded over. The Sun stopped; Ray would have shut the house up.
static func boarded_window(parent: Node3D, at: Vector3, facing: float,
		w: float = 1.1, h: float = 1.3) -> void:
	var frame := _mat(Color("3b3a36"), 0.78)
	var reveal := _mat(Color("0a0c11"), 0.95)
	var f := 0.06
	# Dark reveal so the opening reads as depth, not a painted rectangle.
	_box(parent, at, Vector3(w, h, 0.02), reveal, facing)
	# Frame: two uprights, head, sill.
	_box(parent, at + Vector3(-w * 0.5 + f * 0.5, 0, 0.01), Vector3(f, h + f, 0.05), frame, facing)
	_box(parent, at + Vector3(w * 0.5 - f * 0.5, 0, 0.01), Vector3(f, h + f, 0.05), frame, facing)
	_box(parent, at + Vector3(0, h * 0.5 - f * 0.5, 0.01), Vector3(w, f, 0.05), frame, facing)
	_box(parent, at + Vector3(0, -h * 0.5 - 0.02, 0.06), Vector3(w + 0.14, 0.05, 0.14), frame, facing)
	# Boarding: planks at slightly different angles, nailed across.
	var plank := Surface.textured(Color("4a3a28"), "wood", 2.4, 0.5, 0.9, 0.85)
	var y := -h * 0.5 + 0.16
	var i := 0
	while y < h * 0.5 - 0.05:
		var ang := -9.0 + float(i % 3) * 7.0
		_box(parent, at + Vector3(0, y, 0.035), Vector3(w + 0.10, 0.17, 0.022), plank, facing)
		var bm := Node3D.new()
		bm.position = at + Vector3(0, y, 0.05)
		bm.rotation_degrees = Vector3(0, facing, ang)
		parent.add_child(bm)
		y += 0.21
		i += 1

## Ceiling rose plus a pendant. Gives the room an actual light fitting.
static func pendant(parent: Node3D, at: Vector3, drop: float = 0.42,
		warm: bool = true) -> void:
	var rose := _mat(Color("cfc7b8"), 0.8)
	_box(parent, at + Vector3(0, 0.012, 0), Vector3(0.24, 0.025, 0.24), rose)
	_box(parent, at + Vector3(0, -0.005, 0), Vector3(0.13, 0.02, 0.13), rose)
	var flex := _mat(Color("1e1c1a"), 0.9)
	_box(parent, at + Vector3(0, -drop * 0.5, 0), Vector3(0.012, drop, 0.012), flex)
	var shade := _mat(Color("e8dcc4") if warm else Color("8d9bb0"), 0.85)
	shade.emission_enabled = warm
	shade.emission = Color("ffcf8a")
	shade.emission_energy_multiplier = 0.9
	var cone := CylinderMesh.new()
	cone.top_radius = 0.045
	cone.bottom_radius = 0.15
	cone.height = 0.17
	cone.radial_segments = 16
	var sm := MeshInstance3D.new()
	sm.mesh = cone
	sm.material_override = shade
	sm.position = at + Vector3(0, -drop - 0.07, 0)
	sm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(sm)

## Cornice: the moulding where wall meets ceiling. Cheap and very readable.
static func cornice(parent: Node3D, room: Vector3, height: float) -> void:
	var c := _mat(Color("33363d"), 0.8)
	var hx := room.x * 0.5
	var hz := room.z * 0.5
	var d := 0.09
	_box(parent, Vector3(0, height - d * 0.6, -hz + d * 0.5), Vector3(room.x, d * 1.2, d), c)
	_box(parent, Vector3(0, height - d * 0.6, hz - d * 0.5), Vector3(room.x, d * 1.2, d), c)
	_box(parent, Vector3(-hx + d * 0.5, height - d * 0.6, 0), Vector3(d, d * 1.2, room.z), c)
	_box(parent, Vector3(hx - d * 0.5, height - d * 0.6, 0), Vector3(d, d * 1.2, room.z), c)

## Door architrave, so the doorway is a hole in a wall rather than a gap.
static func architrave(parent: Node3D, at: Vector3, width: float, height: float,
		facing: float = 0.0) -> void:
	var t := 0.09
	var a := _mat(Color("4a463f"), 0.8)
	_box(parent, at + Vector3(-width * 0.5 - t * 0.5, height * 0.5, 0.01), Vector3(t, height + t, 0.05), a, facing)
	_box(parent, at + Vector3(width * 0.5 + t * 0.5, height * 0.5, 0.01), Vector3(t, height + t, 0.05), a, facing)
	_box(parent, at + Vector3(0, height + t * 0.5, 0.01), Vector3(width + t * 2.0, t, 0.05), a, facing)