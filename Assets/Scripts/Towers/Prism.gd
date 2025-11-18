class_name Prism extends BaseTower
const ColorRYB = ColorRYB_Operations.ColorRYB

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")

var intensity_penalty: float = 0.1
var laser_dictionary = {}

func configureTower():
	pass

func a(lasers: Array[Laser]):
	if (len(lasers) == 1):
		var colors = ColorRYB_Operations.Split(lasers[0].color)
		if (len(colors) == 1):
			pass # Split
		else:
			pass # Pass
	elif (len(lasers) != 0):
		var new_color = ColorRYB_Operations.Add(lasers.map(func(x): return x.color))
		var new_intensity = 0
		var new_distance = 0
		for i in range(len(lasers)):
			new_intensity += lasers[i].intensity
			new_distance += lasers[i].distance - lasers[i].global_position.distance_to(lasers[i].get_collision_point())

func begin_laser_collision(laser: Laser, collider = null):
	pass

func continue_laser_collision(laser, collider = null):
	pass

func end_laser_collision(laser):
	pass
