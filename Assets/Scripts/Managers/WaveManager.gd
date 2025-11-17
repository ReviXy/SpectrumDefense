extends Node
class_name WaveManager

@export var waves: Array[WaveData]
@export var wave: int = 0
@export var autoLaunch: bool = false
@onready var WaveDelayTimer: Timer = $WaveDelayTimer
var EntityCount: int = 0
var PendingDeployments: int = 0


func _ready() -> void:
	await LevelManager.this.get_parent_node_3d().ready
	WaveDelayTimer.timeout.connect(func(): if (autoLaunch): LaunchNextWave())
	
# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	#print(WaveDelayTimer.time_left)
	if (EntityCount == 0 and PendingDeployments == 0) and (Input.is_action_just_pressed("LaunchWave")):
		LaunchNextWave()
		WaveDelayTimer.stop()

signal WaveLaunched(wave_index)
signal WaveEnded(wave_index)

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
		var Enemy: BaseEntity = deployment.Enemy.instantiate()
		Enemy.EnemyWeakColor = deployment.EnemyColor
		get_node(deployment.PathNode).add_child(Enemy)
		if (i < deployment.EnemyCount-1):
			await get_tree().create_timer(deployment.DeployDelay, false).timeout
	PendingDeployments -= 1

func EnemyDied():
	if (EntityCount == 0 and PendingDeployments == 0):
		WaveEnded.emit(wave)
		if (wave >= waves.size()):
			printerr("NYI: implement a victory condition")
		elif(autoLaunch):
			LevelManager.this.ResourceM.GainResources(waves[wave].WaveReward)
			WaveDelayTimer.start(waves[wave+1].Pre_wave_delay)
