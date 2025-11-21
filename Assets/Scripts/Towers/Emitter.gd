class_name Emitter extends BaseTower
const ColorRYB = preload("res://Assets/Scripts/ColorRYB.gd").ColorRYB

@onready var laser: Laser = $Laser
@onready var mainCollider = $MainCollider
var laser_dictionary = {}

@export var color: ColorRYB = ColorRYB.Red:
	set(new_color):
		color = new_color
		if laser: laser.set_params(color, distance, intensity)

@export var distance: float = 1000:
	set(new_distance):
		distance = new_distance
		if laser: laser.set_params(color, distance, intensity)

@export var intensity: float = 10:
	set(new_intensity):
		intensity = new_intensity
		if laser: laser.set_params(color, distance, intensity)

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var lasers = (mainCollider as Area3D).get_overlapping_areas()
	for l in lasers:
		(l.get_parent() as Laser).set_update_flag()
	laser.set_params(color, distance, intensity)

var is_rotating: bool = false
var cur_step : int = 1
func _rotate_coroutine(t):
	if (t > cur_step):
		for l in laser_dictionary.keys():
			l.set_update_flag()
		laser.set_update_flag()
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
		laser.set_update_flag()
		is_rotating = false

func configureTower():
	color = ((color + 1) % ColorRYB.size() ) as ColorRYB

func destroyTower():
	await get_tree().physics_frame
	for l in laser_dictionary.keys():
		l.set_update_flag()
	super()

func begin_laser_collision(laser: Laser, collider = null):
	laser_dictionary[laser] = null

func continue_laser_collision(laser, collider = null):
	pass

func end_laser_collision(laser):
	laser_dictionary.erase(laser)
