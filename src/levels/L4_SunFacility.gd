extends Node3D

const WALL_H := 3.6
const ROOM := Vector3(14.0, 0.0, 12.0)

var player: Player
var hud: Hud
var runner: DialogueRunner
var notebook: Notebook
var lumen: Speaker
var sun_switch: BeamReceiver

const INTRO := [
	{ "t": "thought", "s": "Nobody's touched a switch down here in eleven days." },
	{ "t": "thought", "s": "And yet the lights are on. Which means someone's power doesn't come from the grid." },
	{ "t": "objective", "s": "Find the lamp that never went out" },
]

const TAPE := "HELLO, RAY.\n\nIF YOU ARE READING THIS, I HAVE FORGOTTEN,\nAND YOU WILL WANT TO KNOW WHY.\n\n— R."

func _ready() -> void:
	Snd.set_track("l4")
	_build_env()
	_build_vault()
	_build_lumen()
	_build_control()
	_actors()
	_hud_build()
	player.can_move = true
	await get_tree().create_timer(0.5).timeout
	runner.play(INTRO)

func _build_env() -> void:
	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("04050a")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("2b3859")
	e.ambient_light_energy = 0.34
	e.fog_enabled = true
	e.fog_light_color = Color("080d16")
	e.fog_density = 0.02
	Atmosphere.apply(e, 0.34)
	env.environment = e
	add_child(env)
	TorchDust.build(self)

func _build_vault() -> void:
	var hx := ROOM.x * 0.5
	var hz := ROOM.z * 0.5

	_wall(Vector3(0, WALL_H * 0.5, -hz), Vector3(ROOM.x, WALL_H, 0.4), Color("232833"))
	_wall(Vector3(0, WALL_H * 0.5, hz), Vector3(ROOM.x, WALL_H, 0.4), Color("1e2330"))
	_wall(Vector3(-hx, WALL_H * 0.5, 0), Vector3(0.4, WALL_H, ROOM.z), Color("262b38"))
	_wall(Vector3(hx, WALL_H * 0.5, 0), Vector3(0.4, WALL_H, ROOM.z), Color("262b38"))
	_floor()
	_ceiling()
	_fill_lights()

	Trim.skirting(self, ROOM)
	Trim.panel_lines(self, ROOM)
	Trim.ceiling_beams(self, ROOM, WALL_H, 5)
	Trim.conduit(self, Vector3(-ROOM.x * 0.5 + 0.3, WALL_H - 0.3, -ROOM.z * 0.5 + 0.25), Vector3(ROOM.x * 0.5 - 0.3, WALL_H - 0.3, -ROOM.z * 0.5 + 0.25))
	Trim.conduit(self, Vector3(-ROOM.x * 0.5 + 0.3, WALL_H - 0.52, -ROOM.z * 0.5 + 0.25), Vector3(ROOM.x * 0.5 - 0.3, WALL_H - 0.52, -ROOM.z * 0.5 + 0.25))
	Props.crate(self, Vector3(-5.2, 0.0, 3.4), Vector3(0.5, 0.42, 0.5), 8.0)
	Props.papers(self, Vector3(0.2, 0.0, 1.2), 5, 0.5)
	Trim.vent(self, Vector3(ROOM.x * 0.5 - 0.09, 2.5, -1.8), Vector2(0.62, 0.5), -90.0)

	_label(Vector3(-hx + 0.22, 2.6, -3.0), "LAMP VAULT", Vector3(0, 90, 0))
	_label(Vector3(-3.9, 2.95, -hz + 0.42), "SUN CONTROL", Vector3.ZERO)

	var door := GateDoor.new()
	door.gate_id = "to_switch"
	door.position = Vector3(0.0, 1.2, hz - 0.22)
	door.opened.connect(func() -> void:
		Game.set_flag("control_door_open", true)
		hud.set_objective("Step through to the Annex")
	)
	add_child(door)

	var travel := Area3D.new()
	travel.position = Vector3(0.0, 1.0, hz - 1.0)
	travel.collision_layer = 0
	travel.collision_mask = 2
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.8, 2.4, 1.2)
	cs.shape = bs
	travel.add_child(cs)
	add_child(travel)

	var lg := LevelGate.new()
	lg.gate_id = "enter_switch"
	travel.add_child(lg)
	travel.body_entered.connect(func(_b: Node3D) -> void:
		if lg.can_enter():
			lg.travel()
	)

func _build_lumen() -> void:
	var hx := ROOM.x * 0.5
	lumen = Speaker.new()
	lumen.speaker_name = "LUMEN"
	lumen.name = "Speaker_LUMEN"
	lumen.interact_range = 4.0
	lumen.prompt = "Question Lumen"
	lumen.states = [
		{ "lines": [
			{ "t": "say", "who": "LUMEN", "s": "I'm on. I've always been on." },
			{ "t": "say", "who": "RAY", "s": "You're on? Nobody's touched a switch down here in eleven days." },
			{ "t": "say", "who": "LUMEN", "s": "No. Nobody has to." },
			{ "t": "say", "who": "LUMEN", "s": "You have not asked me properly once." },
		], "grants": [] },
		{ "lines": [
			{ "t": "say", "who": "RAY", "s": "When did you last see anyone?" },
			{ "t": "say", "who": "LUMEN", "s": "Nine thirteen. Forty-one." },
			{ "t": "say", "who": "RAY", "s": "Describe him." },
			{ "t": "say", "who": "LUMEN", "s": "He was not in a hurry. That's the part I won't be able to explain to you afterwards. He was not in a hurry and he was afraid, and he said thank you to a lamp." },
			{ "t": "say", "who": "RAY", "s": "That's not a description, that's a mood." },
		], "grants": ["F-01"] },
		{ "requires": ["V-03"], "lines": [
			{ "t": "say", "who": "LUMEN", "s": "You are holding the badge number that let him in. You do not need to read it out. I've watched a hundred people read it out." },
			{ "t": "say", "who": "RAY", "s": "..." },
			{ "t": "say", "who": "LUMEN", "s": "Ask me the question properly and I'll answer it." },
		], "grants": ["F-02"] },
		{ "requires": ["F-04"], "lines": [
			{ "t": "say", "who": "RAY", "s": "You said thank you to a lamp." },
			{ "t": "say", "who": "LUMEN", "s": "You said it to me eleven times since. You're saying it now." },
		], "grants": [] },
	]
	lumen.position = Vector3(-hx + 0.45, 2.0, -3.0)
	add_child(lumen)

	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.7, 0.7, 0.7)
	cs.shape = bs
	lumen.add_child(cs)

	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.3
	sm.height = 0.6
	mi.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("fff2d8")
	mat.emission_enabled = true
	mat.emission = Color("d9f2a8")
	mat.emission_energy_multiplier = 3.4
	sm.material = mat
	lumen.add_child(mi)

	var pl := OmniLight3D.new()
	pl.light_color = Color("d9f2a8")
	pl.light_energy = 2.6
	pl.omni_range = 10.0
	pl.shadow_enabled = false
	lumen.add_child(pl)

func _build_control() -> void:
	var hz := ROOM.z * 0.5

	sun_switch = BeamReceiver.new()
	sun_switch.clue_id = "F-03"
	sun_switch.revealed_text = "COUNTER  2\n\nMARLOW (11d)\nCD-19 (new)\n\n— R. (fresh)"
	sun_switch.armed = true
	sun_switch.hold_time = 1.0
	sun_switch.position = Vector3(0.0, 1.5, -hz + 0.3)
	sun_switch.revealed.connect(_on_switch_read)
	add_child(sun_switch)

	_label(Vector3(0.0, 2.35, -hz + 0.24), "SUN CONTROL SWITCH", Vector3.ZERO)

	var tape := TapeProp.new()
	tape.tape_text = TAPE
	tape.clue_on_read = "F-04"
	tape.position = Vector3(-2.4, 1.0, -hz + 0.7)
	add_child(tape)

	_label(Vector3(-2.4, 1.32, -hz + 0.62), "ACCESS LOG", Vector3.ZERO)

	var log := LogProp.new()
	log.clue_id = "F-05"
	log.body_text = ""
	log.position = Vector3(2.6, 1.0, -hz + 0.7)
	add_child(log)
	log.used.connect(func(_w: Node) -> void:
		Game.add_clue("F-05")
		hud.toast("F-05", Game.clue_title("F-05"))
		hud.think("Twelve lines. Eleven of them are a record. The twelfth is a clean black nothing.")
	)

	_label(Vector3(2.6, 1.32, -hz + 0.62), "LOG ENTRY 914", Vector3.ZERO)

	_label(Vector3(0.0, 2.9, hz - 0.3), "ANNEX  ←", Vector3(0, 180, 0))

func _on_switch_read(id: String) -> void:
	hud.toast("F-03", Game.clue_title("F-03"))
	hud.set_objective("Read the access log")
	hud.think("Same two events. Same badge. And a thumbprint made this morning.")
	hud.think("That's my thumb. I'd know it anywhere. That's a terrible thing to be able to say.")

func _actors() -> void:
	player = Player.new()
	player.position = Vector3(0.0, 0.1, 4.0)
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
	hud.set_objective("Find the lamp that never went out")

func _label(pos: Vector3, text: String, rot: Vector3) -> void:
	var mi := Sign.label(self, pos, text, 0.30)
	mi.rotation_degrees = rot

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

func _fill_lights() -> void:
	var spots := [
		Vector2(0.0, -4.2), Vector2(0.0, 0.6), Vector2(0.0, 5.0),
		Vector2(-4.6, -2.4), Vector2(4.6, -2.4),
		Vector2(-4.6, 3.6), Vector2(4.6, 3.6),
	]
	for i in spots.size():
		var at: Vector2 = spots[i]
		var fixture := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.8, 0.08, 0.2)
		fixture.mesh = bm
		fixture.position = Vector3(at.x, WALL_H - 0.28, at.y)
		var fmat := StandardMaterial3D.new()
		fmat.albedo_color = Color("39445c")
		fmat.emission_enabled = true
		fmat.emission = Color("5f7396")
		fmat.emission_energy_multiplier = 1.6
		bm.material = fmat
		add_child(fixture)

		var lamp := OmniLight3D.new()
		lamp.light_color = Color("8496b8")
		lamp.light_energy = 0.7
		lamp.omni_range = 13.0
		lamp.omni_attenuation = 0.8
		lamp.shadow_enabled = false
		lamp.position = Vector3(at.x, WALL_H - 0.55, at.y)
		add_child(lamp)

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
	var mat := Surface.textured(Color("101319"), "floor", 0.7, 0.35, 1.0, 0.5)
	pm.material = mat
	add_child(mi)