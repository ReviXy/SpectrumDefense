@tool
extends Resource
class_name Deployment

@export var PathNode: NodePath
@export var Enemy: PackedScene:
	set(value):
		Enemy = value
		notify_property_list_changed()
@export var EnemyCount: int
@export var DeployDelay: float
@export var PreDeployDelay: float
@export var EnemyColor: Color

func _get_property_list():
		var properties = []
		# Add your dynamic properties here
		properties.append({
			"name": "Enemy_Color",
			"type": TYPE_COLOR,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		return properties
