extends Node3D

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	if GlobalLevelManager.levelID == -1:
		var level = load("res://Assets/Scenes/Levels/TestLevel.tscn").instantiate()
		add_child(level)
	else:
		var level = load("res://Assets/Scenes/Levels/Level"+str(GlobalLevelManager.levelID)+".tscn").instantiate()
		add_child(level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
