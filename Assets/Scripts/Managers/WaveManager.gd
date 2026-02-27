extends Node
class_name WaveManager

@export var waves: Array[WaveData]
@export var wave: int = 0
@onready var WaveDelayTimer: Timer = $WaveDelayTimer
var EntityCount: int = 0
var PendingDeployments: int = 0
var autoLaunch: bool = false
var PathCounts: Dictionary[Path3D,int] = {}

const INDICATOR_SCENE: PackedScene = preload("res://Assets/Scenes/WaveIndicator.tscn")

func _ready() -> void:
	await LevelManager.this.get_parent_node_3d().ready
	WaveDelayTimer.timeout.connect(func():
		LaunchNextWave()
		LevelManager.this.UIM.startWaveLabel.text = "")
	LevelManager.this.UIM.maxWaveLabel.text = str(len(waves))
	LevelManager.this.UIM.waveLabel.text = "1"
	for pathT in find_children("*","Path3D", false):
		var path = pathT as Path3D
		PathCounts[path] = floor(path.curve.get_baked_length() / 50)
	DisplayIndicators()

signal WaveLaunched(wave_index)
signal WaveEnded(wave_index)

func LaunchNextWave():
	if (EntityCount == 0 and PendingDeployments == 0):
		if (wave >= waves.size()):
			printerr("Attempt to call the next wave when all waves have been finished.\nImplement the check in the caller and check the call cases.\n this branch should never be reached.")
		else:
			for path in PathCounts.keys():
				for indicator in path.get_children():
					indicator.queue_free()
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
			#Load new wave data JSON
			wave += 1
			if autoLaunch:
				LaunchNextWave()
			else:
				DisplayIndicators()
				WaveDelayTimer.start(waves[wave].Pre_wave_delay)
				

func DisplayIndicators():
	var ColorsPerPath := {}
	for deployment in waves[wave].Deployments:
		var P = get_node(deployment.PathNode) as Path3D
		if ColorsPerPath.has(P): 
			ColorsPerPath[P][deployment.EnemyColor] = true
		else: ColorsPerPath[P] = {deployment.EnemyColor: true}
	print(ColorsPerPath)
	for path in ColorsPerPath.keys():
		var Interval : float = path.curve.get_baked_length()/PathCounts[path]
		for i in range(PathCounts[path]):
			var cols = ColorsPerPath[path].keys()
			cols.sort()
			cols.reverse()
			for colI in range(len(cols)):
				var indicator = INDICATOR_SCENE.instantiate()
				path.add_child.call_deferred(indicator)
				(indicator as PathFollow3D).progress = i*Interval + colI*3
				(indicator.get_child(0) as MeshInstance3D).material_override.albedo_color = ColorRYB_Operations.ToColor(cols[colI])
