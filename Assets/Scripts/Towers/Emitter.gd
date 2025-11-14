class_name Emitter extends BaseTower

@onready var laser: Laser = $Laser

@export var color: Color = Color.RED:
	set(new_color):
		color = new_color
		if laser: laser.color = new_color

@export var distance: float = 1000:
	set(new_distance):
		distance = new_distance
		if laser: laser.distance = new_distance

@export var intensity: float = 10:
	set(new_intensity):
		intensity = new_intensity
		if laser: laser.intensity = new_intensity

func _ready() -> void:
	laser.color = color
	laser.distance = distance
	laser.intensity = intensity

func configureTower():
	pass

func begin_laser_collision(laser: Laser):
	pass

func continue_laser_collision(laser):
	pass

func end_laser_collision(laser):
	pass
