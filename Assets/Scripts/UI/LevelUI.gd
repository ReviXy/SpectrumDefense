class_name LevelUI extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await $"..".ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

@onready var camera: Camera3D = get_viewport().get_camera_3d()

@onready var towerConfigurationPanel = $TowerConfigurationPanel
@onready var rotateButton = $TowerConfigurationPanel/RotateButton
@onready var configureButton = $TowerConfigurationPanel/ConfigureButton
@onready var destroyButton = $TowerConfigurationPanel/DestroyButton

@onready var towerPlacementPanel = $TowerPlacementPanel
#@onready var minimizePanelButton = $TowerPlacementPanel/MinimizePanelButton
var minimized := false

@onready var currencyLabel = $TowerPlacementPanel/VBoxContainer/HBoxContainer/Currency/Label
@onready var healthLabel = $TowerPlacementPanel/VBoxContainer/HBoxContainer/Health/Label

@onready var pauseMenu = $PauseMenu
@onready var missionWin = $MissionWin
@onready var missionLose = $MissionLose

#__________ Tower Configuration __________

func resetTowerPanel():
	towerConfigurationPanel.global_position = Vector2(-50, -50)

func showTowerPanel(tower):
	towerConfigurationPanel.global_position = camera.unproject_position(LevelManager.this.GridM.map_to_local(tower.cellCoords[0]))
	rotateButton.disabled = !tower.rotatable
	configureButton.disabled = !tower.configurable
	destroyButton.disabled = !tower.destroyable

func _on_rotate_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.rotateTower()

func _on_configure_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.configureTower()

func _on_destroy_button_pressed() -> void:
	LevelManager.this.GridM.set_cell_item(LevelManager.this.GridM.configuratedTower.cellCoords[0], LevelManager.this.GridM.mesh_library.find_item_by_name("TowerTile"))
	for pos in LevelManager.this.GridM.configuratedTower.cellCoords:
		LevelManager.this.GridM.towers.erase(pos)
	LevelManager.this.GridM.configuratedTower.destroyTower()
	
	LevelManager.this.GridM.state = LevelManager.this.GridM.State.None
	resetTowerPanel()

#__________ Tower Placement __________

func _on_place_tower_button_pressed(button: Button) -> void:
	var gridmap = LevelManager.this.GridM
	
	if gridmap.state == gridmap.State.None:
		gridmap.state = gridmap.State.Placing
		gridmap.placingTowerKey = button.get_meta("TowerType")
	elif gridmap.state == gridmap.State.Placing:
		gridmap.state = gridmap.State.None
		gridmap.resetHighlight()

#__________ Pause Menu __________

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	pauseMenu.visible = false

func _on_options_button_pressed() -> void:
	SettingsManager.showSettingsMenu()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pauseMenu.visible = true

#__________ Mission end screens __________

func show_mission_win():
	# TODO
	# Check if next level exists. If not? Block or delete NextLevelButton
	(get_node("MissionWin/Panel/HBoxContainer/NextLevelButton") as Button).disabled = true
	get_tree().paused = true
	missionWin.visible = true
	
func show_mission_lose():
	get_tree().paused = true
	missionLose.visible = true

#__________ Scene Manipulation __________

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

func _on_level_selection_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/LevelSelectionMenu.tscn")

func _on_next_level_button_pressed() -> void:
	GlobalLevelManager.levelID += 1
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

#__________ Labels __________

func _update_hp() -> void:
	healthLabel.text = str(LevelManager.this.ResourceM.HP)

func _update_currency() -> void:
	currencyLabel.text = str(LevelManager.this.ResourceM.Resources)
