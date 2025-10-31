extends GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelUI.gridmap = self
	
	resetHighlight()
	levelUI.resetTowerPanel()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

enum State {None, Placing, Configuration}
var state := State.None
var configuratedTowerIndex: int
var towers := []

@onready var tileHighlight := $TileHighlight
@onready var camera := get_viewport().get_camera_3d()
@onready var levelUI := get_node("../LevelUI")

var towerPrefab := preload("res://Assets/Scenes/Towers/Tower.tscn")

func resetHighlight():
	tileHighlight.global_position = Vector3(0, 100, 0)

func getTowerIndex(cellCoords):
	for i in range(len(towers)):
		if cellCoords in towers[i].cellCoords:
			return i
	return null

# Return coordinates of tile under mouse cursor. Returns null if ray missed this gridmap
func getTileUnderMouse(mouseEvent):
	if camera:
		var from = camera.project_ray_origin(mouseEvent.position)
		var to = from + camera.project_ray_normal(mouseEvent.position) * 1000 # Adjust ray length as needed

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)

		if result:
			if result.collider == self:
				var hit_position = result.position
				var cell_coords = local_to_map(to_local(hit_position))
				return cell_coords
		return null

func _unhandled_input(event):
	match state:
		State.None:
			# Click on existing tower
			# Open Configuration menu
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var cell_coords = getTileUnderMouse(event)
				if cell_coords and mesh_library.get_item_name(get_cell_item(cell_coords)) == "PlaceholderTile":
					state = State.Configuration
					configuratedTowerIndex = getTowerIndex(cell_coords)
					levelUI.showTowerPanel(towers[configuratedTowerIndex])
		
		State.Placing:
			# Tile Highligth
			if event is InputEventMouse:
				var cell_coords = getTileUnderMouse(event)
				if cell_coords:
					if mesh_library.get_item_name(get_cell_item(cell_coords)) == "TowerTile":
						tileHighlight.get_surface_override_material(0).albedo_color = Color(0, 1, 0, 0.5)
					else:
						tileHighlight.get_surface_override_material(0).albedo_color = Color(1, 0, 0, 0.5)
					tileHighlight.global_position = map_to_local(cell_coords)
				else:
					resetHighlight()
			
			# Place tower	
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var cell_coords = getTileUnderMouse(event)
				if cell_coords and mesh_library.get_item_name(get_cell_item(cell_coords)) == "TowerTile":
					set_cell_item(cell_coords, mesh_library.find_item_by_name("PlaceholderTile"))
					
					var newTower = towerPrefab.instantiate()
					add_child(newTower)
					newTower.global_position = map_to_local(cell_coords)
					newTower.cellCoords = [cell_coords]
					towers.append(newTower)
					
					resetHighlight()
					state = State.None
			
			# Cancel tower placing
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				resetHighlight()
				state = State.None

		State.Configuration:
			# Close tower configuration menu
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				state = State.None
				levelUI.resetTowerPanel()
