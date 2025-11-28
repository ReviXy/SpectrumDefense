extends Node
class_name WaveManager

@export var waves: Array[WaveData]
@export var wave: int = 0
@onready var WaveDelayTimer: Timer = $WaveDelayTimer
var EntityCount: int = 0
var PendingDeployments: int = 0
var autoLaunch: bool = false


func _ready() -> void:
	await LevelManager.this.get_parent_node_3d().ready
	WaveDelayTimer.timeout.connect(func(): 
		LaunchNextWave()
		LevelManager.this.UIM.startWaveLabel.text = "")
	LevelManager.this.UIM.maxWaveLabel.text = str(len(waves))
	LevelManager.this.UIM.waveLabel.text = "1"

signal WaveLaunched(wave_index)
signal WaveEnded(wave_index)

func LaunchNextWave():
	if (EntityCount == 0 and PendingDeployments == 0):
		if (wave >= waves.size()):
			printerr("Attempt to call the next wave when all waves have been finished.\nImplement the check in the caller and check the call cases.\n this branch should never be reached.")
		else:
			LevelManager.this.UIM.waveLabel.text = str(wave+1)
			for deployment in waves[wave].Deployments:
				DeployDeployment(deployment)
			WaveLaunched.emit(wave)

func DeployDeployment(deployment: Deployment):
	PendingDeployments += 1
	await get_tree().create_timer(deployment.PreDeployDelay, false).timeout
	for i in range(deployment.EnemyCount):
		var Enemy: BaseEntity = deployment.Enemy.instantiate()
		Enemy.EnemyWeakColor = deployment.EnemyColor
		for override in deployment.Value_Overrides:
			if override in Enemy:
				Enemy.set(override,deployment.Value_Overrides[override])
		get_node(deployment.PathNode).add_child(Enemy)
		if (i < deployment.EnemyCount-1):
			await get_tree().create_timer(deployment.DeployDelay, false).timeout
	PendingDeployments -= 1

func EnemyGone():
	if (EntityCount == 0 and PendingDeployments == 0):
		WaveEnded.emit(wave)
		if (wave >= waves.size()-1):
			#printerr("NYI: implement a victory condition")
			LevelManager.this.UIM.show_mission_win()
		else:
			LevelManager.this.ResourceM.GainResources(waves[wave].WaveReward)
			wave += 1
			if autoLaunch:
				LaunchNextWave()
			else:
				WaveDelayTimer.start(waves[wave].Pre_wave_delay)
