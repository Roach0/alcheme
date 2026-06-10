class_name TileResource
extends Resource

@export var icons: Array[Texture2D]
# TileData.tres — your resource files map type name → scene/texture
@export var type_name: String = "tree"
@export var scene: PackedScene
@export var texture: Texture2D
@export var weight: float = 1.0  # for biasing collapse
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
