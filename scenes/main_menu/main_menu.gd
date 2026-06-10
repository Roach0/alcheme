extends Control
class_name MainMenu

func _ready() -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/game_scene.tscn")
