extends Node3D
class_name ResourceManager

@export var _HP: int = 100:
	set(value):
		_HP = value
		if LevelManager.this.UIM:
			LevelManager.this.UIM._update_hp()
var HP: int:
	get:
		return _HP
@export var AbsractTowerCurrency: int = 0:
	set(value):
		AbsractTowerCurrency = value
		if LevelManager.this.UIM:
			LevelManager.this.UIM._update_hp()

signal damage_taken

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await LevelManager.this.get_parent_node_3d().ready
	LevelManager.this.UIM._update_currency()
	LevelManager.this.UIM._update_hp()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func TakeDamage(damage: int):
	damage_taken.emit(damage)
	_HP = max(0, _HP - damage)
	if HP == 0:
		printerr("NYI: level lost")
