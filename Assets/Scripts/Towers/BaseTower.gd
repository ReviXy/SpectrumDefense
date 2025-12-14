@abstract
class_name BaseTower extends MeshInstance3D

var cellCoords = []

@export var active := true
@export var rotatable := true
@export var configurable := true
@export var upgradable := true
@export var destroyable := true

@export var level = 1:
	set(new_level):
		if upgrades.has(new_level):
			upgrades[new_level].call()
			if (new_level == max_level): upgradable = false
			level = new_level
var max_level
var upgrades = {}

#===========================================================
# Functions for rotate, destroy, configure placeholder

func rotateTower(clockwise: bool):
	self.rotation_degrees.y = roundi(self.rotation_degrees.y + (-45 if clockwise else 45)) % 360

func destroyTower():
	self.queue_free()

func configureTower():
	pass

@abstract
func getTowerKey() -> String

#===========================================================
# Laser interraction

@abstract
func begin_laser_collision(laser: Laser, collider = null)

@abstract
func continue_laser_collision(laser: Laser, collider = null)

@abstract
func end_laser_collision(laser: Laser)
