extends PathFollow3D
class_name BaseEntity
const ColorRYB = ColorRYB_Operations.ColorRYB

@export var BaseSpeed: float = 3
@export var SpeedMult: float = 1
##Because multiplying by zero is the only multiplication, which can't be reversed
var Stops: int = 0
var EnemyWeakColor: ColorRYB
var EnemyStrongColor: ColorRYB:
	get: return ColorRYB_Operations.Invert(EnemyStrongColor)
@export var MaxHP: float = 100
@export var HP: float = 100
@export var Damage: int = 1
@export var ResourcesGain: int = 0
var Attachments: Dictionary = {}
@onready var MainMeshInstance: MeshInstance3D = find_child("MainMesh")
@onready var APlayer: AnimationPlayer = find_child("AnimationPlayer")

@onready var healthBar: ProgressBar = $SubViewport/HealthBar
@onready var damageNumberPool: DamageNumberPool = $SubViewport

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
	if MainMeshInstance:
		if MainMeshInstance.material_override:
			var shader_material: ShaderMaterial = MainMeshInstance.material_override
			shader_material.set_shader_parameter("part_color",ColorRYB_Operations.ToColor(EnemyWeakColor))
	if (LevelManager.this):
		LevelManager.this.WaveM.EntityCount += 1
		on_spawn()
	
func _exit_tree() -> void:
	if (LevelManager.this):
		LevelManager.this.WaveM.EntityCount -= 1
		LevelManager.this.WaveM.EnemyGone()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func TakeDamage(damage: float, color: ColorRYB):
	var preSum = Ref.new(0.0)
	var mult = Ref.new(1.0)
	var postSum = Ref.new(0.0)
	var proceed = pre_damage(damage,color,preSum,mult,postSum)
	for a:EnemyAttachment in Attachments.values():
		proceed = proceed and a.pre_damage(damage,color,preSum,mult,postSum)
	if proceed:
		var damageCoefficient = (2.0 if color == EnemyWeakColor else (0.25 if color == EnemyStrongColor else 1.0))
		var damageTaken = max(((damage+preSum.value)*mult.value+postSum.value)*damageCoefficient,0.0)
		HP -= damageTaken
		if healthBar != null: healthBar.value = HP / MaxHP * 100
		if damageNumberPool != null: damageNumberPool.show_damage(damageTaken, damageCoefficient, color)
		post_damage(damageTaken,color)
		for a:EnemyAttachment in Attachments.values():
			a.post_damage(damageTaken,color)
		if (HP <= 0):
			DeathCheck()

func RestoreHP(Healing: float):
	HP = min(MaxHP,HP+Healing)
	if healthBar != null: healthBar.value = HP / MaxHP * 100

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
	if (not is_queued_for_deletion()):
		pre_death()
		for a:EnemyAttachment in Attachments.values():
			a.pre_death()
		if (HP <= 0):
			on_death()
			for a:EnemyAttachment in Attachments.values():
				a.on_death()
			LevelManager.this.ResourceM.GainResources(ResourcesGain)
			set_physics_process(false)
			set_process(false)
			$Area3D.monitorable = false
			$Area3D.monitoring = false
			APlayer.play("BaseEntityAnims/death")
