extends Node3D
class_name ResourceManager

@export var HP: int = 100:
	set(value):
		HP = value
		if LevelManager.this.UIM:
			LevelManager.this.UIM._update_hp()
		if HP <= 0:
			printerr("NYI: level lost")

@export var Resources: int = 0:
	set(value):
		Resources = value
		if LevelManager.this.UIM:
			LevelManager.this.UIM._update_currency()

signal health_gained(health: int)
signal damage_taken(damage: int)
signal resources_gained(resource: int)
signal resources_lost(resource: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await LevelManager.this.get_parent_node_3d().ready
	LevelManager.this.UIM._update_currency()
	LevelManager.this.UIM._update_hp()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func GainHealth(health: int):
	health_gained.emit(health)
	HP = max(HP,HP + health)

func TakeDamage(damage: int):
	damage_taken.emit(damage)
	HP = max(0, min(HP - damage,HP))

func GainResources(resource: int):
	resources_gained.emit(resource)
	Resources = max(Resources,Resources + resource)

func LoseResources(resource: int):
	if (resource <= Resources):
		resources_lost.emit(resource)
		Resources = max(0, min(Resources - resource,HP))
		return true
	else:
		return false
