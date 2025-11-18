class_name Mirror extends BaseTower

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")

@onready var mainCollider = $MainCollider
@onready var leftCollider = $LeftCollider
@onready var rightCollider = $RightCollider

var intensity_penalty: float = 0.1
var laser_dictionary = {}

func _ready() -> void:
	configurable = false
	await get_tree().physics_frame
	await get_tree().physics_frame
	var colliders = [mainCollider, leftCollider, rightCollider]
	for collider in colliders:
		var lasers = (collider as Area3D).get_overlapping_areas()
		for l in lasers:
			(l.get_parent() as Laser).set_update_flag()

var is_rotating: bool = false
var cur_step : int = 1
func _rotate_coroutine(t):
	if (t > cur_step):
		for l in laser_dictionary.keys():
			l.set_update_flag()
		cur_step += 1

func rotateTower():
	if (!is_rotating):
		is_rotating = true
		cur_step = 1
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(self, "rotation_degrees", Vector3(self.rotation_degrees.x, roundi(self.rotation_degrees.y - 45), self.rotation_degrees.z), 0.5)
		tween.tween_method(_rotate_coroutine, 0.0, 30.0, 0.5)
		
		await tween.finished
		self.rotation_degrees.y = roundi(self.rotation_degrees.y) % 360
		for l in laser_dictionary.keys():
			l.set_update_flag()
		is_rotating = false

func configureTower():
	pass

func reflect(ray: Vector3, normal: Vector3) -> Vector3:
	ray = ray.normalized()
	return ray.reflect(normal).normalized()

func begin_laser_collision(laser: Laser, collider = null):
	if (collider == mainCollider):
		var new_laser: Laser = laser_prefab.instantiate()
		add_child(new_laser)
		laser_dictionary[laser] = new_laser
		continue_laser_collision(laser, collider)
	else:
		laser_dictionary[laser] = null

func continue_laser_collision(laser, collider = null):
	if (collider == mainCollider):
		if (!laser_dictionary[laser]):
			begin_laser_collision(laser, collider)
			return
		var reflected_ray = reflect(laser.global_position - laser.get_collision_point(), laser.get_collision_normal())
		laser_dictionary[laser].position = to_local(laser.get_collision_point())
		laser_dictionary[laser].look_at(laser_dictionary[laser].global_position + reflected_ray, Vector3.UP)
		laser_dictionary[laser].rotate_object_local(Vector3.RIGHT, -PI / 2)
		laser_dictionary[laser].set_params(laser.color, laser.distance - laser.global_position.distance_to(laser.get_collision_point()), laser.intensity * (1 - intensity_penalty))
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
	
