extends PathFollow3D
class_name BaseEntity

@export var BaseSpeed: float = 3
@export var SpeedMult: float = 1
##Because multiplying by zero is the only multiplication, which can't be reversed
var Stops: int = 0
@export var EnemyWeakColor: Color
var EnemyStrongColor: Color:
	get: return EnemyStrongColor.inverted()
@export var MaxHP: float = 100
@export var HP: float = 100
@export var Damage: int = 1
@export var ResourcesGain: int = 0
var Attachments: Dictionary = {}

func on_spawn():
	pass

func pre_physics(_delta: float):
	pass

func post_physics(_delta: float, _distance: float):
	pass

func pre_damage(_baseDamage: float, _color:Color, _preSum:Ref, _mult:Ref, _sum:Ref):
	return true

func post_damage(_damage: float, _color: Color):
	pass

func pre_death():
	pass

func on_death():
	pass

func on_end_reached():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (LevelManager.this):
		LevelManager.this.WaveM.EntityCount += 1
		on_spawn()
	
func _exit_tree() -> void:
	if (LevelManager.this):
		LevelManager.this.WaveM.EntityCount -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func TakeDamage(damage: float, color: Color):
	var preSum = Ref.new(0.0)
	var mult = Ref.new(1.0)
	var postSum = Ref.new(0.0)
	var proceed = pre_damage(damage,color,preSum,mult,postSum)
	for a:EnemyAttachment in Attachments.values():
		proceed = proceed and a.pre_damage(damage,color,preSum,mult,postSum)
	if proceed:
		var damageTaken = max(((damage+preSum.value)*mult.value+postSum.value)*(2.0 if color == EnemyWeakColor else (0.25 if color == EnemyStrongColor else 1.0)),0.0)
		HP -= damageTaken
		post_damage(damageTaken,color)
		for a:EnemyAttachment in Attachments.values():
			a.post_damage(damageTaken,color)
		if (HP <= 0):
			DeathCheck()

func RestoreHP(Healing: float):
	HP = min(MaxHP,HP+Healing)

func _physics_process(delta: float) -> void:
	if (HP <= 0):
		DeathCheck()
	
	pre_physics(delta)
	for a:EnemyAttachment in Attachments.values():
		a.pre_physics(delta)
	
	var dist = BaseSpeed*SpeedMult*delta if Stops == 0 else 0.0
	progress += dist
	
	post_physics(delta,dist)
	for a:EnemyAttachment in Attachments.values():
		a.post_physics(delta,dist)
	
	if progress_ratio == 1:
		ReachedExit()
		queue_free()

func ReachedExit():
	on_end_reached()
	for a:EnemyAttachment in Attachments.values():
		a.on_end_reached()
	LevelManager.this.ResourceM.TakeDamage(Damage)
	queue_free()

func DeathCheck():
	pre_death()
	for a:EnemyAttachment in Attachments.values():
		a.pre_death()
	if (HP <= 0):
		on_death()
		for a:EnemyAttachment in Attachments.values():
			a.on_death()
		queue_free()
