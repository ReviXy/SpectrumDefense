extends BaseEntity
class_name ShieldEntity

@onready var cooldown_timer: Timer = $CooldownTimer
@export var ShieldCooldown: float
@export var ShieldHP: float

func on_spawn():
	spawn_shield()
	cooldown_timer.timeout.connect(func():
		Stops += 1
		get_tree().create_timer(0.5,false).timeout.connect(func(): 
			Stops -= 1
			spawn_shield()
			)
		)

func spawn_shield():
	var ShieldNode: ShieldStack
	if not Attachments.has("ShieldStack"):
		ShieldNode = ShieldStack.BaseInstance.instantiate() as ShieldStack
		add_child(ShieldNode)
	else:
		ShieldNode = Attachments["ShieldStack"] as ShieldStack
	ShieldNode.add_shield(ShieldHP,EnemyWeakColor)
	ShieldNode.Shields.back().OnDestroy.connect(func(): cooldown_timer.start(ShieldCooldown))
