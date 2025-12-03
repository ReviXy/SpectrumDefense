@abstract
class_name BaseTower extends MeshInstance3D

@export var cellCoords = []

@export var active := true
@export var rotatable := true
@export var configurable := true
@export var destroyable := true

#===========================================================
# Functions for rotate, destroy, configure placeholder

func rotateTower():
	self.rotation_degrees.y = roundi(self.rotation_degrees.y - 45) % 360

func destroyTower():
	self.queue_free()

func configureTower():
	pass

#===========================================================
# Laser interraction

@abstract
func begin_laser_collision(laser: Laser, collider = null)

@abstract
func continue_laser_collision(laser: Laser, collider = null)

@abstract
func end_laser_collision(laser: Laser)
