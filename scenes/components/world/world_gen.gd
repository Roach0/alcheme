class_name WFCGenerator

# ── Config ────────────────────────────────────────────────────────────────────

# Adjacency rules: what each tile TYPE allows as neighbours in each direction.
# Drives all clustering — tweak this to change biome shapes.
const RULES := {
	"empty": {
		"n": ["empty", "tree", "water", "stone"],
		"s": ["empty", "tree", "water", "stone"],
		"e": ["empty", "tree", "water", "stone"],
		"w": ["empty", "tree", "water", "stone"],
	},
	"tree": {
		"n": ["tree", "empty"],
		"s": ["tree", "empty"],
		"e": ["tree", "empty"],
		"w": ["tree", "empty"],
	},
	"water": {
		"n": ["water", "empty"],
		"s": ["water", "empty"],
		"e": ["water", "empty"],
		"w": ["water", "empty"],
	},
	"stone": {
		"n": ["stone", "tree", "empty"],
		"s": ["stone", "tree", "empty"],
		"e": ["stone", "empty"],
		"w": ["stone", "empty"],
	},
}

# Collapse weights — higher = more likely to be chosen when a cell collapses.
const WEIGHTS := {
	"empty": 8,
	"tree":  4,
	"water": 2,
	"stone": 1,
}

const DIRS := { "n": Vector2i(0,-1), "s": Vector2i(0,1), "e": Vector2i(1,0), "w": Vector2i(-1,0) }
const OPP  := { "n": "s", "s": "n", "e": "w", "w": "e" }

# ── State ─────────────────────────────────────────────────────────────────────

var width:  int
var height: int
var size:   int
var types:  Array   # ["empty", "tree", ...]

# Each cell = Array of still-possible type strings (superposition)
var cells: Array

# ── Init ──────────────────────────────────────────────────────────────────────

func _init(w: int, h: int, tile_resources: Dictionary) -> void:
	width  = w
	height = h
	size   = w * h
	# Only include types we actually have resources for
	types  = tile_resources.keys()
	if "empty" not in types:
		types.append("empty")

# ── Public entry ──────────────────────────────────────────────────────────────

func generate() -> Array:
	_reset()
	var attempts := 0
	while attempts < 50:
		var result = _run()
		if result != null:
			return result
		attempts += 1
		_reset()
	push_error("WFC: failed after 50 attempts, returning all-empty map")
	var fallback: Array = []
	fallback.resize(size)
	fallback.fill("empty")
	return fallback

# ── Core loop ─────────────────────────────────────────────────────────────────

func _run() -> Variant:
	while true:
		var idx = _lowest_entropy_idx()
		if idx == -1:
			break  # all collapsed
		if not _collapse(idx):
			return null  # contradiction
		if not _propagate(idx):
			return null

	# Extract result — each cell should now be size-1
	var out: Array = []
	out.resize(size)
	for i in size:
		out[i] = cells[i][0] if cells[i].size() > 0 else "empty"
	return out

func _reset() -> void:
	cells = []
	cells.resize(size)
	for i in size:
		cells[i] = types.duplicate()

# ── Entropy ───────────────────────────────────────────────────────────────────

func _lowest_entropy_idx() -> int:
	var best_idx   := -1
	var best_count := 999999
	for i in size:
		var n = cells[i].size()
		if n == 1:
			continue  # already collapsed
		if n == 0:
			return -2  # contradiction
		if n < best_count:
			best_count = n
			best_idx   = i
	return best_idx

# ── Collapse ──────────────────────────────────────────────────────────────────

func _collapse(idx: int) -> bool:
	var options: Array = cells[idx]
	if options.is_empty():
		return false

	# Build weighted pool
	var pool := []
	for t in options:
		var w = WEIGHTS.get(t, 1)
		for _i in w:
			pool.append(t)

	cells[idx] = [pool[randi() % pool.size()]]
	return true

# ── Propagation ───────────────────────────────────────────────────────────────

func _propagate(start_idx: int) -> bool:
	var queue := [start_idx]
	var in_queue := {}
	in_queue[start_idx] = true

	while not queue.is_empty():
		var cur = queue.pop_front()
		in_queue.erase(cur)
		var cur_options: Array = cells[cur]
		var cp = _idx_to_pos(cur)

		for dir in DIRS:
			var np = cp + DIRS[dir]
			if not _in_bounds(np.x, np.y):
				continue
			var ni = _pos_to_idx(np.x, np.y)
			var neighbor: Array = cells[ni]
			if neighbor.size() == 1:
				continue  # already collapsed

			# What does cur allow in this direction?
			var allowed := {}
			for t in cur_options:
				var rule = RULES.get(t, {})
				for a in rule.get(dir, []):
					allowed[a] = true

			# Filter neighbour
			var new_options := []
			for t in neighbor:
				if t in allowed:
					new_options.append(t)

			if new_options.is_empty():
				return false  # contradiction

			if new_options.size() < neighbor.size():
				cells[ni] = new_options
				if ni not in in_queue:
					queue.append(ni)
					in_queue[ni] = true

	return true

# ── Helpers ───────────────────────────────────────────────────────────────────

func _pos_to_idx(x: int, y: int) -> int:
	return y * width + x

func _idx_to_pos(idx: int) -> Vector2i:
	return Vector2i(idx % width, idx / width)

func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height
