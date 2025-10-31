extends Resource
class_name Deployment

@export var PathNode: NodePath
@export var Enemy: PackedScene
@export var _EnemyCount: float
var EnemyCount: int:
	get:
		return roundi(_EnemyCount)
	set (value):
		_EnemyCount = value
@export var DeployDelay: float
@export var PreDeployDelay: float
