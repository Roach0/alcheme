extends TileResource
class_name Trees

@export var max_hp: int = 10
@export var wood_per_click: int = 1
@export var wood_on_destroy: int = 5

var current_hp: int = 10

func _post_duplicate() -> void:
	current_hp = max_hp
	print("Tree initialized with HP: %d" % current_hp)

func _click() -> Dictionary:
	current_hp -= 1
	print("Tree chopped! HP: %d/%d" % [current_hp, max_hp])
	if current_hp <= 0:
		return { "destroyed": true, "wood": wood_on_destroy }
	return { "destroyed": false, "wood": wood_per_click }

func _on_destroy() -> void:
	print("A tree has been felled.")
