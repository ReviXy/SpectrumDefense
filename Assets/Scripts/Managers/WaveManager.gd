extends Node
class_name WaveManager

@export var waves: Array[WaveData]
@export var wave: int = 0
var EntityCount: int = 0
var PendingDeployments: int = 0

func _ready() -> void:
	await LevelManager.this.get_parent_node_3d().ready
	
# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LaunchWave") and (wave < waves.size()):
		LaunchNextWave()
	if (EntityCount == 0 and PendingDeployments == 0):
		if (wave < waves.size()):
			LaunchNextWave()
		else:
			printerr("NYI: implement a victory condition")

signal WaveLaunched(wave_index)

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
	PendingDeployments += 1
	await get_tree().create_timer(deployment.PreDeployDelay, false).timeout
	for i in range(deployment.EnemyCount):
		get_node(deployment.PathNode).add_child(deployment.Enemy.instantiate())
		await get_tree().create_timer(deployment.DeployDelay, false).timeout
	PendingDeployments -= 1
