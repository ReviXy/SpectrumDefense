extends Node
class_name LevelMaster

@export var waves: Array[WaveData]
var wave: int = 0
var EntityCount: int = 0
var ActiveDeployments: int = 0
@export var HP: int = 100
# Let's call our resource ATC and confuse the players
@export var AbsractTowerCurrency: int = 0
## Yes, this is a crutch.
## Yes, this allows global access to the script without any shenanigans.
## Yes, this is a singleton pattern.
## No, using autoLoad will make the object persist when it shouldn't, resulting in even less safety.
## Yes, this is relatively unsafe (And by that I mean "not perfectly foolproof")
## (but since nothing should be ever able to call it before or after it exists, no null calls should happen)
## If you are trying to access this before loading the scene or after unloading it: Why? You know it isn't.
## If you are trying to access this right after loading the scene, just get it from the node
## like you normally would.
## Or attatch the rest of the code to the "scene_ready" signal I have provided. This is even more than you would get.
## Basically, if you somehow mishandle it, you are the problem.
## Yes, this is attatched to the scene's root.
## No, making everything static will throw the inspector and the instance variability under the bus.
## Yes, this is the best (and by far the cleanest) solution.
## Yes, I've learned it from Unity. Bite me.
## Yes, Godot only enables this behavior by having a consistent scene load/unload sequence.
## Yes, I'm looking at you, Unity. How did you know?
static var this:LevelMaster
func _init() -> void:
	this = self
func _exit_tree() -> void:
	this = null
signal scene_ready
func _ready() -> void:
	emit_signal("scene_ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LaunchWave") and (wave < waves.size()):
		LaunchNextWave()
	if (EntityCount == 0 and ActiveDeployments == 0):
		if (wave < waves.size()):
			LaunchNextWave()
		else:
			printerr("NYI: implement a victory condition")

signal WaveLaunched(wave)

func LaunchNextWave():
	# This is a redundancy check in case someone calls the function when there are no more waves.
	if (wave >= waves.size()):
		printerr("Attempt to call the next wave when all waves have been finished.\nImplement the check in the caller and check the call cases.\n this branch should never be reached.")
	else:
		for deployment in waves[wave].Deployments:
			DeployDeployment(deployment)
		WaveLaunched.emit(wave)
		wave += 1

func DeployDeployment(deployment: Deployment):
	ActiveDeployments += 1
	await get_tree().create_timer(deployment.PreDeployDelay).timeout
	for i in range(deployment.EnemyCount):
		get_node(deployment.PathNode).add_child(deployment.Enemy.instantiate())
		await get_tree().create_timer(deployment.DeployDelay).timeout
	ActiveDeployments -= 1

func ReachedExit(Entity: BaseEntity):
	HP -= Entity.Damage
	printerr("NYI: update the HP display.", HP)
	if (HP <= 0):
		printerr("NYI: level lost.")
