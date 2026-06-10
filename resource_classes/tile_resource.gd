class_name TileResource
extends Resource

@export var name: String
@export var icons: Array[Texture2D]
var icon: Texture2D

func _init():
	_randomize_icon()

func get_icon() -> Texture2D:
	if icon == null:
		_randomize_icon()
	return icon

func _randomize_icon():
	if icons.is_empty():
		icon = null
		return
	icon = icons[randi() % icons.size()]
