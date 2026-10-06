class_name Player
extends CharacterBody3D

const SPEED := 3.2
const ACCEL := 14.0
const MOUSE_SENS := 0.0022
const TIER_RANGE := 9.0

const Interactable := preload("res://src/core/Interactable.gd")
const BeamReceiver := preload("res://src/core/BeamReceiver.gd")
const Speaker := preload("res://src/core/Speaker.gd")

var can_move: bool = true
var yaw: float = 0.0
var pitch: float = 0.0
var focus: Interactable = null

var _cam: Camera3D
var _torch: OmniLight3D
var _torch_bloom: OmniLight3D
var _step_acc := 0.0
var _torch_fill: OmniLight3D
var _head: Node3D

func _ready() -> void:
	add_to_group("player")
	_build()
	# Browsers refuse to grant pointer lock without a user gesture, so grabbing
	# the mouse here would silently fail on web. Wait for a click or keypress,
	# and re-grab whenever the lock is dropped (Esc, tab switch, iframe exit).
	# Desktop keeps the original immediate capture.
	Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE
		if OS.has_feature("web") else Input.MOUSE_MODE_CAPTURED)

func grab_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build() -> void:
	collision_layer = 2
	collision_mask = 1

	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.7
	shape.shape = cap
	shape.position = Vector3(0.0, 0.85, 0.0)
	add_child(shape)

	_head = Node3D.new()
	_head.name = "Head"
	_head.position = Vector3(0.0, 1.62, 0.0)
	add_child(_head)

	_cam = Camera3D.new()
	_cam.fov = 72.0
	_cam.near = 0.05
	_cam.far = 400.0
	_head.add_child(_cam)

	_torch_fill = OmniLight3D.new()
	_torch_fill.light_color = Color("ffc98a")
	_torch_fill.light_energy = 0.4
	_torch_fill.omni_range = 8.0
	_torch_fill.omni_attenuation = 1.0
	_torch_fill.shadow_enabled = false
	_torch_fill.light_specular = 0.0
	_torch_fill.light_volumetric_fog_energy = 0.0
	_torch_fill.position = Vector3(0.0, 0.1, -0.6)
	_cam.add_child(_torch_fill)

	_torch = OmniLight3D.new()
	_torch.light_color = Color("ffc98a")
	_torch.light_energy = 3.6
	_torch.omni_range = 16.0
	_torch.omni_attenuation = 0.9
	_torch.shadow_enabled = true
	_torch.shadow_bias = 0.1
	_torch.shadow_normal_bias = 3.0
	_torch.light_specular = 0.06
	_torch.light_volumetric_fog_energy = 0.0
	_torch.position = Vector3(0.0, 0.0, -0.5)
	_cam.add_child(_torch)

	_torch_bloom = OmniLight3D.new()
	_torch_bloom.light_color = Color("ffb968")
	_torch_bloom.light_energy = 0.8
	_torch_bloom.omni_range = 3.0
	_torch_bloom.shadow_enabled = false
	_torch_bloom.light_volumetric_fog_energy = 0.0
	_cam.add_child(_torch_bloom)



func _unhandled_input(event: InputEvent) -> void:
	# Re-acquire pointer lock on any deliberate press. On web this is the only
	# thing that grants it; browsers drop it on Esc or when leaving the iframe.
	var gesture := false
	if event is InputEventMouseButton and event.pressed:
		gesture = true
	elif event is InputEventKey and event.pressed and not event.echo:
		gesture = true
		if (event as InputEventKey).keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if gesture and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		grab_mouse()

	if event.is_action_pressed("interact"):
		_try_interact()
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		yaw -= mm.relative.x * MOUSE_SENS
		pitch = clampf(pitch - mm.relative.y * MOUSE_SENS, -1.35, 1.35)

func _try_interact() -> void:
	if focus != null and is_instance_valid(focus) and focus.can_interact():
		focus.interact(self)
		Snd.sfx("interact", -5.0)
		if not focus.can_interact():
			focus = null
			_push_prompt()

func _apply_look() -> void:
	rotation.y = yaw
	if _cam != null:
		_cam.rotation.x = pitch

func _physics_process(delta: float) -> void:
	_apply_look()

	var dir := Vector2.ZERO
	# Desktop still requires the pointer lock; on web it is dropped constantly
	# and refusing to move in that state reads as the game being broken.
	if can_move and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED or OS.has_feature("web")):
		dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish := (transform.basis * Vector3(dir.x, 0.0, dir.y)).normalized() * SPEED
	velocity.x = move_toward(velocity.x, wish.x, ACCEL * delta * SPEED)
	velocity.z = move_toward(velocity.z, wish.z, ACCEL * delta * SPEED)
	velocity.y -= 9.8 * delta
	move_and_slide()

	var planar := Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and planar > 0.8:
		_step_acc += planar * delta
		if _step_acc > 0.52:
			_step_acc = 0.0
			var step_var = randi_range(0, 3)
			var step_name = ["step_a", "step_b", "step_c", "step_d"][step_var]
			Snd.sfx(step_name, -9.0, randf_range(0.92, 1.08))
	else:
		_step_acc = 0.0

func _process(delta: float) -> void:
	_apply_look()
	if Input.is_action_just_pressed("torch"):
		Game.torch_on = not Game.torch_on
		_torch.visible = Game.torch_on
		_torch_bloom.visible = Game.torch_on
		_torch_fill.visible = Game.torch_on
		Snd.sfx("torch", -4.0)

	_torch_bloom.light_energy = 0.85 + 0.1 * sin(Time.get_ticks_msec() / 260.0)

	if not Game.torch_on:
		Game.set_tier(Game.Tier.MOON)
		var r_off := _sweep(delta, false)
		_scan_sky()
		_update_hold(r_off)
		_push_prompt()
		return

	var receiver := _sweep(delta, true)
	Game.set_tier(Game.Tier.AGREED if receiver != null else Game.Tier.BEAM)
	_scan_sky()
	_update_hold(receiver)
	_push_prompt()

func _update_hold(receiver: BeamReceiver) -> void:
	var hud := Game.hud
	if hud != null and hud.has_method("set_hold"):
		if receiver != null and receiver.armed and not receiver.is_revealed:
			hud.call("set_hold", receiver.hold / receiver.hold_time)
		else:
			hud.call("set_hold", 0.0)

func _scan_sky() -> void:
	if _cam == null or focus != null:
		return
	var fwd := -_cam.global_transform.basis.z
	var best: Speaker = null
	var best_dot := 0.0

	for n in get_tree().get_nodes_in_group("sky_speaker"):
		var sp := n as Speaker
		if sp == null:
			continue
		var to: Vector3 = sp.global_position - _cam.global_position
		var d := to.length()
		if d > sp.interact_range:
			continue
		var dir := to / d
		var dot := fwd.dot(dir)
		var need := cos(deg_to_rad(sp.view_angle_deg))
		if dot >= need and dot > best_dot:
			best_dot = dot
			best = sp

	if best != null:
		_set_focus(best)

var _receiver_focus: BeamReceiver = null

func _sweep(delta: float, active: bool) -> BeamReceiver:
	if _cam == null:
		return null
	var space := get_world_3d().direct_space_state
	var from := _cam.global_position
	var to := from + -_cam.global_transform.basis.z * TIER_RANGE
	var q := PhysicsRayQueryParameters3D.create(from, to, 1)
	q.collide_with_areas = false

	var hit := space.intersect_ray(q)
	if hit.is_empty():
		_receiver_focus = null
		_clear_focus()
		return null

	var body: Object = hit.get("collider") as Object
	if body == null:
		_receiver_focus = null
		_clear_focus()
		return null

	if body.is_in_group("interactable"):
		_receiver_focus = null
		var item := body as Interactable
		if item != null and item.interact_range >= _cam.global_position.distance_to(item.global_position):
			_set_focus(item)
		else:
			_clear_focus()
		return null

	if not body.is_in_group("beam_receiver"):
		_receiver_focus = null
		_clear_focus()
		return null

	var recv := body as BeamReceiver
	if recv == null or recv.is_revealed:
		_receiver_focus = null
		return null

	_receiver_focus = recv
	if not recv.armed:
		return null

	var local: Vector3 = recv.to_local(hit["position"] as Vector3)
	var offset := Vector2(local.x, local.y).length()
	var reach: float = recv.dead_radius

	var holding_interact := Input.is_action_pressed("interact")
	var is_active := active or holding_interact
	if is_active and offset <= reach:
		var strength: float = 1.0 - (offset / reach) * 0.4
		recv.receive(strength, delta)
		return recv

	recv.miss(delta)
	return recv if is_active else null

func _set_focus(item: Interactable) -> void:
	if focus == item:
		return
	focus = item
	_push_prompt()

func _push_prompt() -> void:
	var hud := Game.hud
	if hud == null or not hud.has_method("set_prompt"):
		return
	if focus != null and (not is_instance_valid(focus) or not focus.can_interact()):
		focus = null
	if focus != null and is_instance_valid(focus) and focus.can_interact():
		hud.call("set_prompt", focus.focus_text())
		return
	if _receiver_focus != null and is_instance_valid(_receiver_focus) and not _receiver_focus.is_revealed:
		hud.call("set_prompt", _receiver_focus.focus_prompt())
		return
	hud.call("set_prompt", "")

func _clear_focus() -> void:
	if focus == null:
		return
	if is_instance_valid(focus) and focus.is_in_group("beam_receiver"):
		return
	focus = null
	_push_prompt()

func head() -> Node3D:
	return _head

func camera() -> Camera3D:
	return _cam





