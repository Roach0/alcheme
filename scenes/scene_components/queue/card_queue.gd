class_name CardQueue
extends MarginContainer

@onready var grid: Dictionary = {
	1: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	2: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	3: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	4: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	5: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	6: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	7: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	8: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	9: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	10: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	11: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	12: [null, null, null, null, null, null, null, null, null, null, null, null, null],
	13: [null, null, null, null, null, null, null, null, null, null, null, null, null],
}

var active_row: int = 1
var pending_slot: Vector2i = Vector2i(-1, -1)
signal queue_is_full
signal discard
signal setup

func _ready() -> void:
	for row in grid:
		for i in range(grid[row].size()):
			var btn = get_node_or_null("Layout/Row%d/Slot%d/Button" % [row, i + 1])
			if btn:
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.modulate.a = 0.3
				btn.pressed.connect(_on_queue_button_pressed.bind(btn))
	setup.emit()
	_pick_pending_slot()

# --- Grid Helpers ---
func _grid_row() -> Array:
	return grid[active_row]

func _write_to_grid(row: int, index: int, card: CardResource) -> void:
	grid[row][index] = card

func _clear_from_grid(row: int, index: int) -> void:
	grid[row][index] = null

# --- Queries ---
func _next_open_slot() -> Vector2i:
	if pending_slot == Vector2i(-1, -1):
		_pick_pending_slot()
	return pending_slot

func is_full() -> bool:
	return _next_open_slot() == Vector2i(-1, -1)

func open_slots() -> Array:
	var empties = []
	for row in grid:
		for i in range(grid[row].size()):
			if grid[row][i] == null:
				var node = get_node_or_null("Layout/Row%d/Slot%d" % [row, i + 1])
				if node:
					empties.append(node)
	return empties

func _find_slot_index(card: CardResource) -> Vector2i:
	for row in range(1, grid.size() + 1):
		var idx = grid[row].find(card)
		if idx != -1:
			return Vector2i(row, idx)
	return Vector2i(-1, -1)

# --- Pending / Highlight ---
func _set_pending_slot(target: Vector2i) -> void:
	if pending_slot != Vector2i(-1, -1):
		var old_btn = get_node_or_null("Layout/Row%d/Slot%d/Button" % [pending_slot.x, pending_slot.y + 1])
		if old_btn:
			old_btn.modulate.a = 0.3
	pending_slot = target
	if pending_slot == Vector2i(-1, -1):
		return
	var btn = get_node_or_null("Layout/Row%d/Slot%d/Button" % [pending_slot.x, pending_slot.y + 1])
	if btn:
		btn.modulate.a = 1.0

func _pick_pending_slot() -> void:
	var open = []
	for row in range(1, grid.size() + 1):
		for i in range(grid[row].size()):
			if grid[row][i] == null:
				open.append(Vector2i(row, i))
	if open.is_empty():
		_set_pending_slot(Vector2i(-1, -1))
		return
	_set_pending_slot(open[randi() % open.size()])

# --- Methods ---
func add_card(card: CardResource) -> Node:
	if is_full():
		queue_is_full.emit()
		return null
	var open = _next_open_slot()
	var row = open.x
	var index = open.y
	var slot_number = index + 1
	var slot = get_node_or_null("Layout/Row%d/Slot%d" % [row, slot_number])
	var button = get_node_or_null("Layout/Row%d/Slot%d/Button" % [row, slot_number])
	if not slot or not button:
		push_error("CardQueue: missing node for row %d slot %d" % [row, slot_number])
		return null
	grid[row][index] = card
	pending_slot = Vector2i(-1, -1)
	button.modulate.a = 0.3  # reset before picking a new pending slot
	slot.button = button
	slot.assign(card)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	_pick_pending_slot()
	return slot

func remove_card(button: Button) -> void:
	var slot = button.get_parent()
	var row_node = slot.get_parent()
	var slot_number = int(slot.name.lstrip("Slot"))
	var row_number = int(row_node.name.lstrip("Row"))
	var card = slot.card
	grid[row_number][slot_number - 1] = null
	discard.emit(card)
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.modulate.a = 0.3
	slot.is_clearing = true
	var tw = slot.remove_out()
	tw.tween_callback(func():
		slot.clear()
		slot.is_clearing = false
		_set_pending_slot(Vector2i(row_number, slot_number - 1))
	)

func lock_queue_slot(slot: Node) -> void:
	var slot_number = int(slot.name.lstrip("Slot"))
	var row_number = int(slot.get_parent().name.lstrip("Row"))
	var button = get_node_or_null("Layout/Row%d/Slot%d/Button" % [row_number, slot_number])
	if button:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.modulate.a = 0.5

# --- Debug Utility ---
func print_grid() -> void:
	for row in grid:
		var row_str = grid[row].map(func(c): return c.name if c else "·")
		print("Row %d: %s" % [row, ", ".join(row_str)])

# --- Handlers ---
func _on_queue_button_pressed(button: Button) -> void:
	remove_card(button)
