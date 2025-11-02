extends Control

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")

func _on_level_button_pressed(button) -> void:
	GlobalLevelManager.levelID = (button as Button).text.to_int()
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

func _on_test_level_button_pressed() -> void:
	GlobalLevelManager.levelID = -1
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")
