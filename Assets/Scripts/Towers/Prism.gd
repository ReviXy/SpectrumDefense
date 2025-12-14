class_name Prism extends BaseTower
const ColorRYB = ColorRYB_Operations.ColorRYB

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")

@onready var mainCollider = $MainCollider

var intensity_penalty: float:
	set(new_intensity_penalty):
		intensity_penalty = new_intensity_penalty
		process_input_lasers(input_lasers)

var input_lasers: Array[Laser] = []
var output_lasers: Array[Laser] = []

func getTowerKey() -> String:
	return "Prism"

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
	var lasers = (mainCollider as Area3D).get_overlapping_areas()
	for l in lasers:
		(l.get_parent() as Laser).set_update_flag()

var is_rotating: bool = false
var cur_step : int = 1
func _rotate_coroutine(t):
	if (t > cur_step):
		for l in input_lasers:
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
		for l in input_lasers:
			l.set_update_flag()
		is_rotating = false

func configureTower():
	pass

func process_input_lasers(lasers: Array[Laser]):
	for l in output_lasers:
		l.queue_free()
	output_lasers.clear()
	
	if (len(lasers) == 1):
		var colors = ColorRYB_Operations.Split(lasers[0].color)
		if (len(colors) == 1):
			#!!! One unsplittable laser
			var new_laser: Laser = laser_prefab.instantiate()
			add_child(new_laser)
			output_lasers = [new_laser]
			new_laser.encountered_prisms = lasers[0].encountered_prisms + [self]
			new_laser.position = to_local(position)
			#new_laser.look_at(new_laser.global_position + Vector3(1, 0, 0), Vector3.UP)
			#new_laser.rotate_object_local(Vector3.UP, -PI / 2)
			new_laser.set_params(colors[0], lasers[0].distance - lasers[0].global_position.distance_to(lasers[0].get_collision_point()), lasers[0].intensity * (1 - intensity_penalty))
		
		else:
			#!!! One splittable laser
			var new_intensity = lasers[0].intensity * (1 - intensity_penalty)
			var new_distance = lasers[0].distance - lasers[0].global_position.distance_to(lasers[0].get_collision_point())
			
			if colors.has(ColorRYB.Red):
				var new_laser: Laser = laser_prefab.instantiate()
				add_child(new_laser)
				output_lasers.append(new_laser)
				new_laser.encountered_prisms = lasers[0].encountered_prisms + [self]
				new_laser.position = to_local(position)
				new_laser.look_at(to_global(new_laser.position + Vector3(1, 1, 0)), Vector3.UP)
				new_laser.rotate_object_local(Vector3.RIGHT, -PI / 2)
				new_laser.set_params(ColorRYB.Red, new_distance / len(colors), new_intensity / len(colors))
			if colors.has(ColorRYB.Yellow):
				var new_laser: Laser = laser_prefab.instantiate()
				add_child(new_laser)
				output_lasers.append(new_laser)
				new_laser.encountered_prisms = lasers[0].encountered_prisms + [self]
				new_laser.position = to_local(position)
				new_laser.look_at(to_global(new_laser.position + Vector3(0, 1, 0)), Vector3.UP)
				new_laser.rotate_object_local(Vector3.RIGHT, -PI / 2)
				new_laser.set_params(ColorRYB.Yellow, new_distance / len(colors), new_intensity / len(colors))
			if colors.has(ColorRYB.Blue):
				var new_laser: Laser = laser_prefab.instantiate()
				add_child(new_laser)
				output_lasers.append(new_laser)
				new_laser.encountered_prisms = lasers[0].encountered_prisms + [self]
				new_laser.position = to_local(position)
				new_laser.look_at(to_global(new_laser.position + Vector3(-1, 1, 0)), Vector3.UP)
				new_laser.rotate_object_local(Vector3.RIGHT, -PI / 2)
				new_laser.set_params(ColorRYB.Blue, new_distance / len(colors), new_intensity / len(colors))
			
	elif (len(lasers) != 0):
		#!!! Multiple lasers
		var new_color = ColorRYB_Operations.Add(lasers.map(func(x): return x.color))
		var new_intensity = 0
		var new_distance = 0
		var new_encountered_prisms = []
		for i in range(len(lasers)):
			new_intensity += lasers[i].intensity
			new_distance += lasers[i].distance - lasers[i].global_position.distance_to(lasers[i].get_collision_point())
			new_encountered_prisms += lasers[i].encountered_prisms
		
		var new_laser: Laser = laser_prefab.instantiate()
		add_child(new_laser)
		output_lasers = [new_laser]
		new_laser.encountered_prisms = new_encountered_prisms + [self]
		new_laser.position = to_local(position)
		#new_laser.look_at(new_laser.global_position + Vector3(1, 0, 0), Vector3.UP)
		#new_laser.rotate_object_local(Vector3.RIGHT, -PI / 2)
		new_laser.set_params(new_color, new_distance, new_intensity * (1 - intensity_penalty))

func begin_laser_collision(laser: Laser, collider = null):
	if (!laser.encountered_prisms.has(self)):
		input_lasers.append(laser)
		process_input_lasers(input_lasers)

var flag = false
func continue_laser_collision(laser, collider = null):
	if (!laser.encountered_prisms.has(self)):
		flag = true

func _process(delta: float) -> void:
	if (flag):
		flag = false
		if (is_rotating):
			for l in output_lasers:
				l.set_update_flag()
		else:
			process_input_lasers(input_lasers)

func end_laser_collision(laser):
	if (!laser.encountered_prisms.has(self)):
		input_lasers.erase(laser)
		process_input_lasers(input_lasers)

func destroyTower():
	await get_tree().physics_frame
	for l in input_lasers:
		l.set_update_flag()
	super()
