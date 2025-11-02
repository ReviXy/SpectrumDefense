extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/LevelSelectionMenu.tscn")

func _on_options_button_pressed() -> void:
	SettingsManager.showSettingsMenu()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
