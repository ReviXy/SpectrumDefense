extends Node3D
class_name LevelManager

static var this:LevelManager

@onready var WaveM: WaveManager = $WaveManager
@onready var GridM: GridManager = $GridManager
@onready var ResourceM: ResourceManager = $ResourceManager
@onready var UIM: LevelUI = $"../LevelUI"

func _init() -> void:
	this = self
func _exit_tree() -> void:
	this = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(WaveM)
	print(GridM)
	print(ResourceM)
	print(UIM)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
