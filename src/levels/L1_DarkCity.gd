extends Node3D

const ROOM := Vector3(10.0, 0.0, 8.0)
const WALL_H := 3.2

var hud: Hud
var player: Player
var runner: DialogueRunner
var receiver: BeamReceiver
var notebook: Notebook

var _sw_a: LightSwitch
var _sw_b: LightSwitch
var _sw_c: LightSwitch
var _sw_d: LightSwitch
var _switches: Array[LightSwitch] = []

var _done_a := false
var _done_b := false
var _c_jokes := 0
var _beat_done := false

const INTRO := [
	{ "t": "thought", "s": "Nine fourteen. Every clock says nine fourteen." },
	{ "t": "thought", "s": "So the Sun is gone, and they gave the job to me, and let's be clear who's winning here. I am." },
	{ "t": "thought", "s": "The last hour is soft. Not missing. Soft. There's a difference and I'm being very generous about it." },
	{ "t": "objective", "s": "Throw switches A and B" },
]

const AFTER_AB := [
	{ "t": "flag", "s": "annex_power" },
	{ "t": "thought", "s": "A team. A and B. Of course. Why would a thing need a team." },
	{ "t": "objective", "s": "Hold your beam on the mark" },
]

const REVEALED := [
	{ "t": "thought", "s": "Nine fourteen. Yes. Everyone keeps saying nine fourteen." },
	{ "t": "thought", "s": "Alright. Write it down, Ray." },
	{ "t": "thought", "s": "Might as well. Somebody will want it signed." },
	{ "t": "objective", "s": "Look at the lectern" },
	{ "t": "thought", "s": "Might as well. Somebody will want it signed." },
]

func _ready() -> void:
	Snd.set_track("l1")
	_build_world()
	var hz := ROOM.z * 0.5
	_build_actors(hz)
	_gate(hz)
	_build_hud()
	player.can_move = true
	await get_tree().create_timer(0.6).timeout
	runner.play(INTRO)

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("020306")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("0d121c")
	e.ambient_light_energy = 0.05
	e.fog_enabled = true
	e.fog_density = 0.012
	e.fog_light_color = Color("05070c")
	Atmosphere.apply(e, 0.05)
	env.environment = e
	add_child(env)

	TorchDust.build(self)

	var hx := ROOM.x * 0.5
	var hz := ROOM.z * 0.5
	_wall(Vector3(0, WALL_H * 0.5, -hz), Vector3(ROOM.x, WALL_H, 0.3), Color("20232a"))
	_wall(Vector3(0, WALL_H * 0.5, hz), Vector3(ROOM.x, WALL_H, 0.3), Color("1a1c22"))
	_wall(Vector3(-hx, WALL_H * 0.5, 0), Vector3(0.3, WALL_H, ROOM.z), Color("1d2026"))
	_wall(Vector3(hx, WALL_H * 0.5, 0), Vector3(0.3, WALL_H, ROOM.z), Color("1d2026"))
	_floor()
	_ceiling()

	Trim.skirting(self, ROOM)
	Trim.dado_rail(self, ROOM, 1.0)
	Trim.ceiling_beams(self, ROOM, WALL_H, 3)

func _wall(pos: Vector3, size: Vector3, color: Color) -> void:
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
	var mat := Surface.textured(color, "wall", 0.9, 0.35, 1.0, 0.5)
	bm.material = mat
	body.add_child(mi)

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
	var mat := Surface.textured(Color("16181f"), "floor", 0.7, 0.35, 1.0, 0.5)
	pm.material = mat
	add_child(mi)

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
	var mat := Surface.mat(Color("14171d"), 0.45, 0.8, 0.25)
	bm.material = mat
	mi.position = Vector3(0, WALL_H + 0.1, 0)
	body.add_child(mi)

func _dress(hz: float) -> void:
	var hx := ROOM.x * 0.5

	Room.cornice(self, ROOM, WALL_H)
	Room.architrave(self, Vector3(0.0, 0.0, hz - 0.10), 1.5, 2.15, 180.0)

	Room.boarded_window(self, Vector3(-hx + 0.10, 1.55, -1.9), 90.0)
	Room.boarded_window(self, Vector3(hx - 0.10, 1.55, 1.9), -90.0)

	Room.socket(self, Vector3(2.6, Room.SOCKET_H, -hz + 0.09))
	Room.socket(self, Vector3(-hx + 0.09, Room.SOCKET_H, 2.6), 90.0)

	Room.pendant(self, Vector3(0.0, WALL_H - 0.02, 0.4), 0.46, false)

func _gate(hz: float) -> void:
	var gate := GateDoor.new()
	gate.gate_id = "to_suspect_street"
	gate.position = Vector3(0.0, 1.1, hz - 0.15)
	gate.opened.connect(func() -> void:
		Game.set_flag("annex_door_open", true)
		if hud != null:
			hud.set_objective("Step through to the Street")
	)
	add_child(gate)

	var travel := Area3D.new()
	travel.position = Vector3(0.0, 1.0, hz - 1.0)
	travel.collision_layer = 0
	travel.collision_mask = 2
	var tcs := CollisionShape3D.new()
	var tbs := BoxShape3D.new()
	tbs.size = Vector3(1.6, 2.2, 1.2)
	tcs.shape = tbs
	travel.add_child(tcs)
	add_child(travel)

	var lg := LevelGate.new()
	lg.gate_id = "leave_annex"
	travel.add_child(lg)
	travel.body_entered.connect(func(_b: Node3D) -> void:
		if lg.can_enter():
			lg.travel()
	)

	receiver = BeamReceiver.new()
	receiver.clue_id = "I-06"
	receiver.revealed_text = "9:14"
	receiver.position = Vector3(-1.8, 1.50, -hz + 0.17)
	receiver.revealed.connect(_on_revealed)
	add_child(receiver)

	_placard(Vector3(-3.5, 2.35, -hz + 0.17), "MODULE 1:\nLIGHT IS EVIDENCE", 1.7)
	_placard(Vector3(2.5, 2.35, -hz + 0.17), "THROW\nA AND B", 1.5)
	_placard(Vector3(-1.8, 2.35, -hz + 0.17), "HOLD YOUR BEAM\nON THE MARK", 1.7)
	_clock_prop(hz)
	_mirror_prop()
	_lamp_prop()
	_lectern(hz)
	_dress(hz)

# Desk prop with mirror surface
func _mirror_prop() -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(-4.5, 1.5, 1.6)
	body.rotation_degrees = Vector3(0, 15, 0)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.86, 1.4, 0.07)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.8, 1.3, 0.05)
	mi.mesh = bm
	bm.material = Surface.mirror_glass()
	body.add_child(mi)

	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color("2c2620")
	frame.roughness = 0.72
	frame.metallic = 0.25

	var mi2 := MeshInstance3D.new()
	var bm2 := BoxMesh.new()
	bm2.size = Vector3(0.86, 1.4, 0.07)
	mi2.mesh = bm2
	mi2.material_override = frame
	mi2.position = Vector3(0, 0, 0.06)
	mi2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mi2)

	var mi3 := MeshInstance3D.new()
	var bm3 := BoxMesh.new()
	bm3.size = Vector3(0.86, 0.14, 0.07)
	mi3.mesh = bm3
	mi3.material_override = frame
	mi3.position = Vector3(0, -0.7, 0.06)
	body.add_child(mi3)

func _lamp_prop() -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(4.5, 1.5, 1.6)
	body.rotation_degrees = Vector3(0, -15, 0)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.86, 1.4, 0.07)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.8, 1.3, 0.05)
	mi.mesh = bm
	bm.material = Surface.mirror_glass()
	body.add_child(mi)

	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color("2c2620")
	frame.roughness = 0.72
	frame.metallic = 0.25

	for side in [-1, 1]:
		var mi2 := MeshInstance3D.new()
		var bm2 := BoxMesh.new()
		bm2.size = Vector3(0.86, 1.4, 0.07)
		mi2.mesh = bm2
		mi2.material_override = frame
		mi2.position = Vector3(side * 0.43, 0, 0.06)
		mi2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		body.add_child(mi2)

func _lectern(hz: float) -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(-0.6, 0.6, -hz + 0.17)
	body.rotation_degrees = Vector3(0, 0, 0)
	body.collision_layer = 1
	body.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.6, 1.2, 0.4)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.6, 1.2, 0.4)
	mi.mesh = bm
	var mat := Surface.mat(Color("3a3026"), 0.75, 0.92, 0.6)
	bm.material = mat
	body.add_child(mi)

	var top := MeshInstance3D.new()
	var bm2 := BoxMesh.new()
	bm2.size = Vector3(0.65, 0.08, 0.45)
	top.mesh = bm2
	top.material_override = Surface.mat(Color("3a3026"), 0.75, 0.92, 0.6)
	top.position = Vector3(0, 0.64, 0)
	body.add_child(top)

	var log := LogProp.new()
	log.position = Vector3(-0.6, 1.30, -hz + 0.17)
	add_child(log)

func _build_actors(hz: float) -> void:
	player = Player.new()
	player.position = Vector3(-0.2, 0.1, 2.8)
	player.rotation_degrees = Vector3(0, 0, 0)
	add_child(player)

	_sw_a = LightSwitch.new()
	_sw_a.letter = "A"
	_sw_a.position = Vector3(1.55, 1.20, -hz + 0.19)
	_sw_a.thrown.connect(_on_switch)
	add_child(_sw_a)
	_switches.append(_sw_a)

	_sw_b = LightSwitch.new()
	_sw_b.letter = "B"
	_sw_b.position = Vector3(2.07, 1.20, -hz + 0.19)
	_sw_b.thrown.connect(_on_switch)
	add_child(_sw_b)
	_switches.append(_sw_b)

	_sw_c = LightSwitch.new()
	_sw_c.letter = "C"
	_sw_c.position = Vector3(2.59, 1.20, -hz + 0.19)
	_sw_c.thrown.connect(_on_switch)
	add_child(_sw_c)
	_switches.append(_sw_c)

	_sw_d = LightSwitch.new()
	_sw_d.letter = "D"
	_sw_d.position = Vector3(3.11, 1.20, -hz + 0.19)
	_sw_d.thrown.connect(_on_switch)
	add_child(_sw_d)
	_switches.append(_sw_d)

func _build_hud() -> void:
	hud = Hud.new()
	hud.setup_switches(_switches)
	add_child(hud)
	runner = DialogueRunner.new()
	runner.hud = hud
	add_child(runner)
	Game.runner = runner
	notebook = Notebook.new()
	add_child(notebook)

func _placard(pos: Vector3, text: String, _height: float) -> void:
	var tm := TextMesh.new()
	tm.font = preload("res://assets/Cinzel.tres")
	tm.text = text
	tm.font_size = 56
	tm.pixel_size = 0.004
	tm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("d9f2a8")
	mat.emission_enabled = true
	mat.emission = Color("d9f2a8")
	mat.emission_energy_multiplier = 2.2
	tm.material = mat

	var mi := MeshInstance3D.new()
	mi.mesh = tm
	mi.material_override = mat
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

	mi.scale = Vector3.ONE * 0.6
	var tw := create_tween()
	tw.tween_property(mi, "scale", Vector3.ONE, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _clock_prop(hz: float) -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(0.0, 2.8, -hz + 0.17)
	body.rotation_degrees = Vector3(0, 0, 0)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.2, 0.5, 0.05)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.1, 0.45, 0.05)
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("1a1c20")
	mat.roughness = 0.72
	mat.metallic = 0.05
	bm.material = mat
	body.add_child(mi)

	var tm := TextMesh.new()
	tm.font = preload("res://assets/Cinzel.tres")
	tm.text = "9:14:00"
	tm.font_size = 64
	tm.pixel_size = 0.004
	var tmat := StandardMaterial3D.new()
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tmat.albedo_color = Color("9db4d6")
	tmat.emission_enabled = true
	tmat.emission = Color("9db4d6")
	tmat.emission_energy_multiplier = 1.0
	tm.material = tmat
	var tmi := MeshInstance3D.new()
	tmi.mesh = tm
	tmi.position = Vector3(0.0, 0.0, 0.04)
	body.add_child(tmi)

func _find_switch(letter: String) -> int:
	for i in range(_switches.size()):
		if _switches[i].letter == letter:
			return i
	return -1

func _on_revealed(id: String) -> void:
	Game.add_clue(id)
	Game.set_flag("annex_power", true)
	Game.set_flag("solved_p1b", true)
	if hud != null:
		hud.set_objective("Leave the annex")
	runner.play(REVEALED)

func _on_switch_used(letter: String) -> void:
	var idx := _find_switch(letter)
	if idx >= 0:
		_switches[idx].consumed = true

func _on_switch(letter: String) -> void:
	Snd.sfx("switch", -3.0)
	if _sw_a != null and _sw_b != null and _sw_a.is_thrown and _sw_b.is_thrown:
		if receiver != null and not receiver.armed:
			receiver.armed = true
			if not _beat_done:
				_beat_done = true
				runner.play(AFTER_AB)