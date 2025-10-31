class_name LevelUI extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var camera = get_viewport().get_camera_3d()

@onready var towerConfigurationPanel = $TowerConfigurationPanel
@onready var rotateButton = $TowerConfigurationPanel/RotateButton
@onready var configureButton = $TowerConfigurationPanel/ConfigureButton
@onready var destroyButton = $TowerConfigurationPanel/DestroyButton

@onready var towerPlacementPanel = $TowerPlacementPanel
@onready var minimizePanelButton = $TowerPlacementPanel/MinimizePanelButton
var minimized := false

@onready var currencyLabel = $Currency/Label
@onready var healthLabel = $Health/Label

var gridmap: GridMap # soon to be manager (get promoted upon merge)

func resetTowerPanel():
	towerConfigurationPanel.global_position = Vector2(-50, -50)

func showTowerPanel(tower):
	towerConfigurationPanel.global_position = camera.unproject_position(gridmap.map_to_local(tower.cellCoords[0]))
	rotateButton.disabled = !tower.rotatable
	configureButton.disabled = !tower.configurable
	destroyButton.disabled = !tower.destroyable

func _on_rotate_button_pressed() -> void:
	gridmap.towers[gridmap.configuratedTowerIndex].rotateTower()

func _on_configure_button_pressed() -> void:
	pass 

func _on_destroy_button_pressed() -> void:
	gridmap.set_cell_item(gridmap.towers[gridmap.configuratedTowerIndex].cellCoords[0], gridmap.mesh_library.find_item_by_name("TowerTile"))
	gridmap.towers[gridmap.configuratedTowerIndex].destroyTower()
	gridmap.towers.remove_at(gridmap.configuratedTowerIndex)
	gridmap.state = gridmap.State.None
	resetTowerPanel()





func _on_minimize_panel_button_pressed() -> void:
	if minimized:
		towerPlacementPanel.global_position.x -= 250
		minimizePanelButton.text = "->"
	else: 
		towerPlacementPanel.global_position.x += 250
		minimizePanelButton.text = "<-"
	minimized = !minimized


func _on_place_test_tower_button_pressed() -> void:
	if gridmap.state == gridmap.State.None: 
		gridmap.state = gridmap.State.Placing
	elif gridmap.state == gridmap.State.Placing: 
		gridmap.state = gridmap.State.None
		gridmap.resetHighlight()
