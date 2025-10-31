extends PathFollow3D
class_name BaseEntity

@export var BaseSpeed: float = 3
@export var SpeedMult: float = 1
@export var EnemyWeakColor: Color
var EnemyStrongColor: Color:
	get: return EnemyStrongColor.inverted()
@export var HP: float = 100
@export var Damage: int = 1
var Attachments: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelMaster.this.EntityCount += 1
	
func _exit_tree() -> void:
	LevelMaster.this.EntityCount -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func TakeDamage(damage: float, color: Color):
	var preSum = Ref.new(0.0)
	var mult = Ref.new(1.0)
	var postSum = Ref.new(0.0)
	var proceed = true
	for attachment in Attachments.values():
		proceed = proceed and attachment.pre_damage(damage,preSum,mult,postSum,color)
	if proceed:
		var damageTaken = max(((damage+preSum)*mult+postSum)*(2.0 if color == EnemyWeakColor else (0.25 if color == EnemyStrongColor else 1.0)),0.0)
		HP -= damageTaken
		for attachment in Attachments.values():
			attachment.post_damage(damageTaken, color)

func _physics_process(delta: float) -> void:
	if (HP <= 0):
		queue_free()
		return
	for attachment in Attachments.values():
		attachment.pre_physics_process()
	progress += BaseSpeed*SpeedMult*delta
	
	if progress_ratio == 1:
		LevelMaster.this.ReachedExit(self)
		queue_free()
