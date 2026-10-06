extends Node3D

const WALL_H := 3.6
const STREET_W := 9.0
const STREET_L := 22.0

var player: Player
var hud: Hud
var runner: DialogueRunner
var notebook: Notebook
var _sky_ref: Dictionary = {}

const INTRO := [
	{ "t": "thought", "s": "One shutter open in the whole street. That's not a coincidence, that's an invitation." },
	{ "t": "thought", "s": "People are easy. They have opinions and not one of them is evidence." },
	{ "t": "objective", "s": "Question the Moon, the Lamp, and the toaster" },
	]

func _ready() -> void:
	Snd.set_track("l2")
	_build_env()
	_build_street()
	_suspects()
	_actors()
	_hud_build()
	player.can_move = true
	await get_tree().create_timer(0.5).timeout
	runner.play(INTRO)

func _build_env() -> void:
	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = load("res://shaders/nightsky.gdshader")
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("38466a")
	e.ambient_light_energy = 0.42
	e.fog_enabled = true
	e.fog_light_color = Color("0d1420")
	e.fog_density = 0.006
	e.fog_sky_affect = 0.0
	Atmosphere.apply(e, 0.42)
	env.environment = e
	add_child(env)
	TorchDust.build(self)

	var moon := DirectionalLight3D.new()
	moon.light_color = Color("9db4d6")
	moon.light_energy = 0.26
	moon.rotation_degrees = Vector3(-52, 20, 0)
	moon.shadow_enabled = false
	add_child(moon)

func _build_street() -> void:
	var hw := STREET_W * 0.5
	var hl := STREET_L * 0.5
	_wall(Vector3(0, WALL_H * 0.5, -hl), Vector3(STREET_W + 1.0, WALL_H, 0.4), Color("23262e"))
	_wall(Vector3(0, WALL_H * 0.5, hl), Vector3(STREET_W + 1.0, WALL_H, 0.4), Color("23262e"))
	_wall(Vector3(-hw, WALL_H * 0.5, 0), Vector3(0.4, WALL_H, STREET_L), Color("2b2f38"))
	_wall(Vector3(hw, WALL_H * 0.5, 0), Vector3(0.4, WALL_H, STREET_L), Color("262a32"))
	_floor()

	Trim.skirting(self, Vector3(STREET_W, 0.0, STREET_L))
	Trim.dado_rail(self, Vector3(STREET_W, 0.0, STREET_L), 1.05)
	Props.crate(self, Vector3(-3.9, 0.0, 6.2), Vector3(0.46, 0.4, 0.46), 12.0)
	Props.crate(self, Vector3(3.9, 0.0, -7.4), Vector3(0.44, 0.36, 0.44), -22.0)
	Props.bucket(self, Vector3(-3.6, 0.0, -2.2))
	Props.papers(self, Vector3(1.2, 0.0, 3.4), 7, 0.7)
	Trim.vent(self, Vector3(-STREET_W * 0.5 + 0.09, 2.4, 4.0), Vector2(0.55, 0.45), 90.0)
	Trim.conduit(self, Vector3(-STREET_W * 0.5 + 0.14, WALL_H - 0.4, -STREET_L * 0.5 + 0.3), Vector3(-STREET_W * 0.5 + 0.14, WALL_H - 0.4, STREET_L * 0.5 - 0.3))

	var door := GateDoor.new()
	door.gate_id = "to_villain_lair"
	door.position = Vector3(0.0, 1.2, hl - 0.22)
	door.opened.connect(func() -> void:
		Game.set_flag("villain_door_open", true)
		hud.set_objective("Step through the door")
	)
	add_child(door)

	var travel := Area3D.new()
	travel.position = Vector3(0.0, 1.0, hl - 1.0)
	travel.collision_layer = 0
	travel.collision_mask = 2
	var tcs := CollisionShape3D.new()
	var tbs := BoxShape3D.new()
	tbs.size = Vector3(1.6, 2.2, 1.2)
	tcs.shape = tbs
	travel.add_child(tcs)
	add_child(travel)

	var lg := LevelGate.new()
	lg.gate_id = "enter_lair"
	travel.add_child(lg)
	travel.body_entered.connect(func(_b: Node3D) -> void:
		if lg.can_enter():
			lg.travel()
	)

func _suspects() -> void:
	_add_sky_speaker("MOON", "THE MOON", Vector3(14.0, 42.0, -78.0), [
		{ "lines": [
			{ "t": "say", "who": "THE MOON", "s": "Yes." },
			{ "t": "say", "who": "RAY", "s": "You're the Moon." },
			{ "t": "say", "who": "THE MOON", "s": "I am." },
			{ "t": "say", "who": "RAY", "s": "Nine thirteen. Was the Sun up?" },
			{ "t": "say", "who": "THE MOON", "s": "Yes." },
			{ "t": "say", "who": "RAY", "s": "Nine fourteen?" },
			{ "t": "say", "who": "THE MOON", "s": "No. That is the whole event. Please stop walking around it." },
		], "grants": [] },
		{ "lines": [
			{ "t": "say", "who": "RAY", "s": "Did anything come with it? When it went." },
			{ "t": "say", "who": "THE MOON", "s": "Every shadow in this city swung east at once. A hundred thousand people turning to look at the same thing." },
			{ "t": "say", "who": "RAY", "s": "East. Toward the Sun Control Facility." },
			{ "t": "say", "who": "THE MOON", "s": "Toward where the light *was*. Shadows point at the thing you lost." },
		], "grants": ["S-01"] },
		{ "requires": ["S-01", "S-03"], "lines": [
			{ "t": "say", "who": "RAY", "s": "He wasn't running away. He was running *to* something." },
			{ "t": "say", "who": "THE MOON", "s": "People run toward explosions. It is the entire reason they are still alive." },
			{ "t": "say", "who": "RAY", "s": "You're annoyingly encouraging for a rock." },
			{ "t": "say", "who": "THE MOON", "s": "I am a philosopher. Encouragement is a side effect." },
		], "grants": [] },
	])

	_add_speaker("WICK", "MR. WICK", Vector3(2.9, 0, -1.0), [
		{ "lines": [
			{ "t": "say", "who": "MR. WICK", "s": "I am a lamp in a shop. Yes." },
			{ "t": "say", "who": "RAY", "s": "What do you see?" },
			{ "t": "say", "who": "MR. WICK", "s": "Exactly what has been pointed at me. People think that because I'm on, I see. I see the counter. I see the ceiling tile with the water stain." },
		], "grants": [] },
		{ "lines": [
			{ "t": "say", "who": "RAY", "s": "Did you see anyone come in this morning?" },
			{ "t": "say", "who": "MR. WICK", "s": "No." },
			{ "t": "say", "who": "RAY", "s": "You don't have a door." },
			{ "t": "say", "who": "MR. WICK", "s": "I do not. So that was never impressive. Thank you." },
		], "grants": [] },
		{ "requires": ["S-03"], "lines": [
			{ "t": "say", "who": "RAY", "s": "Your filament's blown outward. So is the toaster. One push, from the east." },
			{ "t": "say", "who": "MR. WICK", "s": "Correct. Finally." },
		], "grants": ["D-02"] },
	])

	_add_speaker("SIR", "SIR", Vector3(-2.6, 0, -4.6), [
		{ "lines": [
			{ "t": "say", "who": "RAY", "s": "It has a nameplate." },
			{ "t": "say", "who": "RAY", "s": "Sir." },
			{ "t": "say", "who": "RAY", "s": "Of course." },
			{ "t": "say", "who": "SIR", "s": "[pops toast — a burnt photograph of a surge entering from the right]" },
			{ "t": "say", "who": "RAY", "s": "That's not burnt. That's a photograph. The bread did the only honest thing available to it." },
		], "grants": ["S-03"] },
		{ "lines": [
			{ "t": "say", "who": "SIR", "s": "[a pale, barely-burned slice. Old.]" },
			{ "t": "say", "who": "RAY", "s": "That one's old. Eleven days old. Sir, you've been keeping the first one." },
		], "grants": ["S-04"] },
	])

	_add_sky_speaker("CLOUDS", "THE CLOUDS", Vector3(-12.0, 56.0, -66.0), [
		{ "lines": [
			{ "t": "say", "who": "RAY", "s": "Were you moving at nine fourteen?" },
			{ "t": "say", "who": "THE CLOUDS", "s": "We were told to hold." },
			{ "t": "say", "who": "RAY", "s": "Who told you to hold?" },
			{ "t": "say", "who": "THE CLOUDS", "s": "The man who was already up there." },
			{ "t": "say", "who": "RAY", "s": "Define up." },
		], "grants": [] },
	])

func _add_speaker(id: String, who: String, pos: Vector3, states: Array) -> void:
	var sp := Speaker.new()
	sp.speaker_name = who
	sp.name = "Speaker_" + id
	for s in states:
		sp.states.append(s)
	sp.position = pos
	add_child(sp)

	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.2, 1.8, 1.2)
	cs.shape = bs
	sp.add_child(cs)

func _add_sky_speaker(id: String, who: String, pos: Vector3, states: Array) -> void:
	var sp := Speaker.new()
	sp.speaker_name = who
	sp.name = "Speaker_" + id
	sp.sky_facing = true
	sp.view_angle_deg = 15.0
	for s in states:
		sp.states.append(s)
	sp.position = pos
	add_child(sp)
	_sky_ref[id] = sp

	var cs := CollisionShape3D.new()
	var bs := SphereShape3D.new()
	bs.radius = 7.0
	cs.shape = bs
	sp.add_child(cs)

func _actors() -> void:
	player = Player.new()
	player.position = Vector3(0, 0.1, 8.5)
	add_child(player)
	_wick_lamp()
	_moon_prop()
	_clouds_prop()
	_toaster_prop()
	_sign_prop()

func _wick_lamp() -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(2.9, 1.4, -1.0)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.5, 1.2, 0.5)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.24
	sm.height = 0.48
	mi.mesh = sm
	mi.position = body.position + Vector3(0, 0.75, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffd9a8")
	mat.emission_enabled = true
	mat.emission = Color("ffb968")
	mat.emission_energy_multiplier = 3.2
	sm.material = mat
	add_child(mi)

	var pl := OmniLight3D.new()
	pl.position = body.position + Vector3(0, 0.75, 0)
	pl.light_color = Color("ffb968")
	pl.light_energy = 2.4
	pl.omni_range = 6.5
	pl.shadow_enabled = true
	add_child(pl)

func _moon_prop() -> void:
	var sp: Speaker = _sky_ref.get("MOON") as Speaker
	if sp == null:
		return
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 6.5
	sm.height = 13.0
	sm.radial_segments = 48
	sm.rings = 24
	mi.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("dfe8f4")

	var ntex := NoiseTexture2D.new()
	ntex.width = 256
	ntex.height = 128
	ntex.seamless = true
	var fn := FastNoiseLite.new()
	fn.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fn.frequency = 0.035
	fn.fractal_octaves = 4
	ntex.noise = fn
	mat.albedo_texture = ntex

	mat.emission_enabled = true
	mat.emission_texture = ntex
	mat.emission = Color("8ba0c0")
	mat.emission_energy_multiplier = 0.6
	mat.roughness = 1.0
	sm.material = mat
	sp.add_child(mi)

	var pl := OmniLight3D.new()
	pl.light_color = Color("9db4d6")
	pl.light_energy = 2.2
	pl.omni_range = 130.0
	pl.shadow_enabled = false
	sp.add_child(pl)

func _clouds_prop() -> void:
	var sp: Speaker = _sky_ref.get("CLOUDS") as Speaker
	if sp == null:
		return
	var tex := _cloud_texture()
	var puffs := [
		[Vector3(-34.0, 2.0, 10.0), 76.0, 44.0, 0.85],
		[Vector3(-4.0, -7.0, -2.0), 88.0, 50.0, 1.0],
		[Vector3(28.0, 3.0, 8.0), 70.0, 40.0, 0.8],
		[Vector3(-16.0, 15.0, -16.0), 58.0, 32.0, 0.6],
	]
	for p in puffs:
		_cloud_puff(sp, tex, p[0], p[1], p[2], p[3])

func _cloud_puff(parent: Node3D, tex: Texture2D, offset: Vector3, w: float, h: float, alpha: float) -> void:
	var qm := QuadMesh.new()
	qm.size = Vector2(w, h)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.128, 0.152, 0.196, alpha)
	mat.albedo_texture = tex
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	qm.material = mat

	var mi := MeshInstance3D.new()
	mi.mesh = qm
	mi.position = offset
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var to_player := Vector3(0.0, 8.0, 8.5) - (parent.position + offset)
	mi.rotation.y = atan2(to_player.x, to_player.z)
	parent.add_child(mi)

func _cloud_texture() -> ImageTexture:
	var w := 256
	var h := 128
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	var n := FastNoiseLite.new()
	n.seed = 9142026
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.016
	n.fractal_octaves = 3

	for y in h:
		var v := float(y) / float(h - 1)
		for x in w:
			var u := float(x) / float(w)
			var val := n.get_noise_2d(u * 3.0, v * 1.6)
			var d := Vector2((u - 0.5) * 2.0, (v - 0.5) * 2.0 * 1.7).length()
			var falloff := 1.0 - smoothstep(0.30, 0.98, d)
			var a := smoothstep(-0.06, 0.26, val) * falloff
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(a, 0.0, 1.0)))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

func _toaster_prop() -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(-2.6, 0.6, -4.6)
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.7, 0.9, 0.6)
	cs.shape = bs
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.62, 0.82, 0.52)
	mi.mesh = bm
	mi.position = body.position
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("3a4049")
	bm.material = mat
	body.add_child(mi)

func _sign_prop() -> void:
	Sign.label(self, Vector3(4.15, 2.5, 1.2), "SUN'S OUT?\nWE'RE STILL OPEN", 0.24, Color("b9c8dd"), true, -PI * 0.5)

func _actors_built() -> void:
	pass

func _hud_build() -> void:
	hud = Hud.new()
	add_child(hud)
	runner = DialogueRunner.new()
	runner.hud = hud
	add_child(runner)
	Game.runner = runner
	notebook = Notebook.new()
	add_child(notebook)
	hud.set_objective("Question the Moon, the Lamp, and the toaster")

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
	bs.size = Vector3(STREET_W, 0.2, STREET_L)
	cs.shape = bs
	cs.position = Vector3(0, -0.1, 0)
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(STREET_W, STREET_L)
	mi.mesh = pm
	var mat := Surface.textured(Color("15181e"), "floor", 0.7, 0.35, 1.0, 0.5)
	pm.material = mat
	add_child(mi)
