class_name Lens extends BaseTower

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")

@onready var mainCollider = $MainCollider
@onready var leftCollider = $LeftCollider
@onready var rightCollider = $RightCollider

@export_range(0.1, 1.0, 0.1) var modification_coefficient: float = 0.5:
	set(new_modification_coefficient):
		if (new_modification_coefficient > 1):
			modification_coefficient = 1
		elif (new_modification_coefficient < 0.1):
			modification_coefficient = 0.1
		else: 
			modification_coefficient = new_modification_coefficient
		for laser in laser_dictionary.keys():
			laser.set_update_flag()

var intensity_penalty: float:
	set(new_intensity_penalty):
		intensity_penalty = new_intensity_penalty
		for laser in laser_dictionary.keys():
			laser.set_update_flag()

var laser_dictionary = {}

func getTowerKey() -> String:
	return "Lens"

func _ready() -> void:
	upgrades = {
		1: func(): intensity_penalty = 0.2,
		2: func(): intensity_penalty = 0.1,
		3: func(): intensity_penalty = 0
	}
	upgrades[1].call()
	max_level = upgrades.keys().max()
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

func rotateTower(clockwise: bool):
	if (!is_rotating):
		is_rotating = true
		cur_step = 1
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(self, "rotation_degrees", Vector3(self.rotation_degrees.x, roundi(self.rotation_degrees.y + (-45 if clockwise else 45)), self.rotation_degrees.z), 0.5)
		tween.tween_method(_rotate_coroutine, 0.0, 30.0, 0.5)
		await tween.finished
		
		self.rotation_degrees.y = roundi(self.rotation_degrees.y) % 360
		for l in laser_dictionary.keys():
			l.set_update_flag()
		is_rotating = false

func configureTower():
	pass

func begin_laser_collision(laser: Laser, collider = null):
	if (collider == mainCollider and (laser.get_collision_point() - laser.global_position).dot(to_global(Vector3(1,0,0)) - global_position) > 0):
		var new_laser: Laser = laser_prefab.instantiate()
		add_child(new_laser)
		laser_dictionary[laser] = new_laser
		new_laser.encountered_prisms = laser.encountered_prisms
		continue_laser_collision(laser, collider)
	else:
		laser_dictionary[laser] = null

func continue_laser_collision(laser, collider = null):
	if (collider == mainCollider):
		if (!laser_dictionary[laser]):
			begin_laser_collision(laser, collider)
			return
		var laser_direction = (laser.get_collision_point() - laser.global_position).normalized()
		laser_dictionary[laser].global_position = (laser.get_collision_point() + 0.05 * laser_direction) # Связано с костылём
		# надо будет добавить второй коллайдер и поменять логику преломления с проверкой коллайдера
		laser_dictionary[laser].look_at(to_global(laser_dictionary[laser].position + Vector3(1, 0, 0)), Vector3.UP)
		#laser_dictionary[laser].look_at(laser_dictionary[laser].global_position + laser_direction, Vector3.UP)
		laser_dictionary[laser].rotate_object_local(Vector3.RIGHT, -PI / 2)
		
		laser_dictionary[laser].set_params(laser.color, (laser.distance - laser.global_position.distance_to(laser.get_collision_point())) * modification_coefficient, laser.intensity * (1 - intensity_penalty) * (1 / modification_coefficient))
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
	for l in laser_dictionary.values():
		if l:
			l.queue_free()
	super()
	
