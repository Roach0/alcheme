extends VBoxContainer
class_name Player

@onready var wood_label: Label = $Wood

var wood: int = 0

func _ready() -> void:
	_update_labels()

func add_wood(amount: int) -> void:
	wood += amount
	_update_labels()

func _update_labels() -> void:
	wood_label.text = "Wood: %d" % wood
