extends BaseEntity
class_name ShieldEntity

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var pause_timer: Timer = $PauseTimer
@export var ShieldCooldown: float
@export var PauseDuration: float
@export var ShieldHP: float

func on_spawn():
	spawn_shield()
	cooldown_timer.timeout.connect(func():
		Stops += 1
		pause_timer.start(PauseDuration))
		
	pause_timer.timeout.connect(func(): 
		Stops -= 1
		spawn_shield())

func spawn_shield():
	var ShieldNode: ShieldStack
	if not Attachments.has("ShieldStack"):
		ShieldNode = ShieldStack.BaseInstance.instantiate() as ShieldStack
		add_child(ShieldNode)
	else:
		ShieldNode = Attachments["ShieldStack"] as ShieldStack
	ShieldNode.add_shield(ShieldHP,EnemyWeakColor)
	ShieldNode.Shields.back().OnDestroy.connect(func(): cooldown_timer.start(ShieldCooldown))

func on_death():
	cooldown_timer.stop()
	pause_timer.stop()
