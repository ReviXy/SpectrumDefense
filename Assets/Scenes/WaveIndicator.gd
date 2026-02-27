extends PathFollow3D
class_name WaveIndicator

@onready var Model = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Model.scale = Vector3.ONE*clampf(abs((progress_ratio-0.5)*5)-1.5,0.5,1)
	Model.transparency = clampf(1-(abs((0.5-progress_ratio)*2.5)),0.25,0.75)
	
	
func _physics_process(delta: float) -> void:
	progress += delta*50/Engine.time_scale
