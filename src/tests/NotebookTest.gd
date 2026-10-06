extends Node

var _nb: Notebook
var _fail := 0
var _out: Array[String] = []

func _ready() -> void:
	var level: Node = load("res://src/levels/L1_DarkCity.tscn").instantiate()
	add_child(level)
	await get_tree().process_frame

	_nb = null
	for c in level.get_children():
		if c is Notebook:
			_nb = c as Notebook

	_check(_nb != null, "notebook instantiates in level")
	if _nb == null:
		_finish()
		return

	_check(_nb.clue_list_size() == 0, "starts with zero clues")

	Game.add_clue("I-06")
	Game.add_clue("I-04")
	Game.add_clue("D-02")
	_nb.open = true
	_nb.visible = true
	_nb.refresh()

	_check(_nb.clue_list_size() == 3, "lists all three clues")
	_check(_nb.people_met_count() == 1, "D-02 unlocks exactly one person (Wick)")
	_check(_nb.know_line_count() == 3, "three clues write three handwritten lines")
	_check(_nb.select(3), "connect tab selectable")

	_nb.pick("sig")
	_check(_nb.placed_count() == 1, "chip one placed")
	_nb.pick("hand")
	_check(_nb.placed_count() == 2, "chip two placed")
	_check(_nb.reason_text() != "", "pairing produces a Ray line")
	_nb.pick("cnt")
	_check(_nb.placed_count() == 3, "all three placed")
	_check(_nb.reason_text() == "Case closed.", "three chips close the case")
	_check(Game.closed_case, "Game.closed_case set")
	_finish()

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("NOTEBOOK: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)