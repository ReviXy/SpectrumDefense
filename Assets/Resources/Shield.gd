extends Resource
class_name Shield
const ColorRYB = ColorRYB_Operations.ColorRYB

@export var WeakColor: ColorRYB
var StrongColor: ColorRYB:
	get: return ColorRYB_Operations.Invert(WeakColor)
@export var HP: float
@export var currentHP: float

@warning_ignore("unused_signal")
signal OnDestroy
