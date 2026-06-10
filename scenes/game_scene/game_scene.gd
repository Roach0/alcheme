extends Node
class_name GameScene

@onready var tile_queue: TileQueue = $Effects/TileQueue
@onready var player: Player = $Effects/S1/Player

func _ready():
	var current_map = preload("res://scenes/components/maps/forest.tres")
	tile_queue.load_map(current_map)
	tile_queue.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile: TileResource, button: Button, result: Dictionary) -> void:
	var wood_gained = result.get("wood", 0)
	if wood_gained > 0:
		player.add_wood(wood_gained)

	if not result.get("destroyed", false) and tile is Trees:
		var slot = button.get_parent()
		slot.update_hp_display(tile.current_hp, tile.max_hp)
