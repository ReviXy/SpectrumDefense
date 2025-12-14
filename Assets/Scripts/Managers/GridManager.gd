@tool
extends GridMap
class_name GridManager

@export var initialTowerPlacementCosts = {
	"Emitter": 50,
	"Mirror": 5,
	"Filter": 10,
	"Lens": 30,
	"Prism": 50
}

@export var towerPlacementCostIncrement = {
	"Emitter": 30,
	"Mirror": 2,
	"Filter": 5,
	"Lens": 10,
	"Prism": 20
}

@export var initialTowerUpgradeCosts = {
	"Emitter": 0,
	"Mirror": 10,
	"Filter": 30,
	"Lens": 30,
	"Prism": 30
}

@export var TowerUpgradeCostsIncrement = {
	"Emitter": 0,
	"Mirror": 5,
	"Filter": 10,
	"Lens": 20,
	"Prism": 20
}

@export var towerDestroyCashbackCoefficient = 0.75

@onready var tileHighlight := $TileHighlight
@onready var camera := get_viewport().get_camera_3d()

enum State {None, Placing, Configuration}
var state: State = State.None
var configuratedTower: BaseTower
var towers := {}

var initialTowerCounts
var towerCounts = {
	"Emitter": 0,
	"Mirror": 0,
	"Filter": 0,
	"Lens": 0,
	"Prism": 0
}

var towerPrefabDictionary = {
	"Emitter": preload("res://Assets/Scenes/Towers/Emitter.tscn"),
	"Mirror": preload("res://Assets/Scenes/Towers/Mirror.tscn"),
	"Filter": preload("res://Assets/Scenes/Towers/Filter.tscn"),
	"Lens": preload("res://Assets/Scenes/Towers/Lens.tscn"),
	"Prism": preload("res://Assets/Scenes/Towers/Prism.tscn")
}

func resetHighlight():
	tileHighlight.global_position = Vector3(0, 100, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): 
		for tower in get_children():
			if tower is BaseTower:
				towers[local_to_map(to_local(tower.global_position))] = tower
		return

	state = State.None
	resetHighlight()
	#This waits until everything is ready in scene
	await LevelManager.this.get_parent_node_3d().ready
	LevelManager.this.UIM.resetTowerPanel()
	
	for tower in get_children():
		if tower is BaseTower:
			towers[local_to_map(to_local(tower.global_position))] = tower
			tower.cellCoords = [local_to_map(to_local(tower.global_position))]
			towerCounts[tower.getTowerKey()] += 1
	initialTowerCounts = towerCounts.duplicate()

var update_cooldown = 0.0
func _process(delta: float) -> void: # Editor mode only
	if !Engine.is_editor_hint(): return 
	if update_cooldown > 0: update_cooldown -= delta; return
	update_cooldown = 0.2
	
	for cell in towers.keys():
		if mesh_library.get_item_name(get_cell_item(cell)) != (towers[cell] as BaseTower).get_script().get_global_name():
			var tower = towers[cell] as BaseTower
			towers.erase(local_to_map(to_local(tower.global_position)))
			tower.queue_free()
	
	for cell in get_used_cells():
		var tileName = mesh_library.get_item_name(get_cell_item(cell))
		if towerPrefabDictionary.keys().has(tileName) and !towers.keys().has(cell):
			var newTower = towerPrefabDictionary[tileName].instantiate()
			add_child(newTower)
			newTower.owner = get_tree().edited_scene_root
			newTower.name = tileName
			newTower.global_position = map_to_local(cell) + Vector3(0, 0.7, 0) #Y offset so tower doesnt sink into the ground
			towers[cell] = newTower

func getTileUnderMouse(mousePosition):
	if camera:
		var from = camera.project_ray_origin(mousePosition)
		var to = from + camera.project_ray_normal(mousePosition) * 1000 # Adjust ray length as needed

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 1)
		var result = space_state.intersect_ray(query)

		if result:
			if result.collider == self:
				var hit_position = result.position
				var cell_coords = local_to_map(to_local(hit_position))
				return cell_coords
		return null

func placeTower(placingTowerKey, cell_coords):
	towerCounts[placingTowerKey] += 1
	set_cell_item(cell_coords, mesh_library.find_item_by_name(placingTowerKey))
	var newTower = towerPrefabDictionary[placingTowerKey].instantiate()
	add_child(newTower)
	newTower.global_position = map_to_local(cell_coords) + Vector3(0, 0.7, 0) #Y offset so tower doesnt sink into the ground
	newTower.cellCoords = [cell_coords]
	towers[cell_coords] = newTower

func destroyActiveTower():
	towerCounts[configuratedTower.getTowerKey()] -= 1
	set_cell_item(configuratedTower.cellCoords[0], mesh_library.find_item_by_name("TowerTile"))
	for pos in configuratedTower.cellCoords:
		towers.erase(pos)
	configuratedTower.destroyTower()
	state = State.None

var active_cell_coords = null
func _unhandled_input(event):
	if Engine.is_editor_hint(): return 
	match state:
		State.None:
			# Tile Highlight
			if event is InputEventMouse or event is InputEventKey:
				var cell_coords = getTileUnderMouse(get_viewport().get_mouse_position())
				if cell_coords != null:
					tileHighlight.get_surface_override_material(0).albedo_color = Color(0.3, 0.3, 0.3, 0.5)
					tileHighlight.global_position = map_to_local(cell_coords)
				else:
					resetHighlight()
			
			# Left click on tile
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				active_cell_coords = getTileUnderMouse(get_viewport().get_mouse_position())
				# Tower placing
				if active_cell_coords and mesh_library.get_item_name(get_cell_item(active_cell_coords)) == "TowerTile":
					state = State.Placing
					LevelManager.this.UIM.showTowerPlacementPanel()
					tileHighlight.get_surface_override_material(0).albedo_color = Color(0, 1, 0, 0.5)
				# Tower configuration
				if active_cell_coords and towerPrefabDictionary.has(mesh_library.get_item_name(get_cell_item(active_cell_coords))):
					state = State.Configuration
					configuratedTower = towers[active_cell_coords]
					LevelManager.this.UIM.showTowerConfigurationPanel()
					tileHighlight.get_surface_override_material(0).albedo_color = Color(0, 1, 0, 0.5)
		
		State.Configuration:
			# Close tower configuration menu
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				state = State.None
				configuratedTower = null
				LevelManager.this.UIM.resetTowerPanel()
		State.Placing:
			# Close tower configuration menu
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				state = State.None
				LevelManager.this.UIM.hideTowerPlacementPanel()
