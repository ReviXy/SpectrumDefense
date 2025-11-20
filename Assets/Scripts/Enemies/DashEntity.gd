extends BaseEntity
class_name DashEntity

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var duration_timer: Timer = $DurationTimer
@export var DashSpeedMult: float
@export var DashDuration: float
@export var DashCooldown: float

func on_spawn():
	duration_timer.timeout.connect(func(): 
		SpeedMult /= DashSpeedMult
		if (DashCooldown > 0):
			cooldown_timer.start(DashCooldown)
	)

func post_damage(_damage: float, _color: Color):
	if duration_timer.is_stopped() and cooldown_timer.is_stopped():
		SpeedMult *= DashSpeedMult
		duration_timer.start(DashDuration)
