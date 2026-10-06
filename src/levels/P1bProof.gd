extends Node3D

const WALL_H := 3.2
const ROOM := Vector3(9.0, 0.0, 7.0)

var _hud: Hud
var _player: Player
var _receiver: BeamReceiver
var _stage: int = 0
var _await_switch := false
var _await_mark := false

func _ready() -> void:
	_build_world()
	_build_player()
	_build_hud()

	_hud.think("Nine fourteen. Every clock says nine fourteen.")
	_hud.think("So the Sun is gone, and they gave the job to me, and let's be clear who's winning here. I am.")

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("05070c")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("2c3a52")
	e.ambient_light_energy = 0.16
	e.fog_enabled = true
	e.fog_light_color = Color("101725")
	e.fog_density = 0.035
	env.environment = e
	add_child(env)

	var moon := DirectionalLight3D.new()
	moon.light_color = Color("9db4d6")
	moon.light_energy = 0.22
	moon.rotation_degrees = Vector3(-58, 34, 0)
	moon.shadow_enabled = false
	add_child(moon)

	var s := Vector3(ROOM.x, WALL_H, ROOM.z)
	var h := ROOM.x * 0.5
	var d := ROOM.z * 0.5

	_wall(Vector3(0, WALL_H * 0.5, -d), Vector3(s.x, WALL_H, 0.3), Color("2b2f38"))
	_wall(Vector3(0, WALL_H * 0.5, d), Vector3(s.x, WALL_H, 0.3), Color("23262e"))
	_wall(Vector3(-h, WALL_H * 0.5, 0), Vector3(0.3, WALL_H, s.z), Color("262a32"))
	_wall(Vector3(h, WALL_H * 0.5, 0), Vector3(0.3, WALL_H, s.z), Color("262a32"))
	_floor()

	_receiver = BeamReceiver.new()
	_receiver.clue_id = "I-06"
	_receiver.revealed_text = "9:14"
	_receiver.position = Vector3(0.0, 1.62, -d + 0.17)
	_receiver.revealed.connect(_on_revealed)
	add_child(_receiver)

	_switch_bank()
	_placard(Vector3(-2.4, 2.0, -d + 0.17), "MODULE 1:  LIGHT IS EVIDENCE")
	_placard(Vector3(2.4, 2.1, -d + 0.17), "THROW  A  AND  B")
	_lamp_prop()
	_mirror_prop()
	_clock_prop()

func _wall(pos: Vector3, size: Vector3, col: Color) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = 0.92
	mat.metallic = 0.0
	bm.material = mat
	add_child(mi)

	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

func _floor() -> void:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(ROOM.x, ROOM.z)
	mi.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("171a20")
	mat.roughness = 0.7
	pm.material = mat
	add_child(mi)

	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(ROOM.x, 0.2, ROOM.z)
	cs.shape = bs
	cs.position = Vector3(0, -0.1, 0)
	body.add_child(cs)
	add_child(body)

func _placard(pos: Vector3, text: String) -> void:
	var mi := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(1.5, 0.42)
	mi.mesh = qm
	mi.position = pos
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("b9c4d8")
	mat.emission_enabled = true
	mat.emission = Color("6d7c96")
	mat.emission_energy_multiplier = 0.5
	qm.material = mat
	add_child(mi)

func _switch_bank() -> void:
	_player_can_move(true)
	var names := ["A", "B", "C", "D"]
	for i in 4:
		var x: float = 2.55 + i * 0.34
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.2, 0.34, 0.08)
		mi.mesh = bm
		mi.position = Vector3(x, 1.55, -ROOM.z * 0.5 + 0.16)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("8c97aa")
		mat.emission_enabled = true
		mat.emission = Color("6d7c96")
		mat.emission_energy_multiplier = 0.4
		bm.material = mat
		add_child(mi)

func _lamp_prop() -> void:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.13
	sm.height = 0.26
	mi.mesh = sm
	mi.position = Vector3(-3.2, 0.13, 1.4)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("4a5262")
	mi.mesh.material = mat
	add_child(mi)

func _mirror_prop() -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.9, 1.2, 0.05)
	mi.mesh = bm
	mi.position = Vector3(2.9, 0.6, 1.2)
	mi.rotation_degrees = Vector3(0, -22, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("b9c8dd")
	mat.metallic = 0.85
	mat.roughness = 0.12
	bm.material = mat
	add_child(mi)

func _clock_prop() -> void:
	var tm := TextMesh.new()
	tm.text = "9:14:00"
	tm.font_size = 64
	tm.pixel_size = 0.004
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("9db4d6")
	mat.emission_enabled = true
	mat.emission = Color("9db4d6")
	mat.emission_energy_multiplier = 0.85
	tm.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = tm
	mi.position = Vector3(3.1, 2.25, -ROOM.z * 0.5 + 0.17)
	add_child(mi)

func _build_player() -> void:
	_player = Player.new()
	_player.position = Vector3(0, 0.1, 2.6)
	add_child(_player)
	_player.can_move = false
	_player.yaw = PI

func _build_hud() -> void:
	_hud = Hud.new()
	add_child(_hud)
	_hud.set_objective("Look at the mark on the far wall")

func _player_can_move(v: bool) -> void:
	if _player != null:
		_player.can_move = v

func _process(_delta: float) -> void:
	if _receiver != null:
		_hud.set_hold(_receiver.hold / _receiver.hold_time)

	if _await_mark:
		return

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var k := event as InputEventKey
	if not k.pressed or k.echo:
		return

	if k.keycode == KEY_E:
		_interact()

func _interact() -> void:
	if _await_switch:
		_await_switch = false
		_hud.set_objective("Look at the mark on the far wall")
		_hud.think("A team. A and B. Of course. Why would a thing need a team.")
		_hud.think("Sunwriting is invisible until the light is agreed upon.")
		_hud.set_objective("Hold your beam on the mark")
		_player_can_move(true)
		_receiver.armed = true
		_await_mark = true

func _on_revealed(_id: String) -> void:
	_hud.set_hold(0.0)
	_hud.set_objective("Ray writes it down")
	_hud.think("Nine fourteen. Yes. Everyone keeps saying nine fourteen.")
	_hud.think("Alright. Write it down, Ray.")
	_hud.toast("I-06", "9:14, written on the wall")
	_await_mark = false