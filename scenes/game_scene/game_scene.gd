extends Node

@onready var tile_queue: TileQueue = $Effects/CardQueue

# want to populate the grid map using preload maps stored in resources, so the initial layouts

func _ready():
	var current_map = preload("res://scenes/components/maps/forest.tres")
	tile_queue.load_map(current_map)
