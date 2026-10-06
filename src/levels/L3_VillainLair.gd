extends Node3D

const WALL_H := 3.4
const ROOM := Vector3(11.0, 0.0, 9.0)

var player: Player
var hud: Hud
var runner: DialogueRunner
var notebook: Notebook
var counter: BeamReceiver
var marlow: Speaker

const INTRO := [
	{ "t": "thought", "s": "Only one light left in this city and it's under a lighthouse." },
	{ "t": "thought", "s": "So that's where the man lives. Of course it is." },
	{ "t": "objective", "s": "Question Marlow" },
]

func _ready() -> void:
	Snd.set_track("l3")
	_build_env()
	_build_room()
	_build_marlow()
	_build_counter()
	_actors()
	_hud_build()
	player.can_move = true
	await get_tree().create_timer(0.5).timeout
	runner.play(INTRO)

func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("05070c")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("2a3248")
	e.ambient_light_energy = 0.70
	e.fog_enabled = true
	e.fog_light_color = Color("0c1119")
	e.fog_density = 0.034
	Atmosphere.apply(e, 0.42)
	env.environment = e
	add_child(env)
	TorchDust.build(self)

func _build_room() -> void:
	var hx := ROOM.x * 0.5
	var hz := ROOM.z * 0.5

	_wall(Vector3(0, WALL_H * 0.5, -hz), Vector3(ROOM.x, WALL_H, 0.35), Color("2a2d34"))
	_wall(Vector3(0, WALL_H * 0.5, hz), Vector3(ROOM.x, WALL_H, 0.35), Color("23262d"))
	_wall(Vector3(-hx, WALL_H * 0.5, 0), Vector3(0.35, WALL_H, ROOM.z), Color("262a31"))
	_wall(Vector3(hx, WALL_H * 0.5, 0), Vector3(0.35, WALL_H, ROOM.z), Color("262a31"))
	_floor()
	_ceiling()

	Trim.skirting(self, ROOM)
	Trim.panel_lines(self, ROOM)
	Trim.ceiling_beams(self, ROOM, WALL_H, 3)
	Props.crate(self, Vector3(-4.1, 0.0, 2.6), Vector3(0.52, 0.44, 0.52), 26.0)
	Props.crate(self, Vector3(-4.2, 0.0, 3.5), Vector3(0.4, 0.3, 0.4), -14.0)
	Props.papers(self, Vector3(1.2, 0.0, 1.6), 8, 0.75)
	Props.bucket(self, Vector3(3.4, 0.0, -1.9))
	Trim.vent(self, Vector3(ROOM.x * 0.5 - 0.09, 2.4, 1.2), Vector2(0.5, 0.44), -90.0)

	_beacon()
	_bench(hz)
	_mirrors()

	var door := GateDoor.new()
	door.gate_id = "to_facility"
	door.position = Vector3(0.0, 1.15, hz - 0.2)
	door.opened.connect(func() -> void:
		Game.set_flag("lair_door_open", true)
		hud.set_objective("Step through to the Facility")
	)
	add_child(door)

	var travel := Area3D.new()
	travel.position = Vector3(0.0, 1.0, hz - 1.0)
	travel.collision_layer = 0
	travel.collision_mask = 2
	var tcs := CollisionShape3D.new()
	var tbs := BoxShape3D.new()
	tbs.size = Vector3(1.8, 2.4, 1.2)
	tcs.shape = tbs
	travel.add_child(tcs)
	add_child(travel)

	var lg := LevelGate.new()
	lg.gate_id = "enter_facility"
	travel.add_child(lg)
	travel.body_entered.connect(func(_b: Node3D) -> void:
		if lg.can_enter():
			lg.travel()
	)

func _beacon() -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(0.0, WALL_H - 0.6, -ROOM.z * 0.5 + 0.6)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.9, 0.7, 0.9)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.3
	sm.height = 0.6
	mi.mesh = sm
	mi.position = body.position
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffe0b0")
	mat.emission_enabled = true
	mat.emission = Color("ffcf8a")
	mat.emission_energy_multiplier = 4.0
	sm.material = mat
	add_child(mi)

	var pl := OmniLight3D.new()
	pl.position = body.position
	pl.light_color = Color("ffcf8a")
	pl.light_energy = 2.0
	pl.omni_range = 8.0
	pl.omni_attenuation = 0.85
	pl.shadow_enabled = true
	add_child(pl)

	_label(Vector3(0.0, WALL_H - 1.25, -ROOM.z * 0.5 + 0.62), "THE BEACON IS AIMED AT THE CITY")

func _mirrors() -> void:
	for i in 2:
		var body := StaticBody3D.new()
		body.position = Vector3(-3.2 + i * 1.5, 1.5, 1.6)
		body.rotation_degrees = Vector3(0, 20 - i * 40, 0)
		body.collision_layer = 1
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(0.86, 1.4, 0.07)
		cs.shape = bs
		body.add_child(cs)
		add_child(body)

		var frame := StandardMaterial3D.new()
		frame.albedo_color = Color("2c2620")
		frame.roughness = 0.72
		frame.metallic = 0.25

		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.8, 1.3, 0.05)
		mi.mesh = bm
		bm.material = Surface.mirror_glass()
		body.add_child(mi)

		for side in [-1.0, 1.0]:
			_frame_bar(body, frame, Vector3(0.0, side * 0.68, 0.0), Vector3(0.92, 0.07, 0.09))
			_frame_bar(body, frame, Vector3(side * 0.43, 0.0, 0.0), Vector3(0.07, 1.42, 0.09))

		_frame_bar(body, frame, Vector3(0.0, -1.02, 0.0), Vector3(0.5, 0.06, 0.16))

func _frame_bar(parent: Node3D, mat: Material, pos: Vector3, size: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)

func _bench(hz: float) -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(2.6, 0.5, -hz + 0.75)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.6, 1.0, 0.8)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.6, 0.9, 0.7)
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("33302b")
	mat.roughness = 0.9
	bm.material = mat
	body.add_child(mi)

	_label(Vector3(2.6, 2.30, -hz + 0.72), "SUN CONTROL SWITCH  (REPLICA)")

func _build_counter() -> void:
	counter = BeamReceiver.new()
	counter.clue_id = "V-02"
	counter.revealed_text = "2\n\nMARLOW (11d)\nCD-19 (new)"
	counter.armed = true
	counter.hold_time = 0.9
	counter.position = Vector3(2.6, 1.50, -ROOM.z * 0.5 + 0.6)
	counter.revealed.connect(_on_counter)
	add_child(counter)

func _build_marlow() -> void:
	marlow = Speaker.new()
	marlow.speaker_name = "MARLOW"
	marlow.name = "Speaker_MARLOW"
	marlow.states = [
		{ "lines": [
			{ "t": "say", "who": "MARLOW", "s": "I DIDN'T DO IT." },
			{ "t": "say", "who": "RAY", "s": "You haven't heard the question." },
			{ "t": "say", "who": "MARLOW", "s": "I DON'T NEED TO. EVERYBODY COMES DOWN HERE AND ASKS. I DIDN'T DO IT." },
			{ "t": "say", "who": "RAY", "s": "What is it?" },
			{ "t": "say", "who": "MARLOW", "s": "THAT'S WHAT I'VE BEEN SAYING." },
		], "grants": [] },
		{ "requires": ["S-04"], "lines": [
			{ "t": "say", "who": "MARLOW", "s": "Eleven days ago I cut the Sun for four seconds. Just to see. It came back. It always comes back." },
			{ "t": "say", "who": "RAY", "s": "So you did do it." },
			{ "t": "say", "who": "MARLOW", "s": "I DIDN'T DO IT. Do you understand the words? Four seconds. There is no it after four seconds. There's only after." },
		], "grants": ["V-01"] },
		{ "requires": ["V-02"], "lines": [
			{ "t": "say", "who": "MARLOW", "s": "I've tried that. Eleven days, I've tried that. It won't take my light." },
			{ "t": "say", "who": "RAY", "s": "...It took mine." },
		], "grants": [] },
		{ "requires": ["V-02"], "lines": [
			{ "t": "say", "who": "MARLOW", "s": "Whoever finished it signed something. There's only one person in this city who gets to sign things, and he's upstairs pretending to be a person." },
			{ "t": "say", "who": "RAY", "s": "That's not a real name, Marlow." },
			{ "t": "thought", "s": "...That's not a real name." },
		], "grants": ["V-03"] },
	]
	marlow.position = Vector3(-2.4, 0, -1.2)
	marlow.rotation_degrees = Vector3(0, 14, 0)
	add_child(marlow)

	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.7, 1.8, 0.6)
	cs.shape = bs
	cs.position = Vector3(0.0, 0.9, 0.0)
	marlow.add_child(cs)

	var coat := StandardMaterial3D.new()
	coat.albedo_color = Color("2e2823")
	coat.roughness = 0.92

	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color("6b5b4d")
	skin.roughness = 0.85

	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color("1b1815")
	dark.roughness = 0.95

	# A man in a heavy coat, built from primitives. The flare and the collar are
	# what make it read as a person in a coat rather than a stack of boxes.
	# Each row: position offset, size, material.
	var parts := [
		# legs, slightly apart
		[Vector3(-0.12, 0.40, 0.0), Vector3(0.16, 0.80, 0.18), dark],
		[Vector3(0.12, 0.40, 0.0), Vector3(0.16, 0.80, 0.18), dark],
		# coat skirt, flared
		[Vector3(0.0, 0.86, 0.0), Vector3(0.58, 0.34, 0.40), coat],
		[Vector3(0.0, 1.16, 0.0), Vector3(0.52, 0.36, 0.34), coat],
		# chest and shoulders
		[Vector3(0.0, 1.42, 0.0), Vector3(0.56, 0.22, 0.32), coat],
		[Vector3(0.0, 1.53, 0.0), Vector3(0.62, 0.10, 0.33), coat],
		# collar, turned up
		[Vector3(0.0, 1.60, 0.0), Vector3(0.30, 0.09, 0.26), coat],
		# arms, hanging slightly out from the body
		[Vector3(-0.34, 1.24, 0.02), Vector3(0.12, 0.52, 0.14), coat],
		[Vector3(0.34, 1.24, 0.02), Vector3(0.12, 0.52, 0.14), coat],
	]
	for p in parts:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = p[1]
		mi.mesh = bm
		mi.position = p[0]
		mi.material_override = p[2]
		marlow.add_child(mi)

	# Head as a capsule so it reads as a skull, not a cube.
	var head := MeshInstance3D.new()
	var hm := CapsuleMesh.new()
	hm.radius = 0.105
	hm.height = 0.28
	hm.radial_segments = 12
	hm.rings = 6
	head.mesh = hm
	head.material_override = skin
	head.position = Vector3(0.0, 1.74, 0.0)
	marlow.add_child(head)

	# Peaked cap.
	var cap := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.10
	cm.bottom_radius = 0.12
	cm.height = 0.11
	cm.radial_segments = 12
	cap.mesh = cm
	cap.material_override = dark
	cap.position = Vector3(0.0, 1.88, 0.0)
	marlow.add_child(cap)

	var brim := MeshInstance3D.new()
	var bmm := BoxMesh.new()
	bmm.size = Vector3(0.26, 0.02, 0.16)
	brim.mesh = bmm
	brim.material_override = dark
	brim.position = Vector3(0.0, 1.835, 0.10)
	marlow.add_child(brim)

func _actors() -> void:
	player = Player.new()
	player.position = Vector3(0.0, 0.1, 3.2)
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
	hud.set_objective("Question Marlow")

func _on_counter(id: String) -> void:
	hud.toast("V-02", Game.clue_title("V-02"))
	hud.set_objective("Read the stamps")
	hud.think("Two. He's only ever accounted for one. Somebody finished what he started.")

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

func _label(pos: Vector3, text: String) -> void:
	Sign.label(self, pos, text, 0.30)

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
	var mat := Surface.textured(Color("14161b"), "floor", 0.7, 0.35, 1.0, 0.5)
	pm.material = mat
	add_child(mi)