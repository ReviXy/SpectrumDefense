@abstract
class_name BaseTower extends MeshInstance3D

var cellCoords = []

var active := true
var rotatable := true
var configurable := true
var destroyable := true

#===========================================================
# Functions for rotate, destroy, configure placeholder

func rotateTower():
	self.rotation_degrees.y = roundi(self.rotation_degrees.y - 45) % 360

func destroyTower():
	self.queue_free()

@abstract
func configureTower()

#===========================================================
# Laser interraction

@abstract
func begin_laser_collision(laser: Laser)

@abstract
func continue_laser_collision(laser)

@abstract
func end_laser_collision(laser)
