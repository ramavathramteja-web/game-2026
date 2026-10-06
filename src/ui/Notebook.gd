class_name Notebook
extends CanvasLayer

const FONT_TITLE := preload("res://assets/Cinzel.tres")
const FONT_BODY := preload("res://assets/Outfit.tres")

const VOID := Color("04050a")
const PANEL := Color("080c14")
const TXT := Color("f0f3f8")
const DIM := Color("8fa0b8")
const FAINT := Color("526074")
const TORCH := Color("ffb968")
const GOLD := Color("ffc98a")
const PHOS := Color("d9f2a8")

const TABS := ["CLUES", "PEOPLE", "WHAT I KNOW", "CONNECT"]

const CHIPS := [
	{ "id": "sig", "label": "SIGNATURE / CD-19",
	  "pairs": { "hand": "A signature and my handwriting. That's not a coincidence, that's a policy.",
	             "cnt": "Somebody finished what Marlow started, and they had to sign for it." } },
	{ "id": "hand", "label": "HANDWRITING / MINE",
	  "pairs": { "sig": "A signature and my handwriting. That's not a coincidence, that's a policy.",
	             "cnt": "I knew about one of these. I wrote down one of these and then I forgot it." } },
	{ "id": "cnt", "label": "COUNTER / 2",
	  "pairs": { "sig": "Somebody finished what Marlow started, and they had to sign for it.",
	             "hand": "I knew about one of these. I wrote down one of these and then I forgot it." } },
]

var open: bool = false

var _panel: PanelContainer
var _tab_buttons: Array[Button] = []
var _panes: Array[Control] = []
var _clue_list: VBoxContainer
var _detail: VBoxContainer
var _people_grid: GridContainer
var _know_box: VBoxContainer
var _chip_row: HBoxContainer
var _chip_buttons: Dictionary = {}
var _target: PanelContainer
var _target_count: Label
var _reason: Label
var _selected_row: String = ""
var _people_met: int = 0

var _held: String = ""
var _placed: Array[String] = []

func _ready() -> void:
	layer = 20
	visible = false
	_build()

func toggle() -> void:
	open = not open
	visible = open
	if open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		refresh()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _build() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.01, 0.015, 0.03, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 80
	_panel.offset_right = -80
	_panel.offset_top = 50
	_panel.offset_bottom = -50
	_panel.add_theme_stylebox_override("panel", _style(PANEL, Color(1.0, 0.76, 0.44, 0.22), 10))
	backdrop.add_child(_panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	_panel.add_child(col)

	col.add_child(_build_header())

	var div := ColorRect.new()
	div.custom_minimum_size = Vector2(0, 1)
	div.color = Color(1.0, 0.76, 0.44, 0.18)
	col.add_child(div)

	var body := Control.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)

	_panes = []
	_panes.append(_build_clues())
	_panes.append(_build_people())
	_panes.append(_build_know())
	_panes.append(_build_connect())
	for p in _panes:
		body.add_child(p)
	_select(0)

func _build_header() -> Control:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.custom_minimum_size = Vector2(0, 48)

	var title := _label("CASE 0001 · DETECTIVE RAY", 12, GOLD, true)
	title.custom_minimum_size = Vector2(240, 0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(title)

	for i in TABS.size():
		var b := Button.new()
		b.text = TABS[i]
		b.add_theme_font_override("font", FONT_TITLE)
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", DIM)
		b.add_theme_color_override("font_hover_color", TORCH)
		var b_norm := StyleBoxFlat.new()
		b_norm.bg_color = Color(0, 0, 0, 0)
		b_norm.content_margin_left = 12
		b_norm.content_margin_right = 12
		b.add_theme_stylebox_override("normal", b_norm)
		b.pressed.connect(_select.bind(i))
		head.add_child(b)
		_tab_buttons.append(b)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)

	var close := Button.new()
	close.text = "CLOSE  [TAB]"
	close.add_theme_font_override("font", FONT_BODY)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", FAINT)
	close.add_theme_color_override("font_hover_color", TORCH)
	var c_norm := StyleBoxFlat.new()
	c_norm.bg_color = Color(0.08, 0.1, 0.16, 0.6)
	c_norm.border_color = Color(1.0, 1.0, 1.0, 0.1)
	c_norm.set_border_width_all(1)
	c_norm.set_corner_radius_all(6)
	c_norm.content_margin_left = 12
	c_norm.content_margin_right = 12
	c_norm.content_margin_top = 4
	c_norm.content_margin_bottom = 4
	close.add_theme_stylebox_override("normal", c_norm)
	close.pressed.connect(toggle)
	head.add_child(close)

	return head

func _select(i: int) -> void:
	for j in _tab_buttons.size():
		_tab_buttons[j].add_theme_color_override("font_color", TORCH if j == i else DIM)
	for j in _panes.size():
		_panes[j].visible = j == i
	refresh()

func _build_clues() -> Control:
	var wrap := HBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrap.add_theme_constant_override("separation", 16)

	var left := ScrollContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.custom_minimum_size = Vector2(440, 0)
	left.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wrap.add_child(left)

	_clue_list = VBoxContainer.new()
	_clue_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clue_list.add_theme_constant_override("separation", 6)
	left.add_child(_clue_list)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(1, 0)
	sep.color = Color(1.0, 1.0, 1.0, 0.08)
	wrap.add_child(sep)

	var right := ScrollContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wrap.add_child(right)

	_detail = VBoxContainer.new()
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 10)
	right.add_child(_detail)

	return wrap

func _build_people() -> Control:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_people_grid = GridContainer.new()
	_people_grid.columns = 3
	_people_grid.add_theme_constant_override("h_separation", 14)
	_people_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_people_grid)
	return scroll

func _build_know() -> Control:
	var wrap := VBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrap.offset_left = 60
	wrap.offset_top = 20
	wrap.add_theme_constant_override("separation", 24)
	_know_box = VBoxContainer.new()
	_know_box.add_theme_constant_override("separation", 20)
	wrap.add_child(_know_box)
	return wrap

func _build_connect() -> Control:
	var wrap := VBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.add_theme_constant_override("separation", 18)

	var lede := _label("Drag every entry onto the Sun Control switch. Ray will tell you what he thinks it means.", 13, DIM, false)
	lede.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wrap.add_child(lede)

	_chip_row = HBoxContainer.new()
	_chip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_chip_row.add_theme_constant_override("separation", 12)
	wrap.add_child(_chip_row)

	_target = PanelContainer.new()
	_target.custom_minimum_size = Vector2(280, 120)
	_target.add_theme_stylebox_override("panel", _style(Color(0.02, 0.03, 0.02, 0.7), Color(0.85, 0.95, 0.66, 0.4), 8))
	var tcol := VBoxContainer.new()
	tcol.alignment = BoxContainer.ALIGNMENT_CENTER
	_target.add_child(tcol)
	var tl := _label("SUN CONTROL SWITCH", 12, PHOS, true)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tcol.add_child(tl)
	_target_count = _label("0 / 3", 11, FAINT, false)
	_target_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tcol.add_child(_target_count)
	wrap.add_child(_target)

	_reason = _label("", 15, Color("9db4d6"), false)
	_reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reason.custom_minimum_size = Vector2(640, 60)
	wrap.add_child(_reason)

	_build_chips()
	return wrap

func _build_chips() -> void:
	for c in CHIPS:
		var b := Button.new()
		b.text = String(c["label"])
		b.add_theme_font_override("font", FONT_BODY)
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", PHOS)
		b.add_theme_color_override("font_hover_color", Color("ffffff"))
		b.add_theme_stylebox_override("normal", _style(Color(0.85, 0.95, 0.66, 0.08), Color(0.85, 0.95, 0.66, 0.35), 6))
		b.add_theme_stylebox_override("hover", _style(Color(0.85, 0.95, 0.66, 0.22), Color(0.85, 0.95, 0.66, 0.7), 6))
		b.pressed.connect(_pick_chip.bind(String(c["id"])))
		_chip_row.add_child(b)
		_chip_buttons[String(c["id"])] = b

func _pick_chip(id: String) -> void:
	_held = id
	_place()

func _place() -> void:
	if _held == "" or _placed.has(_held):
		return
	_placed.append(_held)
	_held = ""

	for id in _chip_buttons.keys():
		if _placed.has(String(id)):
			var b := _chip_buttons[id] as Button
			if b != null:
				b.visible = false

	_target_count.text = str(_placed.size()) + " / 3"

	if _placed.size() >= 2:
		var last := _placed[_placed.size() - 1]
		var prior := _placed[_placed.size() - 2]
		var chip := _chip(last)
		var pairs: Dictionary = chip["pairs"]
		_reason.text = String(pairs.get(prior, ""))

	if _placed.size() == 3:
		_reason.add_theme_color_override("font_color", PHOS)
		_reason.text = "Case closed."
		Game.closed_case = true
		Game.set_flag("case_closed", true)
		var t := get_tree().create_timer(2.6, true, false, true)
		t.timeout.connect(_on_case_closed)

func _on_case_closed() -> void:
	if Game.hud != null and Game.hud.has_method("show_finale"):
		Game.hud.call("show_finale")

func _chip(id: String) -> Dictionary:
	for c in CHIPS:
		if String(c["id"]) == id:
			return c
	return {}

func _style(bg: Color, border: Color, radius: int = 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb

func _label(text: String, size: int, col: Color, is_title: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT_TITLE if is_title else FONT_BODY)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("notebook"):
		toggle()
		get_viewport().set_input_as_handled()

func refresh() -> void:
	if not visible:
		return
	_refresh_clues()
	_refresh_people()
	_refresh_know()

func _refresh_clues() -> void:
	for c in _clue_list.get_children():
		c.queue_free()

	if Game.clues.is_empty():
		_clue_list.add_child(_label("Nothing found yet. Sweep with the flashlight.", 13, FAINT, false))
		return

	var ids := Game.clues.duplicate()
	ids.reverse()
	for id in ids:
		var b := Button.new()
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_override("font", FONT_BODY)
		b.add_theme_font_size_override("font_size", 13)
		b.add_theme_color_override("font_color", TXT)
		b.add_theme_color_override("font_hover_color", TORCH)
		var b_sb := StyleBoxFlat.new()
		b_sb.bg_color = Color(0.04, 0.06, 0.1, 0.6)
		b_sb.border_color = Color(1.0, 0.76, 0.44, 0.15)
		b_sb.set_border_width_all(1)
		b_sb.set_corner_radius_all(4)
		b_sb.content_margin_left = 12
		b_sb.content_margin_right = 12
		b_sb.content_margin_top = 8
		b_sb.content_margin_bottom = 8
		b.add_theme_stylebox_override("normal", b_sb)
		var b_hover := b_sb.duplicate() as StyleBoxFlat
		b_hover.bg_color = Color(0.08, 0.12, 0.18, 0.8)
		b_hover.border_color = TORCH
		b.add_theme_stylebox_override("hover", b_hover)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.text = "[" + String(id) + "]   " + Game.clue_title(id)
		b.pressed.connect(_show_detail.bind(id))
		_clue_list.add_child(b)
		if _selected_row == "":
			_show_detail(id)

	if _selected_row != "":
		_show_detail(_selected_row)

func _show_detail(id: String) -> void:
	_selected_row = id
	for c in _detail.get_children():
		c.queue_free()

	_detail.add_child(_label("CLUE RECORD · " + String(id), 11, TORCH, true))
	var t := _label(Game.clue_title(id), 22, TXT, false)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(t)

	_detail.add_child(_spacer(8))
	_detail.add_child(_label("FOUND IN", 10, FAINT, true))
	var loc := _label(_where(id), 14, DIM, false)
	loc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(loc)
	_detail.add_child(_spacer(8))
	_detail.add_child(_label("SIGNIFICANCE", 10, FAINT, true))
	var sig := _label(_unlocks(id), 14, DIM, false)
	sig.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(sig)

func _where(id: String) -> String:
	match id:
		"I-01": return "Annex, wall clock"
		"I-04": return "Annex, lectern logbook"
		"I-05": return "Annex, swivel mirror"
		"I-06": return "Annex, far wall"
		_: return "—"

func _unlocks(id: String) -> String:
	match id:
		"I-06": return "Nothing. Yet. That is the point."
		"I-04": return "The blank page is not blank on page twelve."
		_: return "—"

func _refresh_people() -> void:
	for c in _people_grid.get_children():
		c.queue_free()
	_people_met = 0

	var rows := [
		["THE MOON", "WITNESS / CORNER", Game.has_clue("S-01")],
		["MR. WICK", "TALKING LAMP / SHOP", Game.has_clue("D-02")],
		["SIR", "TOASTER / DINER", Game.has_clue("S-03")],
		["THE CLOUDS", "WITNESS / ABOVE", false],
		["MARLOW", "THE VILLAIN", Game.has_clue("V-02")],
		["LUMEN", "SECOND LAMP / VAULT", Game.has_clue("F-01")],
	]

	for r in rows:
		var known: bool = r[2]
		if known:
			_people_met += 1
		var card := PanelContainer.new()
		var bg := Color(0.04, 0.06, 0.1, 0.85) if known else Color(0.02, 0.03, 0.04, 0.8)
		var border := Color(1.0, 0.76, 0.44, 0.3) if known else Color(1, 1, 1, 0.07)
		card.add_theme_stylebox_override("panel", _style(bg, border, 8))
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 6)
		card.add_child(col)

		var nm := _label(String(r[0]), 14, TXT if known else FAINT, true)
		col.add_child(nm)
		col.add_child(_label(String(r[1]), 10, FAINT, false))
		if not known:
			col.add_child(_label("Not met yet", 12, FAINT, false))

		_people_grid.add_child(card)

func _refresh_know() -> void:
	for c in _know_box.get_children():
		c.queue_free()

	if Game.has_clue("I-06"):
		_know_box.add_child(_hand("9:14", true))
	if Game.clues.size() >= 2:
		_know_box.add_child(_hand("Something pushed it. Something east.", false))
	if Game.has_clue("I-04"):
		_know_box.add_child(_hand("It was me.", true))

	if _know_box.get_child_count() == 0:
		_know_box.add_child(_label("Ray hasn't written anything down yet.", 14, FAINT, false))

func _hand(text: String, glow: bool) -> Label:
	var l := _label(text, 28, PHOS if glow else Color("e8e4da"), false)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func clue_list_size() -> int:
	return _clue_list.get_child_count()

func know_line_count() -> int:
	return _know_box.get_child_count()

func placed_count() -> int:
	return _placed.size()

func reason_text() -> String:
	return _reason.text

func people_met_count() -> int:
	return _people_met

func select(i: int) -> bool:
	if i < 0 or i >= _panes.size():
		return false
	_select(i)
	return true

func pick(id: String) -> void:
	_pick_chip(id)