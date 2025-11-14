class_name Mirror extends BaseTower

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")

var intensity_penalty: float = 0.1
var laser_dictionary = {}

func reflect(ray: Vector3, normal: Vector3) -> Vector3:
	ray = ray.normalized()
	return ray.reflect(normal).normalized()

func begin_laser_collision(laser: Laser):
	var new_laser: Laser = laser_prefab.instantiate()
	add_child(new_laser)
	new_laser.position = to_local(laser.get_collision_point())
	new_laser.look_at(new_laser.global_position + reflect(laser.global_position - laser.get_collision_point(), laser.get_collision_normal()), Vector3.UP)
	new_laser.rotate_object_local(Vector3.RIGHT, -PI / 2)
	
	new_laser.color = laser.color
	new_laser.distance = laser.distance - laser.global_position.distance_to(laser.get_collision_point())
	new_laser.intensity = laser.intensity * (1 - intensity_penalty)
	laser_dictionary[laser] = new_laser

func continue_laser_collision(laser):
	laser_dictionary[laser].position = to_local(laser.get_collision_point())
	var reflected_ray = reflect(laser.global_position - laser.get_collision_point(), laser.get_collision_normal())
	laser_dictionary[laser].look_at(laser_dictionary[laser].global_position + reflected_ray, Vector3.UP)
	laser_dictionary[laser].rotate_object_local(Vector3.RIGHT, -PI / 2)
	
	laser_dictionary[laser].color = laser.color
	laser_dictionary[laser].distance = laser.distance - laser.global_position.distance_to(laser.get_collision_point())
	laser_dictionary[laser].intensity = laser.intensity * (1 - intensity_penalty)
	
func end_laser_collision(laser):
	laser_dictionary[laser].queue_free()
	laser_dictionary.erase(laser)

func configureTower():
	pass
