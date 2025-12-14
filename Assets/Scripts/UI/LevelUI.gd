class_name LevelUI extends CanvasLayer
const ColorRYB = preload("res://Assets/Scripts/ColorRYB.gd").ColorRYB

func _ready() -> void:
	await $"..".ready
	get_node("TopPanel").mouse_entered.connect(func(): LevelManager.this.GridM.resetHighlight())
	get_node("PauseButton").mouse_entered.connect(func(): LevelManager.this.GridM.resetHighlight())
	LevelManager.this.ResourceM.resources_gained.connect(updateUpgradeButton)
	LevelManager.this.ResourceM.resources_lost.connect(updateUpgradeButton)
	LevelManager.this.ResourceM.resources_gained.connect(updatePlacementButtons)
	LevelManager.this.ResourceM.resources_lost.connect(updatePlacementButtons)
	towerConfigurationPanel.position = Vector2(1280, 0)
	towerPlacementPanel.position = Vector2(1280, 0)

func updateUpgradeButton(a):
	var tower = LevelManager.this.GridM.configuratedTower
	if (tower): 
		upgradeButton.disabled = !(tower.upgradable and LevelManager.this.ResourceM.Resources >= getTowerUpgradeCost(tower))

func updatePlacementButtons(a):
	if (LevelManager.this.GridM.state == LevelManager.this.GridM.State.Placing):
		for tower in towerPlacementButtons.keys():
			towerPlacementButtons[tower].disabled = LevelManager.this.ResourceM.Resources >= getTowerPlacementCost(tower)

func _process(_delta: float) -> void:
	if not LevelManager.this.WaveM.WaveDelayTimer.is_stopped():
		startWaveLabel.text = str(LevelManager.this.WaveM.WaveDelayTimer.time_left+1).pad_decimals(0) 

@onready var camera: Camera3D = get_viewport().get_camera_3d()

@onready var towerRotationPanel: Panel = $TowerRotationPanel
@onready var rotateClockwiseButton: Button = $TowerRotationPanel/RotateClockwiseButton
@onready var rotateCounterClockwiseButton: Button = $TowerRotationPanel/RotateCounterClockwiseButton


@onready var towerConfigurationPanel: Panel = $TowerConfigurationPanel
@onready var upgradeButton: Button = $TowerConfigurationPanel/UpgradeButton
@onready var upgradeCostLabel: Label = $TowerConfigurationPanel/UpgradeCostLabel
@onready var destroyButton: Button = $TowerConfigurationPanel/DestroyButton
@onready var destroyCompensationLabel: Label = $TowerConfigurationPanel/DestroyCompensationLabel
@onready var towerConfigurationMenus = {
	"Emitter": $TowerConfigurationPanel/Emitter,
	"Mirror": $TowerConfigurationPanel/Mirror,
	"Filter": $TowerConfigurationPanel/Filter,
	"Lens": $TowerConfigurationPanel/Lens,
	"Prism": $TowerConfigurationPanel/Prism
}
@onready var emitterIntensityLabel: Label = $TowerConfigurationPanel/Emitter/IntensityValueLabel
@onready var emitterDistanceLabel: Label = $TowerConfigurationPanel/Emitter/DistanceValueLabel
@onready var emitterColorDropDown: OptionButton = $TowerConfigurationPanel/Emitter/ColorDropDown

@onready var mirrorLevelLabel: Label = $TowerConfigurationPanel/Mirror/LevelLabel
@onready var mirrorIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Mirror/IntensityPenaltyValueLabel

@onready var filterLevelLabel: Label = $TowerConfigurationPanel/Filter/LevelLabel
@onready var filterIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Filter/IntensityPenaltyValueLabel
@onready var filterColorDropDown: OptionButton = $TowerConfigurationPanel/Filter/ColorDropDown

@onready var lensLevelLabel: Label = $TowerConfigurationPanel/Lens/LevelLabel
@onready var lensIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Lens/IntensityPenaltyValueLabel
@onready var lensCoefficientSlider: Slider = $TowerConfigurationPanel/Lens/CoefficientSlider

@onready var prismLevelLabel: Label = $TowerConfigurationPanel/Prism/LevelLabel
@onready var prismIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Prism/IntensityPenaltyValueLabel


@onready var towerPlacementPanel = $TowerPlacementPanel
@onready var towerPlacementButtons = {
	"Emitter": $TowerPlacementPanel/VBoxContainer/PlaceEmitterButton,
	"Mirror": $TowerPlacementPanel/VBoxContainer/PlaceMirrorButton,
	"Filter": $TowerPlacementPanel/VBoxContainer/PlaceFilterButton,
	"Lens": $TowerPlacementPanel/VBoxContainer/PlaceLensButton,
	"Prism": $TowerPlacementPanel/VBoxContainer/PlacePrismButton
}
@onready var towerPlacementCostLabels = {
	"Emitter": $TowerPlacementPanel/VBoxContainer/PlaceEmitterButton/Cost,
	"Mirror": $TowerPlacementPanel/VBoxContainer/PlaceMirrorButton/Cost,
	"Filter": $TowerPlacementPanel/VBoxContainer/PlaceFilterButton/Cost,
	"Lens": $TowerPlacementPanel/VBoxContainer/PlaceLensButton/Cost,
	"Prism": $TowerPlacementPanel/VBoxContainer/PlacePrismButton/Cost
}

@onready var currencyLabel: Label = $TopPanel/Currency/Label
@onready var healthLabel: Label = $TopPanel/Health/Label

@onready var pauseMenu = $PauseMenu
@onready var missionWin = $MissionWin
@onready var missionLose = $MissionLose

@onready var startWaveButton = $TopPanel/StartWave
@onready var startWaveLabel = $TopPanel/StartWave/Label
@onready var startWaveHoldTimer = $TopPanel/StartWave/StartWaveHoldTimer
@onready var waveLabel = $TopPanel/StartWave/HBoxContainer/WaveLabel
@onready var maxWaveLabel = $TopPanel/StartWave/HBoxContainer/MaxWaveLabel

#__________ Tower Configuration __________

func getTowerPlacementCost(towerKey):
	var gridm = LevelManager.this.GridM
	var towersPlaced = max(0, gridm.towerCounts[towerKey] - gridm.initialTowerCounts[towerKey])
	return gridm.initialTowerPlacementCosts[towerKey] + towersPlaced * gridm.towerPlacementCostIncrement[towerKey]

func getTowerUpgradeCost(tower):
	var gridm = LevelManager.this.GridM
	var towerKey = tower.getTowerKey()
	return gridm.initialTowerUpgradeCosts[towerKey] + (tower.level - 1) * gridm.TowerUpgradeCostsIncrement[towerKey]

func getTowerDestroyCompensation(tower):
	var gridm = LevelManager.this.GridM
	var towerKey = tower.getTowerKey()
	var towerValue = gridm.initialTowerPlacementCosts[towerKey]
	for i in range(tower.level - 1): towerValue += gridm.initialTowerUpgradeCosts[towerKey] + i * gridm.TowerUpgradeCostsIncrement[towerKey]
	return floor(towerValue * gridm.towerDestroyCashbackCoefficient) 

func updateTowerConfigurationInfo():
	var tower = LevelManager.this.GridM.configuratedTower
	rotateClockwiseButton.disabled = !tower.rotatable
	rotateCounterClockwiseButton.disabled = !tower.rotatable
	
	upgradeButton.disabled = !(tower.upgradable and LevelManager.this.ResourceM.Resources >= getTowerUpgradeCost(tower))
	if tower.upgradable: 
		upgradeCostLabel.text = "-%.0f$" % getTowerUpgradeCost(tower)
	else: 
		upgradeCostLabel.text = "MAX"
	
	destroyButton.disabled = !tower.destroyable
	if tower.destroyable: destroyCompensationLabel.text = "+%.0f$" % getTowerDestroyCompensation(tower); destroyCompensationLabel.visible = true
	else: destroyCompensationLabel.visible = false

	towerConfigurationMenus[tower.getTowerKey()].visible = true
	match (tower.getTowerKey()):
		"Emitter":
			tower = (tower as Emitter)
			emitterIntensityLabel.text = "%.0f" % tower.intensity
			emitterDistanceLabel.text = "%.0f" % tower.distance
			emitterColorDropDown.clear()
			for i in range(7):
				if tower.availableColors.has((i as ColorRYB)):
					emitterColorDropDown.add_item(ColorRYB.keys()[i as ColorRYB], i)
			emitterColorDropDown.selected = emitterColorDropDown.get_item_index(tower.color)
			emitterColorDropDown.disabled = !tower.configurable
		"Mirror":
			tower = (tower as Mirror)
			mirrorLevelLabel.text = "Ур.%.0f" % tower.level
			mirrorIntensityPenaltyLabel.text = "%.0f" % (tower.intensity_penalty * 100) + "%"
		"Filter":
			tower = (tower as Filter)
			filterLevelLabel.text = "Ур.%.0f" % tower.level
			filterIntensityPenaltyLabel.text = "%.0f" % (tower.intensity_penalty * 100) + "%"
			filterColorDropDown.clear()
			for i in range(7):
				if tower.availableColors.has((i as ColorRYB)):
					filterColorDropDown.add_item(ColorRYB.keys()[i as ColorRYB], i)
			filterColorDropDown.selected = filterColorDropDown.get_item_index(tower.color)
			filterColorDropDown.disabled = !tower.configurable
		"Lens":
			tower = (tower as Lens)
			lensLevelLabel.text = "Ур.%.0f" % tower.level
			lensIntensityPenaltyLabel.text = "%.0f" % (tower.intensity_penalty * 100) + "%"
			lensCoefficientSlider.value = tower.modification_coefficient
			lensCoefficientSlider.editable = tower.configurable
		"Prism":
			tower = (tower as Prism)
			prismLevelLabel.text = "Ур.%.0f" % tower.level
			prismIntensityPenaltyLabel.text = "%.0f" % (tower.intensity_penalty * 100) + "%"

func resetTowerPanel():
	towerRotationPanel.global_position = Vector2(0, 720)
	
	var tween = get_tree().create_tween()
	tween.tween_property(towerConfigurationPanel, "position", Vector2(1280, towerConfigurationPanel.position.y), 0.1)
	await tween.finished
	
	for menu in towerConfigurationMenus.values(): menu.visible = false

func showTowerConfigurationPanel():
	var tower = LevelManager.this.GridM.configuratedTower
	towerRotationPanel.global_position = camera.unproject_position(LevelManager.this.GridM.map_to_local(tower.cellCoords[0])) + Vector2(-towerRotationPanel.size.x / 2, towerRotationPanel.size.y / 2)
	
	updateTowerConfigurationInfo()
	
	var tween = get_tree().create_tween()
	tween.tween_property(towerConfigurationPanel, "position", Vector2(1030, towerConfigurationPanel.position.y), 0.1)
	await tween.finished

func _on_upgrade_button_pressed() -> void:
	var tower = LevelManager.this.GridM.configuratedTower
	LevelManager.this.ResourceM.LoseResources(getTowerUpgradeCost(tower))
	tower.level += 1
	updateTowerConfigurationInfo()

func _on_destroy_button_pressed() -> void:
	LevelManager.this.ResourceM.GainResources(getTowerDestroyCompensation(LevelManager.this.GridM.configuratedTower))
	LevelManager.this.GridM.destroyActiveTower()
	resetTowerPanel()

func _on_rotate_clockwise_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.rotateTower(true)

func _on_rotate_counter_clockwise_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.rotateTower(false)

func _on_emitter_color_dropdown_item_selected(index: int) -> void:
	(LevelManager.this.GridM.configuratedTower as Emitter).color = emitterColorDropDown.get_item_id(index) as ColorRYB

func _on_filter_color_dropdown_item_selected(index: int) -> void:
	(LevelManager.this.GridM.configuratedTower as Filter).color = filterColorDropDown.get_item_id(index) as ColorRYB

func _on_lens_coefficient_slider_value_changed(value: float) -> void:
	(LevelManager.this.GridM.configuratedTower as Lens).modification_coefficient = value

#__________ Tower Placement __________

func updateTowerPlacementInfo():
	for tower in towerPlacementButtons.keys():
		towerPlacementButtons[tower].disabled = !(LevelManager.this.ResourceM.Resources >= getTowerPlacementCost(tower))
	
	for tower in towerPlacementCostLabels.keys():
		towerPlacementCostLabels[tower].text = "%.0f$" % getTowerPlacementCost(tower)

func showTowerPlacementPanel():
	updateTowerPlacementInfo()
	
	var tween = get_tree().create_tween()
	tween.tween_property(towerPlacementPanel, "position", Vector2(1030, towerPlacementPanel.position.y), 0.1)
	await tween.finished

func hideTowerPlacementPanel():
	updateTowerPlacementInfo()
	
	var tween = get_tree().create_tween()
	tween.tween_property(towerPlacementPanel, "position", Vector2(1280, towerPlacementPanel.position.y), 0.1)
	await tween.finished

func _on_place_tower_button_pressed(button: Button) -> void:
	LevelManager.this.ResourceM.LoseResources(getTowerPlacementCost(button.get_meta("TowerType")))
	var gridmap = LevelManager.this.GridM
	
	gridmap.placeTower(button.get_meta("TowerType"), gridmap.active_cell_coords)
	gridmap.resetHighlight()
	gridmap.state = gridmap.State.None
	hideTowerPlacementPanel()

#__________ Pause Menu __________

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	pauseMenu.visible = false

func _on_options_button_pressed() -> void:
	SettingsManager.showSettingsMenu()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
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
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

func _on_level_selection_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/LevelSelectionMenu.tscn")

func _on_next_level_button_pressed() -> void:
	GlobalLevelManager.levelID += 1
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

#__________ Labels __________

func _update_hp() -> void:
	healthLabel.text = str(LevelManager.this.ResourceM.HP)

func _update_currency() -> void:
	currencyLabel.text = str(LevelManager.this.ResourceM.Resources) + "$"

#__________ Waves __________

func _on_start_wave_button_down() -> void:
	startWaveHoldTimer.timeout.connect(func():
		startWaveLabel.text = "auto"
		LevelManager.this.WaveM.autoLaunch = true
		LevelManager.this.WaveM.LaunchNextWave())
	startWaveHoldTimer.start(1)

func _on_start_wave_button_up() -> void:
	if not startWaveHoldTimer.is_stopped():
		startWaveHoldTimer.stop()
		startWaveLabel.text = ""
		LevelManager.this.WaveM.autoLaunch = false
		LevelManager.this.WaveM.LaunchNextWave()
		LevelManager.this.WaveM.WaveDelayTimer.stop()

func _on_fast_forward_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 2.0
	else:
		Engine.time_scale = 1.0
