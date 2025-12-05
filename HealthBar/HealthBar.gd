extends Node3D

@export_range(0,100) var hp : float = 100

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	ChangeSize(23,hp,100)


func ChangeSize(damage : float, currhp: float, maxhp: float = 100):
	visible = true
	$Sprite3D.scale.x = currhp/maxhp
	$Sprite3D/Label3D.text = str(-damage)
