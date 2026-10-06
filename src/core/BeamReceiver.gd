class_name BeamReceiver
extends StaticBody3D

signal revealed(id: String)

@export var clue_id: String = ""
@export var dead_radius: float = 0.55
@export var hold_time: float = 0.7
@export var max_range: float = 6.0
@export var revealed_text: String = "9:14"

var hold: float = 0.0
var is_revealed: bool = false
var armed: bool = false

var _material: ShaderMaterial
var _label: Node3D
var _beacon_light: OmniLight3D

func _ready() -> void:
	add_to_group("beam_receiver")
	_build()

func focus_prompt() -> String:
	if is_revealed:
		return ""
	if not armed:
		return "Terminal Inactive (Switches Required)"
	return "[E / Torch] Hold Beam on Mark"

func _build() -> void:
	# Physical dark metallic base plate so the station is visible in 3D
	var plate := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.56
	cyl.bottom_radius = 0.56
	cyl.height = 0.03
	cyl.radial_segments = 32
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color("141820")
	pmat.roughness = 0.75
	pmat.metallic = 0.4
	plate.mesh = cyl
	plate.material_override = pmat
	plate.rotation_degrees = Vector3(90, 0, 0)
	plate.position = Vector3(0.0, 0.0, -0.015)
	plate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(plate)

	# Radiant beacon light to illuminate the station in dark rooms
	_beacon_light = OmniLight3D.new()
	_beacon_light.light_color = Color("ffb968")
	_beacon_light.light_energy = 0.7
	_beacon_light.omni_range = 3.5
	_beacon_light.shadow_enabled = false
	add_child(_beacon_light)

	var quad := QuadMesh.new()
	quad.size = Vector2(1.6, 1.6)

	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/beam_receiver.gdshader")
	quad.material = mat

	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.name = "Mark"
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	_material = mat

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.6, 0.06)
	shape.shape = box
	add_child(shape)

func _process(delta: float) -> void:
	if _material == null:
		return
	_material.set_shader_parameter("progress", clamp(hold / hold_time, 0.0, 1.0))
	if _beacon_light != null:
		if is_revealed:
			_beacon_light.light_energy = 1.3
		elif armed:
			_beacon_light.light_energy = 0.7 + 0.35 * sin(Time.get_ticks_msec() / 280.0)
		else:
			_beacon_light.light_energy = 0.25
	if not is_revealed:
		return
	var t := float(Time.get_ticks_msec()) / 1000.0
	var f := 0.72 + 0.28 * sin(t * 3.3) * sin(t * 1.7)
	_material.set_shader_parameter("flicker", f)

func receive(strength: float, delta: float) -> void:
	if is_revealed or not armed:
		hold = maxf(0.0, hold - delta * 1.6)
		_material.set_shader_parameter("aligned", 0.0)
		return

	_material.set_shader_parameter("aligned", strength)
	hold += delta * (0.55 + strength * 0.75)
	if hold >= hold_time:
		_do_reveal()

func miss(delta: float) -> void:
	if is_revealed or not armed:
		return
	hold = maxf(0.0, hold - delta * 1.6)
	_material.set_shader_parameter("aligned", 0.0)
	_material.set_shader_parameter("progress", clamp(hold / hold_time, 0.0, 1.0))

func _do_reveal() -> void:
	is_revealed = true
	hold = hold_time
	_material.set_shader_parameter("progress", 1.0)
	_material.set_shader_parameter("aligned", 0.0)
	_material.set_shader_parameter("revealed", 1.0)
	_spawn_label()
	if clue_id != "":
		Game.add_clue(clue_id)
	revealed.emit(clue_id)

func _spawn_label() -> void:
	var tm := TextMesh.new()
	tm.font = preload("res://assets/Cinzel.tres")
	tm.text = revealed_text
	tm.font_size = 96
	tm.pixel_size = 0.006
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
	mi.name = "Sunwriting"
	mi.position = Vector3(0.0, 0.0, 0.05)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

	mi.scale = Vector3.ONE * 0.6
	var tw := create_tween()
	tw.tween_property(mi, "scale", Vector3.ONE, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	mat.albedo_color = Color("d9f2a8", 0.0)
	mat.emission_energy_multiplier = 0.0
	var tw2 := create_tween()
	tw2.set_parallel(true)
	tw2.tween_property(mat, "albedo_color:a", 1.0, 0.9)
	tw2.tween_property(mat, "emission_energy_multiplier", 2.2, 0.9)