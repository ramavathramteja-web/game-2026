class_name Hud
extends CanvasLayer

const FONT_TITLE := preload("res://assets/Cinzel.tres")
const FONT_BODY := preload("res://assets/Outfit.tres")

const VOID := Color("04050a")
const TXT := Color("f2f4f8")
const DIM := Color("a0aab8")
const FAINT := Color("627084")
const TORCH := Color("ffb968")
const MOON := Color("9db4d6")
const PHOS := Color("d9f2a8")

var reticle: Reticle
var _tier_label: Label
var _clock: Label
var _torch_pill: PanelContainer
var _torch_dot: ColorRect
var _torch_lbl: Label
var _watch: Label
var _objective: Label
var _prompt: Label
var _prompt_panel: PanelContainer
var _prompt_action: String = ""
var _sub_name: Label
var _sub_text: Label
var _sub_box: PanelContainer
var _thought: Label
var _thought_box: PanelContainer
var _toasts: VBoxContainer
var _hold_progress: float = 0.0

var _type_tween: Tween
var _sub_hold: float = 0.0

var _switches: Array = []

func setup_switches(switches: Array) -> void:
	_switches = switches

func _ready() -> void:
	layer = 10
	_build()
	Game.hint.connect(_on_hint)
	Game.tape_requested.connect(_on_tape)
	Game.hud = self

func _on_tape(text: String) -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.008, 0.012, 0.02, 0.97)
	root.add_child(bg)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -360
	box.offset_right = 360
	box.offset_top = -170
	box.offset_bottom = 190
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 26)
	root.add_child(box)

	var edge_top := ColorRect.new()
	edge_top.custom_minimum_size = Vector2(0, 2)
	edge_top.color = Color(0.85, 0.95, 0.66, 0.35)
	box.add_child(edge_top)

	box.add_child(_lbl("ACCESS LOG / SUN CONTROL FLOOR / ENTRY 914", 11, FAINT, true))

	var body := _lbl(text, 26, PHOS)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(720, 220)
	body.add_theme_font_override("font", _hand_font())
	box.add_child(body)

	var edge_bot := ColorRect.new()
	edge_bot.custom_minimum_size = Vector2(0, 2)
	edge_bot.color = Color(0.85, 0.95, 0.66, 0.35)
	box.add_child(edge_bot)

	var close := Button.new()
	close.text = "FOLD IT AWAY"
	close.add_theme_font_override("font", FONT_TITLE)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", PHOS)
	close.pressed.connect(func() -> void: root.queue_free())
	box.add_child(close)

	var tw := create_tween()
	root.modulate.a = 0.0
	tw.tween_property(root, "modulate:a", 1.0, 0.5)

func _hand_font() -> Font:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Segoe Script", "Bradley Hand", "Ink Free", "Comic Sans MS"])
	f.font_weight = 400
	return f

func show_finale() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.9, 0.82, 0.66, 1.0)
	root.add_child(bg)

	var warm := ColorRect.new()
	warm.set_anchors_preset(Control.PRESET_FULL_RECT)
	warm.color = Color(1.0, 0.78, 0.42, 0.28)
	root.add_child(warm)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 20)
	root.add_child(box)

	var l1 := _lbl("9:14:01", 54, Color(0.06, 0.05, 0.04), true)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l1)

	var l2 := _lbl("EVERY CLOCK IN THE CITY IS MOVING AGAIN", 14, Color(0.18, 0.14, 0.10), true)
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l2)

	var l3 := _lbl("RAY'S WATCH READS 9:55", 13, Color(0.24, 0.18, 0.12), false)
	l3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l3)

	var tw := create_tween()
	root.modulate.a = 0.0
	tw.tween_property(root, "modulate:a", 1.0, 2.2)

	setTimeout(func() -> void: _final_card(root), 5200)

func _final_card(root: Control) -> void:
	for c in root.get_children():
		if c is ColorRect:
			c.queue_free()
	for c in root.get_children():
		if c is VBoxContainer:
			c.queue_free()

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 26)
	root.add_child(box)

	var head := _lbl("LOG ENTRY 914", 12, Color(0.35, 0.35, 0.32), true)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(head)

	var line := _lbl("LINE 12", 14, Color(0.22, 0.22, 0.2), true)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(line)

	var black := ColorRect.new()
	black.custom_minimum_size = Vector2(520, 30)
	black.color = Color(0, 0, 0, 1)
	box.add_child(black)

	var t := _lbl("9:13:41", 46, Color(0.30, 0.30, 0.28), true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)

func setTimeout(cb: Callable, ms: int) -> void:
	var timer := get_tree().create_timer(ms / 1000.0, true, false, true)
	timer.timeout.connect(cb)

func set_prompt(text: String) -> void:
	_prompt_action = text
	if text == "":
		_prompt.modulate.a = 0.0
		if _prompt_panel != null:
			_prompt_panel.modulate.a = 0.0
		return
	_prompt.text = "[E]   " + text
	_prompt.modulate.a = 1.0
	if _prompt_panel != null:
		_prompt_panel.modulate.a = 1.0

func prompt_text() -> String:
	return _prompt_action if _prompt.modulate.a > 0.0 else ""

func _on_hint(text: String) -> void:
	say("RAY", text)

func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_build_clock(root)
	_build_torch(root)
	_build_watch(root)
	_build_reticle(root)
	_build_objective(root)
	_build_prompt(root)
	_build_subtitle(root)
	_build_thought(root)
	_build_toasts(root)

func _lbl(text: String, size: int, col: Color, is_title: bool = false, track: float = 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT_TITLE if is_title else FONT_BODY)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	if track > 0.0:
		l.add_theme_constant_override("line_spacing", 0)
	return l

func _build_clock(root: Control) -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(28, 24)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.07, 0.82)
	sb.border_color = Color("ffb968", 0.35)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)

	_clock = _lbl("9:14:00", 20, TORCH, true)
	box.add_child(_clock)

	var sub_row := HBoxContainer.new()
	sub_row.add_theme_constant_override("separation", 6)
	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(5, 5)
	dot.color = Color("9db4d6")
	sub_row.add_child(dot)
	var tag := _lbl("FROZEN IN TIME", 9, Color("9db4d6"), true)
	sub_row.add_child(tag)
	box.add_child(sub_row)

func _build_torch(root: Control) -> void:
	_torch_pill = PanelContainer.new()
	_torch_pill.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_torch_pill.position = Vector2(-70, 24)
	_torch_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.05, 0.08, 0.75)
	sb.border_color = Color(1.0, 0.725, 0.408, 0.35)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	_torch_pill.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_torch_pill.add_child(row)

	_torch_dot = ColorRect.new()
	_torch_dot.custom_minimum_size = Vector2(8, 8)
	_torch_dot.color = TORCH
	row.add_child(_torch_dot)

	_torch_lbl = _lbl("[F]  TORCH", 11, TORCH, false)
	row.add_child(_torch_lbl)

	root.add_child(_torch_pill)

func _build_watch(root: Control) -> void:
	_watch = _lbl("9:27:41", 13, FAINT, true)
	_watch.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_watch.position = Vector2(-110, 24)
	_watch.modulate.a = 0.0
	root.add_child(_watch)

func _build_reticle(root: Control) -> void:
	reticle = Reticle.new()
	reticle.set_anchors_preset(Control.PRESET_CENTER)
	reticle.position = Vector2(-32, -32)
	root.add_child(reticle)

	_tier_label = _lbl("T2", 10, FAINT, true)
	_tier_label.set_anchors_preset(Control.PRESET_CENTER)
	_tier_label.position = Vector2(-14, 40)
	_tier_label.modulate.a = 0.0
	root.add_child(_tier_label)

func _build_objective(root: Control) -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.position = Vector2(28, -28)
	panel.custom_minimum_size = Vector2(320, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.07, 0.88)
	sb.border_color = Color(1.0, 0.73, 0.41, 0.45)
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	box.add_child(_lbl("CURRENT OBJECTIVE · BEAT 1", 10, TORCH, true))
	_objective = _lbl("Hold your beam on the mark", 14, TXT, false)
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_objective)

func _build_prompt(root: Control) -> void:
	_prompt_panel = PanelContainer.new()
	_prompt_panel.set_anchors_preset(Control.PRESET_CENTER)
	_prompt_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_prompt_panel.position = Vector2(0, 62)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.05, 0.09, 0.92)
	sb.border_color = Color("ffb968", 0.75)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	_prompt_panel.add_theme_stylebox_override("panel", sb)

	_prompt = _lbl("", 13, TXT, false)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_panel.add_child(_prompt)
	_prompt_panel.modulate.a = 0.0
	root.add_child(_prompt_panel)

func _build_subtitle(root: Control) -> void:
	_sub_box = PanelContainer.new()
	_sub_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_sub_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_sub_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_sub_box.position = Vector2(0, -96)
	_sub_box.custom_minimum_size = Vector2(760, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.08, 0.92)
	sb.border_color = Color(1.0, 1.0, 1.0, 0.16)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 26
	sb.content_margin_right = 26
	sb.content_margin_top = 12
	sb.content_margin_bottom = 14
	_sub_box.add_theme_stylebox_override("panel", sb)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_sub_box.add_child(col)

	_sub_name = _lbl("", 12, TORCH, true)
	_sub_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_sub_name)

	_sub_text = _lbl("", 18, TXT, false)
	_sub_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_sub_text)

	_sub_name.modulate.a = 0.0
	_sub_text.modulate.a = 0.0
	_sub_box.modulate.a = 0.0
	root.add_child(_sub_box)

func _build_thought(root: Control) -> void:
	_thought_box = PanelContainer.new()
	_thought_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_thought_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_thought_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_thought_box.position = Vector2(0, -32)
	_thought_box.custom_minimum_size = Vector2(680, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.03, 0.06, 0.88)
	sb.border_color = Color("9db4d6", 0.35)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 8
	sb.content_margin_bottom = 9
	_thought_box.add_theme_stylebox_override("panel", sb)

	_thought = _lbl("", 16, MOON, false)
	_thought.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_thought.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_thought_box.add_child(_thought)

	_thought_box.modulate.a = 0.0
	_thought.modulate.a = 0.0
	root.add_child(_thought_box)

func _build_toasts(root: Control) -> void:
	_toasts = VBoxContainer.new()
	_toasts.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_toasts.position = Vector2(-320, -110)
	_toasts.custom_minimum_size = Vector2(300, 0)
	_toasts.add_theme_constant_override("separation", 10)
	root.add_child(_toasts)

func _process(delta: float) -> void:
	if _sub_hold > 0.0:
		_sub_hold -= delta
		if _sub_hold <= 0.0:
			_sub_name.modulate.a = 0.0
			_sub_text.modulate.a = 0.0
			if _sub_box != null:
				_sub_box.modulate.a = 0.0

	var t := Game.tier
	var col: Color = Game.tier_color()
	reticle.tier = t
	reticle.tint = col
	if t == Game.Tier.AGREED:
		_tier_label.text = "T3"
		_tier_label.add_theme_color_override("font_color", PHOS)
		_tier_label.modulate.a = 1.0
	elif t == Game.Tier.MOON:
		_tier_label.text = "T1"
		_tier_label.modulate.a = 0.0
	else:
		_tier_label.text = "T2"
		_tier_label.modulate.a = 0.0
	reticle.progress = _hold_progress
	reticle.queue_redraw()

	_torch_dot.color = TORCH if Game.torch_on else FAINT
	_torch_lbl.add_theme_color_override("font_color", TORCH if Game.torch_on else FAINT)

	if not Game.torch_on:
		_watch.modulate.a = 1.0

func set_hold(p: float) -> void:
	_hold_progress = clampf(p, 0.0, 1.0)

func say(who: String, line: String) -> void:
	_sub_name.text = who.to_upper()
	_sub_text.text = line
	_sub_name.modulate.a = 1.0
	_sub_text.modulate.a = 1.0
	if _sub_box != null:
		_sub_box.modulate.a = 1.0
	_thought.modulate.a = 0.0
	if _thought_box != null:
		_thought_box.modulate.a = 0.0
	_sub_hold = 1.4 + line.length() * 0.045

func think(line: String) -> void:
	_thought.text = "\u201c" + line + "\u201d"
	var tw := create_tween()
	if _thought_box != null:
		tw.tween_property(_thought_box, "modulate:a", 0.95, 0.35)
		tw.parallel().tween_property(_thought, "modulate:a", 1.0, 0.35)
		tw.tween_interval(2.6)
		tw.tween_property(_thought_box, "modulate:a", 0.0, 0.7)
		tw.parallel().tween_property(_thought, "modulate:a", 0.0, 0.7)
	else:
		tw.tween_property(_thought, "modulate:a", 0.92, 0.35)
		tw.tween_interval(2.6)
		tw.tween_property(_thought, "modulate:a", 0.0, 0.7)

func set_objective(text: String) -> void:
	_objective.text = text

func toast(clue_id: String, title: String) -> void:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.024, 0.035, 0.06, 0.94)
	sb.border_color = Color(1.0, 0.725, 0.408, 0.5)
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	pc.add_theme_stylebox_override("panel", sb)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	pc.add_child(box)

	var tag := _lbl("CLUE FOUND · " + clue_id, 10, TORCH, true)
	var t := _lbl(title, 14, TXT, false)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(280, 0)
	box.add_child(tag)
	box.add_child(t)

	pc.modulate.a = 0.0
	_toasts.add_child(pc)

	var tw := create_tween()
	tw.tween_property(pc, "modulate:a", 1.0, 0.35)
	tw.tween_interval(4.0)
	tw.tween_property(pc, "modulate:a", 0.0, 0.45)
	tw.tween_callback(pc.queue_free)