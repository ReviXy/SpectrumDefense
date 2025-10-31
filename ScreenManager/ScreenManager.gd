extends Node

@export var MainMenu : Node

@export var BattleScreen : Node

func battle():
	BattleScreen.visible = true
	MainMenu.visible = false
	BattleScreen.set_active(true)
	MainMenu.set_active(false)

func menu():
	BattleScreen.visible = false
	MainMenu.visible = true
	BattleScreen.set_active(false)
	MainMenu.set_active(true)
