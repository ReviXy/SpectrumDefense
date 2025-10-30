class_name Tower extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var cellCoords = []

var active = true
var rotatable = true
var configurable = true
var destroyable = true

# functions for rotate, destroy, configure placeholder

func rotateTower():
	self.rotation_degrees.y = int(self.rotation_degrees.y + 45) % 360
	
func destroyTower():
	self.queue_free()
	
func configureTower():
	#placeholder
	pass
