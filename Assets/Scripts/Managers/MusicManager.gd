extends Control

@onready var menuMusic = $MenuMusic
@onready var levelMusic = $LevelMusic

func _ready() -> void:
	menuMusic.play()

func enter_level():
	menuMusic.stop()
	levelMusic.play()

func enter_menu():
	levelMusic.stop()
	menuMusic.play()
