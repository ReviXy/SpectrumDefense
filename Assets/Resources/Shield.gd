extends Resource
class_name Shield

@export var WeakColor: Color
var StrongColor: Color:
	get: return WeakColor.inverted()
@export var HP: float
@export var currentHP: float

@warning_ignore("unused_signal")
signal OnDestroy
