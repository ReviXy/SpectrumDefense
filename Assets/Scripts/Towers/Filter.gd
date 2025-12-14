class_name Filter extends BaseTower
const ColorRYB = preload("res://Assets/Scripts/ColorRYB.gd").ColorRYB

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")
@onready var indicator_material = ($Indicator).get_surface_override_material(0)
@onready var mainCollider = $MainCollider

@export var color: ColorRYB = ColorRYB.Red:
	set(new_color):
		color = new_color
		if indicator_material: indicator_material.albedo_color = ColorRYB_Operations.ToColor(new_color)
		for laser in laser_dictionary.keys():
			laser.set_update_flag()

@export var availableColors: Array[ColorRYB] = [0 as ColorRYB, 1 as ColorRYB, 2 as ColorRYB, 3 as ColorRYB, 4 as ColorRYB, 5 as ColorRYB, 6 as ColorRYB]

var intensity_penalty: float:
	set(new_intensity_penalty):
		intensity_penalty = new_intensity_penalty
		for laser in laser_dictionary.keys():
			laser.set_update_flag()

var laser_dictionary = {}

func getTowerKey() -> String:
	return "Filter"

func _ready() -> void:
	upgrades = {
		1: func(): intensity_penalty = 0.4,
		2: func(): intensity_penalty = 0.3,
		3: func(): intensity_penalty = 0.2
	}
	upgrades[1].call()
	max_level = upgrades.keys().max()
	rotatable = false
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	color = color # Yes. Because this is godot
	var lasers = (mainCollider as Area3D).get_overlapping_areas()
	for l in lasers:
		(l.get_parent() as Laser).set_update_flag()

func configureTower():
	color = ((color + 1) % ColorRYB.size() ) as ColorRYB
	for l in laser_dictionary.keys():
		l.set_update_flag()

func begin_laser_collision(laser: Laser, collider = null):
	var filtered_color = ColorRYB_Operations.Filter(laser.color, color)
	if (filtered_color != null):
		var new_laser: Laser = laser_prefab.instantiate()
		add_child(new_laser)
		laser_dictionary[laser] = new_laser
		new_laser.encountered_prisms = laser.encountered_prisms
		continue_laser_collision(laser, collider)
	else:
		laser_dictionary[laser] = null

func continue_laser_collision(laser, collider = null):
	var filtered_color = ColorRYB_Operations.Filter(laser.color, color)
	if (filtered_color != null):
		if (!laser_dictionary[laser]):
			begin_laser_collision(laser, collider)
			return
		var laser_direction = (laser.get_collision_point() - laser.global_position).normalized()
		laser_dictionary[laser].position = to_local(laser.get_collision_point() + 0.05 * laser_direction)
		laser_dictionary[laser].look_at(laser_dictionary[laser].global_position + laser_direction, Vector3.UP)
		laser_dictionary[laser].rotate_object_local(Vector3.RIGHT, -PI / 2)
		laser_dictionary[laser].set_params(filtered_color, laser.distance - laser.global_position.distance_to(laser.get_collision_point()), laser.intensity * (1 - intensity_penalty))
	else:
		if (laser_dictionary[laser]):
			laser_dictionary[laser].queue_free()
			laser_dictionary[laser] = null

func end_laser_collision(laser):
	if (laser_dictionary[laser]):
		laser_dictionary[laser].queue_free()
	laser_dictionary.erase(laser)

func destroyTower():
	await get_tree().physics_frame
	for l in laser_dictionary.keys():
		l.set_update_flag()
	super()
