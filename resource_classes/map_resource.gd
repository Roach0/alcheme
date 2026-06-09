class_name MapResource
extends Resource

@export var row_1: Array[TileResource] = []
@export var row_2: Array[TileResource] = []
@export var row_3: Array[TileResource] = []
@export var row_4: Array[TileResource] = []
@export var row_5: Array[TileResource] = []
@export var row_6: Array[TileResource] = []
@export var row_7: Array[TileResource] = []
@export var row_8: Array[TileResource] = []
@export var row_9: Array[TileResource] = []
@export var row_10: Array[TileResource] = []
@export var row_11: Array[TileResource] = []
@export var row_12: Array[TileResource] = []
@export var row_13: Array[TileResource] = []

func get_tile(row_1indexed: int, col_0indexed: int) -> TileResource:
	var row = _get_row(row_1indexed)
	if col_0indexed >= row.size():
		return null
	return row[col_0indexed]

func _get_row(row_1indexed: int) -> Array:
	match row_1indexed:
		1: return row_1
		2: return row_2
		3: return row_3
		4: return row_4
		5: return row_5
		6: return row_6
		7: return row_7
		8: return row_8
		9: return row_9
		10: return row_10
		11: return row_11
		12: return row_12
		13: return row_13
	return []
