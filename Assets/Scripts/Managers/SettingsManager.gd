extends Control

@onready var settingsMenu = $SettingsMenu

func showSettingsMenu():
	settingsMenu.visible = true

func hideSettingsMenu():
	settingsMenu.visible = false

func _on_save_and_quit_button_pressed() -> void:
	hideSettingsMenu()
