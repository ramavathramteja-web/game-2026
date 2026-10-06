extends Node3D

const WALL_H := 3.2
const ROOM := Vector3(10.0, 0.0, 8.0)

var player: Player
var hud: Hud
var runner: DialogueRunner
var notebook: Notebook
var wall: BeamReceiver

var _lamp_done := false
var _mirror_done := false
var _sw_a: LightSwitch
var _sw_b: LightSwitch
var _switches_done := false
var _rebuilt := false
var _case_checked := false

const OPEN := [
	{ "t": "thought", "s": "I know this room. I don't know how I know this room." },
	{ "t": "objective", "s": "Put the light back the way it was" },
]

const M1 := [
	{ "t": "say", "who": "MARLOW (MEMORY)", "s": "It's all there. Line twelve says why." },
	{ "t": "thought", "s": "A restart pushes the east feed first. Nine fourteen in the morning." },
	{ "t": "thought", "s": "That's every office, every school, every cafe in this city. And they're all awake." },
]

const M2 := [
	{ "t": "thought", "s": "Open case. Somebody has to be holding it." },
]

const REVEALED := [
	{ "t": "say", "who": "RAY", "s": "It is not a trick. The case has to be closed by someone who did not close it. I am sorry." },
	{ "t": "thought", "s": "Also line twelve is still on the wall. Use the light." },
	{ "t": "objective", "s": "Read the Custody Transfer panel" },
]

const AFTER_PANEL := [
	{ "t": "thought", "s": "I turned it off." },
	{ "t": "thought", "s": "I turned it off to stop the restart from killing everybody who was awake." },
	{ "t": "thought", "s": "And then I made myself forget, and I sent myself out here to find out who did it." },
	{ "t": "thought", "s": "That's the worst thing I've ever heard. And I respect it enormously." },
	{ "t": "objective", "s": "Open the notebook and close the case" },
]

func _ready() -> void:
	Snd.set_track("l5")
	_build_env()
	_build_room()
	_build_elements()
	_actors()
	_hud_build()
	player.can_move = true
	await get_tree().create_timer(0.5).timeout
	runner.play(OPEN)

func _build_env() -> void:
	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("04050a")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("3a4763")
	e.ambient_light_energy = 0.34
	e.fog_enabled = true
	e.fog_light_color = Color("131b2a")
	e.fog_density = 0.026
	e.ssr_enabled = true
	Atmosphere.apply(e, 0.34)
	env.environment = e
	add_child(env)
	TorchDust.build(self)

func _build_room() -> void:
	var hz := ROOM.z * 0.5
	var hx := ROOM.x * 0.5
	_wall(Vector3(0, WALL_H * 0.5, -hz), Vector3(ROOM.x, WALL_H, 0.3), Color("2b2f38"))
	_wall(Vector3(0, WALL_H * 0.5, hz), Vector3(ROOM.x, WALL_H, 0.3), Color("23262e"))
	_wall(Vector3(-hx, WALL_H * 0.5, 0), Vector3(0.3, WALL_H, ROOM.z), Color("262a32"))
	_wall(Vector3(hx, WALL_H * 0.5, 0), Vector3(0.3, WALL_H, ROOM.z), Color("262a32"))
	_floor()
	_ceiling()

	Trim.skirting(self, ROOM)
	Trim.dado_rail(self, ROOM, 1.0)
	Trim.ceiling_beams(self, ROOM, WALL_H, 3)
	_dress()
	_fill_lights()
	Props.papers(self, Vector3(-1.4, 0.0, 1.8), 6, 0.6)
	Props.crate(self, Vector3(3.9, 0.0, 2.6), Vector3(0.46, 0.38, 0.46), -16.0)

	wall = BeamReceiver.new()
	wall.clue_id = "Z-02"
	wall.revealed_text = "THE CASE HAS TO BE CLOSED\nBY SOMEONE WHO DID NOT CLOSE IT.\nI AM SORRY."
	wall.hold_time = 1.1
	wall.position = Vector3(0.0, 1.62, -hz + 0.17)
	wall.revealed.connect(_on_wall)
	add_child(wall)

	_text(Vector3(0.0, 2.62, -hz + 0.17), "THE MARK", 0.30)

	# demo lamp
	var lamp := Interactable.new()
	lamp.prompt = "Take the demo lamp"
	lamp.interact_range = 2.4
	lamp.position = Vector3(-3.2, 0.9, 1.4)
	add_child(lamp)
	var l_cs := CollisionShape3D.new()
	var l_bs := BoxShape3D.new()
	l_bs.size = Vector3(0.5, 0.5, 0.5)
	l_cs.shape = l_bs
	lamp.add_child(l_cs)
	var l_mi := MeshInstance3D.new()
	var l_bm := BoxMesh.new()
	l_bm.size = Vector3(0.34, 0.34, 0.34)
	l_mi.mesh = l_bm
	var l_mat := StandardMaterial3D.new()
	l_mat.albedo_color = Color("4a5262")
	l_bm.material = l_mat
	lamp.add_child(l_mi)
	lamp.used.connect(func(_w: Node) -> void: _on_lamp())

	# swivel mirror
	var mirror := Interactable.new()
	mirror.prompt = "Set the swivel mirror"
	mirror.interact_range = 2.4
	mirror.position = Vector3(-2.6, 1.5, 0.6)
	mirror.rotation_degrees = Vector3(0, -14, 0)
	add_child(mirror)
	var m_cs := CollisionShape3D.new()
	var m_bs := BoxShape3D.new()
	m_bs.size = Vector3(0.8, 1.1, 0.06)
	m_cs.shape = m_bs
	mirror.add_child(m_cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.8, 1.1, 0.05)
	mi.mesh = bm
	bm.material = Surface.mirror_glass()
	mirror.add_child(mi)
	mirror.used.connect(func(_w: Node) -> void: _on_mirror())

	# switches
	var letters := ["A", "B"]
	for i in 2:
		var sw := LightSwitch.new()
		sw.letter = letters[i]
		sw.position = Vector3(1.9 + i * 0.5, 1.20, -hz + 0.19)
		add_child(sw)
		sw.thrown.connect(func(_l: String) -> void: _on_switch())
		if i == 0:
			_sw_a = sw
		else:
			_sw_b = sw

	_text(Vector3(2.15, 2.2, -hz + 0.19), "A        B", 0.26)

	# custody panel
	var panel := Interactable.new()
	panel.prompt = "Read the Custody Transfer panel"
	panel.interact_range = 2.6
	panel.position = Vector3(3.6, 1.6, -hz + 0.24)
	add_child(panel)
	var p_cs := CollisionShape3D.new()
	var p_bs := BoxShape3D.new()
	p_bs.size = Vector3(1.2, 0.8, 0.1)
	p_cs.shape = p_bs
	panel.add_child(p_cs)
	var p_mi := MeshInstance3D.new()
	var p_bm := BoxMesh.new()
	p_bm.size = Vector3(1.2, 0.8, 0.1)
	p_mi.mesh = p_bm
	var p_mat := StandardMaterial3D.new()
	p_mat.albedo_color = Color("3a4250")
	p_bm.material = p_mat
	panel.add_child(p_mi)
	_text(Vector3(3.6, 2.32, -hz + 0.24), "CUSTODY\nTRANSFER", 0.23)
	panel.used.connect(func(_w: Node) -> void: _on_panel())

func _build_elements() -> void:
	pass

func _actors() -> void:
	player = Player.new()
	player.position = Vector3(0.0, 0.1, 2.8)
	add_child(player)

func _hud_build() -> void:
	hud = Hud.new()
	add_child(hud)
	runner = DialogueRunner.new()
	runner.hud = hud
	add_child(runner)
	Game.runner = runner
	notebook = Notebook.new()
	add_child(notebook)
	hud.set_objective("Put the light back the way it was")

func _prop_box(pos: Vector3, size: Vector3, col: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	bm.material = mat
	body.add_child(mi)

func _text(pos: Vector3, txt: String, height: float = 0.24) -> void:
	Sign.label(self, pos, txt, height)

func _check_rebuilt() -> void:
	if _rebuilt:
		return
	if not (_lamp_done and _mirror_done and _switches_done):
		return
	_rebuilt = true
	wall.armed = true
	hud.set_objective("Hold your beam on the mark")
	hud.think("The light goes this way. I know this way.")

func _on_lamp() -> void:
	if _lamp_done:
		return
	_lamp_done = true
	hud.think("Do not use. Obviously. I'm going to use it.")
	_check_rebuilt()

func _on_mirror() -> void:
	if _mirror_done:
		return
	_mirror_done = true
	hud.think("Why's the mirror like that? Nobody sets a mirror like that.")
	_check_rebuilt()

func _on_switch() -> void:
	if _sw_a.is_thrown and _sw_b.is_thrown:
		_switches_done = true
		hud.think("A team. A and B. Of course.")
	_check_rebuilt()

func _on_wall(_id: String) -> void:
	hud.toast("Z-02", Game.clue_title("Z-02"))
	runner.play(REVEALED)

func _on_panel() -> void:
	if Game.has_clue("Z-01"):
		return
	Game.add_clue("Z-01")
	hud.toast("Z-01", Game.clue_title("Z-01"))
	runner.play(AFTER_PANEL)

func _process(_d: float) -> void:
	if _case_checked or Game.closed_case:
		return
	_case_checked = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func _fill_lights() -> void:
	var spots := [Vector2(0.0, -2.2), Vector2(0.0, 2.0), Vector2(3.6, 0.4)]
	for i in spots.size():
		var at: Vector2 = spots[i]
		var fixture := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.7, 0.08, 0.2)
		fixture.mesh = bm
		fixture.position = Vector3(at.x, WALL_H - 0.26, at.y)
		var fmat := StandardMaterial3D.new()
		fmat.albedo_color = Color("4a3c2c")
		fmat.emission_enabled = true
		fmat.emission = Color("d99a4e")
		fmat.emission_energy_multiplier = 1.4
		bm.material = fmat
		add_child(fixture)

		var lamp := OmniLight3D.new()
		lamp.light_color = Color("e0a765")
		lamp.light_energy = 0.85
		lamp.omni_range = 11.0
		lamp.omni_attenuation = 0.7
		lamp.shadow_enabled = false
		lamp.position = Vector3(at.x, WALL_H - 0.55, at.y)
		add_child(lamp)

## Same real-building dressing as the annex: cornice, architrave, boarded
## windows, sockets and a dead pendant. This is the room the game ends in.
func _dress() -> void:
	var hz := ROOM.z * 0.5
	var hx := ROOM.x * 0.5

	# Desk near the control panel
	var desk := MeshInstance3D.new()
	var dm := BoxMesh.new()
	dm.size = Vector3(1.2, 0.75, 0.7)
	desk.mesh = dm
	desk.material_override = Surface.mat(Color("3a3026"), 0.75, 0.92, 0.6)
	desk.position = Vector3(-4.0, 0.375, 1.5)
	add_child(desk)

	# Chair
	var chair := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.45, 0.85, 0.45)
	chair.mesh = cm
	chair.material_override = Surface.mat(Color("3a3026"), 0.75, 0.9, 0.6)
	chair.position = Vector3(-4.0, 0.425, 2.5)
	add_child(chair)

	# Console/panel near the switch
	var console := MeshInstance3D.new()
	var com := BoxMesh.new()
	com.size = Vector3(1.0, 1.0, 0.3)
	console.mesh = com
	console.material_override = Surface.mat(Color("2e2823"), 0.8, 0.9, 0.3)
	console.position = Vector3(2.5, 1.0, -hz + 1.0)
	add_child(console)

	Room.cornice(self, ROOM, WALL_H)
	Room.architrave(self, Vector3(0.0, 0.0, hz - 0.10), 1.5, 2.15, 180.0)
	Room.boarded_window(self, Vector3(-hx + 0.10, 1.55, -1.4), 90.0)
	Room.socket(self, Vector3(-2.4, Room.SOCKET_H, -hz + 0.09))
	Room.socket(self, Vector3(3.0, Room.SOCKET_H, -hz + 0.09))
	Room.pendant(self, Vector3(0.0, WALL_H - 0.02, -0.6), 0.46, false)

func _wall(pos: Vector3, size: Vector3, col: Color) -> void:
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

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var mat := Surface.textured(col, "wall", 0.9, 0.35, 1.0, 0.5)
	bm.material = mat
	body.add_child(mi)

func _ceiling() -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(ROOM.x, 0.2, ROOM.z)
	cs.shape = bs
	cs.position = Vector3(0, WALL_H + 0.1, 0)
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(ROOM.x, 0.2, ROOM.z)
	mi.mesh = bm
	mi.position = Vector3(0, WALL_H + 0.1, 0)
	var mat := Surface.mat(Color("14171d"), 0.45, 0.8, 0.25)
	bm.material = mat
	add_child(mi)

func _floor() -> void:
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

	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(ROOM.x, ROOM.z)
	mi.mesh = pm
	var mat := Surface.textured(Color("171a20"), "floor", 0.7, 0.35, 1.0, 0.5)
	pm.material = mat
	add_child(mi)