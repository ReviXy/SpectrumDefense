extends BaseEntity
class_name Regenerator

@onready var cooldown_timer: Timer = $CooldownTimer
@export var RegenAmount: float
@export var RegenCooldown: float

func post_damage(_damage: float, _color: Color):
	if RegenCooldown > 0:
		cooldown_timer.start(RegenCooldown)

func pre_physics(_delta: float):
	if cooldown_timer.is_stopped():
		RestoreHP(RegenAmount*_delta)
