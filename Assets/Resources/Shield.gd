extends Resource
class_name Shield

@export var WeakColor: Color
var StrongColor: Color:
	get: return WeakColor.inverted()
@export var HP: float

func  _init(hp: float, weakColor: Color) -> void:
	WeakColor = weakColor
	HP = hp
