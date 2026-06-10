class_name World
extends MarginContainer

signal tile_clicked(tile: TileResource, button: Button, result: Dictionary)
signal queue_is_full
signal discard

const WIDTH  := 13
const HEIGHT := 13
const SIZE   := WIDTH * HEIGHT  # 169

# Flat array — index via _idx(x, y)
var grid: Array = []

var pending_slot: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	grid.resize(SIZE)
	grid.fill(null)

	for y in HEIGHT:
		for x in WIDTH:
			var btn = get_node_or_null("Layout/Row%d/Slot%d/Button" % [y + 1, x + 1])
			if btn:
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.modulate.a = 0.3
				btn.pressed.connect(_on_queue_button_pressed.bind(btn))


# ── Index helpers ─────────────────────────────────────────────────────────────

func _idx(x: int, y: int) -> int:
	return y * WIDTH + x

func _pos(idx: int) -> Vector2i:
	return Vector2i(idx % WIDTH, idx / WIDTH)

func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT


# ── Grid read/write ───────────────────────────────────────────────────────────

func _write(x: int, y: int, tile: TileResource) -> void:
	grid[_idx(x, y)] = tile

func _clear(x: int, y: int) -> void:
	grid[_idx(x, y)] = null

func get_tile(x: int, y: int) -> TileResource:
	if not _in_bounds(x, y): return null
	return grid[_idx(x, y)]


# ── Queries ───────────────────────────────────────────────────────────────────

func is_full() -> bool:
	return _next_open_slot() == Vector2i(-1, -1)

func open_slots() -> Array:
	var empties = []
	for i in SIZE:
		if grid[i] == null:
			var p = _pos(i)
			var node = get_node_or_null("Layout/Row%d/Slot%d" % [p.y + 1, p.x + 1])
			if node:
				empties.append(node)
	return empties

func _find_tile(tile: TileResource) -> Vector2i:
	var idx = grid.find(tile)
	if idx == -1: return Vector2i(-1, -1)
	return _pos(idx)

func _next_open_slot() -> Vector2i:
	if pending_slot == Vector2i(-1, -1):
		_pick_pending_slot()
	return pending_slot


# ── Pending / Highlight ───────────────────────────────────────────────────────

func _set_pending_slot(target: Vector2i) -> void:
	# Dim the old one
	if pending_slot != Vector2i(-1, -1):
		var old_btn = get_node_or_null(
			"Layout/Row%d/Slot%d/Button" % [pending_slot.y + 1, pending_slot.x + 1])
		if old_btn:
			old_btn.modulate.a = 0.3

	pending_slot = target
	if pending_slot == Vector2i(-1, -1):
		return

	# Highlight the new one
	var btn = get_node_or_null(
		"Layout/Row%d/Slot%d/Button" % [pending_slot.y + 1, pending_slot.x + 1])
	if btn:
		btn.modulate.a = 1.0

func _pick_pending_slot() -> void:
	var open = []
	for i in SIZE:
		if grid[i] == null:
			open.append(_pos(i))
	if open.is_empty():
		_set_pending_slot(Vector2i(-1, -1))
		return
	_set_pending_slot(open[randi() % open.size()])


# ── Tile operations ───────────────────────────────────────────────────────────

func add_tile(tile: TileResource) -> Node:
	if is_full():
		queue_is_full.emit()
		return null

	var open = _next_open_slot()
	var x = open.x
	var y = open.y
	var slot   = get_node_or_null("Layout/Row%d/Slot%d"        % [y + 1, x + 1])
	var button = get_node_or_null("Layout/Row%d/Slot%d/Button" % [y + 1, x + 1])

	if not slot or not button:
		push_error("World: missing node at (%d, %d)" % [x, y])
		return null

	_write(x, y, tile)
	pending_slot = Vector2i(-1, -1)

	button.modulate.a = 0.3
	slot.button = button
	slot.assign(tile)
	button.mouse_filter = Control.MOUSE_FILTER_STOP

	_pick_pending_slot()
	return slot

func remove_tile(button: Button) -> void:
	var slot       = button.get_parent()
	var row_node   = slot.get_parent()
	var x          = int(slot.name.lstrip("Slot")) - 1
	var y          = int(row_node.name.lstrip("Row")) - 1
	var tile       = slot.tile

	_clear(x, y)
	discard.emit(tile)

	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.modulate.a   = 0.3
	slot.is_clearing    = true

	var tw = slot.remove_out()
	tw.tween_callback(func():
		slot.clear()
		slot.is_clearing = false
		_set_pending_slot(Vector2i(x, y))
	)

func lock_slot(slot: Node) -> void:
	var x      = int(slot.name.lstrip("Slot")) - 1
	var y      = int(slot.get_parent().name.lstrip("Row")) - 1
	var button = get_node_or_null("Layout/Row%d/Slot%d/Button" % [y + 1, x + 1])
	if button:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.modulate.a   = 0.5


# ── World generation (WFC) ────────────────────────────────────────────────────

func generate_world(tile_resources: Dictionary) -> void:
	var wfc    = WFCGenerator.new(WIDTH, HEIGHT, tile_resources)
	var result = wfc.generate()  # returns flat Array of type-name strings

	for i in SIZE:
		var p         = _pos(i)
		var type_name = result[i]
		var res       = tile_resources.get(type_name)
		if res == null:
			continue
		add_tile(res)  # uses pending slot system, or call _place_directly below

func _place_tile_at(x: int, y: int, tile: TileResource) -> void:
	"""Directly place without using the pending-slot queue — used by world gen."""
	var slot   = get_node_or_null("Layout/Row%d/Slot%d"        % [y + 1, x + 1])
	var button = get_node_or_null("Layout/Row%d/Slot%d/Button" % [y + 1, x + 1])
	if not slot or not button: return

	_write(x, y, tile)
	button.modulate.a = 0.3
	slot.button       = button
	slot.assign(tile)
	button.mouse_filter = Control.MOUSE_FILTER_STOP


# ── Debug ─────────────────────────────────────────────────────────────────────

func print_grid() -> void:
	for y in HEIGHT:
		var row_str = []
		for x in WIDTH:
			var t = get_tile(x, y)
			row_str.append(t.name if t else "·")
		print("Row %d: %s" % [y + 1, ", ".join(row_str)])


# ── Input handler ─────────────────────────────────────────────────────────────

func _on_queue_button_pressed(button: Button) -> void:
	var slot = button.get_parent()
	var tile = slot.tile
	if tile == null:
		return
	if tile.has_method("_click"):
		var result = tile._click()
		tile_clicked.emit(tile, button, result)
		if result.get("destroyed", false):
			remove_tile(button)
	else:
		remove_tile(button)
