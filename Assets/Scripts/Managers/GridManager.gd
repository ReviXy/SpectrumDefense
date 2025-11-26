extends GridMap
class_name GridManager

@onready var tileHighlight := $TileHighlight
@onready var camera := get_viewport().get_camera_3d()

enum State {None, Placing, Configuration}
var state: State = State.None
var configuratedTower: BaseTower
var towers := {}

var placingTowerKey: String
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
	resetHighlight()
	#This waits until everything is ready in scene
	await LevelManager.this.get_parent_node_3d().ready
	LevelManager.this.UIM.resetTowerPanel()

func getTileUnderMouse(mouseEvent):
	if camera:
		var from = camera.project_ray_origin(mouseEvent.position)
		var to = from + camera.project_ray_normal(mouseEvent.position) * 1000 # Adjust ray length as needed

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 1)
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
					configuratedTower = towers[cell_coords]
					LevelManager.this.UIM.showTowerPanel(configuratedTower)
		
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
					
					var newTower = towerPrefabDictionary[placingTowerKey].instantiate()
					add_child(newTower)
					newTower.global_position = map_to_local(cell_coords) + Vector3(0, 0.7, 0) #Y offset so tower doesnt sink into the ground
					newTower.cellCoords = [cell_coords]
					towers[cell_coords] = newTower
					
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
				LevelManager.this.UIM.resetTowerPanel()
