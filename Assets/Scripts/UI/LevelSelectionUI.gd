extends Control

@onready var startButton = $StartButton
@onready var levelPanel = $ScrollContainer/Panel
const levelButtonPrefab = preload("res://Assets/Scenes/UI/LevelButton.tscn")

var levels = {
	1: "The Emitter",
	2: "The Mirror",
	3: "The Filter",
	4: "The Lens",
	5: "The Prism"
}

var last_pressed_button = null

func _ready() -> void:
	startButton.disabled = true
	var panelLength = 200 + 300 * levels.size() - 240
	levelPanel.custom_minimum_size.x = max(panelLength, 1280)
	create_level_buttons()

func create_level_buttons():
	var buttons: Dictionary
	
	for i in levels:
		var levelButton: LevelButton = levelButtonPrefab.instantiate()
		levelPanel.add_child(levelButton)
		buttons.set(i, levelButton)
	
	var sandboxLevelButton: LevelButton = levelButtonPrefab.instantiate()
	levelPanel.add_child(sandboxLevelButton)
	
	await get_tree().process_frame
	
	for i in buttons:
		var levelButton = buttons[i]
		levelButton.position.x = 100 + 300 * (i - 1)
		levelButton.position.y = 275
		levelButton.set_label(("Level %d"%i) + "\n\"" + levels[i] + "\"")
		levelButton.set_dotted_line_visibility(i != 1)
		if !GlobalLevelManager.is_level_accessible(i): levelButton.disable()
		levelButton.pressed.connect(_on_level_button_pressed.bind(levelButton))
		levelButton.set_meta("level", i)
	
	sandboxLevelButton.position.x = 100
	sandboxLevelButton.position.y = 100
	sandboxLevelButton.set_label(("Level ?") + "\n\"The Sandbox\"")
	sandboxLevelButton.set_dotted_line_visibility(false)
	sandboxLevelButton.pressed.connect(_on_level_button_pressed.bind(sandboxLevelButton))
	sandboxLevelButton.set_meta("level", -1)

func reset_selection():
	startButton.disabled = true
	if last_pressed_button: last_pressed_button.button_pressed = false
	last_pressed_button = null

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")

func _on_level_button_pressed(button) -> void:
	if last_pressed_button == button and !button.button_pressed:
		startButton.disabled = true
		last_pressed_button = null
		return
	startButton.disabled = false
	if last_pressed_button: last_pressed_button.button_pressed = false
	last_pressed_button = button

func _on_start_button_pressed() -> void:
	MusicManager.enter_level()
	GlobalLevelManager.levelID = last_pressed_button.get_meta("level")
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")
