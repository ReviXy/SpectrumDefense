extends PathFollow3D
class_name BaseEntity

@export var BaseSpeed: float = 3
@export var SpeedMult: float = 1
@export var EnemyWeakColor: Color
var EnemyStrongColor: Color:
	get: return EnemyStrongColor.inverted()
@export var HP: float = 100
@export var Damage: int = 1
@export var ResourcesGain: int = 0
var Attachments: Dictionary = {}

signal pre_damage
signal post_damage
signal pre_physics

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.this.WaveM.EntityCount += 1
	
func _exit_tree() -> void:
	LevelManager.this.WaveM.EntityCount -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func TakeDamage(damage: float, color: Color):
	var preSum = Ref.new(0.0)
	var mult = Ref.new(1.0)
	var postSum = Ref.new(0.0)
	var proceed = Ref.new(true)
	pre_damage.emit(damage,color,preSum,mult,postSum,proceed)
	if proceed.value:
		var damageTaken = max(((damage+preSum)*mult+postSum)*(2.0 if color == EnemyWeakColor else (0.25 if color == EnemyStrongColor else 1.0)),0.0)
		HP -= damageTaken
		post_damage.emit(damageTaken, color)

func _physics_process(delta: float) -> void:
	if (HP <= 0):
		queue_free()
		return
		
	pre_physics.emit()
	progress += BaseSpeed*SpeedMult*delta
	
	if progress_ratio == 1:
		ReachedExit()
		queue_free()

func ReachedExit():
	#add signal here
	LevelManager.this.ResourceM.TakeDamage(Damage)
	queue_free()
