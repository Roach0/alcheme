extends TileResource
class_name Trees


func _tick():
	pass

func _click():
	print("This just got chopped!")
	pass

func _on_destroy():
	print("A tree has been felled.")
	pass
